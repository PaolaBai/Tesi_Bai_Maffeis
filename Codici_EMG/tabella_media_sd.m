function tabella_media_sd(DATA, cartella_excel, movimento, out_dir, lato_paz, RICOSTRUZIONE)
%TABELLA_MEDIA_SD  Costruisce la tabella riassuntiva di un movimento con, per
%  ogni indice e ciascun gruppo (Sani, T0, T1), il valore "media (SD)" seguito
%  da '*' se statisticamente significativo.
%
%  I valori (media, SD) sono RICALCOLATI dal DATA (numeri puliti), perche' le SD
%  nei file Excel hanno il separatore decimale corrotto. La SIGNIFICATIVITA' (gli
%  asterischi) e' invece letta dal file <movimento>_tab.xlsx.
%
%  Un foglio Excel per blocco: valori base, co-contrazione (per sottogruppo),
%  sinergie. Righe = indici; colonne = Sani, T0, T1.
%
%  USO
%    tabella_media_sd(DATA, cartella_excel, 'Addu', out_dir, lato_paz)
%    tabella_media_sd(DATA, cartella_excel, 'Reach', out_dir, lato_paz)
%
%  movimento: nome-file ('Addu','Circ_Avanti','RandG_R'...).
%  RICOSTRUZIONE (opzionale): output di vaf_crossfit, per includere il VAF.

if nargin < 5 || isempty(lato_paz); lato_paz = struct(); end
if nargin < 6; RICOSTRUZIONE = []; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};
SG  = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
IND_CC = {'FWHM','CoA','TMCi','Rud','FW'};
grp = {{'Sani','T'}, {'Patologici','T0'}, {'Patologici','T1'}};
gcol = {'Sani','T0','T1'};

[mov_data, fase_base, fasi_cc_lab, fasi_cc_sfx, pref, is_randg] = mappa(movimento);
out = fullfile(out_dir, [movimento '_tabella.xlsx']);
if exist(out,'file'); delete(out); end

% ===== VALORI BASE: un foglio per indice (ampMax, media, onset) =====
for campo = {'amp_max_uV','media_uV','onset_pct'}
    pre = strrep(strrep(strrep(campo{1},'amp_max_uV','ampMax'),'media_uV','media'),'onset_pct','onset');
    righe = {}; nomi_riga = {};
    for mi = 1:numel(MUS)
        nome_ex = sprintf('%s_%s', pre, MUS{mi});
        [v, sig] = val_sig(cartella_excel, movimento, nome_ex);
        righe(end+1,:) = riga_6col(v, sig); nomi_riga{end+1} = nome_ex; %#ok<AGROW>
    end
    scrivi_foglio6(out, pre, nomi_riga, righe);
end

% ===== SINERGIE: un foglio per k, + VAF =====
for kk = {'k_AIC','k_VAF','k_VAF90'}
    pre = strrep(strrep(strrep(kk{1},'k_AIC','kAIC'),'k_VAF90','kVAF90'),'k_VAF','kVAF');
    righe = {}; nomi_riga = {};
    for fi = 1:numel(fasi_cc_lab)
        if ~is_randg && fi>1; break; end
        if is_randg; nome_ex = sprintf('%s_%s', pre, fasi_cc_lab{fi});
        else;        nome_ex = sprintf('%s_Totale', pre); end
        fase_k = costruisci_fase_cc(pref, fasi_cc_sfx{fi}, is_randg);
        [v, sig] = val_sig(cartella_excel, movimento, nome_ex);
        righe(end+1,:) = riga_6col(v, sig); nomi_riga{end+1} = nome_ex; %#ok<AGROW>
    end
    scrivi_foglio6(out, pre, nomi_riga, righe);
end
if ~isempty(RICOSTRUZIONE)
    [v, sig] = val_sig(cartella_excel, movimento, 'VAF');
    scrivi_foglio6(out, 'VAF', {'VAF'}, riga_6col(v, sig));
end

% ===== CO-CONTRAZIONE: un foglio per indice; righe = indice_sottogruppo_fase =====
for ii = 1:numel(IND_CC)
    righe = {}; nomi_riga = {};
    for s = 1:numel(SG)
        for fi = 1:numel(fasi_cc_lab)
            nome_ex = sprintf('%s_%s_%s', IND_CC{ii}, SG{s}, fasi_cc_lab{fi});
            fase = costruisci_fase_cc(pref, fasi_cc_sfx{fi}, is_randg);
            [v, sig] = val_sig(cartella_excel, movimento, nome_ex);
            righe(end+1,:) = riga_6col(v, sig); nomi_riga{end+1} = nome_ex; %#ok<AGROW>
        end
    end
    scrivi_foglio6(out, IND_CC{ii}, nomi_riga, righe);
end

fprintf('[tabella_media_sd] scritto: %s\n', out);
end

