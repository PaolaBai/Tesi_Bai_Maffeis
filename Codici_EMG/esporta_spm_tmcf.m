function esporta_spm_tmcf(DATA, out_dir, lato_paz)
%ESPORTA_SPM_TMCF  Esegue l'SPM sulla TMCf per tutti i movimenti, sottogruppi e
%  confronti, ed esporta in Excel gli intervalli del ciclo risultati significativi.
%  Per ogni cluster significativo riporta: movimento, sottogruppo, fase, confronto,
%  inizio e fine del cluster (% del ciclo), t di picco, soglia critica, p-value.
%
%  USO
%    esporta_spm_tmcf(DATA, 'C:\...\out', lato_paz)
%
%  Richiede spm1d nel path. Outlier rimossi con IQR 1.5 (come tmcf_gruppo_spm).

if nargin < 3 || isempty(lato_paz); lato_paz = struct(); end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

spm1dPath = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\spm1dmatlab-master';
if isempty(which('spm1d.stats.nonparam.ttest2')) && isfolder(spm1dPath)
    addpath(spm1dPath); p8=fullfile(spm1dPath,'spm8'); if isfolder(p8); addpath(p8); end
end

SG_LIST = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
% movimenti e fasi (andata/ritorno) - come in tmcf_gruppo_spm
MOV = {
 'Adduzione',        'Addu',  'R_Salita','R_Discesa','andata','ritorno'
 'Adduzione orizz.', 'Addu_orizz','R_Salita','R_Discesa','andata','ritorno'
 'Flessione',        'Flex',  'R_Salita','R_Discesa','andata','ritorno'
 'Circ. avanti',     'Circ',  'RAvanti_Salita','RAvanti_Discesa','andata','ritorno'
 'Circ. indietro',   'Circ',  'RIndietro_Salita','RIndietro_Discesa','andata','ritorno'
 'Reach',            'RandG', 'RAndata_Intero','RRitorno_Intero','andata','ritorno'
 'Grasp',            'RandG', 'GAndata_Intero','GRitorno_Intero','andata','ritorno'
};
CONF = {'Sani vs T0','Sani vs T1','T0 vs T1'};

righe = {{'Movimento','Sottogruppo','Fase','Confronto','Inizio (%)','Fine (%)','t_picco','soglia','p_cluster'}};

for mi = 1:size(MOV,1)
    mov_lab=MOV{mi,1}; mov_data=MOV{mi,2};
    for fa_idx = 1:2  % andata, ritorno
        fase = MOV{mi, 2+fa_idx}; fase_lab = MOV{mi, 4+fa_idx};
        % estrai curve dei 3 gruppi (con filtro IQR)
        [CS,~]  = curve_gruppo(DATA,'Sani','T',mov_data,fase,SG_LIST,lato_paz);
        [C0,S0] = curve_gruppo(DATA,'Patologici','T0',mov_data,fase,SG_LIST,lato_paz);
        [C1,S1] = curve_gruppo(DATA,'Patologici','T1',mov_data,fase,SG_LIST,lato_paz);
        for g = 1:numel(SG_LIST)
            SG=SG_LIST{g};
            if ~isfield(CS,SG); continue; end
            A=filtra_iqr(CS.(SG));
            [B0,s0]=filtra_iqr(C0.(SG),S0.(SG));
            [B1,s1]=filtra_iqr(C1.(SG),S1.(SG));
            % appaio T0-T1 per soggetto (stessi soggetti in entrambi)
            [~,i0,i1]=intersect(s0,s1,'stable');
            B0p=B0(i0,:); B1p=B1(i1,:);
            coppie={A,B0,[],'Sani vs T0',false; A,B1,[],'Sani vs T1',false; B0p,B1p,[],'T0 vs T1',true};
            for cc=1:3
                Y1=coppie{cc,1}; Y2=coppie{cc,2}; cname=coppie{cc,4}; paired=coppie{cc,5};
                cl = spm_clusters(Y1,Y2,paired);
                for k=1:size(cl,1)
                    righe{end+1,1} = {mov_lab, SG, fase_lab, cname, ...
                        round(cl(k,1),1), round(cl(k,2),1), round(cl(k,3),2), round(cl(k,4),2), cl(k,5)}; %#ok<AGROW>
                end
            end
        end
    end
