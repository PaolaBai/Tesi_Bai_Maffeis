function OUT = grafico_vaf(cartella_excel, out_dir)
%GRAFICO_VAF  Grafico a barre (Sani, T0, T1) del VAF con i 7 MOVIMENTI sull'asse x.
%  Il VAF e' un valore unico per movimento (non per sottogruppo/fase), quindi un
%  solo grafico. Valori e significativita' letti dai file <mov>_tab.xlsx.
%
%  USO
%    grafico_vaf('C:\...\Tabelle', 'C:\...\Figure')
%
%  Serve leggi_media_sd.m e leggi_ttest.m nel path.

if ~exist(out_dir,'dir'); mkdir(out_dir); end
COL = [0.20 0.60 0.85; 0.85 0.30 0.30; 0.50 0.20 0.60];   % Sani, T0, T1

% 7 movimenti: {etichetta-x, nome-file}
MOV = {'Adduzione','Adduzione'; 'Adduzione orizz.','Adduzione_orizzontale'; ...
       'Flessione','Flessione'; 'Circ. avanti','Circ_Avanti'; ...
       'Circ. indietro','Circ_Indietro'; 'Reach','Reach'; 'Grasp','Grasp'};
nMov = size(MOV,1);

MU=nan(nMov,3); SD=nan(nMov,3); SIG=false(nMov,3);
for k=1:nMov
    RAW = carica_excel(cartella_excel, MOV{k,2});
    if isempty(RAW); continue; end
    [m3,s3] = leggi_media_sd(RAW, 'VAF');
    MU(k,:)=m3; SD(k,:)=s3;
    SIG(k,:)=leggi_ttest(RAW, 'VAF');
end

fig=figure('Color','w','Position',[70 70 1000 520],'Visible','off');
ax=axes(fig); set(ax,'Color','w'); hold(ax,'on');
hb=bar(ax, MU, 'grouped','EdgeColor','none');
for i=1:3; try; hb(i).FaceColor=COL(i,:); catch; end; end
ng=nMov; nb=3; gw=min(0.8,nb/(nb+1.5)); xc=nan(nMov,3);
for i=1:nb
    xc(:,i)=(1:ng)-gw/2+(2*i-1)*gw/(2*nb);
    errorbar(ax,xc(:,i),MU(:,i),SD(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4,'HandleVisibility','off');
end
set(ax,'XTick',1:nMov,'XTickLabel',MOV(:,1),'TickLabelInterpreter','none'); xtickangle(ax,20);
ylabel(ax,'VAF');
title(ax, 'VAF — Varianza spiegata dalle sinergie', 'FontWeight','bold');
legend(ax, hb, {'Sani','T0','T1'}, 'Location','northeastoutside');
box(ax,'off'); grid(ax,'on');
% barrette significativita'
ymax=max(MU(:)+SD(:),[],'omitnan'); if isnan(ymax)||ymax<=0; ymax=1; end
passo=0.05*ymax; coppie=[1 2;1 3;2 3];
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
ylim(ax,[0, min(1, ymax*1.35)]);   % VAF tra 0 e 1

fname=fullfile(out_dir,'VAF.png');
try; exportgraphics(fig,fname,'Resolution',150); catch; saveas(fig,fname); end
close(fig);
fprintf('[grafico_vaf] salvato: %s\n', fname);
OUT.file=fname; OUT.mean=MU; OUT.sd=SD; OUT.sig=SIG;
end

%% ---------------------------------------------------------
function RAW = carica_excel(cartella, mv)
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
if isnumeric(v); if isscalar(v)&&~isnan(v); s=v; else; s=''; end; return; end
if ischar(v); s=v; return; end
if isstring(v); if ismissing(v); s=''; else; s=char(v); end; return; end
try; if all(ismissing(v)); s=''; return; end; catch; end
try; s=char(string(v)); catch; s=''; end
end
