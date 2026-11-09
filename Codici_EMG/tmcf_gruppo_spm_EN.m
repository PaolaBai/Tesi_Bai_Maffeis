function OUT = tmcf_gruppo_spm_EN(DATA, movimento, out_dir, lato_paz)
%TMCF_GRUPPO_SPM  Per un MOVIMENTO, un grafico TMCf per sottogruppo con ANDATA e
%  RITORNO concatenate in un'unica curva (andata 0-50%, ritorno 50-100%).
%  L'SPM e' calcolato SEPARATAMENTE su andata e ritorno (coerente col TMCi di
%  JASP), e mostrato sotto l'asse nelle due meta' del grafico. Outlier rimossi
%  con IQR 1.5 su andata e ritorno separatamente.
%
%  USO
%    tmcf_gruppo_spm(DATA, 'Addu', out_dir, lato_paz)
%    tmcf_gruppo_spm(DATA, 'Circ', out_dir, lato_paz)   % avanti e indietro
%    tmcf_gruppo_spm(DATA, 'RandG', out_dir, lato_paz)  % reach e grasp
%
%  SPM: Sani-T0 e Sani-T1 indipendenti, T0-T1 appaiato.

if nargin < 4 || isempty(lato_paz); lato_paz = struct(); end
if nargin < 3 || isempty(out_dir); out_dir = pwd; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

spm1dPath = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\spm1dmatlab-master';
if isempty(which('spm1d.stats.nonparam.ttest2'))
    if isfolder(spm1dPath)
        addpath(spm1dPath); p8=fullfile(spm1dPath,'spm8'); if isfolder(p8); addpath(p8); end
    else; warning('Cartella SPM1D non trovata: %s', spm1dPath); end
end

COL_SANI=[0.20 0.60 0.85]; COL_T0=[0.85 0.30 0.30]; COL_T1=[0.50 0.20 0.60];
SG_LIST = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};

GRU = fasi_gruppi(movimento);            % uno o piu' grafici, ognuno con N segmenti
mov_data = GRU(1).mov_data;

conta_esclusi('reset');
% ===== PRIMO GIRO: estrazione + scala Y comune =====
ymax_glob = 0; DAT = struct();
for gi = 1:numel(GRU)
    fasi = GRU(gi).fasi; nSeg = numel(fasi);
    for g = 1:numel(SG_LIST)
        SG = SG_LIST{g};
        for sgm = 1:nSeg
            S = estrai_coppia(DATA, mov_data, fasi{sgm}, SG, lato_paz);
            DAT.(sprintf('gr%d_g%d_s%d', gi, g, sgm)) = S;
            for yy = {S.muS+S.sdS, S.m0+S.s0, S.m1+S.s1}
                mm=max(yy{1}(:),[],'omitnan'); if ~isnan(mm); ymax_glob=max(ymax_glob,mm); end
            end
        end
    end
end
if ymax_glob<=0; ymax_glob=1; end
ytop = ceil(ymax_glob*1.15/10)*10;

