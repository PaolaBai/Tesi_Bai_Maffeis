function OUT = grafico_confronti(DATA, cartella_excel, indice, movimento, out_dir, lato_paz)
%GRAFICO_CONFRONTI  Per un INDICE e un MOVIMENTO, genera i grafici a barre
%  (Sani, T0, T1) per TUTTI i 7 sottogruppi muscolari e li salva in out_dir.
%  I grafici dello stesso indice condividono la stessa scala Y (confrontabili
%  a vista). Asse Y in % per gli indici percentuali (TMCi, Rud, FW, FWHM, CoA).
%
%  USO
%    grafico_confronti(DATA, cartella_excel, 'TMCi', 'Addu', out_dir, lato_paz)
%    grafico_confronti(DATA, cartella_excel, 'CoA', 'RandG_R', out_dir, lato_paz)
%
%  - mean/SD dal DATA; significativita' dal file <movimento>_tab.xlsx.
%  - un file per sottogruppo: <movimento>_<indice>_<sottogruppo>.png

if nargin < 6 || isempty(lato_paz); lato_paz = struct(); end
if nargin < 5 || isempty(out_dir); out_dir = pwd; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end
COL = [0.20 0.60 0.85; 0.85 0.30 0.30; 0.50 0.20 0.60];   % Sani, T0, T1
SG_LIST = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};

% etichetta Y: % per gli indici percentuali
pct = {'TMCi','Rud','FW','FWHM','CoA'};
if any(strcmpi(indice, pct)); ylab = [indice ' %']; else; ylab = indice; end

[fasi_lab, fasi_sfx, mov_data, pref] = fasi_di(movimento);
nF = numel(fasi_lab);

% --- PRIMO GIRO: calcolo mean/SD di tutti i sottogruppi per trovare la scala comune ---
nSG = numel(SG_LIST);
MUall = cell(1,nSG); SDall = cell(1,nSG); SIGall = cell(1,nSG);
ymax_glob = 0;
for g = 1:nSG
    MU = nan(nF,3); SD = nan(nF,3);
    for f = 1:nF
        fase_R = costruisci_fase(pref, fasi_sfx{f}, movimento);
        [MU(f,1),SD(f,1)] = media_gruppo(DATA,'Sani','T',        mov_data,fase_R,SG_LIST{g},indice,lato_paz);
        [MU(f,2),SD(f,2)] = media_gruppo(DATA,'Patologici','T0', mov_data,fase_R,SG_LIST{g},indice,lato_paz);
        [MU(f,3),SD(f,3)] = media_gruppo(DATA,'Patologici','T1', mov_data,fase_R,SG_LIST{g},indice,lato_paz);
    end
    MUall{g}=MU; SDall{g}=SD;
    SIGall{g}=leggi_significativita(cartella_excel, movimento, indice, SG_LIST{g}, fasi_lab);
    m = max(MU(:)+SD(:),[],'omitnan'); if ~isnan(m); ymax_glob = max(ymax_glob, m); end
end
if ymax_glob<=0; ymax_glob=1; end
YL = [0, ymax_glob*1.35];          % scala Y comune a tutti i sottogruppi

