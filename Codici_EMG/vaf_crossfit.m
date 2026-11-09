function R = vaf_crossfit(DATA, opts)
%VAF_CROSSFIT  Quanto le sinergie MEDIE dei sani ricostruiscono l'EMG di ogni
%  persona (VAF 0-1), col metodo di Roh: mean synergies per matching+media
%  (NON clustering), leave-one-out sui sani. Un VAF per ogni movimento.
%
%  Riferimento sani = mean synergies: si sceglie un sano-modello, si appaiano
%  le sinergie di tutti gli altri al modello col MASSIMO prodotto scalare, e si
%  mediano. Numero di sinergie del riferimento = MODA dei k_AIC dei sani (k fisso).
%  Per valutare un sano X, le mean synergies sono costruite SENZA X (leave-one-out).
%  Per i pazienti si usano le mean synergies di tutti i sani.
%
%  VAF (Nonnegative Reconstruction): W = mean synergies (fisse), si stima H>=0
%  che minimizza ||EMG - W*H||, poi VAF = 1 - ||EMG-WH||^2 / ||EMG||^2.
%
%  USO
%    RICOSTRUZIONE = vaf_crossfit(DATA, struct('lato_paz', lato_paz))
%
%  opts: .lato_paz (richiesto) ; .gruppo_sani ('Sani') ; .gruppo_paz ('Patologici')
%        .tempo_sani ('T')
%
%  OUTPUT R
%    .TAB   tabella long: soggetto | gruppo | timepoint | mov | fase | VAF
%    .movimenti  lista movimenti analizzati

if nargin < 2, opts = struct; end
if ~isfield(opts,'lato_paz'), error('vaf_crossfit:lato','Serve opts.lato_paz.'); end
if ~isfield(opts,'gruppo_sani'), opts.gruppo_sani = 'Sani'; end
if ~isfield(opts,'gruppo_paz'),  opts.gruppo_paz  = 'Patologici'; end
if ~isfield(opts,'tempo_sani'),  opts.tempo_sani  = 'T'; end
lato_paz = opts.lato_paz;

sani = fieldnames(DATA.(opts.gruppo_sani));

% --- movimenti e fasi attive (R) dei sani, dal primo sano disponibile ---
coppie = scopri_coppie(DATA, opts.gruppo_sani, opts.tempo_sani);
if isempty(coppie); error('vaf_crossfit:vuoto','Nessuna fase Intero trovata nei sani.'); end

righe = {};
movs_visti = {};
for k = 1:size(coppie,1)
    mov = coppie{k,1}; fase = coppie{k,2};
    movs_visti = union(movs_visti, {mov});

    % k del riferimento = moda dei k_AIC dei sani per questa fase
    kref = moda_kAIC(DATA, opts.gruppo_sani, opts.tempo_sani, mov, fase);
    if isnan(kref) || kref < 1; continue; end

    % --- SANI: leave-one-out ---
    for s = 1:numel(sani)
        Xs = sani{s};
        Wref = mean_synergies(DATA, opts.gruppo_sani, opts.tempo_sani, mov, fase, kref, Xs); % esclude Xs
        if isempty(Wref); continue; end
        E = prendi_emgcat(DATA, opts.gruppo_sani, Xs, opts.tempo_sani, mov, fase);
        if isempty(E); continue; end
        v = vaf_nnr(E, Wref);
        righe(end+1,:) = { Xs, 'sano', opts.tempo_sani, mov, fase, v }; %#ok<AGROW>
    end

    % --- mean synergies su TUTTI i sani (per i pazienti) ---
    Wall = mean_synergies(DATA, opts.gruppo_sani, opts.tempo_sani, mov, fase, kref, ''); % nessuna esclusione
    if isempty(Wall); continue; end

    % --- PAZIENTI: T0 e T1 separati, fase allineata al lato affetto ---
    paz = fieldnames(DATA.(opts.gruppo_paz));
    for pz = 1:numel(paz)
        Xp = paz{pz};
        lato = 'R'; if isfield(lato_paz,Xp); lato = upper(lato_paz.(Xp)); end
        fase_p = fase;
        if ~strcmpi(mov,'RandG') && strcmp(lato,'L'); fase_p = regexprep(fase,'^R','L'); end
        for TP = {'T0','T1'}
            tp = TP{1};
            E = prendi_emgcat(DATA, opts.gruppo_paz, Xp, tp, mov, fase_p);
            if isempty(E); continue; end
            v = vaf_nnr(E, Wall);
            righe(end+1,:) = { Xp, 'paziente', tp, mov, fase_p, v }; %#ok<AGROW>
        end
    end
