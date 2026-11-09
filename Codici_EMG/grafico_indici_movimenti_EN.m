function OUT = grafico_indici_movimenti_EN(DATA, cartella_excel, indice, out_dir, lato_paz)
%GRAFICO_INDICI_MOVIMENTI  Per un INDICE di co-contrazione, grafici a barre
%  (Sani, T0, T1) con i 7 MOVIMENTI sull'asse x. Un grafico per ogni
%  SOTTOGRUPPO e per ciascuna delle due fasi (andata / ritorno).
%  I grafici andata e ritorno dello stesso sottogruppo condividono la scala Y.
%
%  USO
%    grafico_indici_movimenti(DATA, cartella_excel, 'TMCi', out_dir, lato_paz)
%
%  indice: 'TMCi'|'Rud'|'FW'|'FWHM'|'CoA'. Valori dal DATA; significativita' dai
%  file <mov>_tab.xlsx. Asse y in % per gli indici percentuali.
%
%  Mappatura fasi per movimento:
%    normali  andata=R_Salita       ritorno=R_Discesa
%    Circ     andata=R<dir>_Salita  ritorno=R<dir>_Discesa
%    Reach    andata=RAndata_Intero ritorno=RRitorno_Intero
%    Grasp    andata=GAndata_Intero ritorno=GRitorno_Intero

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end
if ~exist(out_dir,'dir'); mkdir(out_dir); end
COL = [0.20 0.60 0.85; 0.85 0.30 0.30; 0.50 0.20 0.60];
SG_LIST = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};

% etichetta y
pct={'TMCi','Rud','FW','FWHM','CoA','Kel','Unn'};
if any(strcmpi(indice,pct)); ylab=[indice ' %']; else; ylab=indice; end

