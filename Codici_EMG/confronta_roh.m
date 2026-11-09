function R = confronta_roh(PROTO, DATA, arg4, varargin)
%CONFRONTA_ROH  Confronto pazienti-vs-sani col metodo di Roh et al. (2015):
%  r_norm = prodotto scalare tra il prototipo sano (template) e la sinergia
%  appaiata del paziente; soglia 0.8 per "simile/conservata". Piu' incidenza
%  dei cluster tra gruppi con Fisher's exact test.
%
%  I prototipi (template normativo) vengono da tutti_prototipi_roh (PROTO).
%  Allineamento lato affetto come nel resto della pipeline: pazienti 'L' usano
%  la fase L omologa (swap R->L); RandG sempre Completo_Intero; sani sempre R.
%
%  DUE MODALITA' (come confronta_con_prototipo):
%
%  SINGOLO (arg4 = codice paziente, stringa):
%    R = confronta_roh(PROTO, DATA, 'S041','T0','Flex','R_Intero', lato_paz [,opts])
%
%  GRUPPO (arg4 = tabella lato_paz, struct):
%    R = confronta_roh(PROTO, DATA, lato_paz [,opts])
%    -> per ogni movimento/fase: r_norm medio per gruppo + incidenza dei cluster
%       (quanti soggetti "esprimono" ogni prototipo) sani vs pazienti + Fisher.
%
%  opts: .soglia (0.8, Roh) ; .gruppo_paz ('Patologici') ; .gruppo_sani ('Sani')
%        .tempo_sani ('T')

if isstruct(arg4)
    lato_paz = arg4;
    opts = struct(); if ~isempty(varargin), opts = varargin{1}; end
    R = cr_gruppo(PROTO, DATA, lato_paz, opts);
else
    if numel(varargin) < 4
        error('confronta_roh:args', ...
            'Uso singolo: (PROTO, DATA, sog_paz, tempo, mov, fase_proto, lato_paz [,opts])');
    end
    tempo = varargin{1}; mov = varargin{2}; fase_proto = varargin{3};
    lato_paz = varargin{4};
    opts = struct(); if numel(varargin) >= 5, opts = varargin{5}; end
    R = cr_singolo(PROTO, DATA, arg4, tempo, mov, fase_proto, lato_paz, opts);
end
end

%% ========================================================= SINGOLO
function R = cr_singolo(PROTO, DATA, sog_paz, tempo, mov, fase_proto, lato_paz, opts)
opts = default_opts(opts);
[Wref, fase_paz, lato] = prep(PROTO, sog_paz, mov, fase_proto, lato_paz, opts);
n_proto = size(Wref,2);

R.sog_paz=sog_paz; R.mov=mov; R.tempo=tempo; R.fase_proto=fase_proto;
R.fase_paz=fase_paz; R.lato=lato; R.n_proto=n_proto; R.nota='';

try
    Wp = estrai_W(DATA, sog_paz, tempo, mov, fase_paz);
catch e
    R.r_norm=nan(n_proto,1); R.espressi=[]; R.assenti=1:n_proto; R.frazione=0;
    R.nota=sprintf('fase "%s" assente', fase_paz);
    fprintf('[%s %s] fase "%s" non trovata (%s)\n', sog_paz, mov, fase_paz, e.message);
    return;
end
Wp = normalizza_colonne(Wp);

% r_norm: assegnazione OTTIMA uno-a-uno prototipi<->sinergie (max somma, Roh)
S = Wref' * Wp;  S = max(0, min(1, S));
[rn, jmatch] = rnorm_ott(S);
R.S=S; R.r_norm=rn; R.match_paz=jmatch;
R.espressi = find(rn >= opts.soglia)';
R.assenti  = find(rn <  opts.soglia)';
R.frazione = numel(R.espressi)/n_proto;