end

intest = {'soggetto','gruppo','timepoint','mov','fase','VAF'};
if exist('cell2table','file'); R.TAB = cell2table(righe,'VariableNames',intest);
else; R.TAB = [intest; righe]; end
R.movimenti = movs_visti;

% --- stampa sintetica ---
fprintf('\n===== vaf_crossfit (Roh: mean synergies + leave-one-out) =====\n');
fprintf('k riferimento = moda dei k_AIC (per fase)\n');
fprintf('%-8s %-9s %-4s %-12s %-14s %6s\n','sogg','gruppo','tp','mov','fase','VAF');
for i=1:size(righe,1)
    fprintf('%-8s %-9s %-4s %-12s %-14s %6.3f\n', righe{i,1},righe{i,2},righe{i,3},righe{i,4},righe{i,5},righe{i,6});
end
fprintf('===============================================================\n');
end

%% ---------------------------------------------------------
function Wref = mean_synergies(DATA, gruppo, tempo, mov, fase, kref, escludi)
% mean synergies del gruppo (metodo Roh): sano-modello + matching col massimo
% prodotto scalare + media. Tutte le W estratte a kref sinergie. 'escludi' = sano
% da lasciare fuori (leave-one-out), '' per nessuno.
Wref = [];
sani = fieldnames(DATA.(gruppo));
if ~isempty(escludi); sani = sani(~strcmp(sani, escludi)); end

% raccoglie le W (kref colonne) di ogni sano
Ws = {};
for s = 1:numel(sani)
    W = estrai_W_k(DATA, gruppo, sani{s}, tempo, mov, fase, kref);
    if ~isempty(W); Ws{end+1} = normalizza_colonne(W); end %#ok<AGROW>
end
if numel(Ws) < 2; return; end

% modello = primo sano; appaia gli altri col massimo prodotto scalare
Wmod = Ws{1};
Acc = Wmod;                 % accumulatore per la media
cnt = 1;
for s = 2:numel(Ws)
    Wapp = appaia_max_scalar(Wmod, Ws{s});   % riordina Ws{s} per matchare Wmod
    Acc = Acc + Wapp; cnt = cnt + 1;
end
Wref = Acc / cnt;
Wref = normalizza_colonne(Wref);            % mean synergies a norma 1
end

%% ---------------------------------------------------------
function Wapp = appaia_max_scalar(Wmod, W)
% riordina le colonne di W per MASSIMIZZARE LA SOMMA TOTALE dei prodotti scalari
% con Wmod (assegnazione ottima uno-a-uno, come Roh: "highest total sum").
% matchpairs (Hungarian); fallback greedy.
k = size(Wmod,2);
S = Wmod' * W;                 % [k x k] prodotti scalari
ord = zeros(1,k);
try
    M = matchpairs(1 - S, 1.5);            % ottimo
    for r = 1:size(M,1); ord(M(r,1)) = M(r,2); end
    if any(ord==0)                          % completa eventuali non assegnate
        rest = setdiff(1:k, ord(ord>0));
        ord(ord==0) = rest;
    end
catch
    usate_c = false(1,k); Stmp = S;         % fallback greedy
    for it = 1:k
        [~, idx] = max(Stmp(:));
        [r, c] = ind2sub(size(Stmp), idx);
        ord(r) = c; usate_c(c) = true;
        Stmp(r,:) = -Inf; Stmp(:,c) = -Inf;
    end
end
Wapp = W(:, ord);
end

