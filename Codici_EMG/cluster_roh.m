function P = cluster_roh(DATA, mov, fase, opts)
%CLUSTER_ROH  Prototipi del gruppo sani col metodo di Roh et al. (2015):
%  distanza euclidea (Minkowski p=2), linkage Ward, e numero di cluster pari al
%  MINIMO che garantisce non piu' di UNA sinergia per soggetto in ogni cluster.
%
%  E' la variante "delle fonti", alternativa/citabile rispetto a
%  sinergie_prototipo (coseno + complete-linkage + prevalenza >=50%).
%  Roh 2015 usa 8 muscoli (spalla/gomito), come questo dataset.
%
%  USO
%    P = cluster_roh(DATA, 'Addu', 'R_Intero');
%    P = cluster_roh(DATA, 'Circ', 'RAvanti_Intero', struct('gruppo','Sani'));
%
%  opts: .gruppo (default 'Sani'), .tempo (default 'T'), .kmax (tetto di sicurezza)
%
%  OUTPUT P
%    .Wref        [8 x nCluster] centroidi (media delle sinergie del cluster), a norma 1
%    .n_cluster   numero di cluster scelto dal criterio
%    .prevalenza  [nCluster x 1] n. soggetti distinti per cluster
%    .n_membri    [nCluster x 1]
%    .soggetti    {nCluster x 1}
%    .n_sani, .saltati, .metodo
%    .Wall, .owner (diagnostica)

if nargin < 4, opts = struct; end
if ~isfield(opts,'gruppo'), opts.gruppo = 'Sani'; end
if ~isfield(opts,'tempo'),  opts.tempo  = 'T';    end
if ~isfield(opts,'kmax'),   opts.kmax   = 30;     end   % tetto di sicurezza

if ~isfield(DATA, opts.gruppo)
    error('cluster_roh:gruppo','Gruppo "%s" non trovato in DATA.', opts.gruppo);
end
sani = fieldnames(DATA.(opts.gruppo));

%% --- raccolta di tutte le sinergie dei sani ---
Wall = []; owner = []; owner_names = {}; saltati = {}; iu = 0;
for s = 1:numel(sani)
    try
        W = estrai_W(DATA, sani{s}, opts.tempo, mov, fase);
    catch
        saltati{end+1} = sani{s}; %#ok<AGROW>
        continue;
    end
    W = normalizza_colonne(W);
    iu = iu + 1;
    Wall  = [Wall, W];                         %#ok<AGROW>
    owner = [owner, repmat(iu, 1, size(W,2))]; %#ok<AGROW>
    owner_names{end+1} = sani{s};              %#ok<AGROW>
end
n_sani = numel(sani) - numel(saltati);
if isempty(Wall)
    error('cluster_roh:vuoto','Nessun sano ha sinergie per %s / %s.', mov, fase);
end

%% --- clustering: euclidea (Minkowski p=2) + Ward ---
% (metodo Roh 2015: pdist Minkowski p=2, linkage 'ward', cluster)
D = pdist(Wall', 'minkowski', 2);        % = distanza euclidea
Z = linkage(D, 'ward');

%% --- numero di cluster: minimo con <=1 sinergia per soggetto per cluster ---
n_syn = size(Wall,2);
kmax  = min(opts.kmax, n_syn);
n_cluster = kmax;                        % fallback
for k = 1:kmax
    lab = cluster(Z, 'maxclust', k);
    if rispetta_vincolo(lab, owner)
        n_cluster = k; break;
    end
end
lab = cluster(Z, 'maxclust', n_cluster);

%% --- centroidi, prevalenza, soggetti ---
cent = zeros(size(Wall,1), n_cluster);
prev = zeros(n_cluster,1); nmemb = zeros(n_cluster,1); sogg = cell(n_cluster,1);
for c = 1:n_cluster
    idx = find(lab == c);
    v = mean(Wall(:, idx), 2);
    nv = norm(v); if nv > eps, v = v/nv; end   % centroide a norma 1
    cent(:,c) = v;
    nmemb(c)  = numel(idx);
    uo = unique(owner(idx));
    prev(c)   = numel(uo);
    sogg{c}   = owner_names(uo);
end
% ordina per condivisione (prevalenza decrescente), coerente con sinergie_prototipo
[~, ord] = sort(prev, 'descend');

P.Wref       = cent(:,ord);
P.n_cluster  = n_cluster;
P.prevalenza = prev(ord);
P.n_membri   = nmemb(ord);
P.soggetti   = sogg(ord);
P.n_sani     = n_sani;
P.saltati    = saltati;
P.metodo     = 'Roh2015 (euclidea, Ward, 1-per-soggetto)';
P.mov = mov;  P.fase = fase;
P.Wall = Wall; P.owner = owner; P.owner_names = {owner_names};

%% --- stampa ---
fprintf('\n== cluster_roh — %s / %s ==\n', mov, fase);
fprintf('sani usati: %d', n_sani);
if ~isempty(saltati), fprintf('  (saltati: %s)', strjoin(saltati, ', ')); end
fprintf('\ntotale sinergie: %d  ->  %d cluster (criterio: <=1 per soggetto)\n', n_syn, n_cluster);
fprintf('%-8s %11s %9s   %s\n','cluster','prevalenza','n.membri','soggetti');
for c = 1:n_cluster
    fprintf('C%-7d %7d/%-3d %9d   %s\n', c, P.prevalenza(c), n_sani, P.n_membri(c), strjoin(P.soggetti{c}, ', '));
end
fprintf('\n');
end

%% ---------------------------------------------------------
function ok = rispetta_vincolo(lab, owner)
% vero se NESSUN cluster contiene due o piu' sinergie dello stesso soggetto
ok = true;
for c = 1:max(lab)
    o = owner(lab == c);
    if numel(o) ~= numel(unique(o)); ok = false; return; end
end
end

%% ========================================================= (da sinergie_prototipo)
function W = estrai_W(DATA, sog, tempo, mov, fase)
gruppi = fieldnames(DATA);
M = [];
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
if isempty(M); error('cluster_roh:soggetto','%s / %s (tempo %s) non trovato.', sog, mov, tempo); end
if ~isfield(M,'sinergie'); error('cluster_roh:sinergie','Nessuna sinergia per %s/%s.', sog, mov); end
syn = M.sinergie; lab = cellstr(syn.phase_labels);
j = find(strcmp(lab, fase), 1);
if isempty(j); error('cluster_roh:fase','Fase "%s" non trovata. Disp: %s', fase, strjoin(lab,', ')); end
W = syn.W{j};
if isempty(W); error('cluster_roh:vuota','W vuota per %s/%s/%s.', sog, mov, fase); end
if iscell(W); W = W{1}; end
end

function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i)); if n > eps; W(:,i) = W(:,i)/n; end
end
end
