function varargout = confronta_con_prototipo(PROTO, DATA, arg3, varargin)
%CONFRONTA_CON_PROTOTIPO  Confronta le sinergie dei pazienti contro i prototipi
%  sani, allineando il LATO AFFETTO. Due modalita' nella stessa funzione:
%
%  SINGOLO (arg3 = codice paziente, stringa):
%    R = confronta_con_prototipo(PROTO, DATA, 'S041','T0','Flex','R_Intero', lato_paz)
%    R = confronta_con_prototipo(PROTO, DATA, 'S041','T0','Flex','R_Intero', lato_paz, opts)
%
%  Utilizza i prototipi creati seguendo l'articolo di roh et al.
%   [TAB_roh, RES_roh] = confronta_con_prototipo(PROTO_roh, DATA, lato_paz);
%
%  TUTTI (arg3 = tabella lato_paz, struct):
%    [TAB, RES] = confronta_con_prototipo(PROTO, DATA, lato_paz)
%    [TAB, RES] = confronta_con_prototipo(PROTO, DATA, lato_paz, opts)
%    itera su tutti i pazienti, timepoint, movimenti e fasi di PROTO.
%
%  Logica: i sani sono registrati a destra -> i prototipi sono fasi R. Il
%  paziente ha le sonde sul lato affetto: se 'L', si usa la sua fase L omologa
%  (swap R->L). Per il RandG la fase e' sempre 'Completo_Intero' (un solo
%  braccio). Si confronta solo contro i prototipi con prevalenza >= 50%.
%
%  opts: .soglia (0.75) cosine "esprime il modulo"
%        .soglia_merging (0.75*soglia) per il merging
%        .prevalenza_min (0.50) frazione minima di sani per tenere un prototipo
%        .gruppo_paz ('Patologici')

if isstruct(arg3)
    lato_paz = arg3;
    opts = struct(); if ~isempty(varargin), opts = varargin{1}; end
    [TAB, RES] = cc_tutti(PROTO, DATA, lato_paz, opts);
    varargout = {TAB, RES};
else
    if numel(varargin) < 4
        error('confronta_con_prototipo:args', ...
            'Uso singolo: (PROTO, DATA, sog_paz, tempo, mov, fase_proto, lato_paz [,opts])');
    end
    tempo = varargin{1}; mov = varargin{2}; fase_proto = varargin{3};
    lato_paz = varargin{4};
    opts = struct(); if numel(varargin) >= 5, opts = varargin{5}; end
    R = cc_singolo(PROTO, DATA, arg3, tempo, mov, fase_proto, lato_paz, opts);
    varargout = {R};
end
end

%% ========================================================= confronto SINGOLO
function R = cc_singolo(PROTO, DATA, sog_paz, tempo, mov, fase_proto, lato_paz, opts)
if ~isfield(opts,'soglia'),         opts.soglia = 0.75;          end
if ~isfield(opts,'prevalenza_min'), opts.prevalenza_min = 0.50;  end
if ~isfield(opts,'gruppo_paz'),     opts.gruppo_paz = 'Patologici'; end
if ~isfield(opts,'soglia_merging'), opts.soglia_merging = opts.soglia * 0.75; end

is_randg = strcmpi(mov,'RandG');

if is_randg
    fase_paz = fase_proto; lato = '-';
else
    if ~isfield(lato_paz, sog_paz)
        error('confronta_con_prototipo:lato','Lato non definito per %s in lato_paz.', sog_paz);
    end
    lato = upper(lato_paz.(sog_paz));
    if strcmp(lato,'L'); fase_paz = regexprep(fase_proto,'^R','L'); else; fase_paz = fase_proto; end
end

if ~isfield(PROTO, mov) || ~isfield(PROTO.(mov), fase_proto)
    error('confronta_con_prototipo:proto','PROTO non ha %s / %s.', mov, fase_proto);
end
P = PROTO.(mov).(fase_proto);
keep = (P.prevalenza(:) / P.n_sani) >= opts.prevalenza_min;
Wref = P.Wref(:, keep);  prev = P.prevalenza(keep);  n_proto = size(Wref,2);

R.sog_paz = sog_paz; R.mov = mov; R.tempo = tempo;
R.fase_proto = fase_proto; R.fase_paz = fase_paz; R.lato = lato;
R.n_proto = n_proto; R.prevalenza_proto = prev; R.nota = '';

if n_proto == 0
    R.espressi = []; R.assenti = []; R.frazione = NaN; R.S = []; R.merging = [];
    R.nota = sprintf('nessun prototipo sopra prevalenza %.0f%%', 100*opts.prevalenza_min);
    fprintf('[%s %s/%s] %s -> confronto non possibile\n', sog_paz, mov, fase_proto, R.nota);
    return;
end

try
    Wp = estrai_W(DATA, sog_paz, tempo, mov, fase_paz);
catch e
    R.espressi = []; R.assenti = 1:n_proto; R.frazione = 0; R.S = []; R.merging = [];
    R.nota = sprintf('fase "%s" assente', fase_paz);
    fprintf('[%s %s] fase "%s" non trovata (%s)\n', sog_paz, mov, fase_paz, e.message);
    return;
end
Wp = normalizza_colonne(Wp);  k_paz = size(Wp,2);

