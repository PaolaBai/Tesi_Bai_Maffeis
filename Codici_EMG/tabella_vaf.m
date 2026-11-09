function tabella_vaf(cartella_excel, out_dir)
%TABELLA_VAF  Tabella Excel del VAF con i 7 MOVIMENTI in riga e il layout a 6
%  colonne (3 confronti). Il VAF e' un valore unico per movimento, quindi una
%  sola tabella (niente sottogruppi ne' andata/ritorno).
%
%  USO
%    tabella_vaf('C:\...\Tabelle', 'C:\...\Tabelle_out')
%
%  Serve leggi_media_sd.m e leggi_ttest.m nel path.

if ~exist(out_dir,'dir'); mkdir(out_dir); end
MOV = {'Adduzione','Adduzione'; 'Adduzione orizz.','Adduzione_orizzontale'; ...
       'Flessione','Flessione'; 'Circ. avanti','Circ_Avanti'; ...
       'Circ. indietro','Circ_Indietro'; 'Reach','Reach'; 'Grasp','Grasp'};
nMov=size(MOV,1);

out = fullfile(out_dir, 'VAF_tabella.xlsx');
if exist(out,'file'); delete(out); end

CELLE = {};
CELLE(end+1,:)=pad7({'VAF — Varianza spiegata dalle sinergie'});
CELLE(end+1,:)=pad7({'', 'Sani vs T0','', 'Sani vs T1','', 'T0 vs T1',''});
CELLE(end+1,:)=pad7({'Movimento','Sani','T0','Sani','T1','T0','T1'});
for k=1:nMov
    RAW = carica_excel(cartella_excel, MOV{k,2});
    v={'','',''}; sig=false(1,3);
    if ~isempty(RAW)
        [mu,sd]=leggi_media_sd(RAW,'VAF'); v=fmt3(mu,sd); sig=leggi_ttest(RAW,'VAF');
    end
    CELLE(end+1,:)=[{MOV{k,1}}, riga_6col(v,sig)]; %#ok<AGROW>
end
writecell(CELLE, out, 'Sheet', 'VAF');
fprintf('[tabella_vaf] scritto %s\n', out);
end

%% --- helper ---
function c = pad7(x); c=repmat({''},1,7); c(1:numel(x))=x; end
function v = fmt3(mu,sd)
v=cell(1,3);
for g=1:3
    if isfinite(mu(g))
        if isfinite(sd(g)); v{g}=sprintf('%.3f (%.3f)',mu(g),sd(g)); else; v{g}=sprintf('%.3f',mu(g)); end
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