%% ---------------------------------------------------------
function v = vaf_nnr(EMG, W)
% Nonnegative Reconstruction: W fisso, stima H>=0 colonna per colonna; poi VAF.
T = size(EMG,2); k = size(W,2); H = zeros(k,T);
for t = 1:T; H(:,t) = lsqnonneg(W, EMG(:,t)); end
Rec = W*H;
v = 1 - sum((EMG(:)-Rec(:)).^2) / sum(EMG(:).^2);
v = max(0, min(1, v));
end

%% ---------------------------------------------------------
function coppie = scopri_coppie(DATA, gruppo, tempo)
% (mov,fase) attive R + RandG Completo_Intero, dai sani
coppie = {};
sani = fieldnames(DATA.(gruppo));
movs = {};
for s = 1:numel(sani)
    st = DATA.(gruppo).(sani{s});
    if isfield(st, tempo); movs = union(movs, fieldnames(st.(tempo))); end
end
for m = 1:numel(movs)
    mov = movs{m};
    fasi = fasi_intero_di(DATA, gruppo, tempo, mov);
    if strcmpi(mov,'RandG')
        fasi = fasi(strcmp(fasi,'Completo_Intero'));
    else
        fasi = fasi(~cellfun(@isempty, regexp(fasi,'^R','once')));
    end
    for f = 1:numel(fasi); coppie(end+1,:) = {mov, fasi{f}}; end %#ok<AGROW>
end
end

function fasi = fasi_intero_di(DATA, gruppo, tempo, mov)
fasi = {}; sani = fieldnames(DATA.(gruppo));
for s = 1:numel(sani)
    st = DATA.(gruppo).(sani{s});
    if ~isfield(st, tempo); continue; end
    st = st.(tempo); if ~isfield(st, mov); continue; end
    M = st.(mov); if ~isfield(M,'sinergie'); continue; end
    lab = cellstr(M.sinergie.phase_labels);
    fasi = lab(~cellfun(@isempty, regexp(lab,'_Intero$','once'))); return;
end
end

function k = moda_kAIC(DATA, gruppo, tempo, mov, fase)
kk = []; sani = fieldnames(DATA.(gruppo));
for s = 1:numel(sani)
    st = DATA.(gruppo).(sani{s});
    if ~isfield(st,tempo) || ~isfield(st.(tempo),mov); continue; end
    syn = st.(tempo).(mov).sinergie; lab = cellstr(syn.phase_labels);
    j = find(strcmp(lab,fase),1); if isempty(j); continue; end
    if size(syn.k_AIC,1)==1; kk(end+1)=syn.k_AIC(1,j); else; kk(end+1)=round(mean(syn.k_AIC(:,j),'omitnan')); end %#ok<AGROW>
end
if isempty(kk); k = NaN; else; k = mode(kk); end
end

%% --- estrazione W a k fisso (ri-fattorizza dall'EMG_cat se serve) ---
function W = estrai_W_k(DATA, gruppo, sog, tempo, mov, fase, kref)
% Se il soggetto ha gia' kref sinergie salvate, usa quelle; altrimenti ri-estrae
% kref sinergie dall'EMG concatenato (per avere un k uniforme, come richiede il
% matching+media alla Roh).
W = [];
E = prendi_emgcat(DATA, gruppo, sog, tempo, mov, fase);
if isempty(E); return; end
[W, ~] = nnmf(E, kref, 'replicates', 10, 'algorithm', 'mult');
end

function E = prendi_emgcat(DATA, gruppo, sog, tempo, mov, fase)
E = [];
if ~isfield(DATA.(gruppo), sog); return; end
ss = DATA.(gruppo).(sog);
if ~isempty(tempo) && isfield(ss,tempo); tgt = ss.(tempo); else; tgt = ss; end
if ~isfield(tgt, mov); return; end
M = tgt.(mov); if ~isfield(M,'sinergie'); return; end
syn = M.sinergie; if ~isfield(syn,'EMG_cat'); return; end
lab = cellstr(syn.phase_labels); j = find(strcmp(lab,fase),1);
if isempty(j) || j > numel(syn.EMG_cat); return; end
E = syn.EMG_cat{j};
end

function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i)); if n > eps; W(:,i) = W(:,i)/n; end
end
end
