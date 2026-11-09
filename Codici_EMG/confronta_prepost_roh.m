function R = confronta_prepost_roh(PROTO, DATA, lato_paz, opts)
%CONFRONTA_PREPOST_ROH  Confronto pre/post (T0 vs T1) DENTRO ogni paziente:
%  per ciascun paziente con entrambi i timepoint, calcola la frazione di moduli
%  sani (prototipi Roh) conservati (r_norm >= 0.8) a T0 e a T1, e li appaia.
%
%  Confronta lo STESSO paziente con se stesso -> elimina la variabilita' tra
%  soggetti e il confondente sani-vs-pazienti-di-lab-diverso. Il test corretto e'
%  APPAIATO: Wilcoxon signed-rank (misure ripetute), non il Fisher.
%
%  USO
%    R_T0vsT1 = confronta_prepost_roh(PROTO_roh, DATA, lato_paz)
%    R = confronta_prepost_roh(PROTO_roh, DATA, lato_paz, struct('soglia',0.8))
%
%  Il confronto e' aggregato su tutti i movimenti/fasi di PROTO (frazione media
%  di moduli conservati per paziente), oppure per singolo movimento se
%  opts.mov/opts.fase sono specificati.
%
%  OUTPUT R
%    .pazienti   {n} codici dei pazienti con T0 e T1
%    .fraz_T0    [n] frazione moduli conservati a T0
%    .fraz_T1    [n] frazione moduli conservati a T1
%    .delta      [n] fraz_T1 - fraz_T0  (>0 = migliora verso il sano)
%    .p_wilcoxon test appaiato T0 vs T1
%    .mediana_T0/.mediana_T1
%    .TAB        tabella paziente x (T0, T1, delta)

if nargin < 4, opts = struct; end
if ~isfield(opts,'soglia'),     opts.soglia = 0.80;   end
if ~isfield(opts,'gruppo_paz'), opts.gruppo_paz = 'Patologici'; end
if ~isfield(opts,'mov'),        opts.mov = '';        end   % '' = tutti
if ~isfield(opts,'fase'),       opts.fase = '';       end

if ~isfield(DATA, opts.gruppo_paz)
    error('confronta_prepost_roh:gruppo','Gruppo "%s" non in DATA.', opts.gruppo_paz);
end
paz = fieldnames(DATA.(opts.gruppo_paz));

% coppie (mov,fase) su cui valutare: da PROTO (solo fasi R/Completo dei sani)
coppie = {};
movs = fieldnames(PROTO);
for m = 1:numel(movs)
    if ~isempty(opts.mov) && ~strcmp(movs{m}, opts.mov); continue; end
    fasi = fieldnames(PROTO.(movs{m}));
    for f = 1:numel(fasi)
        if ~isempty(opts.fase) && ~strcmp(fasi{f}, opts.fase); continue; end
        coppie(end+1,:) = {movs{m}, fasi{f}}; %#ok<AGROW>
    end
end

cod={}; fT0=[]; fT1=[];
for s = 1:numel(paz)
    Snm = paz{s};
    st = DATA.(opts.gruppo_paz).(Snm);
    if ~isfield(st,'T0') || ~isfield(st,'T1'); continue; end   % servono ENTRAMBI
    [f0, n0] = frazione_conservati(PROTO, DATA, Snm, 'T0', coppie, lato_paz, opts);
    [f1, n1] = frazione_conservati(PROTO, DATA, Snm, 'T1', coppie, lato_paz, opts);
    if n0==0 || n1==0; continue; end   % nessun prototipo valutabile
    cod{end+1}=Snm; fT0(end+1)=f0; fT1(end+1)=f1; %#ok<AGROW>
end

n = numel(cod);
if n==0; error('confronta_prepost_roh:vuoto','Nessun paziente con T0 e T1 valutabile.'); end
delta = fT1 - fT0;

% --- test appaiato Wilcoxon signed-rank ---
p = wilcoxon_signrank(fT0(:), fT1(:));

R.pazienti = cod; R.fraz_T0 = fT0(:); R.fraz_T1 = fT1(:); R.delta = delta(:);
R.p_wilcoxon = p;
R.mediana_T0 = median(fT0); R.mediana_T1 = median(fT1);
R.soglia = opts.soglia;

intest = {'paziente','fraz_T0','fraz_T1','delta'};
righe = [cod(:), num2cell(fT0(:)), num2cell(fT1(:)), num2cell(delta(:))];
if exist('cell2table','file'); R.TAB = cell2table(righe,'VariableNames',intest);
else; R.TAB = [intest; righe]; end

% --- stampa ---
amb = 'tutti i movimenti'; if ~isempty(opts.mov); amb = opts.mov; if ~isempty(opts.fase); amb=[amb ' / ' opts.fase]; end; end
fprintf('\n===== confronta_prepost_roh (T0 vs T1, %s) =====\n', amb);
fprintf('frazione di moduli sani conservati (r_norm >= %.2f), per paziente:\n', opts.soglia);
fprintf('%-8s %8s %8s %8s\n','paz','T0','T1','delta');
for i=1:n
    fprintf('%-8s %8.2f %8.2f %+8.2f\n', cod{i}, fT0(i), fT1(i), delta(i));
