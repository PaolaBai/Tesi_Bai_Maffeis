function R = confronta_sinergie(DATA, sog_A, tempo_A, sog_B, tempo_B, mov, fase, soglia)
%CONFRONTA_SINERGIE  Appaia le sinergie di due soggetti via cosine similarity.
%
%  Confronto Sano VS Patologico
%  R = confronta_sinergie(DATA, 'H006', 'T', 'S036', 'T0', 'Addu', 'R_Intero'); 
%  Confronto T0 VS T1
%  R = confronta_sinergie(DATA, 'S036', 'T0', 'S036', 'T1', 'Addu', 'R_Intero');
%
%
%  USO (funzione: chiamare dal Command Window)
%    R = confronta_sinergie(DATA, 'H006', 'S041', 'Addu', 'R_Intero')
%    R = confronta_sinergie(DATA, 'H006', 'S041', 'Addu', 'R_Intero', 0.75)
%
%  Il primo soggetto (sog_A) fa da RIFERIMENTO: tipicamente il sano.
%  soglia: cosine minima per considerare due sinergie "condivise"
%          (default 0.80; in letteratura si usa 0.70-0.80).
%
%  OUTPUT R
%    .S          matrice di similarita' [kA x kB], cosine tra ogni
%                colonna di W_A e ogni colonna di W_B
%    .coppie     [n x 2] indici appaiati (colonna A, colonna B)
%    .cos        similarita' di ciascuna coppia
%    .condivise  numero di coppie sopra soglia
%    .orfane_A   colonne di A senza corrispondenza (moduli del sano
%                che il paziente NON esprime)
%    .orfane_B   colonne di B senza corrispondenza
%    .merging    colonne di B che somigliano a DUE colonne di A
%                (indizio di fusione di moduli, tipico post-stroke)
%
%  PERCHE' LA COSINE SIMILARITY
%  Una sinergia e' un vettore di 8 pesi (uno per muscolo). La cosine
%  similarity misura l'angolo tra due vettori, quindi la FORMA del
%  pattern muscolare, ed e' INVARIANTE ALLA SCALA: e' esattamente cio'
%  che serve, perche' la NNMF ha l'ambiguita' W*a, H/a. Per vettori a
%  componenti non negative (come W) il valore sta sempre in [0,1]:
%  1 = stesso pattern, 0 = nessun muscolo in comune.
%
%  PERCHE' SERVE L'APPAIAMENTO
%  La NNMF parte da inizializzazione random: l'ordine delle colonne e'
%  arbitrario. La "sinergia 1" di un soggetto non e' la "sinergia 1"
%  dell'altro. L'appaiamento risolve questa indeterminazione.
%
%  PREREQUISITO: le sinergie devono essere state estratte con la
%  calcola_sinergie CONCATENATA (una W per fase). Con la versione
%  per-ripetizione i moduli non sono ben separati (nei dati precedenti
%  due sinergie dello stesso soggetto avevano cosine 0.81) e il
%  matching risulta inaffidabile.

if nargin < 8 || isempty(soglia); soglia = 0.80; end

WA = estrai_W(DATA, sog_A, tempo_A, mov, fase);
WB = estrai_W(DATA, sog_B, tempo_B, mov, fase);

