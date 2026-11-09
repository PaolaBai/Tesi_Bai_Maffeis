function OUT = grafico_confronti_base(DATA, cartella_excel, tipo, movimento, lato_paz, RICOSTRUZIONE)
%GRAFICO_CONFRONTI_BASE  Come grafico_confronti ma per valori base e sinergie:
%    tipo='ampMax' | 'media'  -> asse x = 8 muscoli (sigle), fase Intero
%    tipo='k'                 -> asse x = kAIC, kVAF, kVAF90 insieme
%    tipo='kAIC'|'kVAF'|'kVAF90' -> un solo k (fase Intero)
%    tipo='VAF'               -> singolo gruppo di barre (dalla struct RICOSTRUZIONE)
%
%  Barre Sani/T0/T1 (media +/- SD dal DATA; VAF dalla tabella di vaf_crossfit),
%  con barrette di significativita' lette dal file Excel <movimento>_tab.xlsx.
%
%  USO
%    grafico_confronti_base(DATA,'C:\...\Excel','ampMax','Addu', lato_paz)
%    grafico_confronti_base(DATA,'C:\...\Excel','k','RandG_R', lato_paz)
%    grafico_confronti_base(DATA,'C:\...\Excel','VAF','Addu', lato_paz, RICOSTRUZIONE)
%
%  movimento: nome-file ('Addu','Circ_Avanti','RandG_R',...).
%  RICOSTRUZIONE: output di vaf_crossfit (serve SOLO per tipo='VAF').

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end
if nargin < 6; RICOSTRUZIONE = []; end
COL = [0.20 0.60 0.85; 0.85 0.30 0.30; 0.50 0.20 0.60];   % Sani, T0, T1
MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};

[mov_data, fase_R] = mappa_mov(movimento);