fprintf('\n== %s (%s) vs template sani [Roh] — %s / %s ==\n', sog_paz, tempo, mov, fase_proto);
fprintf('  lato: %s   fase paziente: %s   soglia r_norm: %.2f\n', lato, fase_paz, opts.soglia);
for i=1:n_proto
    tag='ASSENTE'; if rn(i)>=opts.soglia; tag='conservata'; end
    fprintf('   proto %d   r_norm = %.3f  -> %s\n', i, rn(i), tag);
end
fprintf('  conservate: %d/%d  (frazione %.2f)\n\n', numel(R.espressi), n_proto, R.frazione);
end

%% ========================================================= GRUPPO
function R = cr_gruppo(PROTO, DATA, lato_paz, opts)
% Analisi di incidenza secondo Roh et al. (2015): per ogni (mov,fase) si
% clusterizzano INSIEME le sinergie di tutti i sani e di tutti i pazienti (di un
% timepoint), poi per ogni cluster si conta quanti soggetti di ciascun gruppo vi
% hanno una sinergia (appartenenza al cluster, NON soglia di similarita'), e si
% testa la differenza con il Fisher. Due analisi: Sani vs T0 e Sani vs T1.
opts = default_opts(opts);
movs = fieldnames(PROTO);
R = struct();
for tp = {'T0','T1'}
    tempo = tp{1};
    righe = {};
    for m = 1:numel(movs)
        mov = movs{m};
        fasi = fieldnames(PROTO.(mov));
        for f = 1:numel(fasi)
            fase = fasi{f};
            % raccoglie TUTTE le sinergie: sani + pazienti del timepoint
            [Wall, owner, grp, n_s, n_p] = raccogli_tutti(DATA, mov, fase, tempo, lato_paz, opts);
            if size(Wall,2) < 2; continue; end
            % clustering congiunto (euclidea, Ward, <=1 sinergia per soggetto)
            lab = cluster_congiunto(Wall, owner, opts.kmax);
            lab = lab(:)';                          % forza riga (cluster() torna colonna)
            nC = max(lab);
            for c = 1:nC
                idx = (lab==c);
                sani_c = unique(owner(idx & grp==1));    % soggetti sani distinti nel cluster
                paz_c  = unique(owner(idx & grp==2));    % soggetti pazienti distinti
                inc_s = numel(sani_c); inc_p = numel(paz_c);
                tab = [inc_s, n_s-inc_s; inc_p, n_p-inc_p];
                p = fisher2x2(tab);
                righe(end+1,:) = { mov, fase, c, inc_s, n_s, inc_p, n_p, p }; %#ok<AGROW>
            end
        end
    end
    intest = {'mov','fase','cluster','inc_sani','n_sani','inc_paz','n_paz','p_fisher'};
    if exist('cell2table','file'); TAB = cell2table(righe,'VariableNames',intest);
    else; TAB = [intest; righe]; end
    R.(tempo).TAB = TAB;
    % stampa
    fprintf('\n===== confronta_roh (incidenza, Roh 2015) — Sani vs %s =====\n', tempo);
    fprintf('clustering congiunto sani+pazienti; incidenza = n. soggetti per gruppo nel cluster\n');
    fprintf('%-11s %-16s %7s %9s %9s %8s\n','mov','fase','cluster','sani','paz','p');
    for i=1:size(righe,1)
        fprintf('%-11s %-16s %7d %5d/%-3d %5d/%-3d %8.3g\n', ...
            righe{i,1},righe{i,2},righe{i,3}, righe{i,4},righe{i,5}, righe{i,6},righe{i,7}, righe{i,8});
    end
    fprintf('==============================================================\n');
end
end

%% ---------------------------------------------------------
function [Wall, owner, grp, n_s, n_p] = raccogli_tutti(DATA, mov, fase, tempo, lato_paz, opts)
% raccoglie le sinergie di tutti i sani (tempo_sani) e di tutti i pazienti
% (tempo). owner = id univoco di soggetto (tra entrambi i gruppi); grp = 1 sano,
% 2 paziente. n_s/n_p = n. soggetti distinti con sinergie per gruppo.
Wall = []; owner = []; grp = []; uid = 0; sani_set = {}; paz_set = {};
% sani
if isfield(DATA, opts.gruppo_sani)
    ss = fieldnames(DATA.(opts.gruppo_sani));
    for s = 1:numel(ss)
        try; W = normalizza_colonne(estrai_W(DATA, ss{s}, opts.tempo_sani, mov, fase)); catch; continue; end
        if isempty(W); continue; end
        uid = uid + 1; Wall=[Wall W]; owner=[owner repmat(uid,1,size(W,2))]; grp=[grp ones(1,size(W,2))]; %#ok<AGROW>
        sani_set{end+1} = ss{s}; %#ok<AGROW>
    end
end
% pazienti (del timepoint), fase allineata al lato affetto
if isfield(DATA, opts.gruppo_paz)
    pp = fieldnames(DATA.(opts.gruppo_paz));
    for s = 1:numel(pp)
        Snm = pp{s}; fase_s = fase;
        if isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L') && ~strcmpi(mov,'RandG')
            fase_s = regexprep(fase,'^R','L');
        end
        try; W = normalizza_colonne(estrai_W(DATA, Snm, tempo, mov, fase_s)); catch; continue; end
        if isempty(W); continue; end
        uid = uid + 1; Wall=[Wall W]; owner=[owner repmat(uid,1,size(W,2))]; grp=[grp 2*ones(1,size(W,2))]; %#ok<AGROW>
        paz_set{end+1} = Snm; %#ok<AGROW>
    end
end
n_s = numel(sani_set); n_p = numel(paz_set);
end

%% ---------------------------------------------------------
function lab = cluster_congiunto(Wall, owner, kmax)
% euclidea (Minkowski p=2) + Ward + numero di cluster = minimo con <=1 sinergia
% per soggetto in ogni cluster (Roh 2015).
D = pdist(Wall', 'minkowski', 2);
Z = linkage(D, 'ward');
n = size(Wall,2); kmax = min(kmax, n); lab = cluster(Z,'maxclust',kmax); lab = lab(:)';
for k = 1:kmax
    l = cluster(Z,'maxclust',k); l = l(:)';     % forza riga
    if vincolo_ok(l, owner); lab = l; break; end
end
end

function ok = vincolo_ok(lab, owner)
% vero se nessun cluster contiene due sinergie dello stesso soggetto.
ok = true;
for c = 1:max(lab)
    o = owner(lab==c);
    if numel(o) ~= numel(unique(o)); ok = false; return; end
end
end

%% ---------------------------------------------------------
function [Wref, fase_paz, lato] = prep(PROTO, sog_paz, mov, fase_proto, lato_paz, opts) %#ok<INUSD>
if ~isfield(PROTO,mov) || ~isfield(PROTO.(mov),fase_proto)
    error('confronta_roh:proto','PROTO non ha %s / %s.', mov, fase_proto);
end
Wref = PROTO.(mov).(fase_proto).Wref;
if strcmpi(mov,'RandG'); fase_paz = fase_proto; lato='-';
else
    if ~isfield(lato_paz,sog_paz); error('confronta_roh:lato','Lato non definito per %s.', sog_paz); end
    lato = upper(lato_paz.(sog_paz));
    if strcmp(lato,'L'); fase_paz = regexprep(fase_proto,'^R','L'); else; fase_paz = fase_proto; end
end
end

function opts = default_opts(opts)
if ~isfield(opts,'soglia'),      opts.soglia = 0.80;          end  % Roh 2015
if ~isfield(opts,'gruppo_paz'),  opts.gruppo_paz = 'Patologici'; end
if ~isfield(opts,'gruppo_sani'), opts.gruppo_sani = 'Sani';   end
if ~isfield(opts,'tempo_sani'),  opts.tempo_sani = 'T';       end
if ~isfield(opts,'kmax'),         opts.kmax = 40;              end
if ~isfield(opts,'tempo_paz'),   opts.tempo_paz = 'T0';       end  % 'T0' | 'T1' | 'tutti'
end

%% ---------------------------------------------------------
function p = fisher2x2(t)
% Fisher's exact test (two-tailed) per tabella 2x2. Usa fishertest se disponibile.
if exist('fishertest','file')
    try; [~, p] = fishertest(t); return; catch; end
end
% fallback: p esatto ipergeometrico (somma delle tabelle con prob <= osservata)
a=t(1,1); b=t(1,2); c=t(2,1); d=t(2,2); n=a+b+c+d;
r1=a+b; r2=c+d; c1=a+c; c2=b+d;
logf = @(x) gammaln(x+1);
lp = @(A) logf(r1)+logf(r2)+logf(c1)+logf(c2) - logf(n) - logf(A) - logf(r1-A) - logf(c1-A) - logf(n-r1-c1+A);
p_obs = lp(a);
p = 0; amin = max(0, r1+c1-n); amax = min(r1, c1);
for A = amin:amax
    lpa = lp(A);
    if lpa <= p_obs + 1e-9; p = p + exp(lpa); end
end
p = min(1, p);
end

%% ========================================================= (da sinergie_prototipo)
function W = estrai_W(DATA, sog, tempo, mov, fase)
gruppi = fieldnames(DATA); M = [];
for g = 1:numel(gruppi)
    if isfield(DATA.(gruppi{g}), sog)
        ss = DATA.(gruppi{g}).(sog);
        if ~isempty(tempo) && isfield(ss, tempo)
            if isfield(ss.(tempo), mov); M = ss.(tempo).(mov); break; end
        else
            if isfield(ss, mov); M = ss.(mov); break; end
        end
    end
end
if isempty(M); error('confronta_roh:soggetto','%s / %s (tempo %s) non trovato.', sog, mov, tempo); end
if ~isfield(M,'sinergie'); error('confronta_roh:sinergie','Nessuna sinergia per %s/%s.', sog, mov); end
syn = M.sinergie; lab = cellstr(syn.phase_labels);
j = find(strcmp(lab, fase), 1);
if isempty(j); error('confronta_roh:fase','Fase "%s" non trovata. Disp: %s', fase, strjoin(lab,', ')); end
W = syn.W{j};
if isempty(W); error('confronta_roh:vuota','W vuota per %s/%s/%s.', sog, mov, fase); end
if iscell(W); W = W{1}; end
end

function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i)); if n > eps; W(:,i) = W(:,i)/n; end
end
end

