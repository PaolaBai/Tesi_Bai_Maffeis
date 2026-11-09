function OUT = grafico_accdec_grasp(cartella_excel, indice, out_dir)
%GRAFICO_ACCDEC_GRASP  Per il GRASP e un INDICE (tipicamente FWHM), confronta le
%  fasi di accelerazione, decelerazione e totale. Un grafico per ogni sottogruppo
%  muscolare, separato in andata e ritorno. Mostra Sani/T0/T1 con asterischi di
%  significativita' (t-test dal file Grasp_tab.xlsx).
%
%  USO
%    grafico_accdec_grasp(cartella_excel, 'FWHM', out_dir)
%
%  Serve leggi_media_sd.m e leggi_ttest.m nel path.

if ~exist(out_dir,'dir'); mkdir(out_dir); end
COL = [0.20 0.60 0.85; 0.85 0.30 0.30; 0.50 0.20 0.60];   % Sani, T0, T1
SG   = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
SGEST= {'Globale','Tronco','Braccio completo','Spalla','Braccio','Avambraccio','Spalla e braccio'};
pct = {'TMCi','Rud','FW','FWHM','CoA','Kel','Unn'};
if any(strcmpi(indice,pct)); ylab=[indice ' %']; else; ylab=indice; end

% le due direzioni, ciascuna con le 3 fasi (etichetta x, suffisso fase nel file)
DIR = {'andata', {'acc_andata','dec_andata','tot_andata'},  {'Accelerazione','Decelerazione','Totale'}; ...
       'ritorno',{'acc_ritorno','dec_ritorno','tot_ritorno'},{'Accelerazione','Decelerazione','Totale'}};

% carico una volta il file Grasp
RAW = carica_excel(cartella_excel, 'Grasp');
if isempty(RAW); error('grafico_accdec_grasp:file','Grasp_tab.xlsx non trovato in %s', cartella_excel); end

OUT=struct(); OUT.files={};
for g = 1:numel(SG)
    SGn = SG{g};
    for d = 1:size(DIR,1)
        dirn = DIR{d,1}; fasi = DIR{d,2}; etich = DIR{d,3};
        nF = numel(fasi);
        MU=nan(nF,3); SD=nan(nF,3); SIG=false(nF,3);
        for f = 1:nF
            nome_ex = sprintf('%s_%s_%s', indice, SGn, fasi{f});
            [mu,sd] = leggi_media_sd(RAW, nome_ex);
            MU(f,:)=mu; SD(f,:)=sd;
            SIG(f,:)=leggi_ttest(RAW, nome_ex);
        end
        if all(isnan(MU(:))); continue; end
        % disegno
        fig=figure('Color','w','Position',[80 80 650 500],'Visible','off');
        ax=axes(fig); set(ax,'Color','w'); hold(ax,'on');
        hb=bar(ax, MU, 'grouped','EdgeColor','none');
        for i=1:3; try; hb(i).FaceColor=COL(i,:); catch; end; end
        ng=nF; nb=3; gw=min(0.8,nb/(nb+1.5)); xc=nan(nF,3);
        for i=1:nb
            xc(:,i)=(1:ng)-gw/2+(2*i-1)*gw/(2*nb);
            errorbar(ax,xc(:,i),MU(:,i),SD(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4,'HandleVisibility','off');
        end
        set(ax,'XTick',1:nF,'XTickLabel',etich,'TickLabelInterpreter','none');
        ylabel(ax,ylab);
        title(ax, sprintf('%s — Grasp / %s / %s', indice, SGEST{g}, dirn), 'FontWeight','bold','Interpreter','none');
        legend(ax, hb, {'Sani','T0','T1'}, 'Location','northeast');
        box(ax,'off'); grid(ax,'on');
        % barrette significativita'
        ymax=max(MU(:)+SD(:),[],'omitnan'); if isnan(ymax)||ymax<=0; ymax=1; end
        passo=0.06*ymax; coppie=[1 2;1 3;2 3];
        for f=1:nF
            top=max(MU(f,:)+SD(f,:),[],'omitnan'); if isnan(top); top=0; end
            liv=0;
            for cc=1:3
                if SIG(f,cc)
                    liv=liv+1; y=top+liv*passo; x1=xc(f,coppie(cc,1)); x2=xc(f,coppie(cc,2));
                    plot(ax,[x1 x1 x2 x2],[y-0.15*passo y y y-0.15*passo],'k','LineWidth',1,'HandleVisibility','off');
                    text(ax,(x1+x2)/2,y+0.02*ymax,'*','HorizontalAlignment','center','FontSize',14,'FontWeight','bold');
                end
            end
        end
        ylim(ax,[0, ymax*1.35]);
        fname=fullfile(out_dir, sprintf('%s_Grasp_%s_%s.png', indice, SGn, dirn));
        try; exportgraphics(fig,fname,'Resolution',150); catch; saveas(fig,fname); end
        close(fig); OUT.files{end+1}=fname; %#ok<AGROW>
    end
end
fprintf('[grafico_accdec_grasp] %s: salvati %d grafici (sottogruppo x andata/ritorno) in %s\n', indice, numel(OUT.files), out_dir);
end

%% ---------------------------------------------------------
function RAW = carica_excel(cartella, mv)
RAW = {};
f = fullfile(cartella, [mv '_tab.xlsx']);
if ~exist(f,'file'); return; end
try; R=readcell(f); catch; [~,~,R]=xlsread(f); end
RAW = cellfun(@to_str2, R, 'UniformOutput', false);
end
function s = to_str2(v)
if isnumeric(v); if isscalar(v)&&~isnan(v); s=v; else; s=''; end; return; end
if ischar(v); s=v; return; end
if isstring(v); if ismissing(v); s=''; else; s=char(v); end; return; end
try; if all(ismissing(v)); s=''; return; end; catch; end
try; s=char(string(v)); catch; s=''; end
end
