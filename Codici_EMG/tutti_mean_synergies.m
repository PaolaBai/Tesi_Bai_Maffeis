function MEAN = tutti_mean_synergies(DATA, opts)
%TUTTI_MEAN_SYNERGIES  Calcola le MEAN SYNERGIES dei sani (matching + media,
%  k = moda dei k_AIC, SENZA leave-one-out) per tutte le fasi Intero del lato
%  registrato (R) di tutti i movimenti, in una struttura navigabile.
%
%  USO
%    MEAN = tutti_mean_synergies(DATA);
%    % accesso:  MEAN.Addu.R_Intero.Wref   MEAN.Circ.RAvanti_Intero.Wref
%
%  OUTPUT
%    MEAN.<movimento>.<fase>.Wref  [8 x k]  mean synergies (norma 1)
%    MEAN.<movimento>.<fase>.k     numero di sinergie (moda dei k_AIC)
%    MEAN.<movimento>.<fase>.n_sani
%
%  Le mean synergies hanno la stessa forma di PROTO (.Wref), quindi sono
%  graficabili con grafico_centroidi_roh o grafico_mean_movimento.

if nargin < 2, opts = struct; end
if ~isfield(opts,'gruppo'), opts.gruppo = 'Sani'; end
if ~isfield(opts,'tempo'),  opts.tempo  = 'T';    end
if ~isfield(opts,'randg_fase'), opts.randg_fase = 'Completo_Intero'; end

coppie = scopri_coppie(DATA, opts.gruppo, opts.tempo, opts.randg_fase);
if isempty(coppie); error('tutti_mean_synergies:vuoto','Nessuna fase Intero R trovata.'); end

MEAN = struct(); riep = {};
sani = fieldnames(DATA.(opts.gruppo));
for c = 1:size(coppie,1)
    mov = coppie{c,1}; fase = coppie{c,2};
    kref = moda_kAIC(DATA, opts.gruppo, opts.tempo, mov, fase);
    if isnan(kref) || kref < 1
        riep{end+1} = sprintf('  %-12s %-18s [k non determinabile]', mov, fase); continue; %#ok<AGROW>
    end
    W = mean_synergies(DATA, opts.gruppo, opts.tempo, mov, fase, kref, '');   % '' = nessun LOO
    if isempty(W)
        riep{end+1} = sprintf('  %-12s %-18s [saltato]', mov, fase); continue; %#ok<AGROW>
    end
    P.Wref = W; P.k = kref; P.n_sani = numel(sani); P.mov = mov; P.fase = fase;
    MEAN.(mov).(fase) = P;
    riep{end+1} = sprintf('  %-12s %-18s  k=%d', mov, fase, kref); %#ok<AGROW>
end

fprintf('\n============ tutti_mean_synergies ============\n');
fprintf('%s\n', riep{:});
fprintf('==============================================\n');
end

%% ========================================================= (da vaf_crossfit)
function Wref = mean_synergies(DATA, gruppo, tempo, mov, fase, kref, escludi)
Wref = [];
sani = fieldnames(DATA.(gruppo));
if ~isempty(escludi); sani = sani(~strcmp(sani, escludi)); end
Ws = {};
for s = 1:numel(sani)
    W = estrai_W_k(DATA, gruppo, sani{s}, tempo, mov, fase, kref);
    if ~isempty(W); Ws{end+1} = normalizza_colonne(W); end %#ok<AGROW>
end
if numel(Ws) < 2; return; end
Wmod = Ws{1}; Acc = Wmod; cnt = 1;
for s = 2:numel(Ws); Acc = Acc + appaia_max_scalar(Wmod, Ws{s}); cnt = cnt + 1; end
Wref = normalizza_colonne(Acc / cnt);
end

function Wapp = appaia_max_scalar(Wmod, W)
% assegnazione ottima uno-a-uno (max somma prodotti scalari); matchpairs, fallback greedy.
k = size(Wmod,2); S = Wmod' * W; ord = zeros(1,k);
try
    M = matchpairs(1 - S, 1.5);
    for r = 1:size(M,1); ord(M(r,1)) = M(r,2); end
    if any(ord==0); rest = setdiff(1:k, ord(ord>0)); ord(ord==0) = rest; end
catch
    Stmp = S;
    for it = 1:k
        [~, idx] = max(Stmp(:)); [r, c] = ind2sub(size(Stmp), idx);
        ord(r) = c; Stmp(r,:) = -Inf; Stmp(:,c) = -Inf;
    end
end
Wapp = W(:, ord);
end

function coppie = scopri_coppie(DATA, gruppo, tempo, randg_fase)
coppie = {}; sani = fieldnames(DATA.(gruppo)); movs = {};
for s = 1:numel(sani)
    st = DATA.(gruppo).(sani{s});
    if isfield(st, tempo); movs = union(movs, fieldnames(st.(tempo))); end
end
for m = 1:numel(movs)
    mov = movs{m}; fasi = fasi_intero_di(DATA, gruppo, tempo, mov);
    if strcmpi(mov,'RandG'); fasi = fasi(strcmp(fasi, randg_fase));
    else; fasi = fasi(~cellfun(@isempty, regexp(fasi,'^R','once'))); end
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

function W = estrai_W_k(DATA, gruppo, sog, tempo, mov, fase, kref)
W = []; E = prendi_emgcat(DATA, gruppo, sog, tempo, mov, fase);
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
for i = 1:size(W,2); n = norm(W(:,i)); if n > eps; W(:,i) = W(:,i)/n; end; end
end