%% ---------------------------------------------------------
function [rn, jm] = rnorm_ott(S)
% r_norm per prototipo con assegnazione OTTIMA uno-a-uno (max somma prodotti
% scalari, come Roh: "highest total sum"). matchpairs (Hungarian); fallback greedy.
% S = [n_proto x k_paz]. Prototipi non appaiati -> r_norm 0.
np = size(S,1); rn = zeros(np,1); jm = zeros(np,1);
try
    M = matchpairs(1 - S, 1.5);          % minimizza (1-S) = massimizza somma S
catch
    M = appaia_greedy_S(S);
end
for r = 1:size(M,1)
    i = M(r,1); j = M(r,2);
    if i>=1 && i<=np && j>=1 && j<=size(S,2); rn(i) = max(0, S(i,j)); jm(i) = j; end
end
end

function M = appaia_greedy_S(S)
% fallback: prende iterativamente la coppia con similarita' massima e la rimuove.
St = S; M = zeros(0,2);
while true
    [v, idx] = max(St(:));
    if ~isfinite(v) || v <= 0; break; end
    [i, j] = ind2sub(size(St), idx);
    M(end+1,:) = [i j]; %#ok<AGROW>
    St(i,:) = -Inf; St(:,j) = -Inf;
    if all(~isfinite(St(:))); break; end
end
end
