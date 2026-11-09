function esporta_jasp(DATA, out_dir, lato_paz, vaf_tab)
%ESPORTA_JASP  Genera i file Excel in formato WIDE (una riga per soggetto) per JASP.
%  7 file, ognuno con 3 fogli (Sani, T0, T1):
%    Flex, Addu, Addu_orizz         -> 3 fasi: Andata/Ritorno/Totale
%    Circ_Avanti, Circ_Indietro     -> 3 fasi (Avanti/Indietro divisi in 2 file)
%    RandG_R, RandG_G               -> 6 fasi: acc/dec/tot x andata/ritorno
%
%  COLONNE (in ordine):
%    ID, Condizione,
%    valori base su fase Intero (Completo_Intero per RandG): ampMax/media/onset
%      x 8 muscoli (sigle ES BB FRC DA RA TB ERC DP),
%    blocco co-contrazione ripetuto per i 7 sottogruppi: FWHM,CoA,TMCi,Rud,Kel,FW,Unn
%      x fasi,
%    k (kAIC,kVAF,kVAF90) x fasi,
%    VAF (cross-fitting, se fornita vaf_tab).
%
%  USO
%    esporta_jasp(DATA, 'C:\...\JASP', lato_paz)
%    esporta_jasp(DATA, 'C:\...\JASP', lato_paz, RICOSTRUZIONE.TAB)   % R.TAB da vaf_crossfit
%
%  Pazienti: lato affetto via lato_paz (swap R->L) per i movimenti normali e il
%  Circ; NESSUNO swap per il RandG (R/G = reach/grasp, non lato).

if nargin < 3 || isempty(lato_paz); lato_paz = struct(); end
if nargin < 4; vaf_tab = []; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};          % sigle 8 muscoli (in ordine canali)
SG  = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
IND = {'FWHM','CoA','TMCi','Rud','Kel','FW','Unn'};         % ordine indici co-contrazione
KK  = {'kAIC','kVAF','kVAF90'};  KF = {'k_AIC','k_VAF','k_VAF90'};

% --- definizione dei 7 file: nome, prefisso fase-lato, mappa fasi (etichetta->suffisso) ---
% suffisso e' cio' che segue il prefisso di lato (R/L o R/G) per formare la fase reale.
FILES = {
  'Flex',        'normale', 'Flex',       {'Andata','_Salita';'Ritorno','_Discesa';'Totale','_Intero'}
  'Addu',        'normale', 'Addu',       {'Andata','_Salita';'Ritorno','_Discesa';'Totale','_Intero'}
  'Addu_orizz',  'normale', 'Addu_orizz', {'Andata','_Salita';'Ritorno','_Discesa';'Totale','_Intero'}
  'Circ_Avanti', 'circ',    'Circ',       {'Andata','Avanti_Salita';'Ritorno','Avanti_Discesa';'Totale','Avanti_Intero'}
  'Circ_Indietro','circ',   'Circ',       {'Andata','Indietro_Salita';'Ritorno','Indietro_Discesa';'Totale','Indietro_Intero'}
  'RandG_R',     'randg',   'RandG',      {'acc_andata','RAndata_Salita';'dec_andata','RAndata_Discesa';'tot_andata','RAndata_Intero';'acc_ritorno','RRitorno_Salita';'dec_ritorno','RRitorno_Discesa';'tot_ritorno','RRitorno_Intero'}
  'RandG_G',     'randg',   'RandG',      {'acc_andata','GAndata_Salita';'dec_andata','GAndata_Discesa';'tot_andata','GAndata_Intero';'acc_ritorno','GRitorno_Salita';'dec_ritorno','GRitorno_Discesa';'tot_ritorno','GRitorno_Intero'}
};

