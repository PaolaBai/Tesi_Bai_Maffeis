function OUT = tmcf_gruppo(DATA, mov, fase, sottogruppo, lato_paz, ylim_val)
%TMCF_GRUPPO  Confronto del profilo TMCf (media +/- SD tra soggetti) tra i tre
%  gruppi: Sani, Pazienti T0, Pazienti T1 — per un sottogruppo.
%
%  USO
%    tmcf_gruppo(DATA,'Addu','R_Intero','Globale', lato_paz)

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end

% Di default imposta il valore massimo dell'asse Y a 40 (da 0 a 40)
if nargin < 6 || isempty(ylim_val)
    ylim_val = [0 40]; 
end

COL_SANI = [0.20 0.60 0.85];   % azzurro
COL_T0   = [0.85 0.30 0.30];   % rosso
COL_T1   = [0.50 0.20 0.60];   % viola

% --- medie per gruppo/timepoint ---
[x, muS, sdS, nS] = media_gruppo(DATA,'Sani',       'T',  mov, fase, sottogruppo, lato_paz);
[~, m0,  s0,  n0] = media_gruppo(DATA,'Patologici', 'T0', mov, fase, sottogruppo, lato_paz);
[~, m1,  s1,  n1] = media_gruppo(DATA,'Patologici', 'T1', mov, fase, sottogruppo, lato_paz);

% --- figura principale: le 3 curve sovrapposte (SENZA LEGENDA) ---
figure('Color','w','Position',[100 100 800 480]); hold on;
banda(x, muS, sdS, COL_SANI);
banda(x, m0,  s0,  COL_T0);
banda(x, m1,  s1,  COL_T1);
plot(x, muS, 'Color',COL_SANI, 'LineWidth',2.2);
plot(x, m0,  'Color',COL_T0,   'LineWidth',2.2);
plot(x, m1,  'Color',COL_T1,   'LineWidth',2.2);

xlabel('% del ciclo'); ylabel('TMCf');
title(sprintf('%s', mov));
grid on; box off; 

% Impostazioni Assi X e Y
xlim([0 100]);
xticks(0:20:100);    % Salti di 20 sull'asse X (0, 20, 40, 60, 80, 100)

ylim(ylim_val);      % Imposta l'asse Y a [0 40]
yticks(0:10:40);     % Tacche sull'asse Y a passi di 10 (0, 10, 20, 30, 40)

% --- seconda figura: immagine contenente solo la legenda ---
crea_figura_legenda(COL_SANI, COL_T0, COL_T1);

OUT.x = x;
OUT.sani = pack(x,muS,sdS,nS);
OUT.T0   = pack(x,m0,s0,n0);
OUT.T1   = pack(x,m1,s1,n1);
end

%% ---------------------------------------------------------
function crea_figura_legenda(colS, col0, col1)
% Crea una nuova figura dedicata esclusivamente alla legenda
figLeg = figure('Color','w','Position',[920 300 220 120],'Name','Legenda','MenuBar','none','ToolBar','none');
axLeg = axes(figLeg, 'Visible', 'off'); 
hold(axLeg, 'on');

% Traccia elementi fittizi fuori dalla vista per generare la legenda
hS = plot(axLeg, NaN, NaN, 'Color', colS, 'LineWidth', 2.2);
h0 = plot(axLeg, NaN, NaN, 'Color', col0, 'LineWidth', 2.2);
h1 = plot(axLeg, NaN, NaN, 'Color', col1, 'LineWidth', 2.2);

% Legenda centrata tramite coordinate normalizzate [left bottom width height]
lgd = legend(axLeg, [hS h0 h1], {'Sani', 'Pazienti T0', 'Pazienti T1'}, ...
    'Location', 'none', 'Position', [0.1 0.1 0.8 0.8], 'FontSize', 11, 'Box', 'off');
end

%% ---------------------------------------------------------
function [x,mu,sd,n] = media_gruppo(DATA, gruppo, tempo, mov, fase, SG, lato_paz)
mu=[]; sd=[]; n=0; x=[];
if ~isfield(DATA, gruppo); error('tmcf_gruppo:gruppo','Gruppo %s assente.', gruppo); end
sogg = fieldnames(DATA.(gruppo));
is_sano = strcmpi(gruppo,'Sani');
is_randg = strcmpi(mov,'RandG');
curve = {};
for s = 1:numel(sogg)
    Snm = sogg{s};
    fase_s = fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L')
        fase_s = regexprep(fase,'^R','L');
    end
    st = DATA.(gruppo).(Snm);
    if ~isfield(st, tempo) || ~isstruct(st.(tempo)) || ~isfield(st.(tempo),mov); continue; end
    M = st.(tempo).(mov);
    if ~isfield(M,SG) || ~isfield(M.(SG),'TMCf'); continue; end
    lab = cellstr(M.phase_labels);
    ph = find(strcmp(lab,fase_s),1);
    if isempty(ph); continue; end
    A = M.(SG).TMCf(:,:,ph);             % [T x n_rep]
    if all(isnan(A(:))); continue; end
    curve{end+1} = riga_nanmean(A);      %#ok<AGROW>  media sui cicli
end
n = numel(curve);
if n==0; error('tmcf_gruppo:vuoto','Nessun soggetto valido per %s (%s) / %s / %s.', gruppo, tempo, mov, SG); end
T = numel(curve{1}); x = linspace(0,100,T);
Cmat = nan(T,n);
for s = 1:n; Cmat(:,s) = curve{s}(:); end
mu = nan(T,1); sd = nan(T,1);
for t = 1:T
    v = Cmat(t,:); v = v(isfinite(v));
    if ~isempty(v); mu(t)=mean(v); end
    if numel(v)>1; sd(t)=std(v); end
end
end

%% ---------------------------------------------------------
function banda(x,mu,sd,col)
if isempty(mu); return; end
xf=[x fliplr(x)]; yf=[(mu+sd)' fliplr((mu-sd)')]; yf(~isfinite(yf))=NaN;
fill(xf,yf,col,'FaceAlpha',0.13,'EdgeColor','none','HandleVisibility','off');
end

function P = pack(x,mu,sd,n); P.x=x; P.media=mu; P.sd=sd; P.n=n; end

function m = riga_nanmean(A)
m=nan(size(A,1),1);
for i=1:size(A,1); v=A(i,:); v=v(isfinite(v)); if ~isempty(v); m(i)=mean(v); end; end
end