% ===== SECONDO GIRO: SPM, disegno, salvataggio =====
OUT=struct(); OUT.files={};
SPM_ROWS = {{'Movimento','Sottogruppo','Segmento','Confronto','Inizio (%)','Fine (%)'}};
for gi = 1:numel(GRU)
    fasi = GRU(gi).fasi; nomi = GRU(gi).nomi; nSeg = numel(fasi);
    etich = GRU(gi).etich;
    bordi = linspace(0,100,nSeg+1);       % confini dei segmenti sull'asse x
    for g = 1:numel(SG_LIST)
        SG=SG_LIST{g};
        fig=figure('Color','w','Position',[100 100 1000 550],'Visible','off'); hold on;
        has_data=false;
        for sgm = 1:nSeg
            S = DAT.(sprintf('gr%d_g%d_s%d', gi, g, sgm));
            if S.nS==0 && S.n0==0 && S.n1==0; continue; end
            has_data=true;
            x = linspace(bordi(sgm), bordi(sgm+1), numel(S.muS));
            banda(x,S.muS,S.sdS,COL_SANI); banda(x,S.m0,S.s0,COL_T0); banda(x,S.m1,S.s1,COL_T1);
            plot(x,S.muS,'Color',COL_SANI,'LineWidth',2.2);
            plot(x,S.m0, 'Color',COL_T0,  'LineWidth',2.2);
            plot(x,S.m1, 'Color',COL_T1,  'LineWidth',2.2);
            sp = spm3(S);
            % --- raccolgo i cluster per l'export (stesse maschere dei grafici) ---
            SPM_ROWS = aggiungi_cluster(SPM_ROWS, nome_mov_display(mov_data,etich), nome_display(SG), nomi{sgm}, x, sp);
            e1 = (sgm==1);   % etichetta barre SPM solo nel primo segmento
            barra_spm(x, sp.S0, -2,   tern(e1,'H vs T0',''), [0.95 0.45 0.1]);
            barra_spm(x, sp.S1, -4.5, tern(e1,'H vs T1',''), [0.7 0.45 0.85]);
            barra_spm(x, sp.T01,-7.0, tern(e1,'T0 vs T1',''),   [0.1 0.6 0.2]);
            text(mean(bordi(sgm:sgm+1)), ytop*0.97, nomi{sgm}, 'HorizontalAlignment','center','FontSize',9,'Color',[0.4 0.4 0.4]);
        end
        if ~has_data; close(fig); continue; end
        line([0 100],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.8,'LineStyle','--');
        for b=2:nSeg; line([bordi(b) bordi(b)],[-9 ytop],'Color',[0.6 0.6 0.6],'LineWidth',1,'LineStyle',':'); end
        xlabel('% of movement','FontWeight','bold'); ylabel('TMCf','FontWeight','bold');
        title(sprintf('TMCf - %s / %s', nome_mov_display_EN(mov_data, etich), nome_display_EN(SG)),'FontWeight','bold','FontSize',12,'Interpreter','none');
        grid on; box off; xlim([0 100]); xticks(0:20:100); ylim([-9, ytop]); yticks(0:10:ytop);
        hS=plot(nan,nan,'Color',COL_SANI,'LineWidth',2.2); h0=plot(nan,nan,'Color',COL_T0,'LineWidth',2.2); h1=plot(nan,nan,'Color',COL_T1,'LineWidth',2.2);
        lg=legend([hS h0 h1],{'Healthy','T0','T1'},'Location','northeast','Box','off'); set(lg,'FontWeight','bold');
        suff = etich; if isempty(suff); suff='AndataRitorno'; end
        fname=fullfile(out_dir, sprintf('%s_%s_%s_TMCf.png', movimento, suff, SG));
        try; exportgraphics(fig,fname,'Resolution',150); catch; saveas(fig,fname); end
        close(fig); OUT.files{end+1}=fname;
    end
end
n_out = conta_esclusi();
% --- esporto i cluster SPM in Excel (identici ai grafici) ---
try
    fxls = fullfile(out_dir, sprintf('%s_SPM_TMCf.xlsx', movimento));
    if exist(fxls,'file'); delete(fxls); end
    MM=cell(numel(SPM_ROWS),6); for i=1:numel(SPM_ROWS); MM(i,:)=SPM_ROWS{i}; end
    writecell(MM, fxls);
    fprintf('[tmcf_gruppo_spm] %s: esportati %d cluster SPM in %s\n', movimento, numel(SPM_ROWS)-1, fxls);
catch ME; warning('export SPM: %s', ME.message); end
fprintf('[tmcf_gruppo_spm] %s: salvati %d grafici; outlier esclusi (IQR 1.5 per fase): %d\n', ...
    movimento, numel(OUT.files), n_out);
OUT.movimento=movimento; OUT.ytop=ytop; OUT.n_outlier=n_out;
end

