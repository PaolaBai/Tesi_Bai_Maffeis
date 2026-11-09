function OUT = grafico_fwhm_polare(DATA, mov, fase, sottogruppo, lato_paz)
%GRAFICO_FWHM_POLARE  FWHM del TMCf in coordinate polari (stile Ranavolo/Fiori
%  2020, Fig. 2b): la curva TMCf media del gruppo e' avvolta attorno al cerchio
%  (angolo = % del ciclo), e l'area colorata e' la porzione SOPRA la meta' del
%  massimo -> il FWHM visualizzato.
%  Tre gruppi (Sani, Pazienti T0, T1) sovrapposti in un unico grafico.
%
%  USO
%    grafico_fwhm_polare(DATA, 'Addu', 'R_Intero', 'Globale', lato_paz)

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end
COL = {[0.20 0.60 0.85], [0.85 0.30 0.30], [0.50 0.20 0.60]};   % Sani, T0, T1
TIT = {'Sani','Pazienti T0','Pazienti T1'};
GRT = {{'Sani','T'}, {'Patologici','T0'}, {'Patologici','T1'}};

% Figura singola con proporzioni quadrate
figure('Color','w','Position',[200 100 650 650]);
ax = gca;
hold(ax, 'on'); 
axis(ax, 'equal'); 
axis(ax, 'off');

% Disegna lo sfondo fisso (cerchio esterno, cerchio meta-massimo e tacche)
disegna_sfondo_fwhm_polare(ax);

OUT = struct();
h_leg = [];
leg_labels = {};

for g = 1:3
    [curva, n] = media_tmcf(DATA, GRT{g}{1}, GRT{g}{2}, mov, fase, sottogruppo, lato_paz);
    
    % Disegna la curva avvolta e l'area FWHM del gruppo
    [fw, h_line] = disegna_gruppo_fwhm_polare(ax, curva, COL{g});
    
    % Memorizza il handle della linea per la legenda
    if ~isnan(fw) && ~isempty(h_line)
        h_leg(end+1) = h_line; %#ok<AGROW>
        leg_labels{end+1} = sprintf('%s (n=%d) - FWHM: %.1f%%', TIT{g}, n, fw); %#ok<AGROW>
    end
    
    OUT.(matlab.lang.makeValidName(TIT{g})) = struct('curva',curva,'FWHM',fw,'n',n);
end

% Aggiunge legenda in basso
if ~isempty(h_leg)
    legend(ax, h_leg, leg_labels, 'Location', 'southoutside', 'FontSize', 10, 'Box', 'off');
end

title(ax, sprintf('FWHM — %s / %s / %s', mov, strrep(fase,'_','\_'), nome_display(sottogruppo)), ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
xlim(ax, [-1.3 1.3]); 
ylim(ax, [-1.35 1.3]);
end

%% ---------------------------------------------------------
function nm = nome_display(campo)
mappa = {'Globale','Globale'; 'Tronco','Tronco'; 'Braccio','Braccio completo';
         'Spalla','Spalla'; 'Gomito','Braccio'; 'Polso','Avambraccio';
         'SpallaGomito','Spalla e braccio'};
i = find(strcmp(mappa(:,1), campo), 1);
if isempty(i); nm = campo; else; nm = mappa{i,2}; end
end

%% ---------------------------------------------------------
function [curva, n] = media_tmcf(DATA, gruppo, tempo, mov, fase, SG, lato_paz)
curva=[]; n=0;
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
acc=[]; cnt=0;
for s=1:numel(sogg)
    Snm=sogg{s};
    fase_s=fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L')
        fase_s=regexprep(fase,'^R','L');
    end
    st=DATA.(gruppo).(Snm);
    if ~isfield(st,tempo) || ~isstruct(st.(tempo)) || ~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov);
    if ~isfield(M,SG) || ~isfield(M.(SG),'TMCf'); continue; end
    lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fase_s),1);
    if isempty(ph); continue; end
    A=M.(SG).TMCf(:,:,ph);                    
    if all(isnan(A(:))); continue; end
    ci=riga_nanmean(A);                       
    if isempty(acc); acc=zeros(numel(ci),1); end
    acc=acc+ci; cnt=cnt+1;