for fi = 1:size(FILES,1)
    nome_file = FILES{fi,1}; tipo = FILES{fi,2}; mov = FILES{fi,3}; mappa = FILES{fi,4};
    fasi_lab = mappa(:,1)';        % etichette colonna (Andata, Ritorno, ...)
    fasi_suf = mappa(:,2)';        % suffisso fase

    % --- intestazione colonne (uguale per i 3 fogli) ---
    hdr = {'ID','Condizione'};
    % valori base per muscolo
    for vb = {'ampMax','media','onset'}
        for m = 1:numel(MUS); hdr{end+1} = sprintf('%s_%s', vb{1}, MUS{m}); end %#ok<AGROW>
    end
    % co-contrazione: per sottogruppo, per indice, per fase
    for g = 1:numel(SG)
        for ii = 1:numel(IND)
            for f = 1:numel(fasi_lab)
                hdr{end+1} = sprintf('%s_%s_%s', IND{ii}, SG{g}, fasi_lab{f}); %#ok<AGROW>
            end
        end
    end
    % k per fase
    for kk = 1:numel(KK)
        for f = 1:numel(fasi_lab); hdr{end+1} = sprintf('%s_%s', KK{kk}, fasi_lab{f}); end %#ok<AGROW>
    end
    hdr{end+1} = 'VAF';

    % --- costruisci i 3 fogli ---
    fogli = {'Sani','T0','T1'};
    dati = struct();
    for sh = 1:3
        foglio = fogli{sh};
        [gruppo, tempo, cond] = mappa_foglio(foglio);
        righe = costruisci_righe(DATA, gruppo, tempo, cond, tipo, mov, fasi_suf, ...
                    MUS, SG, IND, KF, lato_paz, vaf_tab, nome_file, hdr);
        dati.(foglio) = [hdr; righe];
    end

    % --- scrivi il file (3 fogli) ---
    out = fullfile(out_dir, [nome_file '.xlsx']);
    if exist(out,'file'); delete(out); end
    writecell(dati.Sani, out, 'Sheet', 'Sani');
    writecell(dati.T0,   out, 'Sheet', 'T0');
    writecell(dati.T1,   out, 'Sheet', 'T1');
    fprintf('[%s] scritto: %s  (Sani %d, T0 %d, T1 %d righe dati)\n', nome_file, out, ...
        size(dati.Sani,1)-1, size(dati.T0,1)-1, size(dati.T1,1)-1);
end
end

%% =========================================================
function [gruppo, tempo, cond] = mappa_foglio(foglio)
switch foglio
    case 'Sani'; gruppo='Sani';       tempo='T';  cond='sano';
    case 'T0';   gruppo='Patologici'; tempo='T0'; cond='patologico';
    case 'T1';   gruppo='Patologici'; tempo='T1'; cond='patologico';
end
end

%% =========================================================
function righe = costruisci_righe(DATA, gruppo, tempo, cond, tipo, mov, fasi_suf, ...
                    MUS, SG, IND, KF, lato_paz, vaf_tab, nome_file, hdr)
righe = {};
if ~isfield(DATA, gruppo); return; end
sogg = fieldnames(DATA.(gruppo));
ncol = numel(hdr);