%% ---------------------------------------------------------
function ROWS = aggiungi_cluster(ROWS, mov, sg, seg, x, sp)
% estrae gli intervalli [inizio fine] in % da ogni maschera e li accumula
conf = {sp.S0,'Sani vs T0'; sp.S1,'Sani vs T1'; sp.T01,'T0 vs T1'};
for i=1:3
    sig=conf{i,1}; cname=conf{i,2};
    if isempty(sig)||~any(sig); continue; end
    d=diff([0 sig(:)' 0]); a=find(d==1); b=find(d==-1)-1;
    for k=1:numel(a)
        ini=x(a(k)); fin=x(b(k));
        ROWS{end+1,1} = {mov, sg, seg, cname, round(ini,1), round(fin,1)}; %#ok<AGROW>
    end
end
end

function r = tern(c,a,b); if c; r=a; else; r=b; end; end

function s = nome_display_EN(sg)
map = {'Globale','Global';'Tronco','Trunk';'Braccio','Complete arm';'Spalla','Shoulder'; ...
       'Gomito','Arm';'Polso','Forearm';'SpallaGomito','Shoulder and arm'; ...
       'BraccioCompleto','Complete arm';'Avambraccio','Forearm'};
s = sg; for i=1:size(map,1); if strcmpi(sg,map{i,1}); s=map{i,2}; return; end; end
end

function s = nome_mov_display_EN(mov, etich)
% traduce il nome del movimento in inglese
m = lower(string(mov));
if contains(m,'addu') && contains(lower(string(etich)),'oriz'); s='Horiz Adduction';
elseif contains(m,'addu'); s='Adduction';
elseif contains(m,'flex'); s='Flexion';
elseif contains(lower(string(etich)),'indietro')||contains(lower(string(etich)),'bwd'); s='Circ BWD';
elseif contains(lower(string(etich)),'avanti')||contains(lower(string(etich)),'fwd'); s='Circ FWD';
elseif contains(m,'circ'); s='Circumduction';
elseif contains(lower(string(etich)),'reach'); s='Reach';
elseif contains(lower(string(etich)),'grasp'); s='Grasp';
else; s=char(etich); end
s=char(s);
end

%% ---------------------------------------------------------
function G = fasi_gruppi(movimento)
% ogni elemento: struct con .etich (nome grafico), .fasi (fasi DATA da concatenare),
% .nomi (etichette dei segmenti sul grafico), .mov_data.
switch movimento
    case 'RandG'
        G(1).etich='CompletoRandG'; G(1).mov_data='RandG';
        G(1).fasi={'RAndata_Intero','GAndata_Intero','GRitorno_Intero','RRitorno_Intero'};
        G(1).nomi={'R andata','G andata','G ritorno','R ritorno'};
    case 'Circ'
        G(1).etich='Avanti';   G(1).mov_data='Circ'; G(1).fasi={'RAvanti_Salita','RAvanti_Discesa'};   G(1).nomi={'Andata','Ritorno'};
        G(2).etich='Indietro'; G(2).mov_data='Circ'; G(2).fasi={'RIndietro_Salita','RIndietro_Discesa'};G(2).nomi={'Andata','Ritorno'};
    otherwise
        G(1).etich=''; G(1).mov_data=movimento; G(1).fasi={'R_Salita','R_Discesa'}; G(1).nomi={'Andata','Ritorno'};
end
end

%% ---------------------------------------------------------
function S = estrai_coppia(DATA, mov, fase, SG, lato_paz)
% estrae le curve dei 3 gruppi per UNA fase, con rimozione outlier IQR 1.5.
[CS,ogS] = curve_gruppo(DATA,'Sani','T',mov,fase,SG,lato_paz);
[C0,og0] = curve_gruppo(DATA,'Patologici','T0',mov,fase,SG,lato_paz);
[C1,og1] = curve_gruppo(DATA,'Patologici','T1',mov,fase,SG,lato_paz);
[CS,ogS] = filtra_iqr(CS,ogS); [C0,og0]=filtra_iqr(C0,og0); [C1,og1]=filtra_iqr(C1,og1);
% appaiati T0-T1 (stessi soggetti, dopo il filtro)
[~, iT0, iT1] = intersect(og0, og1, 'stable');
S.CS=CS; S.C0=C0; S.C1=C1; S.C0p=C0(iT0,:); S.C1p=C1(iT1,:);
S.nS=size(CS,1); S.n0=size(C0,1); S.n1=size(C1,1);
S.muS=mean(CS,1,'omitnan')'; S.sdS=std(CS,0,1,'omitnan')';
S.m0=mean(C0,1,'omitnan')';  S.s0=std(C0,0,1,'omitnan')';
S.m1=mean(C1,1,'omitnan')';  S.s1=std(C1,0,1,'omitnan')';
if isempty(S.muS); S.muS=nan(100,1); S.sdS=nan(100,1); end
if isempty(S.m0);  S.m0=nan(100,1);  S.s0=nan(100,1);  end
if isempty(S.m1);  S.m1=nan(100,1);  S.s1=nan(100,1);  end
end

function [Cmat, sogg_ok] = curve_gruppo(DATA,gruppo,tempo,mov,fase,SG,lato_paz)
Cmat=[]; sogg_ok={};
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
curve={};
for s=1:numel(sogg)
    Snm=sogg{s}; fs=fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L'); fs=regexprep(fase,'^R','L'); end
    st=DATA.(gruppo).(Snm);
    if ~isfield(st,tempo)||~isstruct(st.(tempo))||~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov); if ~isfield(M,SG)||~isfield(M.(SG),'TMCf'); continue; end
    lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fs),1); if isempty(ph); continue; end
    Aa=M.(SG).TMCf(:,:,ph); if all(isnan(Aa(:))); continue; end
    curve{end+1}=riga_nanmean(Aa); sogg_ok{end+1}=Snm; %#ok<AGROW>
end
n=numel(curve); if n==0; return; end
T=numel(curve{1}); Cmat=nan(n,T);
for s=1:n; Cmat(s,:)=curve{s}(:)'; end
end