% --- definisci categorie asse x, nomi Excel, e come leggere i valori ---
switch lower(tipo)
    case {'ampmax','media'}
        campo = 'amp_max_uV'; pre='ampMax'; if strcmpi(tipo,'media'); campo='media_uV'; pre='media'; end
        cats = MUS; nomi_ex = cellfun(@(m) sprintf('%s_%s',pre,m), MUS, 'UniformOutput',false);
        getval = @(g,t,ci) base_muscolo(DATA,g,t,mov_data,fase_R,campo,ci,lato_paz);
    case 'k'
        cats = {'kAIC','kVAF','kVAF90'}; campi={'k_AIC','k_VAF','k_VAF90'};
        nomi_ex = {'kAIC_Totale','kVAF_Totale','kVAF90_Totale'};    % (RandG: puo' non combaciare)
        getval = @(g,t,ci) k_valore(DATA,g,t,mov_data,fase_R,campi{ci},lato_paz);
    case {'kaic','kvaf','kvaf90'}
        mk = {'kAIC','k_AIC','kAIC_Totale'; 'kVAF','k_VAF','kVAF_Totale'; 'kVAF90','k_VAF90','kVAF90_Totale'};
        ir = find(strcmpi(mk(:,1), tipo), 1);
        cats = mk(ir,1); campi = mk(ir,2); nomi_ex = mk(ir,3);
        getval = @(g,t,ci) k_valore(DATA,g,t,mov_data,fase_R,campi{1},lato_paz);
    case 'vaf'
        cats = {'VAF'}; nomi_ex = {'VAF'};
        if isempty(RICOSTRUZIONE); error('grafico_confronti_base:vaf','Per tipo=VAF passa RICOSTRUZIONE.'); end
        getval = @(g,t,ci) vaf_valori(RICOSTRUZIONE, g, t, mov_data, fase_R);
    otherwise
        error('grafico_confronti_base:tipo','tipo: ampMax | media | k | VAF');
end
nC = numel(cats);

% --- mean/SD per categoria e gruppo ---
grp = {{'Sani','T'}, {'Patologici','T0'}, {'Patologici','T1'}};
MU=nan(nC,3); SD=nan(nC,3);
for ci=1:nC
    for gi=1:3
        vals = getval(grp{gi}{1}, grp{gi}{2}, ci);
        vals = vals(isfinite(vals));
        if ~isempty(vals); MU(ci,gi)=mean(vals); if numel(vals)>1; SD(ci,gi)=std(vals); end; end
    end
end

% --- significativita' dal file Excel ---
SIG = leggi_sig(cartella_excel, movimento, nomi_ex);

% --- disegno ---
fig=figure('Color','w','Position',[70 70 max(150*nC,500) 500]);
ax=axes(fig); set(ax,'Color','w','XColor',[0.15 0.15 0.15],'YColor',[0.15 0.15 0.15]); hold(ax,'on');
if nC==1; Y=[MU;nan(1,3)]; E=[SD;nan(1,3)]; else; Y=MU; E=SD; end   % bar vuole >=2 righe
hb=bar(ax, Y, 'grouped','EdgeColor','none');
for i=1:3; try; hb(i).FaceColor=COL(i,:); catch; end; end
ngroups=size(Y,1); nbars=3; gw=min(0.8,nbars/(nbars+1.5)); xc=nan(ngroups,3);
for i=1:nbars
    xc(:,i)=(1:ngroups) - gw/2 + (2*i-1)*gw/(2*nbars);
    errorbar(ax,xc(:,i),Y(:,i),E(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4);
end
set(ax,'XTick',1:nC,'XTickLabel',cats,'TickLabelInterpreter','none'); if nC>1; xtickangle(ax,15); end
xlim(ax,[0.5 nC+0.5]);
ylabel(ax,tipo);
title(ax, sprintf('%s — %s', tipo, nome_mov(movimento)),'FontWeight','bold','Interpreter','none');
box(ax,'off'); grid(ax,'on');

% --- barrette di significativita' ---
ymax=max(Y(:)+E(:),[],'omitnan'); if isnan(ymax)||ymax<=0; ymax=1; end
passo=0.07*ymax; coppie=[1 2;1 3;2 3];
for ci=1:nC
    top=max(Y(ci,:)+E(ci,:),[],'omitnan'); if isnan(top); top=0; end
    liv=0;
    for cc=1:3
        if SIG(ci,cc)
            liv=liv+1; y=top+liv*passo; x1=xc(ci,coppie(cc,1)); x2=xc(ci,coppie(cc,2));
            plot(ax,[x1 x1 x2 x2],[y-0.15*passo y y y-0.15*passo],'k','LineWidth',1);
            text(ax,(x1+x2)/2,y+0.02*ymax,'*','HorizontalAlignment','center','FontSize',14,'FontWeight','bold');
        end
    end
end
ylim(ax,[0, ymax*1.35]);

OUT.categorie=cats; OUT.mean=MU; OUT.sd=SD; OUT.sig=SIG; OUT.tipo=tipo; OUT.movimento=movimento;
end

%% ---------------------------------------------------------
function [mov_data, fase_R] = mappa_mov(movimento)
if strncmp(movimento,'RandG_',6);      mov_data='RandG'; fase_R='Completo_Intero';
elseif strcmp(movimento,'Circ_Avanti');   mov_data='Circ'; fase_R='RAvanti_Intero';
elseif strcmp(movimento,'Circ_Indietro'); mov_data='Circ'; fase_R='RIndietro_Intero';
else; mov_data=movimento; fase_R='R_Intero'; end
end

function fase_s = fase_lato(fase, gruppo, sog, lato_paz, mov_data)
fase_s=fase;
if ~strcmpi(gruppo,'Sani') && ~strcmpi(mov_data,'RandG') && isfield(lato_paz,sog) && strcmpi(lato_paz.(sog),'L')
    fase_s=regexprep(fase,'^R','L');
end
end

%% --- lettori valori (per soggetto) dal DATA ---
function vals = base_muscolo(DATA, gruppo, tempo, mov, fase, campo, midx, lato_paz)
vals=[];
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo));
for s=1:numel(sogg)
    Snm=sogg{s}; fase_s=fase_lato(fase,gruppo,Snm,lato_paz,mov);
    st=DATA.(gruppo).(Snm); if ~isfield(st,tempo)||~isstruct(st.(tempo))||~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov); if ~isfield(M,'base')||~isfield(M.base,fase_s); continue; end
    B=M.base.(fase_s); if ~isfield(B,campo)||midx>numel(B.(campo)); continue; end
    v=B.(campo)(midx); if isfinite(v); vals(end+1)=v; end %#ok<AGROW>