end
migl = sum(delta>0); peg = sum(delta<0); ug = sum(delta==0);
fprintf('mediana: T0=%.2f  T1=%.2f\n', R.mediana_T0, R.mediana_T1);
fprintf('migliorati: %d   peggiorati: %d   invariati: %d   (n=%d)\n', migl, peg, ug, n);
fprintf('Wilcoxon signed-rank (appaiato) p = %.4g\n', p);
fprintf('=================================================\n');
end

%% ---------------------------------------------------------
function [fraz, n_val] = frazione_conservati(PROTO, DATA, sog, tempo, coppie, lato_paz, opts)
% frazione di prototipi (su tutte le coppie mov/fase) con r_norm >= soglia,
% per il paziente al timepoint dato. Allineamento lato affetto.
tot_proto = 0; tot_espr = 0;
lato = 'R'; if isfield(lato_paz,sog); lato = upper(lato_paz.(sog)); end
for k = 1:size(coppie,1)
    mov = coppie{k,1}; fase = coppie{k,2};
    Wref = PROTO.(mov).(fase).Wref; np = size(Wref,2);
    if np==0; continue; end
    fase_s = fase;
    if ~strcmpi(mov,'RandG') && strcmp(lato,'L'); fase_s = regexprep(fase,'^R','L'); end
    try; Wx = normalizza_colonne(estrai_W(DATA, sog, tempo, mov, fase_s)); catch; continue; end
    S = max(0, min(1, Wref' * Wx));
    rn = rnorm_ott(S);                 % assegnazione ottima uno-a-uno (Roh)
    tot_proto = tot_proto + np;
    tot_espr  = tot_espr  + sum(rn >= opts.soglia);
end
n_val = tot_proto;
if tot_proto>0; fraz = tot_espr/tot_proto; else; fraz = NaN; end
end

%% ---------------------------------------------------------
function p = wilcoxon_signrank(x, y)
% Wilcoxon signed-rank test appaiato (two-tailed). Usa signrank se disponibile,
% altrimenti approssimazione normale con correzione per ties e zeri (Pratt-off).
d = y - x; d = d(d~=0);          % scarta le differenze nulle
nz = numel(d);
if nz == 0; p = 1; return; end
if exist('signrank','file')
    try; p = signrank(x, y); return; catch; end
end
[~,~,r] = unique(abs(d));        % ranghi dei valori assoluti (con ties medi)
% ranghi medi
R = zeros(nz,1);
for i=1:nz; R(i) = mean(find(sort(abs(d))==abs(d(i)))); end
Wp = sum(R(d>0)); Wm = sum(R(d<0));
W  = min(Wp, Wm);
muW = nz*(nz+1)/4;
sdW = sqrt(nz*(nz+1)*(2*nz+1)/24);
if sdW==0; p=1; return; end
z = (W - muW)/sdW;
p = 2*normcdf(-abs(z));
p = min(1, max(0, p));
end

function pc = normcdf(z)
pc = 0.5*erfc(-z./sqrt(2));
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
if isempty(M); error('confronta_prepost_roh:soggetto','%s / %s (tempo %s) non trovato.', sog, mov, tempo); end
if ~isfield(M,'sinergie'); error('confronta_prepost_roh:sinergie','Nessuna sinergia per %s/%s.', sog, mov); end
syn = M.sinergie; lab = cellstr(syn.phase_labels);
j = find(strcmp(lab, fase), 1);
if isempty(j); error('confronta_prepost_roh:fase','Fase "%s" non trovata. Disp: %s', fase, strjoin(lab,', ')); end
W = syn.W{j};
if isempty(W); error('confronta_prepost_roh:vuota','W vuota per %s/%s/%s.', sog, mov, fase); end
if iscell(W); W = W{1}; end
end

function W = normalizza_colonne(W)
for i = 1:size(W,2)
    n = norm(W(:,i)); if n > eps; W(:,i) = W(:,i)/n; end
end
end

%% ---------------------------------------------------------
function rn = rnorm_ott(S)
% r_norm per prototipo con assegnazione OTTIMA uno-a-uno (max somma, Roh).
np = size(S,1); rn = zeros(np,1);
try; M = matchpairs(1 - S, 1.5); catch; M = appaia_greedy_S(S); end
for r = 1:size(M,1)
    i = M(r,1); j = M(r,2);
    if i>=1 && i<=np && j>=1 && j<=size(S,2); rn(i) = max(0, S(i,j)); end
end
end
function M = appaia_greedy_S(S)
St = S; M = zeros(0,2);
while true
    [v, idx] = max(St(:)); if ~isfinite(v) || v<=0; break; end
    [i,j] = ind2sub(size(St), idx); M(end+1,:) = [i j]; %#ok<AGROW>
    St(i,:) = -Inf; St(:,j) = -Inf; if all(~isfinite(St(:))); break; end
end
end
