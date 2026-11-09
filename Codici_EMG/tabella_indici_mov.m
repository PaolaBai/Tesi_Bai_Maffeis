function tabella_indici_mov(cartella_excel, indice, out_dir)
%TABELLA_INDICI_MOV  Tabella Excel di un indice di co-contrazione con i MOVIMENTI
%  in riga e il layout a 6 colonne (3 confronti). Un file per indice, con le
%  tabelle di ogni sottogruppo (andata e ritorno) impilate in un unico foglio.
%
%  USO
%    tabella_indici_mov('C:\...\Tabelle', 'TMCi', 'C:\...\Tabelle_out')
%
%  indice: 'TMCi'|'Rud'|'FW'|'FWHM'|'CoA' (o Kel/Unn). Serve leggi_media_sd.m e
%  leggi_ttest.m nel path.

if ~exist(out_dir,'dir'); mkdir(out_dir); end
SG     = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
SGEST  = {'Globale','Tronco','Braccio completo','Spalla','Braccio','Avambraccio','Spalla e braccio'};
% movimenti: {etichetta, nome-file, fase-excel-andata, fase-excel-ritorno}
MOV = {'Adduzione','Adduzione','Andata','Ritorno'; ...
       'Adduzione orizz.','Adduzione_orizzontale','Andata','Ritorno'; ...
       'Flessione','Flessione','Andata','Ritorno'; ...
       'Circ. avanti','Circ_Avanti','Andata','Ritorno'; ...
       'Circ. indietro','Circ_Indietro','Andata','Ritorno'; ...
       'Reach','Reach','tot_andata','tot_ritorno'; ...
       'Grasp','Grasp','tot_andata','tot_ritorno'};
nMov=size(MOV,1);
TR={'andata','ritorno'};

out = fullfile(out_dir, [indice '_tabella.xlsx']);
if exist(out,'file'); delete(out); end

CELLE={};
for g=1:numel(SG)
    for tr=1:2
        CELLE(end+1,:)=pad7({sprintf('%s — %s / %s', indice, SGEST{g}, TR{tr})}); %#ok<AGROW>
        CELLE(end+1,:)=pad7({'', 'Sani vs T0','', 'Sani vs T1','', 'T0 vs T1',''}); %#ok<AGROW>
        CELLE(end+1,:)=pad7({'Movimento','Sani','T0','Sani','T1','T0','T1'}); %#ok<AGROW>
        for k=1:nMov
            fase_ex = MOV{k,2+tr};   % colonna 3 (andata) o 4 (ritorno)
            nome_ex = sprintf('%s_%s_%s', indice, SG{g}, fase_ex);
            RAW = carica_excel(cartella_excel, MOV{k,2});
            v={'','',''}; sig=false(1,3);
            if ~isempty(RAW)
                [mu,sd]=leggi_media_sd(RAW,nome_ex); v=fmt3(mu,sd); sig=leggi_ttest(RAW,nome_ex);
            end
            CELLE(end+1,:)=[{MOV{k,1}}, riga_6col(v,sig)]; %#ok<AGROW>
        end
        CELLE(end+1,:)=pad7({''}); %#ok<AGROW>
    end
end
writecell(CELLE, out, 'Sheet', indice);
fprintf('[tabella_indici_mov] %s: scritto %s (%d sottogruppi x 2 fasi)\n', indice, out, numel(SG));
end

%% --- helper (identici a tabella_base_mov) ---
function c = pad7(x); c=repmat({''},1,7); c(1:numel(x))=x; end
function v = fmt3(mu,sd)
v=cell(1,3);
for g=1:3
    if isfinite(mu(g))
        if isfinite(sd(g)); v{g}=sprintf('%.2f (%.2f)',mu(g),sd(g)); else; v{g}=sprintf('%.2f',mu(g)); end
    else; v{g}=''; end
end
end
function r = riga_6col(v, sig)
S=v{1}; T0=v{2}; T1=v{3};
a1=S; a2=T0; if sig(1); a1=ast(a1); a2=ast(a2); end
b1=S; b2=T1; if sig(2); b1=ast(b1); b2=ast(b2); end
c1=T0; c2=T1; if sig(3); c1=ast(c1); c2=ast(c2); end
r={a1,a2,b1,b2,c1,c2};
end
function s=ast(s); if ~isempty(s); s=[s '*']; end; end
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