function [Cmat, sogg] = filtra_iqr(Cmat, sogg)
% rimuove le curve il cui TMCi (media temporale) e' outlier IQR 1.5.
if size(Cmat,1)<4; return; end
tmci=mean(Cmat,2,'omitnan');
q1=prctile(tmci,25); q3=prctile(tmci,75); iqr=q3-q1;
keep = tmci>=(q1-1.5*iqr) & tmci<=(q3+1.5*iqr);
ne=sum(~keep); if ne>0; conta_esclusi(ne); end
Cmat=Cmat(keep,:); sogg=sogg(keep);
end

%% ---------------------------------------------------------
function sp = spm3(S)
sp.S0 = spm2(S.CS, S.C0, false);
sp.S1 = spm2(S.CS, S.C1, false);
sp.T01= spm2(S.C0p, S.C1p, true);
end

function sig = spm2(Y1, Y2, is_paired)
T=size(Y1,2); if T==0; T=100; end; sig=false(1,T);
if isempty(Y1)||isempty(Y2); return; end
if is_paired
    vr=all(isfinite(Y1),2)&all(isfinite(Y2),2); Y1=Y1(vr,:); Y2=Y2(vr,:);
    if size(Y1,1)<2; return; end
else
    Y1=Y1(all(isfinite(Y1),2),:); Y2=Y2(all(isfinite(Y2),2),:);
    if size(Y1,1)<2||size(Y2,1)<2; return; end
end
try
    if is_paired; spm=spm1d.stats.nonparam.ttest_paired(Y1,Y2); else; spm=spm1d.stats.nonparam.ttest2(Y1,Y2); end
    inf=spm.inference(0.05,'two_tailed',true,'iterations',-1);   % -1 = tutte le permutazioni (no warning)
    if inf.h0reject
        for c=1:inf.nClusters
            cl=inf.clusters{c}; a=max(1,floor(cl.endpoints(1))+1); b=min(T,ceil(cl.endpoints(2))+1); sig(a:b)=true;
        end
    end
catch ME; warning('SPM: %s', ME.message); end
end

%% ---------------------------------------------------------
function barra_spm(x, sig, y, etich, col)
plot(x, repmat(y,size(x)), 'Color',[0.85 0.85 0.85],'LineWidth',1.5,'HandleVisibility','off');
if any(sig)
    d=diff([0 sig 0]); a=find(d==1); b=find(d==-1)-1;
    for k=1:numel(a); xi=x(a(k):b(k)); plot(xi,repmat(y,size(xi)),'Color',col,'LineWidth',4.7,'HandleVisibility','off'); end
end
if ~isempty(etich); text(-2, y, etich, 'HorizontalAlignment','right','FontSize',8.5,'FontWeight','bold','Color',col); end
end

function tot = conta_esclusi(incr)
persistent C; if isempty(C); C=0; end
if nargin>0 && ~isempty(incr)
    if ischar(incr)&&strcmp(incr,'reset'); C=0; else; C=C+incr; end
end
tot=C;
end

function banda(x,mu,sd,col)
if isempty(mu); return; end
xf=[x fliplr(x)]; yf=[(mu+sd)' fliplr((mu-sd)')]; yf(~isfinite(yf))=NaN;
fill(xf,yf,col,'FaceAlpha',0.13,'EdgeColor','none','HandleVisibility','off');
end

function m = riga_nanmean(A)
m=nan(size(A,1),1);
for i=1:size(A,1); v=A(i,:); v=v(isfinite(v)); if ~isempty(v); m(i)=mean(v); end; end
end

%% ---------------------------------------------------------
function nm = nome_mov_display(mov, etich)
switch mov
    case 'Flex';       nm='Flessione';
    case 'Addu';       nm='Adduzione';
    case 'Addu_orizz'; nm='Adduzione orizzontale';
    case 'Circ'
        if strcmpi(etich,'Avanti'); nm='Circonduzione avanti';
        elseif strcmpi(etich,'Indietro'); nm='Circonduzione indietro';
        else; nm='Circonduzione'; end
    case 'RandG'
        if strcmpi(etich,'Reach'); nm='Reach';
        elseif strcmpi(etich,'Grasp'); nm='Grasp';
        else; nm='Reach and Grasp'; end
    otherwise; nm=mov;
end
end

function nm = nome_display(campo)
mappa = {'Globale','Globale'; 'Tronco','Tronco'; 'Braccio','Braccio completo';
         'Spalla','Spalla'; 'Gomito','Braccio'; 'Polso','Avambraccio';
         'SpallaGomito','Spalla e braccio'};
i = find(strcmp(mappa(:,1), campo), 1);
if isempty(i); nm = campo; else; nm = mappa{i,2}; end
end