% 7 movimenti: {etichetta-x, file-excel, mov_data, fase-andata-DATA, fase-ritorno-DATA, fase-excel-andata, fase-excel-ritorno}
% {etichetta-x, nome-file-excel, mov_data(non piu' usato), fase_DATA_and, fase_DATA_rit, fase_excel_and, fase_excel_rit}
MOV = {
 'Addu',             'Adduzione',             'Addu',      'R_Salita',       'R_Discesa',       'Andata','Ritorno'
 'Horiz Addu',       'Adduzione_orizzontale', 'Addu_orizz','R_Salita',       'R_Discesa',       'Andata','Ritorno'
 'Flex',             'Flessione',             'Flex',      'R_Salita',       'R_Discesa',       'Andata','Ritorno'
 'Circ FWD',         'Circ_Avanti',           'Circ',      'RAvanti_Salita', 'RAvanti_Discesa', 'Andata','Ritorno'
 'Circ BWD',         'Circ_Indietro',         'Circ',      'RIndietro_Salita','RIndietro_Discesa','Andata','Ritorno'
 'Reach',            'Reach',                 'RandG',     'RAndata_Intero', 'RRitorno_Intero', 'tot_andata','tot_ritorno'
 'Grasp',            'Grasp',                 'RandG',     'GAndata_Intero', 'GRitorno_Intero', 'tot_andata','tot_ritorno'
};
nMov=size(MOV,1);
TR = {'andata','ritorno'}; TR_EN = {'Outward','Return'};

OUT=struct(); OUT.files={};
for g=1:numel(SG_LIST)
    SG=SG_LIST{g};
    % calcolo mean/SD per andata e ritorno (per scala comune)
    MU=cell(1,2); SD=cell(1,2); SIG=cell(1,2); ymax_g=0;
    for tr=1:2
        MUt=nan(nMov,3); SDt=nan(nMov,3); SIGt=false(nMov,3);
        for k=1:nMov
            if tr==1; fase_ex=MOV{k,6}; else; fase_ex=MOV{k,7}; end
            nome_ex = sprintf('%s_%s_%s', indice, SG, fase_ex);
            RAW = carica_excel(cartella_excel, MOV{k,2});   % media/SD + sig dal file (outlier gia' rimossi)
            if ~isempty(RAW)
                [m3,s3] = leggi_media_sd(RAW, nome_ex);
                MUt(k,:)=m3; SDt(k,:)=s3;
                SIGt(k,:)=leggi_ttest(RAW, nome_ex);
            end
        end
        MU{tr}=MUt; SD{tr}=SDt; SIG{tr}=SIGt;
        m=max(MUt(:)+SDt(:),[],'omitnan'); if ~isnan(m); ymax_g=max(ymax_g,m); end
    end
    if ymax_g<=0; ymax_g=1; end
    YL=[0, ymax_g*1.35];   % scala comune andata/ritorno
    % disegno i due grafici
    for tr=1:2
        fig=figure('Color','w','Position',[70 70 1000 520],'Visible','off');
        ax=axes(fig); set(ax,'Color','w'); hold(ax,'on');
        MUt=MU{tr}; SDt=SD{tr}; SIGt=SIG{tr};
        hb=bar(ax,MUt,'grouped','EdgeColor','none');
        for i=1:3; try; hb(i).FaceColor=COL(i,:); catch; end; end
        ng=nMov; nb=3; gw=min(0.8,nb/(nb+1.5)); xc=nan(nMov,3);
        for i=1:nb
            xc(:,i)=(1:ng)-gw/2+(2*i-1)*gw/(2*nb);
            errorbar(ax,xc(:,i),MUt(:,i),SDt(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4,'HandleVisibility','off');
        end
        set(ax,'XTick',1:nMov,'XTickLabel',MOV(:,1),'TickLabelInterpreter','none','FontWeight','bold'); xtickangle(ax,20);
        ylabel(ax,ylab,'FontWeight','bold');
        title(ax, sprintf('%s - %s / %s', indice, nome_display_EN(SG), TR_EN{tr}), 'FontWeight','bold','Interpreter','none');
        lg=legend(ax, hb, {'Healthy','T0','T1'}, 'Location','northeast'); set(lg,'FontWeight','bold');
        box(ax,'off'); grid(ax,'on');
        passo=0.05*ymax_g; coppie=[1 2;1 3;2 3];
        for k=1:nMov
            top=max(MUt(k,:)+SDt(k,:),[],'omitnan'); if isnan(top); top=0; end
            liv=0;
            for cc=1:3
                if SIGt(k,cc)
                    liv=liv+1; y=top+liv*passo; x1=xc(k,coppie(cc,1)); x2=xc(k,coppie(cc,2));
                    plot(ax,[x1 x1 x2 x2],[y-0.15*passo y y y-0.15*passo],'k','LineWidth',1,'HandleVisibility','off');
                    text(ax,(x1+x2)/2,y+0.015*ymax_g,'*','HorizontalAlignment','center','FontSize',14,'FontWeight','bold');
                end
            end
        end
        ylim(ax,YL);
        fname=fullfile(out_dir, sprintf('%s_%s_%s.png', indice, SG, TR{tr}));
        try; exportgraphics(fig,fname,'Resolution',150); catch; saveas(fig,fname); end
        close(fig); OUT.files{end+1}=fname; %#ok<AGROW>
    end
end
fprintf('[grafico_indici_movimenti_EN] %s: salvati %d grafici (sottogruppo x andata/ritorno) in %s\n', indice, numel(OUT.files), out_dir);
end

%% ---------------------------------------------------------
function nm = nome_display_EN(campo)
mappa = {'Globale','Global'; 'Tronco','Trunk'; 'Braccio','Complete arm';
         'Spalla','Shoulder'; 'Gomito','Arm'; 'Polso','Forearm';
         'SpallaGomito','Shoulder and arm'};
i = find(strcmp(mappa(:,1), campo), 1);
if isempty(i); nm = campo; else; nm = mappa{i,2}; end
end

function RAW = carica_excel(cartella, mv)
% apre <mv>_tab.xlsx (formato JASP). Caching.
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
% tiene i numeri (per media/SD), converte missing/string.
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