for s = 1:numel(sogg)
    Snm = sogg{s};
    if ~isfield(DATA.(gruppo).(Snm), tempo); continue; end
    st = DATA.(gruppo).(Snm).(tempo);
    if ~isstruct(st) || ~isfield(st, mov); continue; end
    M = st.(mov);

    % --- prefisso di lato per formare le fasi ---
    % normali/circ: R per sani, lato affetto per pazienti (swap R->L).
    % randg: nessun prefisso di lato (le fasi contengono gia' R/G = reach/grasp).
    is_randg = strcmp(tipo,'randg');
    if is_randg
        pref = '';
    else
        lato = 'R';
        if ~strcmp(gruppo,'Sani') && isfield(lato_paz, Snm); lato = upper(lato_paz.(Snm)); end
        pref = lato;   % 'R' o 'L'
    end
    % fase base (Intero) per i valori base
    if is_randg
        fase_base = 'Completo_Intero';
    else
        fase_base = [pref '_Intero'];
        if strcmp(tipo,'circ')
            % direzione corretta per ciascun file (Avanti o Indietro)
            if ~isempty(strfind(nome_file,'Indietro')); dir_circ='Indietro'; else; dir_circ='Avanti'; end
            fase_base = [pref dir_circ '_Intero'];   % es. 'R' + 'Indietro' + '_Intero'
        end
    end

    row = cell(1, ncol);
    row{1} = Snm; row{2} = cond;
    col = 3;

    % --- valori base (ampMax, media, onset) per muscolo, sulla fase Intero ---
    B = leggi_base(M, fase_base);
    for campo = {'amp_max_uV','media_uV','onset_pct'}
        for m = 1:numel(MUS)
            v = NaN; if ~isempty(B) && isfield(B, campo{1}) && m <= numel(B.(campo{1})); v = B.(campo{1})(m); end
            row{col} = v; col = col+1;
        end
    end

    % --- co-contrazione: per sottogruppo, per indice, per fase ---
    lab = cellstr(M.phase_labels);
    for g = 1:numel(SG)
        for ii = 1:numel(IND)
            for f = 1:numel(fasi_suf)
                fase = nome_fase(pref, fasi_suf{f}, is_randg);
                row{col} = media_indice(M, SG{g}, IND{ii}, fase, lab);
                col = col+1;
            end
        end
    end

    % --- k per fase ---
    for kk = 1:numel(KF)
        for f = 1:numel(fasi_suf)
            fase = nome_fase(pref, fasi_suf{f}, is_randg);
            row{col} = leggi_k(M, KF{kk}, fase); col = col+1;
        end
    end

    % --- VAF cross-fitting (dalla tabella vaf_tab, se fornita) ---
    row{col} = cerca_vaf(vaf_tab, Snm, tempo, mov, pref, is_randg);

    righe(end+1,:) = row; %#ok<AGROW>
end
end

%% =========================================================
function fase = nome_fase(pref, suf, is_randg)
% costruisce il nome fase reale dal prefisso di lato e dal suffisso.
if is_randg
    fase = suf;                 % suf e' gia' la fase completa (es. RAndata_Salita)
elseif suf(1)=='_'
    fase = [pref suf];          % es. 'R' + '_Salita' = 'R_Salita'
else
    fase = [pref suf];          % es. 'R' + 'Avanti_Salita' = 'RAvanti_Salita'
end
end

function B = leggi_base(M, fase)
B = [];
if isfield(M,'base') && isfield(M.base, fase); B = M.base.(fase); end
end

function v = media_indice(M, SG, nm, fase, lab)
v = NaN;
if ~isfield(M, SG) || ~isfield(M.(SG), nm); return; end
j = find(strcmp(lab, fase), 1); if isempty(j); return; end
A = M.(SG).(nm); if j > size(A,2); return; end
x = double(A(:,j)); x = x(isfinite(x)); if ~isempty(x); v = mean(x); end
end

function v = leggi_k(M, campo, fase)
v = NaN;
if ~isfield(M,'sinergie') || ~isfield(M.sinergie, campo); return; end
lab = cellstr(M.sinergie.phase_labels); j = find(strcmp(lab, fase),1); if isempty(j); return; end
K = M.sinergie.(campo);
if size(K,1)==1; if j<=size(K,2); v = K(1,j); end
else; if j<=size(K,2); v = round(mean(K(:,j),'omitnan')); end; end
end

function v = cerca_vaf(vaf_tab, sog, tempo, mov, pref, is_randg)
% cerca nella tabella di vaf_crossfit il VAF per (soggetto, timepoint, movimento).
v = NaN;
if isempty(vaf_tab); return; end
% supporta sia table sia cell array [intest; righe]
if istable(vaf_tab)
    C = [vaf_tab.Properties.VariableNames; table2cell(vaf_tab)];
else
    C = vaf_tab;
end
col = @(nm) find(strcmp(C(1,:), nm),1);
cS=col('soggetto'); cT=col('timepoint'); cM=col('mov'); cV=col('VAF');
if isempty(cS)||isempty(cT)||isempty(cM)||isempty(cV); return; end
for r = 2:size(C,1)
    if strcmp(C{r,cS},sog) && strcmp(C{r,cT},tempo) && strcmp(C{r,cM},mov)
        v = C{r,cV}; return;
    end
end
end
