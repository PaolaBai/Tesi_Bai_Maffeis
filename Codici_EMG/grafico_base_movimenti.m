function OUT = grafico_base_movimenti(DATA, cartella_excel, tipo, out_dir, lato_paz, RG)
%GRAFICO_BASE_MOVIMENTI  Per ogni muscolo, grafico a barre (Sani, T0, T1) del
%  valore base (ampMax o media) con i 7 MOVIMENTI sull'asse x. Un grafico per
%  muscolo (cicla su tutti gli 8), salvato in out_dir.
%
%  USO
%    RG = base_reach_grasp(DATA);
%    grafico_base_movimenti(DATA, cartella_excel, 'ampMax', out_dir, lato_paz, RG)
%    grafico_base_movimenti(DATA, cartella_excel, 'media',  out_dir, lato_paz, RG)
%
%  tipo: 'ampMax' | 'media'. RG: output di base_reach_grasp (per Reach e Grasp).
%  Valori dal DATA; significativita' dai file <mov>_tab.xlsx (Reach_tab/Grasp_tab
%  per i due segmenti del RandG). Asse y in microV. Titolo esteso, legenda inclusa.

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end
if nargin < 6; RG = []; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end
COL = [0.20 0.60 0.85; 0.85 0.30 0.30; 0.50 0.20 0.60];   % Sani, T0, T1

MUS   = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};
MUSEST= {'Erettore Spinale','Bicipite Brachiale','Flessore Radiale del Carpo', ...
         'Deltoide Anteriore','Retto Addominale','Tricipite Brachiale', ...
         'Estensore Radiale del Carpo','Deltoide Posteriore'};
% movimenti sull'asse x: {codice, etichetta-x, nome-file-excel (senza _tab.xlsx)}
MOV = {'Addu','Adduzione','Adduzione'; ...
       'Addu_orizz','Adduzione orizz.','Adduzione_orizzontale'; ...
       'Flex','Flessione','Flessione'; ...
       'Circ_Avanti','Circ. avanti','Circ_Avanti'; ...
       'Circ_Indietro','Circ. indietro','Circ_Indietro'; ...
       'Reach','Reach','Reach'; ...
       'Grasp','Grasp','Grasp'};
nMov = size(MOV,1);

if strcmpi(tipo,'media'); campo='media_uV'; pre='media'; ylab='Media [\muV]'; ttlpre='Media del muscolo';
else;                     campo='amp_max_uV'; pre='ampMax'; ylab='Ampiezza massima [\muV]'; ttlpre='Ampiezza massima del muscolo'; end

OUT=struct(); OUT.files={};
for mi = 1:numel(MUS)
    MU=nan(nMov,3); SD=nan(nMov,3); SIG=false(nMov,3);
    for k = 1:nMov
        file_mov = MOV{k,3};        % nome-file reale del movimento
        nome_ex = sprintf('%s_%s', pre, MUS{mi});
        % media e SD lette dal file Excel (outlier gia' rimossi in JASP):
        RAW = carica_excel(cartella_excel, file_mov);
        if ~isempty(RAW)
            [m3,s3] = leggi_media_sd(RAW, nome_ex);
            MU(k,:) = m3; SD(k,:) = s3;
            SIG(k,:) = leggi_ttest(RAW, nome_ex);
        end
    end
    % --- disegno ---
    fig=figure('Color','w','Position',[70 70 1000 520],'Visible','off');
    ax=axes(fig); set(ax,'Color','w'); hold(ax,'on');
    hb=bar(ax, MU, 'grouped','EdgeColor','none');
    for i=1:3; try; hb(i).FaceColor=COL(i,:); catch; end; end
    ng=nMov; nb=3; gw=min(0.8,nb/(nb+1.5)); xc=nan(nMov,3);
    for i=1:nb
        xc(:,i)=(1:ng)-gw/2+(2*i-1)*gw/(2*nb);
        errorbar(ax,xc(:,i),MU(:,i),SD(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4,'HandleVisibility','off');
    end
    set(ax,'XTick',1:nMov,'XTickLabel',MOV(:,2),'TickLabelInterpreter','none'); xtickangle(ax,20);
    ylabel(ax,ylab);
    title(ax, sprintf('%s %s', ttlpre, MUSEST{mi}), 'FontWeight','bold');
    legend(ax, hb, {'Sani','T0','T1'}, 'Location','northeast');
    box(ax,'off'); grid(ax,'on');
    % barrette significativita'
    ymax=max(MU(:)+SD(:),[],'omitnan'); if isnan(ymax)||ymax<=0; ymax=1; end
    passo=0.06*ymax; coppie=[1 2;1 3;2 3];
    for k=1:nMov
        top=max(MU(k,:)+SD(k,:),[],'omitnan'); if isnan(top); top=0; end
        liv=0;
        for cc=1:3
            if SIG(k,cc)
                liv=liv+1; y=top+liv*passo; x1=xc(k,coppie(cc,1)); x2=xc(k,coppie(cc,2));
                plot(ax,[x1 x1 x2 x2],[y-0.15*passo y y y-0.15*passo],'k','LineWidth',1,'HandleVisibility','off');
                text(ax,(x1+x2)/2,y+0.02*ymax,'*','HorizontalAlignment','center','FontSize',14,'FontWeight','bold');
            end
        end
    end
    ylim(ax,[0, ymax*1.35]);
    fname=fullfile(out_dir, sprintf('%s_%s.png', pre, MUS{mi}));
    try; exportgraphics(fig,fname,'Resolution',150); catch; saveas(fig,fname); end
    close(fig); OUT.files{end+1}=fname; %#ok<AGROW>
end
fprintf('[grafico_base_movimenti] %s: salvati %d grafici (un muscolo ciascuno) in %s\n', tipo, numel(OUT.files), out_dir);
end

%% ---------------------------------------------------------
function RAW = carica_excel(cartella, mv)
% apre <mv>_tab.xlsx e lo restituisce come cell di stringhe/numeri. Caching.
persistent CF CR
RAW = {};
f = fullfile(cartella, [mv '_tab.xlsx']);
if isempty(CF) || ~strcmp(CF,f)
    if ~exist(f,'file'); CF=''; return; end
    try; R=readcell(f); catch; [~,~,R]=xlsread(f); end
    CR = cellfun(@to_str2, R, 'UniformOutput', false); CF=f;
end
RAW = CR;
end

function s = to_str2(v)
% come to_str ma TIENE i numeri (per media/SD); converte solo missing/string.
if isnumeric(v); if isscalar(v)&&~isnan(v); s=v; else; s=''; end; return; end
if ischar(v); s=v; return; end
if isstring(v); if ismissing(v); s=''; else; s=char(v); end; return; end
try; if all(ismissing(v)); s=''; return; end; catch; end
try; s=char(string(v)); catch; s=''; end
end

function s = to_str(v)
try
    if ischar(v); s=v; return; end
    if isstring(v); if ismissing(v); s=''; else; s=char(v); end; return; end
    if isnumeric(v); if isscalar(v)&&~isnan(v); s=num2str(v); else; s=''; end; return; end
    if iscell(v); if isempty(v); s=''; else; s=to_str(v{1}); end; return; end
    if all(ismissing(v)); s=''; return; end
    s=char(string(v));
catch; s=''; end
end