% Normalizzazione a norma unitaria (idempotente se gia' normalizzate)
WA = normalizza_colonne(WA);
WB = normalizza_colonne(WB);

kA = size(WA,2);  kB = size(WB,2);

%% --- Matrice di similarita' ---
% W ha colonne a norma 1, quindi il prodotto scalare E' gia' la cosine
S = WA' * WB;                 % [kA x kB]
S = max(0, min(1, S));        % clip per errori numerici

%% --- Appaiamento ottimale ---
% Massimizza la somma delle similarita'. matchpairs risolve il problema
% di assegnazione (Hungarian); su versioni vecchie di MATLAB si usa il
% fallback greedy: prendi la coppia migliore, rimuovila, ripeti.
try
    costo   = 1 - S;                       % matchpairs minimizza
    costoNA = 1;                           % costo di lasciare spaiata
    M = matchpairs(costo, costoNA);        % [n x 2]
catch
    M = appaia_greedy(S);
end

n = size(M,1);
cosv = zeros(n,1);
for i = 1:n
    cosv(i) = S(M(i,1), M(i,2));
end
[cosv, ord] = sort(cosv, 'descend');
M = M(ord,:);

%% --- Orfane ---
orfA = setdiff(1:kA, M(:,1));
orfB = setdiff(1:kB, M(:,2));

%% --- Merging: una colonna di B simile a DUE colonne di A ---
% Se una sinergia del paziente ha similarita' intermedia con due moduli
% distinti del sano, e' l'indizio classico di fusione (merging).
merging = [];
for j = 1:kB
    vicini = find(S(:,j) >= soglia*0.75);
    if numel(vicini) >= 2
        merging(end+1,:) = [j, vicini(1), vicini(2)]; %#ok<AGROW>
    end
end

%% --- Output ---
R.S         = S;
R.coppie    = M;
R.cos       = cosv;
R.condivise = sum(cosv >= soglia);
R.orfane_A  = orfA;
R.orfane_B  = orfB;
R.merging   = merging;
R.soglia    = soglia;
R.sog_A     = sog_A;  R.sog_B = sog_B;
R.mov       = mov;    R.fase  = fase;
R.kA        = kA;     R.kB    = kB;

%% --- Stampa ---
fprintf('\n%s vs %s  |  %s / %s  (soglia %.2f)\n', sog_A, sog_B, mov, fase, soglia);
fprintf('  sinergie: %s=%d, %s=%d\n', sog_A, kA, sog_B, kB);
fprintf('  matrice di similarita'':\n');
fprintf('       ');
for j = 1:kB; fprintf('  B%-4d', j); end
fprintf('\n');
for i = 1:kA
    fprintf('   A%-2d ', i);
    fprintf(' %5.3f', S(i,:));
    fprintf('\n');
end
fprintf('  appaiamenti:\n');
for i = 1:n
    tag = '';
    if cosv(i) >= soglia; tag = ' CONDIVISA'; end
    fprintf('    A%d <-> B%d   cos = %.3f%s\n', M(i,1), M(i,2), cosv(i), tag);
end
fprintf('  condivise sopra soglia: %d\n', R.condivise);
if ~isempty(orfA)
    fprintf('  moduli di %s SENZA corrispondenza: %s\n', sog_A, mat2str(orfA));
end
if ~isempty(orfB)
    fprintf('  moduli di %s SENZA corrispondenza: %s\n', sog_B, mat2str(orfB));
end
if ~isempty(merging)
    for i = 1:size(merging,1)
        fprintf('  possibile MERGING: B%d somiglia ad A%d e A%d\n', ...
                merging(i,1), merging(i,2), merging(i,3));
    end
end
fprintf('\n');
end


%% =========================================================
function W = estrai_W(DATA, sog, tempo, mov, fase)
gruppi = fieldnames(DATA);
M = [];
for g = 1:numel(gruppi)
    if isfield(DATA.(gruppi{g}), sog)
        sog_struct = DATA.(gruppi{g}).(sog);
        
        % Se e' stato specificato un tempo (es. 'T0' o 'T1')
        if ~isempty(tempo) && isfield(sog_struct, tempo)
            if isfield(sog_struct.(tempo), mov)
                M = sog_struct.(tempo).(mov);
                break;
            end
        else
            % Se non c'e' tempo (stringa vuota), cerca direttamente il movimento
            if isfield(sog_struct, mov)
                M = sog_struct.(mov);
                break;
            end
        end
    end
end

if isempty(M)
    error('confronta_sinergie:soggetto', ...
        'Soggetto "%s", movimento "%s" (o tempo "%s") non trovati.', sog, mov, tempo);
end

if ~isfield(M,'sinergie')
    error('confronta_sinergie:sinergie', 'Nessuna sinergia per %s/%s.', sog, mov);
end

syn = M.sinergie;
lab = cellstr(syn.phase_labels);
j   = find(strcmp(lab, fase), 1);
if isempty(j)
    error('confronta_sinergie:fase', ...
        'Fase "%s" non trovata. Disponibili: %s', fase, strjoin(lab, ', '));
end

W = syn.W{j};
if isempty(W)
    error('confronta_sinergie:vuota', 'W vuota per %s/%s/%s.', sog, mov, fase);
end

if iscell(W)
    warning('confronta_sinergie:vecchia_versione', ...
      'W e'' ancora nel formato per-ripetizione.');
    W = W{1};
end
end

%% =========================================================
function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i));
    if n > eps; W(:,i) = W(:,i)/n; end
end
end

%% =========================================================
function M = appaia_greedy(S)
% Fallback se matchpairs non e' disponibile: prende iterativamente la
% coppia con similarita' massima e la rimuove.
S2 = S;
M  = zeros(0,2);
while true
    [v, idx] = max(S2(:));
    if ~isfinite(v) || v <= 0; break; end
    [i, j] = ind2sub(size(S2), idx);
    M(end+1,:) = [i j]; %#ok<AGROW>
    S2(i,:) = -Inf;  S2(:,j) = -Inf;
    if all(~isfinite(S2(:))); break; end
end
end