%% ========================================================= mappatura movimento
function [mov_data, fase_base, lab, sfx, pref, is_randg] = mappa(movimento)
if any(strcmp(movimento,{'Reach','Grasp'})) || strncmp(movimento,'RandG_',6)
    is_randg=true; mov_data='RandG'; pref='';
    % fasi (etichette Excel) del RandG: acc/dec/tot x andata/ritorno
    lab={'acc_andata','dec_andata','tot_andata','acc_ritorno','dec_ritorno','tot_ritorno'};
    sfx=lab;                          % i nomi indice nel file usano le stesse etichette
    fase_base=lab{3};                 % 'tot_andata' come fase di riferimento (per i valori base)
elseif strcmp(movimento,'Circ_Avanti')
    is_randg=false; mov_data='Circ'; pref='R'; fase_base='RAvanti_Intero';
    lab={'Andata','Ritorno','Totale'}; sfx={'Avanti_Salita','Avanti_Discesa','Avanti_Intero'};
elseif strcmp(movimento,'Circ_Indietro')
    is_randg=false; mov_data='Circ'; pref='R'; fase_base='RIndietro_Intero';
    lab={'Andata','Ritorno','Totale'}; sfx={'Indietro_Salita','Indietro_Discesa','Indietro_Intero'};
else
    is_randg=false; mov_data=movimento; pref='R'; fase_base='R_Intero';
    lab={'Andata','Ritorno','Totale'}; sfx={'_Salita','_Discesa','_Intero'};
end
end

function fase = costruisci_fase_cc(pref, sfx, is_randg)
if is_randg; fase=sfx; else; fase=[pref sfx]; end
end

%% ========================================================= lettori dal DATA
function fase_s = fase_lato(fase, gruppo, sog, lato_paz, is_randg)
fase_s=fase;
if ~strcmpi(gruppo,'Sani') && ~is_randg && isfield(lato_paz,sog) && strcmpi(lato_paz.(sog),'L')
    fase_s=regexprep(fase,'^R','L');
end
end

function [v, sig] = val_sig(cartella, movimento, nome_ex)
% legge media(SD) formattata per i 3 gruppi e la significativita' dal file Excel.
% v = {Sani, T0, T1} stringhe "media (SD)"; sig = [1x3] da t-test.
v = {'','',''}; sig = false(1,3);
RAW = carica_excel(cartella, movimento);
if isempty(RAW); return; end
[mu, sd] = leggi_media_sd(RAW, nome_ex);
for g = 1:3
    if isfinite(mu(g))
        if isfinite(sd(g)); v{g} = sprintf('%.2f (%.2f)', mu(g), sd(g));
        else;               v{g} = sprintf('%.2f', mu(g)); end
    end
end
sig = leggi_ttest(RAW, nome_ex);
end

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

function s = fmt(vals)
% "media (SD)" dai valori per soggetto; '' se vuoto.
vals=vals(isfinite(vals));
if isempty(vals); s=''; return; end
m=mean(vals); if numel(vals)>1; sd=std(vals); else; sd=0; end
s=sprintf('%.2f (%.2f)', m, sd);
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

%% ========================================================= layout 6 colonne
function r = riga_6col(v, sig)
% v = {Sani, T0, T1} stringhe. sig = [Sani-T0, Sani-T1, T0-T1].
% layout: [Sani(vs T0) T0 | Sani(vs T1) T1 | T0(vs T1) T1], '*' su entrambi i
% valori della coppia quando quel confronto e' significativo.
S=v{1}; T0=v{2}; T1=v{3};
% blocco Sani vs T0
a1=S; a2=T0; if sig(1); a1=ast(a1); a2=ast(a2); end
% blocco Sani vs T1
b1=S; b2=T1; if sig(2); b1=ast(b1); b2=ast(b2); end
% blocco T0 vs T1
c1=T0; c2=T1; if sig(3); c1=ast(c1); c2=ast(c2); end
r = {a1,a2,b1,b2,c1,c2};
end

function s = ast(s)
if ~isempty(s); s=[s '*']; end
end

function scrivi_foglio6(out, foglio, nomi_riga, righe)
% scrive la tabella a 6 colonne con intestazione a 2 righe.
if isempty(righe); return; end
if ~iscell(nomi_riga); nomi_riga = {nomi_riga}; end
if size(righe,1) ~= numel(nomi_riga) && numel(righe)==6; righe = reshape(righe,1,6); end
foglio = foglio(1:min(end,31));
% riga 1 intestazione: confronti (sopra le coppie)
h1 = {'', 'Sani vs T0','', 'Sani vs T1','', 'T0 vs T1',''};
% riga 2 intestazione: gruppi
h2 = {'Parametro', 'Sani','T0', 'Sani','T1', 'T0','T1'};
celle = [h1; h2; [nomi_riga(:), righe]];
writecell(celle, out, 'Sheet', foglio);
end