S = Wref' * Wp;  S = max(0, min(1, S));  R.S = S;

[best, jbest] = max(S, [], 2);
R.match_cos = best;  R.match_paz = jbest;
R.espressi  = find(best >= opts.soglia)';
R.assenti   = find(best <  opts.soglia)';
R.frazione  = numel(R.espressi) / n_proto;

R.merging = [];
for j = 1:k_paz
    vic = find(S(:,j) >= opts.soglia_merging);
    if numel(vic) >= 2, R.merging(end+1,:) = [j, vic(1), vic(2)]; end %#ok<AGROW>
end

fprintf('\n== %s (%s) vs prototipi sani — %s / %s ==\n', sog_paz, tempo, mov, fase_proto);
fprintf('  lato affetto: %s   fase paziente: %s   sinergie paziente: %d\n', lato, fase_paz, k_paz);
fprintf('  prototipi usati (prevalenza >= %.0f%%): %d\n', 100*opts.prevalenza_min, n_proto);
for i = 1:n_proto
    tag = 'ASSENTE'; if best(i) >= opts.soglia, tag = 'espresso'; end
    fprintf('   proto %d (prev %d/%d)  best cos = %.3f  -> %s\n', i, prev(i), P.n_sani, best(i), tag);
end
fprintf('  espressi: %d/%d  (frazione %.2f)\n', numel(R.espressi), n_proto, R.frazione);
if ~isempty(R.merging)
    for i = 1:size(R.merging,1)
        fprintf('  possibile MERGING: sinergia paziente %d vicina a proto %d e %d\n', ...
            R.merging(i,1), R.merging(i,2), R.merging(i,3));
    end
end
fprintf('\n');
end

%% ========================================================= wrapper TUTTI
function [TAB, RES] = cc_tutti(PROTO, DATA, lato_paz, opts)
if ~isfield(opts,'gruppo_paz'), opts.gruppo_paz = 'Patologici'; end
if ~isfield(DATA, opts.gruppo_paz)
    error('confronta_con_prototipo:gruppo','Gruppo "%s" non in DATA.', opts.gruppo_paz);
end
paz  = fieldnames(DATA.(opts.gruppo_paz));
movs = fieldnames(PROTO);
righe = {}; RES = struct();

for p = 1:numel(paz)
    sog = paz{p};
    tps = fieldnames(DATA.(opts.gruppo_paz).(sog));
    for t = 1:numel(tps)
        tp = tps{t};
        for m = 1:numel(movs)
            mov = movs{m};
            fasi = fieldnames(PROTO.(mov));
            for f = 1:numel(fasi)
                fase = fasi{f};
                try
                    R = cc_singolo(PROTO, DATA, sog, tp, mov, fase, lato_paz, opts);
                catch e
                    R = struct('lato','?','n_proto',NaN,'espressi',[],'frazione',NaN, ...
                        'merging',[],'nota',e.message,'fase_paz','');
                end
                RES.(sog).(tp).(mov).(fase) = R;
                nmerg = 0; if isfield(R,'merging') && ~isempty(R.merging), nmerg = size(R.merging,1); end
                nesp  = 0; if isfield(R,'espressi'), nesp = numel(R.espressi); end
                righe(end+1,:) = { sog, tp, mov, fase, R.lato, R.n_proto, nesp, ...
                    R.frazione, nmerg, R.nota }; %#ok<AGROW>
            end
        end
    end
end

intest = {'paziente','timepoint','mov','fase','lato','n_proto','n_espressi','frazione','n_merging','nota'};
if exist('cell2table','file')
    TAB = cell2table(righe, 'VariableNames', intest);
else
    TAB = [intest; righe];
end

fprintf('\n============ confronta_tutti_pazienti ============\n');
fprintf('%-8s %-4s %-11s %-17s %-4s %5s %5s %6s %5s\n', ...
    'paz','tp','mov','fase','lato','nPro','nEsp','fraz','merg');
for i = 1:size(righe,1)
    fr = righe{i,8}; if isnan(fr), frs='  -'; else, frs=sprintf('%.2f',fr); end
    np = righe{i,6}; if isnan(np), nps='-'; else, nps=sprintf('%d',np); end
    fprintf('%-8s %-4s %-11s %-17s %-4s %5s %5d %6s %5d %s\n', ...
        righe{i,1},righe{i,2},righe{i,3},righe{i,4},righe{i,5}, ...
        nps,righe{i,7},frs,righe{i,9},righe{i,10});
end
fprintf('==================================================\n');
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
if isempty(M); error('confronta_con_prototipo:soggetto','%s / %s (tempo %s) non trovato.', sog, mov, tempo); end
if ~isfield(M,'sinergie'); error('confronta_con_prototipo:sinergie','Nessuna sinergia per %s/%s.', sog, mov); end
syn = M.sinergie; lab = cellstr(syn.phase_labels);
j = find(strcmp(lab, fase), 1);
if isempty(j); error('confronta_con_prototipo:fase','Fase "%s" non trovata. Disp: %s', fase, strjoin(lab,', ')); end
W = syn.W{j};
if isempty(W); error('confronta_con_prototipo:vuota','W vuota per %s/%s/%s.', sog, mov, fase); end
if iscell(W); W = W{1}; end
end

function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i)); if n > eps; W(:,i) = W(:,i)/n; end
end
end