end
n=cnt;
if cnt>0; curva=acc/cnt; end
end

%% ---------------------------------------------------------
function disegna_sfondo_fwhm_polare(ax)
% Disegna le componenti fisse del grafico (cerchio esterno, tacche e cerchio di metà massimo)
to_xy = @(t,rr) deal(rr.*sin(t), rr.*cos(t));

% Cerchio esterno e tacche percentuali
tt = linspace(0, 2*pi, 200); 
[cx, cy] = to_xy(tt, 1); 
plot(ax, cx, cy, 'k', 'LineWidth', 1);

for p = [0 25 50 75]
    a = p/100*2*pi; 
    [x1, y1] = to_xy(a, 0.97); 
    [x2, y2] = to_xy(a, 1.0); 
    plot(ax, [x1 x2], [y1 y2], 'k');
    [tx, ty] = to_xy(a, 1.12); 
    text(ax, tx, ty, sprintf('%d%%', p), 'HorizontalAlignment', 'center', 'FontSize', 9);
end

% Cerchio di riferimento a metà-massimo (r_half)
r_half = 0.15 + 0.85*0.5;
[hx, hy] = to_xy(tt, r_half); 
plot(ax, hx, hy, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1);
end

%% ---------------------------------------------------------
function [fw, h_line] = disegna_gruppo_fwhm_polare(ax, curva, col)
fw = NaN; 
h_line = [];
if isempty(curva); return; end

T = numel(curva); 
th = (0:T-1)'/T*2*pi;           
mx = max(curva); 
if mx <= 0; return; end

% Raggio normalizzato [0.15 .. 1.0]
r = 0.15 + 0.85*(curva/mx);
to_xy = @(t,rr) deal(rr.*sin(t), rr.*cos(t));

r_half = 0.15 + 0.85*0.5;
sopra = curva >= mx/2;

% Area FWHM (con trasparenza per consentire la sovrapposizione visiva)
[segs] = tratti_contigui(sopra);
for k = 1:size(segs,1)
    idx = segs(k,1):segs(k,2);
    ai = th(idx); 
    ri = r(idx);
    [ox, oy] = to_xy(ai, ri);                     
    [ix, iy] = to_xy(flipud(ai), r_half*ones(numel(ai),1)); 
    fill(ax, [ox; ix], [oy; iy], col, 'FaceAlpha', 0.20, 'EdgeColor', 'none');
end

% Curva TMCf avvolta
[gx, gy] = to_xy([th; th(1)], [r; r(1)]); 
h_line = plot(ax, gx, gy, 'Color', col, 'LineWidth', 2);

fw = 100*sum(sopra)/T;                          
end

%% ---------------------------------------------------------
function segs = tratti_contigui(mask)
mask = mask(:)'; 
T = numel(mask);
d = diff([mask(end) mask]);                       
inizi = find(d==1); 
fini = find(d==-1)-1;

if isempty(inizi) && any(mask); segs=[1 T]; return; end
if numel(fini)<numel(inizi); fini=[fini T]; end
if numel(inizi)<numel(fini); inizi=[1 inizi]; end
segs = [inizi(:) fini(:)];
segs = segs(segs(:,1)<=segs(:,2),:);
if isempty(segs) && any(mask); segs=[find(mask,1) find(mask,1,'last')]; end
end

%% ---------------------------------------------------------
function m = riga_nanmean(A)
m = nan(size(A,1),1);
for i = 1:size(A,1)
    v = A(i,:); 
    v = v(isfinite(v)); 
    if ~isempty(v); m(i) = mean(v); end
end
end