% --- SECONDO GIRO: disegno e salvo ogni sottogruppo con la scala comune ---
OUT = struct(); OUT.files = {};
for g = 1:nSG
    SG = SG_LIST{g}; MU=MUall{g}; SD=SDall{g}; SIG=SIGall{g};
    fig=figure('Color','w','Position',[70 70 max(200*nF,600) 500],'Visible','off');
    ax=axes(fig); set(ax,'Color','w','XColor',[0.15 0.15 0.15],'YColor',[0.15 0.15 0.15]); hold(ax,'on');
    hb=bar(ax, MU, 'grouped','EdgeColor','none');
    for i=1:3; try; hb(i).FaceColor=COL(i,:); catch; set(hb(i),'FaceColor','flat'); end; end
    ngroups=nF; nbars=3; gw=min(0.8,nbars/(nbars+1.5)); xc=nan(nF,3);
    for i=1:nbars
        xc(:,i)=(1:ngroups) - gw/2 + (2*i-1)*gw/(2*nbars);
        errorbar(ax,xc(:,i), MU(:,i), SD(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4);
    end
    set(ax,'XTick',1:nF,'XTickLabel',fasi_lab); xtickangle(ax,15); set(ax,'TickLabelInterpreter','none');
    ylabel(ax,ylab);
    title(ax, sprintf('%s — %s / %s', indice, nome_mov_display(movimento), nome_display(SG)), 'FontWeight','bold', 'Interpreter','none');
    box(ax,'off'); grid(ax,'on');
    % barrette di significativita', posizionate rispetto alla scala comune
    passo = 0.05*ymax_glob; coppie=[1 2; 1 3; 2 3];
    for f=1:nF
        top_f = max(MU(f,:)+SD(f,:),[],'omitnan'); if isnan(top_f); top_f=0; end
        liv=0;
        for cc=1:3
            if SIG(f,cc)
                liv=liv+1; y=top_f+liv*passo;
                x1=xc(f,coppie(cc,1)); x2=xc(f,coppie(cc,2));
                plot(ax,[x1 x1 x2 x2],[y-0.15*passo y y y-0.15*passo],'k','LineWidth',1);
                text(ax,(x1+x2)/2, y+0.015*ymax_glob, '*','HorizontalAlignment','center','FontSize',14,'FontWeight','bold');
            end
        end
    end
    ylim(ax, YL);
    % salva
    fname = fullfile(out_dir, sprintf('%s_%s_%s.png', movimento, indice, SG));
    try; exportgraphics(fig, fname, 'Resolution',150); catch; saveas(fig,fname); end
    close(fig);
    OUT.files{end+1} = fname;
end
fprintf('[grafico_confronti] %s / %s: salvati %d grafici in %s (scala Y comune [0 %.2f])\n', ...
    indice, movimento, nSG, out_dir, YL(2));
OUT.indice=indice; OUT.movimento=movimento; OUT.ylim=YL;
end

%% ---------------------------------------------------------
function [lab, sfx, mov_data, pref] = fasi_di(movimento)
if strncmp(movimento,'RandG_',6)
    seg=movimento(7); mov_data='RandG'; pref='';
    lab={'acc_andata','dec_andata','tot_andata','acc_ritorno','dec_ritorno','tot_ritorno'};
    sfx={[seg 'Andata_Salita'],[seg 'Andata_Discesa'],[seg 'Andata_Intero'], ...
         [seg 'Ritorno_Salita'],[seg 'Ritorno_Discesa'],[seg 'Ritorno_Intero']};
elseif strncmp(movimento,'Circ_',5)
    dir=movimento(6:end); mov_data='Circ'; pref='R';
    lab={'Andata','Ritorno','Totale'};
    sfx={[dir '_Salita'],[dir '_Discesa'],[dir '_Intero']};
else
    mov_data=movimento; pref='R';
    lab={'Andata','Ritorno','Totale'};
    sfx={'_Salita','_Discesa','_Intero'};
end
end

function fase = costruisci_fase(pref, sfx, movimento)
if strncmp(movimento,'RandG_',6); fase=sfx;
else; fase=[pref sfx]; end
end

%% ---------------------------------------------------------
function [mu,sd] = media_gruppo(DATA, gruppo, tempo, mov, fase, SG, indice, lato_paz)
mu=NaN; sd=NaN;
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
vals=[];
for s=1:numel(sogg)
    Snm=sogg{s}; fase_s=fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L')
        fase_s=regexprep(fase,'^R','L');
    end
    st=DATA.(gruppo).(Snm);
    if ~isfield(st,tempo); continue; end
    v=valore_medio(st.(tempo), mov, fase_s, SG, indice);
    if ~isnan(v); vals(end+1)=v; end %#ok<AGROW>
end
if ~isempty(vals)
    vv=vals(isfinite(vals));
    if ~isempty(vv); mu=mean(vv); end
    if numel(vv)>1; sd=std(vv); end
end
end

function v = valore_medio(TPstruct, mov, fase, SG, indice)
v=NaN;
if ~isstruct(TPstruct) || ~isfield(TPstruct,mov); return; end
M=TPstruct.(mov);
if ~isfield(M,SG) || ~isfield(M.(SG),indice); return; end
lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fase),1);
if isempty(ph); return; end
col=M.(SG).(indice); if ph>size(col,2); return; end
x=double(col(:,ph)); x=x(isfinite(x));
if ~isempty(x); v=mean(x); end
end

%% ---------------------------------------------------------
function SIG = leggi_significativita(cartella, movimento, indice, SG, fasi_lab)
nF=numel(fasi_lab); SIG=false(nF,3);
f=fullfile(cartella,[movimento '_tab.xlsx']);
persistent CACHE_F CACHE_R
if isempty(CACHE_F) || ~strcmp(CACHE_F,f)
    if ~exist(f,'file'); warning('File %s non trovato.', f); CACHE_F=''; return; end
    try; RAW=readcell(f); catch; [~,~,RAW]=xlsread(f); end
    CACHE_R=cellfun(@to_str,RAW,'UniformOutput',false); CACHE_F=f;
end
RAW=CACHE_R; [nr,nc]=size(RAW);
conf_ord={'Sani vs T0','Sani vs T1','T0 vs T1'}; crow=nan(1,3);
for r=1:nr; for c=1:nc; for k=1:3
    if strcmp(RAW{r,c},conf_ord{k}); crow(k)=r; end
end; end; end
for k=1:3
    if isnan(crow(k)); continue; end
    r0=crow(k); r1=nr; oth=crow(crow>r0); if ~isempty(oth); r1=min(oth)-1; end
    for fi=1:nF
        tgt=sprintf('%s_%s_%s', indice, SG, fasi_lab{fi});
        for r=r0:r1; for c=1:nc
            base=regexprep(RAW{r,c},'_(T0|T1)$','');
            if strcmp(base,tgt)
                if (c+2<=nc && contains(RAW{r,c+2},'*')) || (c+3<=nc && contains(RAW{r,c+3},'*'))
                    SIG(fi,k)=true;
                end
            end
        end; end
    end
end
end

%% ---------------------------------------------------------
function nm = nome_mov_display(movimento)
switch movimento
    case 'Flex'; nm='Flessione';
    case 'Addu'; nm='Adduzione';
    case 'Addu_orizz'; nm='Adduzione orizzontale';
    case 'Circ_Avanti'; nm='Circonduzione avanti';
    case 'Circ_Indietro'; nm='Circonduzione indietro';
    case 'RandG_R'; nm='Reach';
    case 'RandG_G'; nm='Grasp';
    otherwise; nm=movimento;
end
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

%% ---------------------------------------------------------
function nm = nome_display(campo)
% traduce il nome-campo del sottogruppo nel nome da mostrare nei titoli.
mappa = {'Globale','Globale'; 'Tronco','Tronco'; 'Braccio','Braccio completo';
         'Spalla','Spalla'; 'Gomito','Braccio'; 'Polso','Avambraccio';
         'SpallaGomito','Spalla e braccio'};
i = find(strcmp(mappa(:,1), campo), 1);
if isempty(i); nm = campo; else; nm = mappa{i,2}; end
end