end
end

function vals = k_valore(DATA, gruppo, tempo, mov, fase, campo, lato_paz)
vals=[];
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo));
for s=1:numel(sogg)
    Snm=sogg{s}; fase_s=fase_lato(fase,gruppo,Snm,lato_paz,mov);
    st=DATA.(gruppo).(Snm); if ~isfield(st,tempo)||~isstruct(st.(tempo))||~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov); if ~isfield(M,'sinergie')||~isfield(M.sinergie,campo); continue; end
    syn=M.sinergie; lab=cellstr(syn.phase_labels); ph=find(strcmp(lab,fase_s),1); if isempty(ph); continue; end
    K=syn.(campo);
    if size(K,1)==1; v=K(1,ph); else; v=round(mean(K(:,ph),'omitnan')); end
    if isfinite(v); vals(end+1)=v; end %#ok<AGROW>
end
end

function vals = vaf_valori(RIC, gruppo, tempo, mov, fase)
% legge i VAF per soggetto dalla tabella RICOSTRUZIONE.TAB (vaf_crossfit).
vals=[]; if ~isfield(RIC,'TAB'); return; end
TAB=RIC.TAB;
if istable(TAB); C=[TAB.Properties.VariableNames; table2cell(TAB)]; else; C=TAB; end
col=@(nm) find(strcmp(C(1,:),nm),1);
cG=col('gruppo'); cT=col('timepoint'); cM=col('mov'); cF=col('fase'); cV=col('VAF');
if isempty(cG)||isempty(cT)||isempty(cM)||isempty(cV); return; end
gnome='sano'; if ~strcmpi(gruppo,'Sani'); gnome='paziente'; end
for r=2:size(C,1)
    if strcmpi(C{r,cG},gnome) && strcmp(C{r,cT},tempo) && strcmp(C{r,cM},mov) ...
            && (isempty(cF) || strcmp(C{r,cF},fase))
        v=C{r,cV}; if isnumeric(v)&&isfinite(v); vals(end+1)=v; end %#ok<AGROW>
    end
end
end

%% --- significativita' dal file Excel ---
function SIG = leggi_sig(cartella, movimento, nomi_ex)
nC=numel(nomi_ex); SIG=false(nC,3);
f=fullfile(cartella,[movimento '_tab.xlsx']);
if ~exist(f,'file'); warning('File %s non trovato.', f); return; end
try; RAW=readcell(f); catch; [~,~,RAW]=xlsread(f); end
RAW=cellfun(@to_str,RAW,'UniformOutput',false); [nr,nc]=size(RAW);
conf={'Sani vs T0','Sani vs T1','T0 vs T1'}; crow=nan(1,3);
for r=1:nr; for c=1:nc; for k=1:3
    if strcmp(RAW{r,c},conf{k}); crow(k)=r; end
end; end; end
for k=1:3
    if isnan(crow(k)); continue; end
    r0=crow(k); oth=crow(crow>r0); r1=nr; if ~isempty(oth); r1=min(oth)-1; end
    for ci=1:nC
        for r=r0:r1; for c=1:nc
            base=regexprep(RAW{r,c},'_(T0|T1)$','');
            if strcmp(base,nomi_ex{ci}) && ((c+2<=nc&&contains(RAW{r,c+2},'*'))||(c+3<=nc&&contains(RAW{r,c+3},'*')))
                SIG(ci,k)=true;
            end
        end; end
    end
end
end

%% ---------------------------------------------------------
function nm = nome_mov(movimento)
switch movimento
    case 'Flex'; nm='Flessione'; case 'Addu'; nm='Adduzione';
    case 'Addu_orizz'; nm='Adduzione orizzontale';
    case 'Circ_Avanti'; nm='Circonduzione avanti'; case 'Circ_Indietro'; nm='Circonduzione indietro';
    case {'RandG_R','RandG_G','RandG'}; nm='Reach and Grasp';
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
