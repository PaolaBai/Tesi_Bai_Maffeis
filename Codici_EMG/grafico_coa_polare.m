function OUT = grafico_coa_polare(DATA, mov, fase, sottogruppo, lato_paz)
%GRAFICO_COA_POLARE  CoA del TMCf in coordinate polari (stile Ranavolo/Fiori
%  2020, Fig. 2c): ogni pallino e' il CoA di un soggetto, la linea radiale e' il
%  CoA medio del gruppo, il settore circolare e' la SD angolare.
%  Tre gruppi (Sani, Pazienti T0, T1) sovrapposti in un unico grafico.
%
%  USO
%    grafico_coa_polare(DATA, 'Addu', 'R_Intero', 'Globale', lato_paz)

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

% Disegna lo sfondo fisso del grafico polare (cerchio e tacche 0-100%)
disegna_sfondo_polare(ax);

OUT = struct();
h_leg = [];
leg_labels = {};

% Raggi leggermente sfalsati per i pallini dei 3 gruppi (evita sovrapposizioni)
r_dots = [0.93, 0.87, 0.81]; 

for g = 1:3
    [coa_deg, mu_deg, sd_deg, n] = raccogli_coa(DATA, GRT{g}{1}, GRT{g}{2}, mov, fase, sottogruppo, lato_paz);
    
    % Disegna settore SD, linea media e pallini soggetti sul grafico unico
    h_line = disegna_gruppo_polare(ax, coa_deg, mu_deg, sd_deg, COL{g}, r_dots(g));
    
    % Memorizza la linea radiale per la legenda
    if ~isnan(mu_deg) && ~isempty(h_line)
        h_leg(end+1) = h_line; %#ok<AGROW>
        leg_labels{end+1} = sprintf('%s (n=%d) - Media: %.1f%%', TIT{g}, n, mu_deg/(2*pi)*100); %#ok<AGROW>
    end
    
    OUT.(matlab.lang.makeValidName(TIT{g})) = struct('coa_pct',coa_deg/(2*pi)*100, ...
        'media_pct',mu_deg/(2*pi)*100, 'sd_pct',sd_deg/(2*pi)*100, 'n',n);
end

% Aggiunge legenda in basso
if ~isempty(h_leg)
    legend(ax, h_leg, leg_labels, 'Location', 'southoutside', 'FontSize', 10, 'Box', 'off');
end

title(ax, sprintf('CoA — %s / %s / %s', mov, strrep(fase,'_','\_'), nome_display(sottogruppo)), ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
xlim(ax, [-1.3 1.3]); 
ylim(ax, [-1.4 1.3]);
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
function [coa_deg, mu_deg, sd_deg, n] = raccogli_coa(DATA, gruppo, tempo, mov, fase, SG, lato_paz)
coa_deg=[]; mu_deg=NaN; sd_deg=NaN; n=0;
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
ang=[];
for s=1:numel(sogg)
    Snm=sogg{s};
    fase_s=fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L')
        fase_s=regexprep(fase,'^R','L');
    end
    st=DATA.(gruppo).(Snm);
    if ~isfield(st,tempo) || ~isstruct(st.(tempo)) || ~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov);
    if ~isfield(M,SG) || ~isfield(M.(SG),'CoA'); continue; end
    lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fase_s),1);
    if isempty(ph) || ph>size(M.(SG).CoA,2); continue; end
    v=M.(SG).CoA(:,ph); v=v(isfinite(v));
    if isempty(v); continue; end
    coa_pct=mean(v);                          
    ang(end+1)=coa_pct/100*2*pi;              %#ok<AGROW>  
end
n=numel(ang); coa_deg=ang(:);
if n>=1
    C=mean(cos(ang)); S=mean(sin(ang));
    mu_deg=atan2(S,C); if mu_deg<0; mu_deg=mu_deg+2*pi; end
    R=sqrt(C^2+S^2);                          
    if R>0 && R<1; sd_deg=sqrt(-2*log(R)); else; sd_deg=0; end  
end
end

%% ---------------------------------------------------------
function disegna_sfondo_polare(ax)
% Disegna il cerchio e le tacche percentuali del quadrante
to_xy = @(th, r) deal( r.*sin(th), r.*cos(th) );

tt = linspace(0, 2*pi, 200); 
[cx, cy] = to_xy(tt, 1); 
plot(ax, cx, cy, 'k', 'LineWidth', 1);

for p = [0 25 50 75]
    th = p/100*2*pi; 
    [x1, y1] = to_xy(th, 0.97); 
    [x2, y2] = to_xy(th, 1.0);
    plot(ax, [x1 x2], [y1 y2], 'k'); 
    [tx, ty] = to_xy(th, 1.12);
    text(ax, tx, ty, sprintf('%d%%', p), 'HorizontalAlignment', 'center', 'FontSize', 9);
end
end

%% ---------------------------------------------------------
function h_line = disegna_gruppo_polare(ax, ang, mu, sd, col, r_dot)
% Disegna i dati di un singolo gruppo sovrapposto all'asse esistente
to_xy = @(th, r) deal( r.*sin(th), r.*cos(th) );

% Settore SD (trasparente per permettere la sovrapposizione visiva)
if ~isnan(sd) && sd > 0
    a1 = mu - sd; 
    a2 = mu + sd; 
    aa = linspace(a1, a2, 40);
    [sx, sy] = to_xy([mu aa mu], [0 ones(1, numel(aa)) 0] * 0.85);
    fill(ax, sx, sy, col, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
end

% Pallini dei soggetti (tracciati al raggio r_dot specificato)
for i = 1:numel(ang)
    [px, py] = to_xy(ang(i), r_dot);
    plot(ax, px, py, 'o', 'MarkerFaceColor', col, 'MarkerEdgeColor', 'w', 'MarkerSize', 6);
end

% Linea radiale della media
h_line = [];
if ~isnan(mu)
    [mx, my] = to_xy(mu, 0.85); 
    h_line = plot(ax, [0 mx], [0 my], 'Color', col, 'LineWidth', 2.5);
end
end