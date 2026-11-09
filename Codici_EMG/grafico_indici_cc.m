function OUT = grafico_indici_cc(DATA, mov, fase, indice, lato_paz)
%GRAFICO_INDICI  Confronto a barre (media +/- SD tra soggetti) dell'indice di
%  co-contrazione tra i 3 gruppi (Sani, Pazienti T0, Pazienti T1), per i 7
%  sottogruppi muscolari.
%
%  USO
%    grafico_indici_cc(DATA, 'Addu', 'R_Intero', 'TMCi', lato_paz)
%
%  indice : 'TMCi' | 'Rud' | 'Kel' | 'FW' | 'Unn'   (Kellis mostrato grezzo)
%  Allineamento lato: pazienti con lato affetto L usano la fase L omologa
%  (swap R->L); sani sempre R. Il valore per soggetto/fase e' la media sui cicli.

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end
validi = {'TMCi','Rud','Kel','FW','Unn'};
if ~ismember(indice, validi)
    error('grafico_indici:indice','indice deve essere uno di: %s', strjoin(validi,', '));
end
SG_ordine = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
SG_label = {'Globale', 'Tronco', 'BraccioCompleto', 'Spalla', 'Braccio', 'Avambraccio', 'SpallaBraccio'};
COL_SANI=[0.20 0.60 0.85]; COL_T0=[0.85 0.30 0.30]; COL_T1=[0.50 0.20 0.60];

% --- medie per gruppo/timepoint, per ogni sottogruppo ---
muS=nan(1,7); sdS=nan(1,7); m0=nan(1,7); s0=nan(1,7); m1=nan(1,7); s1=nan(1,7);
for b = 1:7
    [muS(b),sdS(b)] = media_gruppo(DATA,'Sani',      'T', mov,fase,SG_ordine{b},indice,lato_paz);
    [m0(b), s0(b) ] = media_gruppo(DATA,'Patologici','T0',mov,fase,SG_ordine{b},indice,lato_paz);
    [m1(b), s1(b) ] = media_gruppo(DATA,'Patologici','T1',mov,fase,SG_ordine{b},indice,lato_paz);
end

% --- figura: 3 barre per sottogruppo ---
fig=figure('Color','w','Position',[80 80 950 480]);
ax=axes(fig); set(ax,'Color','w','XColor',[0.15 0.15 0.15],'YColor',[0.15 0.15 0.15]);
hold(ax,'on');
Y=[muS;m0;m1]'; E=[sdS;s0;s1]';        % [7 x 3]
hb=bar(ax,Y,'grouped','EdgeColor','none');
cols={COL_SANI,COL_T0,COL_T1};
for i=1:3
    try; hb(i).FaceColor=cols{i}; catch; set(hb(i),'FaceColor','flat'); end
end
% baffi SD centrati su ogni barra
ngroups=7; nbars=3; gw=min(0.8,nbars/(nbars+1.5));
for i=1:nbars
    xc=(1:ngroups) - gw/2 + (2*i-1)*gw/(2*nbars);
    errorbar(ax,xc, Y(:,i), E(:,i),'linestyle','none','Color',[0.15 0.15 0.15],'LineWidth',1.0,'CapSize',4);
end
set(ax,'XTick',1:7,'XTickLabel',SG_label); xtickangle(ax,20);
ylabel(ax,indice);
legend(ax,{'Sano','T0','T1'},'Location','best');
title(ax,sprintf('%s — %s / %s  (media \\pm SD tra soggetti)', indice, mov, strrep(fase,'_','\_')));
box(ax,'off'); grid(ax,'on');

OUT.sottogruppi=SG_ordine; OUT.indice=indice;
OUT.sani=[muS;sdS]; OUT.T0=[m0;s0]; OUT.T1=[m1;s1];
end

%% ---------------------------------------------------------
function [mu,sd] = media_gruppo(DATA, gruppo, tempo, mov, fase, SG, indice, lato_paz)
% media +/- SD TRA soggetti del valore (media sui cicli) dell'indice, per un SG,
% al timepoint dato. Pazienti L: fase L omologa (swap R->L). RandG: nessuno swap.
mu=NaN; sd=NaN;
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
vals=[];
for s=1:numel(sogg)
    Snm=sogg{s};
    fase_s=fase;
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
    if numel(vv)>1;  sd=std(vv);  end
end
end

%% ---------------------------------------------------------
function v = valore_medio(TPstruct, mov, fase, SG, indice)
% media sui cicli dell'indice per (movimento, fase, sottogruppo). NaN se assente.
v = NaN;
if ~isstruct(TPstruct) || ~isfield(TPstruct,mov); return; end
M=TPstruct.(mov);
if ~isfield(M,SG) || ~isfield(M.(SG),indice); return; end
lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fase),1);
if isempty(ph); return; end
col=M.(SG).(indice);
if ph>size(col,2); return; end
x=double(col(:,ph)); x=x(isfinite(x));
if ~isempty(x); v=mean(x); end
end
