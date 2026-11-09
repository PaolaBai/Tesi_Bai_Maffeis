function P = sinergie_prototipo(DATA, mov, fase, opts)
%SINERGIE_PROTOTIPO  Costruisce le sinergie PROTOTIPO del gruppo sani per un
%  dato movimento/fase, raggruppando le sinergie di tutti i soggetti sani per
%  similarita' (cosine), e le ordina per quanto sono CONDIVISE nel gruppo.
%
%  P = sinergie_prototipo(DATA, 'Addu', 'R_Intero');
%
%  Metodo (concordato):
%    - raccoglie tutte le W di tutti i sani (una colonna = una sinergia);
%    - similarita' cosine tutte-contro-tutte (stessa metrica di confronta_sinergie);
%    - clustering gerarchico agglomerativo COMPLETE-LINKAGE con taglio a
%      distanza (1 - soglia): dentro ogni cluster TUTTE le coppie hanno
%      cosine >= soglia; nessuna sinergia esclusa (le isolate = singoletti);
%    - prevalenza = numero di SOGGETTI DISTINTI nel cluster;
%    - ordinamento per CONDIVISIONE (prevalenza decrescente); a parita',
%      per consistenza interna (cluster piu' compatto prima).
%
%  USO
%    P = sinergie_prototipo(DATA, 'Addu', 'R_Intero');
%    P = sinergie_prototipo(DATA, 'Circ', 'RAvanti_Intero', struct('soglia',0.80));
%
%  opts (opzionali)
%    .gruppo : nome del campo gruppo sani in DATA (default 'Sani')
%    .tempo  : timepoint dei sani (default 'T')
%    .soglia : cosine minima per stare nello stesso cluster (default 0.80)
%
%  OUTPUT P
%    .Wref        [8 x nCluster]  centroidi (prototipi) rinormalizzati, ORDINATI
%    .prevalenza  [nCluster x 1]  n. soggetti distinti per cluster
%    .n_membri    [nCluster x 1]  n. sinergie nel cluster
%    .consistenza [nCluster x 1]  cosine media membri-centroide (compattezza)
%    .soggetti    {nCluster x 1}  elenco soggetti per cluster
%    .doppi       {nCluster x 1}  soggetti che compaiono >1 volta nel cluster
%    .n_sani      n. sani effettivamente usati
%    .saltati     {..}  sani senza sinergie per questo mov/fase (esclusi)
%    .Wall, .owner (diagnostica: tutte le sinergie e il soggetto di origine)

if nargin < 4, opts = struct; end
if ~isfield(opts,'gruppo'), opts.gruppo = 'Sani'; end
if ~isfield(opts,'tempo'),  opts.tempo  = 'T';    end
if ~isfield(opts,'soglia'), opts.soglia = 0.75;   end

if ~isfield(DATA, opts.gruppo)
    error('sinergie_prototipo:gruppo','Gruppo "%s" non trovato in DATA. Presenti: %s', ...
        opts.gruppo, strjoin(fieldnames(DATA), ', '));
end
sani = fieldnames(DATA.(opts.gruppo));

%% --- raccolta: tutte le W di tutti i sani ---
Wall = []; owner = []; owner_names = {}; saltati = {};
iu = 0;                                                % indice sui sani EFFETTIVAMENTE usati
for s = 1:numel(sani)
    try
        W = estrai_W(DATA, sani{s}, opts.tempo, mov, fase);
    catch
        saltati{end+1} = sani{s}; %#ok<AGROW>
        continue;
    end
    W = normalizza_colonne(W);
    iu = iu + 1;
    Wall = [Wall, W];                                  %#ok<AGROW>
    owner = [owner, repmat(iu, 1, size(W,2))];         %#ok<AGROW>  indicizza owner_names, non 'sani'
    owner_names{end+1} = sani{s};                      %#ok<AGROW>
end
n_sani = numel(sani) - numel(saltati);
if isempty(Wall)
    error('sinergie_prototipo:vuoto','Nessun sano ha sinergie per %s / %s.', mov, fase);
end

%% --- similarita' cosine tutte-contro-tutte e distanza ---
S = Wall' * Wall;                 % colonne a norma 1 -> prodotto = cosine
S = max(0, min(1, S));            % clip numerico
D = 1 - S;                        % distanza coseno
D = (D + D')/2; D(1:size(D,1)+1:end) = 0;

%% --- clustering complete-linkage a taglio (1 - soglia) ---
lab = cluster_complete(D, 1 - opts.soglia);
nCl = max(lab);

%% --- centroidi, prevalenza, consistenza ---
cent = zeros(size(Wall,1), nCl);
prev = zeros(nCl,1); nmemb = zeros(nCl,1); cons = zeros(nCl,1);
sogg = cell(nCl,1); doppi = cell(nCl,1);
for c = 1:nCl
    idx = find(lab == c);
    v = mean(Wall(:, idx), 2);
    nv = norm(v); if nv > eps, v = v/nv; end
    cent(:,c) = v;
    nmemb(c)  = numel(idx);
    o = owner(idx);
    uo = unique(o);
    prev(c)   = numel(uo);
    sogg{c}   = owner_names(uo);
    % soggetti con contributo doppio nello stesso cluster
    d = uo(arrayfun(@(x) sum(o==x) > 1, uo));
    doppi{c}  = owner_names(d);
    cons(c)   = mean(max(0, cent(:,c)' * Wall(:, idx)));   % cosine media col centroide
end

%% --- ordinamento per condivisione (prevalenza desc, poi consistenza desc) ---
[~, ord] = sortrows([-prev, -cons]);
P.Wref        = cent(:, ord);
P.prevalenza  = prev(ord);
P.n_membri    = nmemb(ord);
P.consistenza = cons(ord);
P.soggetti    = sogg(ord);
P.doppi       = doppi(ord);
P.n_sani      = n_sani;
P.saltati     = saltati;
P.soglia      = opts.soglia;
P.mov = mov;  P.fase = fase;
P.Wall = Wall; P.owner = owner; P.owner_names = {owner_names};

%% --- stampa ---
fprintf('\n== sinergie prototipo — %s / %s (soglia %.2f) ==\n', mov, fase, opts.soglia);
fprintf('sani usati: %d', n_sani);
if ~isempty(saltati), fprintf('  (saltati: %s)', strjoin(saltati, ', ')); end
fprintf('\ntotale sinergie: %d  ->  %d cluster\n', size(Wall,2), nCl);
fprintf('%-8s %10s %9s %12s   %s\n','sinergia','prevalenza','n.membri','consistenza','soggetti');
for c = 1:nCl
    fprintf('S%-7d %6d/%-3d %9d %12.3f   %s\n', c, P.prevalenza(c), n_sani, ...
        P.n_membri(c), P.consistenza(c), strjoin(P.soggetti{c}, ', '));
    if ~isempty(P.doppi{c})
        fprintf('          [contributo doppio: %s]\n', strjoin(P.doppi{c}, ', '));
    end
end
fprintf('\n');
end

%% ========================================================= clustering
function lab = cluster_complete(D, cutoff)
% Complete-linkage agglomerativo con taglio a 'cutoff'. Unisce i due cluster
% con distanza complete-linkage (max distanza tra i membri) minima, finche'
% questa e' <= cutoff. Equivale a tagliare il dendrogramma complete a cutoff.
N = size(D,1);
cl = cell(N,1); for i = 1:N, cl{i} = i; end
while numel(cl) > 1
    best = inf; bi = 0; bj = 0;
    for a = 1:numel(cl)-1
        for b = a+1:numel(cl)
            dm = max(max(D(cl{a}, cl{b})));   % complete linkage
            if dm < best, best = dm; bi = a; bj = b; end
        end
    end
    if best > cutoff, break; end
    cl{bi} = [cl{bi}, cl{bj}];
    cl(bj) = [];
end
lab = zeros(N,1);
for c = 1:numel(cl), lab(cl{c}) = c; end
end

%% ========================================================= (da confronta_sinergie)
function W = estrai_W(DATA, sog, tempo, mov, fase)
gruppi = fieldnames(DATA);
M = [];
for g = 1:numel(gruppi)
    if isfield(DATA.(gruppi{g}), sog)
        sog_struct = DATA.(gruppi{g}).(sog);
        if ~isempty(tempo) && isfield(sog_struct, tempo)
            if isfield(sog_struct.(tempo), mov)
                M = sog_struct.(tempo).(mov); break;
            end
        else
            if isfield(sog_struct, mov)
                M = sog_struct.(mov); break;
            end
        end
    end
end
if isempty(M)
    error('sinergie_prototipo:soggetto','Soggetto "%s", mov "%s" (tempo "%s") non trovati.', sog, mov, tempo);
end
if ~isfield(M,'sinergie'), error('sinergie_prototipo:sinergie','Nessuna sinergia per %s/%s.', sog, mov); end
syn = M.sinergie;
lab = cellstr(syn.phase_labels);
j = find(strcmp(lab, fase), 1);
if isempty(j)
    error('sinergie_prototipo:fase','Fase "%s" non trovata. Disponibili: %s', fase, strjoin(lab, ', '));
end
W = syn.W{j};
if isempty(W), error('sinergie_prototipo:vuota','W vuota per %s/%s/%s.', sog, mov, fase); end
if iscell(W), W = W{1}; end
end

function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i));
    if n > eps; W(:,i) = W(:,i)/n; end
end
end
