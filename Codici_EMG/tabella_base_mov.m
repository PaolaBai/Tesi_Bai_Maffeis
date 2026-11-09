function tabella_base_mov(cartella_excel, tipo, out_dir)
%TABELLA_BASE_MOV  Tabella Excel del valore base (ampMax o media) con i MOVIMENTI
%  in riga e il layout a 6 colonne (3 confronti). Un file per parametro, con le
%  tabelle dei muscoli impilate in un unico foglio.
%
%  USO
%    tabella_base_mov('C:\...\Tabelle', 'ampMax', 'C:\...\Tabelle_out')
%    tabella_base_mov('C:\...\Tabelle', 'media',  'C:\...\Tabelle_out')
%
%  Serve leggi_media_sd.m e leggi_ttest.m nel path.

if ~exist(out_dir,'dir'); mkdir(out_dir); end
MUS   = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};
MUSEST= {'Erettore Spinale','Bicipite Brachiale','Flessore Radiale del Carpo', ...
         'Deltoide Anteriore','Retto Addominale','Tricipite Brachiale', ...
         'Estensore Radiale del Carpo','Deltoide Posteriore'};
% movimenti: {etichetta, nome-file}
MOV = {'Adduzione','Adduzione'; 'Adduzione orizz.','Adduzione_orizzontale'; ...
       'Flessione','Flessione'; 'Circ. avanti','Circ_Avanti'; ...
       'Circ. indietro','Circ_Indietro'; 'Reach','Reach'; 'Grasp','Grasp'};
nMov=size(MOV,1);
pre = tipo;   % 'ampMax' o 'media'
titolo_par = 'Ampiezza massima'; if strcmpi(tipo,'media'); titolo_par='Media'; end

out = fullfile(out_dir, [pre '_tabella.xlsx']);
if exist(out,'file'); delete(out); end

CELLE = {};   % accumulo tutte le righe (tabelle impilate)
for mi = 1:numel(MUS)
    nome_mus = MUSEST{mi};
    % intestazione a 2 righe
    CELLE(end+1,:) = pad7({sprintf('%s — %s', titolo_par, nome_mus)}); %#ok<AGROW> titolo tabella
    CELLE(end+1,:) = pad7({'', 'Sani vs T0','', 'Sani vs T1','', 'T0 vs T1',''}); %#ok<AGROW>
    CELLE(end+1,:) = pad7({'Movimento','Sani','T0','Sani','T1','T0','T1'}); %#ok<AGROW>
    for k=1:nMov
        nome_ex = sprintf('%s_%s', pre, MUS{mi});
        RAW = carica_excel(cartella_excel, MOV{k,2});
        v={'','',''}; sig=false(1,3);
        if ~isempty(RAW)
            [mu,sd]=leggi_media_sd(RAW,nome_ex); v=fmt3(mu,sd); sig=leggi_ttest(RAW,nome_ex);
        end
        r6 = riga_6col(v,sig);
        CELLE(end+1,:) = [{MOV{k,1}}, r6]; %#ok<AGROW>
    end
    CELLE(end+1,:) = pad7({''}); %#ok<AGROW> riga vuota tra tabelle
end

writecell(CELLE, out, 'Sheet', titolo_par);
fprintf('[tabella_base_mov] %s: scritto %s (%d muscoli)\n', tipo, out, numel(MUS));
end

%% ---------------------------------------------------------
function c = pad7(x)
c = repmat({''},1,7); c(1:numel(x))=x;
end

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