end

% scrivo l'Excel
out = fullfile(out_dir,'SPM_TMCf_risultati.xlsx');
if exist(out,'file'); delete(out); end
M = cell(numel(righe),9);
for i=1:numel(righe); M(i,:)=righe{i}; end
writecell(M, out);
fprintf('[esporta_spm_tmcf] scritto %s (%d cluster significativi)\n', out, numel(righe)-1);
end

%% ---------------------------------------------------------
function [S,SOG] = curve_gruppo(DATA,gruppo,tempo,mov,fase,SG_LIST,lato_paz)
S=struct(); SOG=struct();
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
for g=1:numel(SG_LIST); S.(SG_LIST{g})=[]; SOG.(SG_LIST{g})={}; end
for s=1:numel(sogg)
    Snm=sogg{s}; fs=fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L'); fs=regexprep(fase,'^R','L'); end
    st=DATA.(gruppo).(Snm);
    if ~isfield(st,tempo)||~isstruct(st.(tempo))||~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov); lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fs),1); if isempty(ph); continue; end
    for g=1:numel(SG_LIST)
        SG=SG_LIST{g};
        if ~isfield(M,SG)||~isfield(M.(SG),'TMCf'); continue; end
        A=M.(SG).TMCf(:,:,ph); if all(isnan(A(:))); continue; end
        curva=riga_nanmean(A);
        S.(SG)=[S.(SG); curva(:)'];
        SOG.(SG)=[SOG.(SG); {Snm}];
    end
end
end

function [C,sog]=filtra_iqr(C,sog)
if nargin<2; sog={}; end
if size(C,1)<4; return; end
tmci=mean(C,2,'omitnan');
q1=prctile(tmci,25);q3=prctile(tmci,75);iqr=q3-q1;
keep=tmci>=(q1-1.5*iqr)&tmci<=(q3+1.5*iqr);
C=C(keep,:);
if ~isempty(sog); sog=sog(keep); end
end

function cl = spm_clusters(Y1,Y2,paired)
% restituisce [inizio% fine% t_picco soglia p] per ogni cluster significativo
cl=zeros(0,5);
if isempty(Y1)||isempty(Y2); return; end
if paired
    % Y1,Y2 gia' appaiati per soggetto, stessa dimensione
    if size(Y1,1)~=size(Y2,1); return; end
    vr=all(isfinite(Y1),2)&all(isfinite(Y2),2);
    Y1=Y1(vr,:);Y2=Y2(vr,:); if size(Y1,1)<2; return; end
else
    Y1=Y1(all(isfinite(Y1),2),:); Y2=Y2(all(isfinite(Y2),2),:);
    if size(Y1,1)<2||size(Y2,1)<2; return; end
end
T=size(Y1,2); x=linspace(0,100,T);
try
    if paired; spm=spm1d.stats.nonparam.ttest_paired(Y1,Y2); else; spm=spm1d.stats.nonparam.ttest2(Y1,Y2); end
    inf=spm.inference(0.05,'two_tailed',true,'iterations',1000);
    if inf.h0reject
        for c=1:inf.nClusters
            C=inf.clusters{c};
            a=max(1,floor(C.endpoints(1))+1); b=min(T,ceil(C.endpoints(2))+1);
            tseg=inf.z(a:b); [~,imax]=max(abs(tseg)); tpk=tseg(imax);
            pval=NaN; try; pval=C.P; catch; end
            cl(end+1,:)=[x(a) x(b) tpk inf.zstar pval]; %#ok<AGROW>
        end
    end
catch ME; warning('SPM %s', ME.message); end
end

function m = riga_nanmean(A)
m=nan(size(A,1),1);
for i=1:size(A,1); v=A(i,:); v=v(isfinite(v)); if ~isempty(v); m(i)=mean(v); end; end
end
