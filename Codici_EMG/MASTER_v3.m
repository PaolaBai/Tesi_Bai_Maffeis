%% =========================================================
%  MASTER PIPELINE v3 - EMG + Co-attivazione + Sinergie
%  =========================================================
%  STRUTTURA CARTELLE ATTESA
%    <root_dir>/<Gruppo>/<Soggetto>/<Timepoint>/
%       <cod>_<mov>_EMG.emt   8 canali EMG continui, lato destro
%       <cod>_<mov>.emt       eventi con Start/Stop/Mid per gruppo
%
%    Patologici: due timepoint reali (T0 = pre-riabilitazione,
%                                     T1 = post-riabilitazione)
%    Sani:       un timepoint fittizio chiamato 'T'
%    La struttura e' uniforme per entrambi i gruppi: cosi' le funzioni
%    a valle non devono indovinare la profondita' della struct.
%
%  STRUTTURA OUTPUT
%    DATA.<Gruppo>.<Soggetto>.<Timepoint>.<Movimento>
%
%  DISEGNO DELLO STUDIO — NOTA IMPORTANTE
%  I pazienti e i sani sono stati acquisiti in LABORATORI DIVERSI:
%  il confronto tra gruppi e' confondato dal sito (elettrodi,
%  amplificatore, impedenza, rumore ambientale). Regge tutto cio' che e'
%  normalizzato ENTRO soggetto (TMCi, indici AA, CoA, FWHM, numero di
%  sinergie): la normalizzazione al picco dinamico divide ogni muscolo
%  per il proprio massimo, quindi guadagno e unita' si semplificano.
%  NON reggono i confronti su ampiezze assolute o linea di base.
%  Il confronto PRE/POST nei pazienti e' invece immune al confondente
%  (stesso soggetto, stesso laboratorio) ed e' il disegno piu' forte
%  che questi dati permettono.
%
%  SCELTE METODOLOGICHE PRINCIPALI
%   - fs RILEVATO dai dati, mai hardcoded (esistono 1000 e 2000 Hz;
%     con fs fisso la banda 20-300 diventerebbe 40-600 senza errore).
%   - Normalizzazione al picco dinamico UNA volta sull'intera
%     registrazione: preserva il rapporto tra lato attivo e
%     controlaterale (che il vecchio formato a 32 canali distruggeva).
%     Le iMVC non sono eseguibili in riabilitazione (activation deficit).
%   - Split al Mid: ogni ripetizione -> Intero / Salita / Discesa.
%   - Co-attivazione su 7 sottogruppi muscolari.
%   - Sinergie con ripetizioni CONCATENATE (una W per fase).
%
%  MUSCOLI (numerazione di progetto)
%    1 Erettore  2 Bicipite  3 Flessore  4 DeltoideAnt
%    5 Addome    6 Tricipite 7 Estensore 8 DeltoidePos
% =========================================================

clear; clc; close all;

%% ---------------------------------------------------------
%  PARAMETRI
% ---------------------------------------------------------
root_dir = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG';

win_rms_ms = 100;    % [ms] finestra RMS
T_norm     = 100;    % campioni per normalizzazione temporale
                     % NB: verificato che k_AIC e' sensibile a T_norm
                     % (il termine -logL scala con T, NDoF_W = N*k e'
                     % costante, NDoF_C satura ai livelli wavelet
                     % profondi). Si mantiene 100, standard in
                     % letteratura, e si dichiara la sensibilita'.

sinergie_solo_intero = false;   % true = NNMF solo sulle fasi 'Intero'

movimenti = {'Flex','Addu','Addu_orizz','Circ','RandG'};
% RandG: struttura eventi diversa (StartR/StopR/StartG/StopG/MidG), rilevata
% automaticamente dal nome file e gestita da leggi_eventi_randg, che produce
% 4 segmenti: RAndata, GAndata, GRitorno, RRitorno (ognuno Intero/Salita/Discesa).
% R_Concat NON e' costruito (discontinuo). Nessun segmento e' ciclico -> CoA lineare.

gruppi = {'Patologici','Sani'};
% ---------------------------------------------------------

dir_risultati = fullfile(root_dir,'Risultati');
for g = 1:numel(gruppi)
    d = fullfile(dir_risultati, gruppi{g});
    if ~exist(d,'dir'); mkdir(d); end
end

DATA = struct();

%% ---------------------------------------------------------
%  LOOP PRINCIPALE
% ---------------------------------------------------------
for g = 1:numel(gruppi)
    gruppo     = gruppi{g};
    dir_gruppo = fullfile(root_dir, gruppo);

    if ~exist(dir_gruppo,'dir')
        fprintf('Cartella non trovata: %s\n', dir_gruppo); continue;
    end

    sog = elenca_cartelle(dir_gruppo);

    fprintf('\n%s\n  GRUPPO: %s  (%d soggetti)\n%s\n\n', ...
        repmat('=',1,64), gruppo, numel(sog), repmat('=',1,64));

    for s = 1:numel(sog)
        cod_sog = sog{s};
        dir_sog = fullfile(dir_gruppo, cod_sog);

        tp = elenca_cartelle(dir_sog);
        if isempty(tp)
            fprintf('Soggetto %s: nessuna cartella timepoint, saltato\n', cod_sog);
            continue;
        end

        fprintf('Soggetto: %s  (timepoint: %s)\n%s\n', ...
                cod_sog, strjoin(tp,', '), repmat('-',1,44));

        for it = 1:numel(tp)
            timepoint = tp{it};
            dir_tp    = fullfile(dir_sog, timepoint);
            fprintf('  [%s]\n', timepoint);

            for m = 1:numel(movimenti)
                mov = movimenti{m};

                f_emg = fullfile(dir_tp, sprintf('%s_%s_EMG.emt', cod_sog, mov));
                f_ev  = fullfile(dir_tp, sprintf('%s_%s.emt',     cod_sog, mov));

                if ~exist(f_emg,'file')
                    fprintf('    [%s] EMG non trovato\n', mov); continue;
                end
                if ~exist(f_ev,'file')
                    fprintf('    [%s] eventi non trovati\n', mov); continue;
                end

                fprintf('    [%s]\n', mov);

                try
                    elab = elabora_emg(f_emg, f_ev, win_rms_ms, T_norm);
                    res  = calcola_coattivazione(elab, mov, T_norm);
                    syn  = calcola_sinergie(elab, T_norm, sinergie_solo_intero);

                    res.sinergie  = syn;
                    res.timepoint = timepoint;
                    res.gruppo    = gruppo;
                    res.soggetto  = cod_sog;

                    DATA.(gruppo).(cod_sog).(timepoint).(mov) = res;
                    stampa_riepilogo(res, syn);

                catch err
                    fprintf('    ERRORE [%s/%s/%s]: %s\n', ...
                            cod_sog, timepoint, mov, err.message);
                end
            end
        end

        f_out    = fullfile(dir_risultati, gruppo, [cod_sog '_risultati.mat']);
        sog_data = DATA.(gruppo).(cod_sog);
        save(f_out, 'sog_data', 'cod_sog', 'gruppo');
        fprintf('  Salvato: %s\n\n', f_out);
    end
end

save(fullfile(dir_risultati,'DATA_completo.mat'), 'DATA');
fprintf('\nStruttura globale: %s\n', fullfile(dir_risultati,'DATA_completo.mat'));


%% =========================================================
%% ============  ELABORAZIONE EMG  =========================
%% =========================================================

function out = elabora_emg(f_emg, f_ev, win_rms_ms, T_norm)

% --- 1. Caricamento; fs rilevato dai dati ---
[tempo, emg_raw, nomi, unita] = leggi_emg(f_emg);
fs = round(1/median(diff(tempo)));

jit = std(diff(tempo))/median(diff(tempo));
if jit > 0.01
    warning('elabora_emg:fs_instabile', ...
        'Campionamento non uniforme (jitter %.1f%%): fs=%d Hz sospetto', 100*jit, fs);
end
fprintf('      EMG: %d canali, %.1f s, fs=%d Hz, unita'' %s\n', ...
        size(emg_raw,2), tempo(end), fs, unita);

% --- 2. Guardia quantizzazione ---
n_livelli = controlla_quantizzazione(emg_raw, nomi, unita);

% --- 3. Mappa muscoli -> indici 1-8 (per NOME, non per posizione) ---
idx       = mappa_muscoli(nomi);
emg_raw   = emg_raw(:, idx);
nomi      = nomi(idx);
n_livelli = n_livelli(idx);

% --- 4. Pipeline + normalizzazione al picco (UNA volta, 0-100) ---
[emg_norm, picchi_raw] = elabora_canali(emg_raw, fs, win_rms_ms);
[base_mean, base_sd]   = stima_baseline_quiete(emg_norm);   % rumore di fondo per canale (0-100)

% --- 5. Eventi (RandG: struttura diversa, rilevata dal nome file) ---
is_randg = contains(f_ev, 'RandG', 'IgnoreCase', true);
if is_randg
    EV = leggi_eventi_randg(f_ev);   % 4 segmenti RAndata/GAndata/GRitorno/RRitorno
else
    EV = leggi_eventi(f_ev);
end
gruppi = fieldnames(EV);
if isempty(gruppi); error('Nessun gruppo riconosciuto nel file eventi'); end

% --- 6. Segmentazione: n_gruppi x 3 fasi ---
fasi   = {'Intero','Salita','Discesa'};
labels = {}; chiuso = [];
out.emg = struct();

for k = 1:numel(gruppi)
    gr = gruppi{k};
    ev = EV.(gr);
    nr = numel(ev.start);

    bad = ~(ev.start < ev.mid & ev.mid < ev.stop);
    if any(bad)
        warning('elabora_emg:mid', '%s: Mid fuori range nelle rep %s', ...
                gr, mat2str(find(bad)'));
    end

    % la fase 'Completo' (gesto intero del RandG) genera solo Intero
    fasi_gr = fasi;
    if strcmp(gr,'Completo'); fasi_gr = {'Intero'}; end

    E = struct();
    for f = 1:numel(fasi_gr); E.(fasi_gr{f}) = nan(T_norm, 8, nr); end

    for r = 1:nr
        E.Intero(:,:,r) = estrai_fase(emg_norm, tempo, ev.start(r), ev.stop(r), T_norm);
        if numel(fasi_gr) > 1
            E.Salita(:,:,r)  = estrai_fase(emg_norm, tempo, ev.start(r), ev.mid(r), T_norm);
            E.Discesa(:,:,r) = estrai_fase(emg_norm, tempo, ev.mid(r),   ev.stop(r), T_norm);
        end
    end

    for f = 1:numel(fasi_gr)
        nome = [gr '_' fasi_gr{f}];
        out.emg.(nome) = E.(fasi_gr{f});
        labels{end+1}  = nome;                     %#ok<AGROW>
        % RandG: nessun segmento e' un ciclo chiuso -> CoA lineare anche per Intero
        chiuso(end+1)  = strcmp(fasi_gr{f},'Intero') && ~is_randg; %#ok<AGROW>
    end

    dur = ev.stop - ev.start;
    psa = 100*(ev.mid - ev.start)./dur;
    fprintf('      %-11s %5.2f-%5.2f s | %d rep | dur %.2f±%.2f s | salita %.0f%%±%.0f%%\n', ...
        gr, ev.start(1), ev.stop(end), nr, mean(dur), std(dur), mean(psa), std(psa));
end

out.phase_labels = labels;
out.ciclo_chiuso = logical(chiuso);
out.nomi_muscoli = nomi;
out.n_livelli    = n_livelli;
out.picchi_raw   = picchi_raw;
out.picchi_uV    = picchi_raw * fattore_uV(unita);
out.base_quiete_mean = base_mean;    % 0-100, per canale (per soglia onset)
out.base_quiete_sd   = base_sd;
out.eventi       = EV;
out.T_norm       = T_norm;
out.fs           = fs;
out.unita        = unita;
end

%% ---------------------------------------------------------
function [tempo, emg, nomi, unita] = leggi_emg(f)
fid = fopen(f,'r');
if fid < 0; error('File non trovato: %s', f); end
righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);

unita = '?';
i = find(cellfun(@(s) ischar(s) && contains(s,'Measure unit'),righe),1);
if ~isempty(i); p = strsplit(righe{i},sprintf('\t')); unita = strtrim(p{end}); end

i_hdr = find(cellfun(@(s) ischar(s) && contains(s,'Frame') && contains(s,'Time'),righe),1);
if isempty(i_hdr); error('Intestazione colonne non trovata in %s', f); end
p    = strsplit(righe{i_hdr},sprintf('\t'));
p    = p(~cellfun(@isempty,strtrim(p)));
nomi = strtrim(p(3:end));

d     = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');
tempo = d(:,2);
emg   = d(:,3:2+numel(nomi));
end

%% ---------------------------------------------------------
%  Guardia quantizzazione. Un export in V con 3 decimali quantizza la
%  sEMG a ~1 mV e la azzera: va intercettato PRIMA di filtrare,
%  altrimenti la normalizzazione al picco stira il rumore fino a 100 e
%  produce numeri plausibili da dati vuoti (fallimento silenzioso).
%  Tre fasce: unita' V = fatale; <20 livelli = canale morto, fatale;
%  <100 livelli = canale debole, avviso e prosegue (es. Addome, che ha
%  segnale vero ma di ampiezza molto bassa).
function n = controlla_quantizzazione(emg_raw, nomi, unita)
n = arrayfun(@(k) numel(unique(emg_raw(~isnan(emg_raw(:,k)),k))), 1:size(emg_raw,2));

if strcmpi(strtrim(unita),'V')
    error('elabora_emg:unita', ...
      ['Export in Volt: la sEMG viene quantizzata a ~1 mV e azzerata. ' ...
       'Ri-esportare in mV o uV.']);
end

for k = 1:numel(n)
    if n(k) < 20
        error('elabora_emg:quantizzazione', ...
          'Canale "%s" privo di segnale utile (%d livelli distinti).', nomi{k}, n(k));
    elseif n(k) < 100
        fprintf('      ~  %s: canale debole (%d livelli) - verra'' stirato a 100%% dalla normalizzazione\n', ...
                nomi{k}, n(k));
    end
end
end

%% ---------------------------------------------------------
%  Mappa i canali sulla numerazione di progetto per NOME (robusto
%  all'ordine di export). Se un pattern non trova esattamente una
%  corrispondenza, errore: meglio fermarsi che calcolare sul muscolo
%  sbagliato.
%  NB: il canale 7 e' 'Extensor carpi ulnaris' in alcuni file e
%  'Ext.Carp.Rad.' in altri. Sono muscoli DIVERSI: il pattern li accetta
%  entrambi, nascondendo la discrepanza. Da chiarire.
function idx = mappa_muscoli(nomi)
pat = {'Erector|Thoracic\s*Es', ...
       'Biceps', ...
       'Flex.*Carp', ...
       'Deltoideus\s*anterior|Ant.*Deltoid', ...
       'Rect.*Abdom', ...
       'Triceps', ...
       'Ext.*Carp', ...
       'Deltoideus\s*posterior|Post.*Deltoid'};
eti = {'Erettore','Bicipite','Flessore','DeltAnt','Addome','Tricipite','Estensore','DeltPos'};
idx = zeros(1,8);
for k = 1:8
    hit = find(~cellfun(@isempty, regexpi(nomi, pat{k}, 'once')));
    if numel(hit) ~= 1
        error('mappa_muscoli:ambiguo', ...
          '%s: %d corrispondenze in {%s}', eti{k}, numel(hit), strjoin(nomi, ', '));
    end
    idx(k) = hit;
end
end

%% ---------------------------------------------------------
%  notch 50 Hz -> Butterworth 20-300 -> rettifica -> RMS ->
%  normalizzazione al picco (0-100), UNA volta sull'intera traccia
function [emg_norm, picchi_raw] = elabora_canali(emg_raw, fs, win_rms_ms)
win = round(win_rms_ms*fs/1000);
nm  = isnan(emg_raw);
n   = size(emg_raw,2);

w0  = 2*pi*50/fs;  rn = 1-(pi*1/fs);
b_n = [1, -2*cos(w0), 1];
a_n = [1, -2*rn*cos(w0), rn^2];
[b_bp,a_bp] = butter(4,[20 300]/(fs/2),'bandpass');

emg_rms = nan(size(emg_raw));
for k = 1:n
    sg = emg_raw(:,k); sg(isnan(sg)) = 0;
    sg = filtfilt(b_n, a_n, sg);
    sg = filtfilt(b_bp,a_bp,sg);
    sg = abs(sg);
    sg = sqrt(conv(sg.^2, ones(win,1)/win, 'same'));
    sg(nm(:,k)) = NaN;
    emg_rms(:,k) = sg;
end

picchi_raw = max(emg_rms, [], 1, 'omitnan');   % PRIMA della normalizzazione

emg_norm = nan(size(emg_rms));
for k = 1:n
    if picchi_raw(k) > 0
        emg_norm(:,k) = (emg_rms(:,k)/picchi_raw(k))*100;
    end
end
end

%% ---------------------------------------------------------
function f = fattore_uV(unita)
u = lower(strtrim(unita));
if     ~isempty(regexp(u, 'µv|uv|micro', 'once')); f = 1;
elseif ~isempty(regexp(u, 'mv|milli',    'once')); f = 1e3;
elseif ~isempty(regexp(u, 'v|volt',      'once')); f = 1e6;
else;                                              f = NaN;
end
end

%% ---------------------------------------------------------
%  Legge eventi BTS. Ricava i gruppi dai nomi di colonna:
%    'RStartAvanti' -> 'RAvanti' | 'RStart' -> 'R'
%  Funziona sia con 12 colonne (4 gruppi, Circ) sia con 6 (2 gruppi).
function EV = leggi_eventi(f)
fid = fopen(f,'r');
if fid < 0; error('File non trovato: %s', f); end
righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);

i_hdr = find(cellfun(@(s) ischar(s) && startsWith(strtrim(s),'Item'),righe),1);
if isempty(i_hdr); error('Intestazione eventi non trovata in %s', f); end
p    = strsplit(righe{i_hdr},sprintf('\t'));
p    = p(~cellfun(@isempty,strtrim(p)));
cols = strtrim(p(2:end));

d = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');
d = d(all(isfinite(d(:,1:numel(cols)+1)),2), :);

EV = struct();
for c = 1:numel(cols)
    tok = regexp(cols{c},'^([RL])Start(.*)$','tokens','once');
    if isempty(tok); continue; end
    gr = [tok{1} tok{2}];

    i_stop = find(strcmp(cols,[tok{1} 'Stop' tok{2}]),1);
    i_mid  = find(strcmp(cols,[tok{1} 'Mid'  tok{2}]),1);
    if isempty(i_stop) || isempty(i_mid)
        warning('leggi_eventi:incompleto','Gruppo %s: Stop o Mid mancante',gr); continue;
    end

    EV.(gr).start = d(:,c+1);      % +1: la colonna 1 e' 'Item'
    EV.(gr).stop  = d(:,i_stop+1);
    EV.(gr).mid   = d(:,i_mid+1);
end
end

%% ---------------------------------------------------------
%  RandG: eventi StartR/StopR/StartG/StopG/MidG (R=reach, G=grasp) ->
%  4 SEGMENTI in formato standard {start, mid, stop}:
%     RAndata  [StartR -> StartG]   braccio dal fianco all'oggetto  (concentrico)
%     GAndata  [StartG -> MidG]     afferra e porta al petto        (mantenimento+carico)
%     GRitorno [MidG   -> StopG]    riporta l'oggetto in posizione  (mantenimento+carico)
%     RRitorno [StopG  -> StopR]    braccio di nuovo al fianco       (eccentrico)
%  Mid di ogni segmento = picco di velocita' se il file li contiene (colonne
%  Pk*), cosi' Salita/Discesa = Acc/Dec; altrimenti punto medio temporale.
%  R_Concat (RAndata+RRitorno) NON e' costruito: e' discontinuo.
%  Ordine atteso: StartR < StartG < MidG < StopG < StopR.
function EV = leggi_eventi_randg(f)
% --- nomi colonne evento RandG (modifica QUI se nel file differiscono) ---
NC   = {'StartR','StopR','StartG','StopG','MidG'};   % confini dei 4 segmenti
NCpk = {'PkRAnd','PkGAnd','PkGRit','PkRRit'};         % picchi velocita' (Mid=Acc/Dec)

fid = fopen(f,'r');
if fid < 0; error('File non trovato: %s', f); end
righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);

i_hdr = find(cellfun(@(s) ischar(s) && startsWith(strtrim(s),'Item'),righe),1);
if isempty(i_hdr); error('Intestazione eventi non trovata in %s', f); end
p    = strsplit(righe{i_hdr},sprintf('\t'));
p    = p(~cellfun(@isempty,strtrim(p)));
cols = strtrim(p(2:end));

d = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');

for i = 1:numel(NC)
    if isempty(find(strcmp(cols,NC{i}),1))
        error('leggi_eventi_randg:colonna', ...
            'Colonna RandG "%s" non trovata.\nPresenti: %s\nCorreggi NC in leggi_eventi_randg.', ...
            NC{i}, strjoin(cols,', '));
    end
end
col = @(nm) d(:, find(strcmp(cols,nm),1) + 1);   % +1: la colonna 1 e' 'Item'
tSR = col('StartR'); tSG = col('StartG'); tMG = col('MidG');
tPG = col('StopG');  tPR = col('StopR');

ok  = isfinite(tSR)&isfinite(tSG)&isfinite(tMG)&isfinite(tPG)&isfinite(tPR);
tSR=tSR(ok); tSG=tSG(ok); tMG=tMG(ok); tPG=tPG(ok); tPR=tPR(ok);
if isempty(tSR); error('leggi_eventi_randg:vuoto','Nessuna ripetizione RandG valida in %s', f); end

% Mid dei segmenti = picchi di velocita' se il file li contiene (Salita/Discesa
% = Acc/Dec); altrimenti punto medio temporale (due meta').
has_pk = all(cellfun(@(nm) ~isempty(find(strcmp(cols,nm),1)), NCpk));
if has_pk
    Pk = cellfun(@(nm) col(nm), NCpk, 'UniformOutput', false);
    Pk = cellfun(@(v) v(ok),   Pk,   'UniformOutput', false);
end

nome = {'RAndata','GAndata','GRitorno','RRitorno'};
St   = {tSR, tSG, tMG, tPG};    % start dei 4 segmenti
Sp   = {tSG, tMG, tPG, tPR};    % stop  dei 4 segmenti
EV = struct();
for k = 1:4
    st = St{k}; sp = Sp{k};
    if any(sp <= st)
        warning('leggi_eventi_randg:ordine', ...
            'Segmento %s: durate <=0 (mappatura eventi da verificare)', nome{k});
    end
    if has_pk
        md = min(max(Pk{k}, st+eps), sp-eps);   % picco di velocita', entro il segmento
    else
        md = (st + sp)/2;                        % fallback: punto medio
    end
    EV.(nome{k}).start = st;
    EV.(nome{k}).stop  = sp;
    EV.(nome{k}).mid   = md;
end

% fase COMPLETA: intero gesto [StartR, StopR], per i valori base EMG
EV.Completo.start = tSR;
EV.Completo.stop  = tPR;
EV.Completo.mid   = (tSR + tPR)/2;
end

%% ---------------------------------------------------------
function seg_t = estrai_fase(emg_norm, tempo, t0, t1, T_norm)
N = size(emg_norm,2);
seg_t = nan(T_norm,N);
mask = tempo >= t0 & tempo <= t1;
seg  = emg_norm(mask,:);
if size(seg,1) < 2; return; end
xo = linspace(0,1,size(seg,1));
xn = linspace(0,1,T_norm);
for k = 1:N
    c = seg(:,k); c(isnan(c)) = 0;
    seg_t(:,k) = max(0, min(100, interp1(xo,c,xn,'pchip')));
end
end

%% ---------------------------------------------------------
function nomi = elenca_cartelle(d)
x = dir(d);
x = x([x.isdir]);
x = x(~ismember({x.name},{'.','..'}));
nomi = {x.name};
end


%% =========================================================
%% ============  CO-ATTIVAZIONE  ===========================
%% =========================================================

%  Sottogruppi. ext/flex ereditati per intersezione dalla partizione
%  globale estensori [1 6 7 8] / flessori [2 3 4 5].
%  NB: e' una partizione ANATOMICA, non funzionale. In tesi scrivere
%  "gruppo estensore vs gruppo flessore", non "agonisti vs antagonisti":
%  l'agonista dipende dal movimento.
function SG = definisci_sottogruppi()
SG = struct( ...
 'Globale',      struct('mus',[1 2 3 4 5 6 7 8],'ext',[1 6 7 8],'flex',[2 3 4 5]), ...
 'Tronco',       struct('mus',[1 5],            'ext',1,        'flex',5), ...
 'Braccio',      struct('mus',[2 3 4 6 7 8],    'ext',[6 7 8],  'flex',[2 3 4]), ...
 'Spalla',       struct('mus',[4 8],            'ext',8,        'flex',4), ...
 'Gomito',       struct('mus',[2 6],            'ext',6,        'flex',2), ...
 'Polso',        struct('mus',[3 7],            'ext',7,        'flex',3), ...
 'SpallaGomito', struct('mus',[4 8 2 6],        'ext',[8 6],    'flex',[4 2]) );
end

%% ---------------------------------------------------------
function res = calcola_coattivazione(elab, mov, T_norm)

SG     = definisci_sottogruppi();
nomiG  = fieldnames(SG);
labels = elab.phase_labels;
np_ph  = numel(labels);
n_rep  = size(elab.emg.(labels{1}), 3);

for g = 1:numel(nomiG)
    nm = nomiG{g};
    res.(nm).TMCi       = nan(n_rep,np_ph);
    res.(nm).FWHM       = nan(n_rep,np_ph);
    res.(nm).CoA        = nan(n_rep,np_ph);
    res.(nm).Rud        = nan(n_rep,np_ph);
    res.(nm).Kel        = nan(n_rep,np_ph);
    res.(nm).Kel_ok     = false(n_rep,np_ph);
    res.(nm).Kel_scambi = nan(n_rep,np_ph);
    res.(nm).FW         = nan(n_rep,np_ph);
    res.(nm).Unn        = nan(n_rep,np_ph);
    res.(nm).TMCf       = nan(T_norm,n_rep,np_ph);
    res.(nm).N          = numel(SG.(nm).mus);
end

for ph = 1:np_ph
    E  = elab.emg.(labels{ph});
    nr = size(E,3);
    cc = elab.ciclo_chiuso(ph);     % CoA circolare solo su 'Intero'
    for r = 1:nr
        R = calcola_indici_rep(squeeze(E(:,:,r)), T_norm, SG, cc);
        for g = 1:numel(nomiG)
            nm = nomiG{g};
            res.(nm).TMCi(r,ph)       = R.(nm).TMCi;
            res.(nm).FWHM(r,ph)       = R.(nm).FWHM;
            res.(nm).CoA(r,ph)        = R.(nm).CoA;
            res.(nm).Rud(r,ph)        = R.(nm).Rud;
            res.(nm).Kel(r,ph)        = R.(nm).Kel;
            res.(nm).Kel_ok(r,ph)     = R.(nm).Kel_ok;
            res.(nm).Kel_scambi(r,ph) = R.(nm).Kel_scambi;
            res.(nm).FW(r,ph)         = R.(nm).FW;
            res.(nm).Unn(r,ph)        = R.(nm).Unn;
            res.(nm).TMCf(:,r,ph)     = R.(nm).TMCf;
        end
    end
end

% ---- valori base EMG per muscolo (ampiezza max, onset, media), in uV ----
% Sul ciclo intero: 'Completo_Intero' per il RandG, i '*_Intero' per gli altri.
is_randg_res = any(strcmp(labels, 'Completo_Intero'));
res.base = struct();
for ph = 1:np_ph
    nomeph = labels{ph};
    e_intero = ~isempty(regexp(nomeph, '_Intero$', 'once'));
    if is_randg_res
        usa = strcmp(nomeph, 'Completo_Intero');
    else
        usa = e_intero;
    end
    if ~usa; continue; end
    res.base.(nomeph) = calcola_base_emg(elab.emg.(nomeph), elab.picchi_uV, ...
                          elab.base_quiete_mean, elab.base_quiete_sd);
end

res.phase_labels = labels;
res.ciclo_chiuso = elab.ciclo_chiuso;
res.sottogruppi  = nomiG;
res.movimento    = mov;
res.nomi_muscoli = elab.nomi_muscoli;
res.n_livelli    = elab.n_livelli;
res.picchi_raw   = elab.picchi_raw;
res.picchi_uV    = elab.picchi_uV;
res.fs           = elab.fs;
res.unita        = elab.unita;
end

%% ---------------------------------------------------------
%  Stima del rumore di fondo per canale (scala 0-100), dal decile piu' basso
%  dell'inviluppo continuo (i tratti di quiete tra le ripetizioni). Serve alla
%  soglia di onset media+3*SD (Hodges & Bui 1996).
function [bmean, bsd] = stima_baseline_quiete(emg_norm)
n = size(emg_norm,2);
bmean = nan(1,n); bsd = nan(1,n);
for k = 1:n
    x = emg_norm(:,k); x = x(isfinite(x));
    if numel(x) < 10; continue; end
    xs = sort(x);
    q  = xs(max(1, round(0.10*numel(xs))));   % soglia del decile piu' basso
    lo = x(x <= q);
    if numel(lo) < 3; lo = x; end
    bmean(k) = mean(lo);
    bsd(k)   = std(lo);
end
end

%% ---------------------------------------------------------
%  Valori base EMG per muscolo, sul ciclo intero, mediati sulle ripetizioni.
%    E         [T_norm x 8 x nrep], scala 0-100 (peak-normalizzata)
%    picchi_uV [1 x 8]  picco per canale in uV (per de-normalizzare)
%    bmean,bsd [1 x 8]  baseline di quiete (0-100) per la soglia onset
%  Ritorna vettori 1x8 (per muscolo): media sui cicli e deviazione standard.
%    amp_max_uV  ampiezza massima (uV)
%    onset_pct   timing di attivazione (% della durata del ciclo), media+3SD
%    media_uV    valore medio dell'inviluppo (uV)
function B = calcola_base_emg(E, picchi_uV, bmean, bsd)
[T_norm, nmus, nrep] = size(E);
thr = bmean + 3*bsd;                       % soglia onset (0-100), per canale
w   = max(1, round(0.03*T_norm));          % permanenza minima sopra soglia (~3%)

amp = nan(nrep, nmus); med = nan(nrep, nmus); ons = nan(nrep, nmus);
for r = 1:nrep
    for c = 1:nmus
        x100 = E(:,c,r);
        xuv  = x100/100 * picchi_uV(c);    % de-normalizzazione in uV
        amp(r,c) = max(xuv);
        med(r,c) = media_no_nan(xuv);
        ons(r,c) = onset_percento(x100, thr(c), w);
    end
end

B.amp_max_uV = zeros(1,nmus); B.amp_max_uV_sd = zeros(1,nmus);
B.onset_pct  = zeros(1,nmus); B.onset_pct_sd  = zeros(1,nmus);
B.media_uV   = zeros(1,nmus); B.media_uV_sd   = zeros(1,nmus);
B.onset_n_valid = zeros(1,nmus);
for c = 1:nmus
    B.amp_max_uV(c)    = media_no_nan(amp(:,c));  B.amp_max_uV_sd(c) = dev_no_nan(amp(:,c));
    B.media_uV(c)      = media_no_nan(med(:,c));  B.media_uV_sd(c)   = dev_no_nan(med(:,c));
    B.onset_pct(c)     = media_no_nan(ons(:,c));  B.onset_pct_sd(c)  = dev_no_nan(ons(:,c));
    B.onset_n_valid(c) = sum(isfinite(ons(:,c)));
end
end

%% ---------------------------------------------------------
%  Onset: primo istante (% del ciclo) in cui il canale supera la soglia e ci
%  resta per almeno w campioni. NaN se e' gia' sopra all'inizio (muscolo attivo
%  da subito, es. stabilizzatori del tronco) o se non la supera mai.
function p = onset_percento(x, thr, w)
T = numel(x);
if ~isfinite(thr); p = NaN; return; end
above = x > thr;
if above(1); p = NaN; return; end
idx = [];
for i = 1:T-w+1
    if all(above(i:i+w-1)); idx = i; break; end
end
if isempty(idx); p = NaN; else; p = 100*(idx-1)/(T-1); end
end

function m = media_no_nan(v)
v = v(isfinite(v)); if isempty(v); m = NaN; else; m = mean(v); end
end
function s = dev_no_nan(v)
v = v(isfinite(v)); if numel(v) < 2; s = NaN; else; s = std(v); end
end

%% ---------------------------------------------------------
%  Indici per UNA ripetizione, su TUTTI i sottogruppi.
%  EMG in ingresso: [T_norm x 8], scala 0-100.
function R = calcola_indici_rep(EMG, T_norm, SG, ciclo_chiuso)

nomi = fieldnames(SG);
R    = struct();

for g = 1:numel(nomi)
    nm  = nomi{g};
    mus = SG.(nm).mus;
    E   = EMG(:,mus);

    % ---------- TMCf (Ranavolo et al. 2015) ----------
    % TMCf = C(d(t)) * m(t) * cc(t), con EMG in 0-100.
    % NESSUN /100 sull'EMG e NESSUN *100 sul TMCi: il range 0-100 e'
    % ereditato dalla scala dell'input. (Bug storico corretto.)
    TMCf = nan(T_norm,1);
    for t = 1:T_norm
        e = E(t,:);
        e = e(isfinite(e));
        n = numel(e);
        if n < 2; continue; end

        ds = 0; npr = 0;
        for i = 1:n-1
            for j = i+1:n
                ds  = ds + abs(e(i)-e(j));
                npr = npr + 1;
            end
        end

        d_t  = ds/(100*npr);                    % media differenze, 0-1
        C_dt = 1 - 1/(1+exp(-12*(d_t-0.5)));
        m_t  = sum(e)/n;                        % media, 0-100
        mx   = max(e);
        cc_t = 0; if mx > eps; cc_t = m_t/mx; end

        TMCf(t) = C_dt * m_t * cc_t;
    end

    R.(nm).TMCf = TMCf;
    R.(nm).TMCi = mean(TMCf,'omitnan');
    R.(nm).N    = numel(mus);
    R.(nm).FWHM = calcola_FWHM(TMCf, T_norm);
    R.(nm).CoA  = calcola_CoA(TMCf, T_norm, ciclo_chiuso);

    % ---------- Indici agonista-antagonista ----------
    M1 = mean(EMG(:,SG.(nm).ext), 2,'omitnan');    % estensori
    M2 = mean(EMG(:,SG.(nm).flex),2,'omitnan');    % flessori

    R.(nm).Rud = indice_rudolph(M1,M2,T_norm);
    R.(nm).FW  = indice_falconer_winter(M1,M2);
    R.(nm).Unn = indice_unnithan(M1,M2);
    R.(nm).Kel = indice_kellis(M1,M2);             % SEMPRE calcolato

    % Validita' di Kellis: e' l'unico dei quattro ASIMMETRICO in M1/M2,
    % quindi l'unico invalidato quando i ruoli si invertono (Circ,
    % R_Concat). Si contano le inversioni di dominanza estensore/flessore:
    % poche = ruoli stabili = Kellis legittimo; molte = il valore e' solo
    % "frazione estensori/totale", non l'indice AA in senso stretto.
    dd = sign(M1 - M2);
    dd = dd(dd~=0);
    R.(nm).Kel_scambi = sum(abs(diff(dd))>0);
    R.(nm).Kel_ok     = R.(nm).Kel_scambi <= 2;
end
end

%% ---------------------------------------------------------
%  Rudolph, Falconer-Winter e Unnithan sono SIMMETRICI in M1/M2:
%  scambiare i gruppi non cambia il risultato. Kellis e' l'unico
%  asimmetrico (scambiando -> 100-CI).
function CI = indice_rudolph(M1,M2,T)
% Rudolph, Axe & Snyder-Mackler (2000), variante Don et al. (2007):
% media invece di somma -> 0-100% invece di 0-200%.
C = nan(T,1);
for t = 1:T
    if ~isfinite(M1(t)) || ~isfinite(M2(t)); continue; end
    dn = max(M1(t),M2(t));
    if dn > eps
        C(t) = (min(M1(t),M2(t))/dn) * ((M1(t)+M2(t))/2);
    else
        C(t) = 0;
    end
end
CI = mean(C,'omitnan');
end

function CI = indice_kellis(M1,M2)
% Kellis, Arabatzi & Papadopoulos (2003). M1 = stabilizzatore.
a1 = trapz(M1); a2 = trapz(M2);
CI = 100*a1/(a1+a2+eps);
end

function CI = indice_falconer_winter(M1,M2)
% Falconer & Winter (1985). I_ant = area di sovrapposizione = int(min).
CI = 100*(2*trapz(min(M1,M2)))/(trapz(M1+M2)+eps);
end

function CI = indice_unnithan(M1,M2)
% Unnithan et al. (1996)
CI = 100*trapz(min(M1,M2))/(trapz(max(M1,M2))+eps);
end

%% ---------------------------------------------------------
%  FWHM: somma delle durate sopra meta' del massimo.
function fwhm = calcola_FWHM(curva, T)
mx = max(curva,[],'omitnan');
if ~isfinite(mx) || mx < eps; fwhm = NaN; return; end
fwhm = 100*sum(curva >= mx/2)/T;
end

%% ---------------------------------------------------------
%  CoA. ciclo_chiuso=true -> statistica circolare (atan2), valida solo
%  se t=T e' adiacente a t=1 (fasi 'Intero'). false -> baricentro
%  lineare, per le mezze fasi dove t=1 e t=T sono posizioni OPPOSTE.
function coa = calcola_CoA(curva, T, ciclo_chiuso)
curva = curva(:);
curva(~isfinite(curva)) = 0;
if max(curva) < eps; coa = NaN; return; end

if ciclo_chiuso
    th = (1:T)'/T*2*pi;
    A = sum(cos(th).*curva);
    B = sum(sin(th).*curva);
    r = atan2(B,A);
    if r < 0; r = r + 2*pi; end
    coa = r/(2*pi)*100;
else
    coa = 100*sum((1:T)'.*curva)/(sum(curva)*T);
end
end


%% =========================================================
%% ============  SINERGIE MUSCOLARI  =======================
%% =========================================================
%
%  CONCATENAZIONE DELLE RIPETIZIONI (scelta metodologica chiave)
%  Fattorizzare ogni ripetizione separatamente produce VAF >0.92 gia'
%  con k=1: una singola ripetizione di un gesto stereotipato non ha
%  variabilita' da spiegare, quindi una sola sinergia la approssima
%  banalmente. Qui le ripetizioni sono concatenate nel tempo in una
%  matrice [8 x (T_norm*n_rep)] e fattorizzate INSIEME -> UNA W per
%  fase, che deve spiegare tutte le ripetizioni e cattura cio' che e'
%  stabile. E' la procedura di Ambrosini et al. 2016 (30 cicli).
%
%  W NORMALIZZATA A NORMA UNITARIA PER COLONNA
%  La NNMF ha l'ambiguita' W*a, H/a. Senza normalizzare, i pesi escono
%  con ampiezze arbitrarie e le W non sono confrontabili tra soggetti.
%
%  CRITERIO VAF: GUADAGNO MARGINALE, non soglia assoluta
%  La soglia 0.90 non discrimina su questi dati (il VAF non e' centrato
%  e l'EMG normalizzato al picco ha un livello medio alto che una sola
%  sinergia cattura). Si usa il k minimo tale che aggiungerne una porti
%  meno del 5%.
%% =========================================================

function syn = calcola_sinergie(elab, T_norm, solo_intero)

dVAF_thr   = 0.05;   % guadagno marginale minimo (criterio VAF "delta")
VAF_soglia = 0.90;   % soglia VAF assoluta per confronto con la letteratura (k_VAF90)
n_rep_nnmf = 10;     % repliche NNMF
N          = 8;

labels = elab.phase_labels;
if solo_intero
    labels = labels(elab.ciclo_chiuso);
end
np_ph = numel(labels);

syn.k_AIC        = nan(1, np_ph);
syn.k_VAF        = nan(1, np_ph);   % criterio guadagno marginale (delta)
syn.k_VAF90      = nan(1, np_ph);   % criterio soglia assoluta 90% (letteratura)
syn.W            = cell(1, np_ph);   % [8 x k], colonne a norma 1
syn.C            = cell(1, np_ph);   % [k x (T_norm*n_rep)]
syn.EMG_cat      = cell(1, np_ph);   % serve per la Nonnegative Reconstruction
syn.VAF_curve    = cell(1, np_ph);
syn.AIC_curve    = cell(1, np_ph);
syn.VAF_scelto   = nan(1, np_ph);
syn.n_rep_usate  = nan(1, np_ph);
syn.phase_labels = labels;

for ph = 1:np_ph
    E_all = elab.emg.(labels{ph});          % [T_norm x 8 x n_rep]

    blocchi = {};
    for r = 1:size(E_all,3)
        Er = squeeze(E_all(:,:,r))';        % [8 x T_norm]
        if all(~isfinite(Er(:))) || max(Er(:)) < eps; continue; end
        Er(~isfinite(Er)) = 0;
        blocchi{end+1} = max(Er, 0);        %#ok<AGROW>
    end
    if isempty(blocchi); continue; end

    EMG = [blocchi{:}];
    syn.n_rep_usate(ph) = numel(blocchi);
    syn.EMG_cat{ph}     = EMG;
    T_cat = size(EMG, 2);
    if max(EMG(:)) < eps; continue; end

    VAF = zeros(N-1,1);  AIC = zeros(N-1,1);
    Wb  = cell(N-1,1);   Cb  = cell(N-1,1);

    for k = 1:N-1
        [Wk, Ck, ~] = nnmf(EMG, k, 'replicates', n_rep_nnmf, 'algorithm', 'mult');

        for i = 1:k
            nrm = norm(Wk(:,i));
            if nrm > eps
                Wk(:,i) = Wk(:,i)/nrm;
                Ck(i,:) = Ck(i,:)*nrm;
            end
        end

        Wb{k} = Wk;  Cb{k} = Ck;
        Mh    = Wk*Ck;
        VAF(k) = 1 - sum((EMG(:)-Mh(:)).^2)/sum(EMG(:).^2);
        AIC(k) = calcola_AIC(EMG, Mh, Ck, k, N, T_cat);
    end

    dVAF = diff([0; VAF(:)]);
    kv   = find(dVAF < dVAF_thr, 1, 'first');
    if isempty(kv); kv = N; end
    kv90 = find(VAF(:) >= VAF_soglia, 1, 'first');   % primo k al 90% (letteratura)
    if isempty(kv90); kv90 = N; end
    [~, ka] = min(AIC);

    syn.k_VAF(ph)      = kv;
    syn.k_VAF90(ph)    = kv90;
    syn.k_AIC(ph)      = ka;
    syn.W{ph}          = Wb{ka};
    syn.C{ph}          = Cb{ka};
    syn.VAF_curve{ph}  = VAF;
    syn.AIC_curve{ph}  = AIC;
    syn.VAF_scelto(ph) = VAF(ka);
end
end

%% ---------------------------------------------------------
%  AIC modificato con rumore signal-dependent (Ranaldi et al.).
%  c_cv = 0.15: CV del rumore, dalla letteratura sui motoneuroni. La
%  FORMA sigma ~ mu e' verificata empiricamente su EMG da Devarajan &
%  Cheung (2014): log(SD) vs log(media) con pendenza ~1, R2adj 0.85-0.91.
function aic = calcola_AIC(M, M_hat, C_syn, k, N_mus, T)
c_cv       = 0.15;
sigma2_M   = var(M(:));
S_smooth   = movmean(M, max(3,round(T*0.02)), 2);
sigma2_SDN = (c_cv*S_smooth).^2;
sigma2_tot = sigma2_M + sigma2_SDN;
res        = M - M_hat;
logL       = -0.5*sum(sum(res.^2./(sigma2_tot+eps)));

NDoF_W = N_mus*k;
NDoF_C = 0;
for i = 1:k
    NDoF_C = NDoF_C + stima_dof_wavelet(C_syn(i,:), T);
end
aic = -logL + NDoF_W + NDoF_C;
end

%% ---------------------------------------------------------
function NDoF = stima_dof_wavelet(sig, T)
maxl = min(6, floor(log2(T)));
try
    [Cw,Lw] = wavedec(sig, maxl, 'db5');
catch
    NDoF = round(T/10); return;
end
mn = Inf; hmin = 1;
for h = 1:maxl
    dt = detcoef(Cw,Lw,h);
    du = interp1(linspace(0,1,numel(dt)), dt, linspace(0,1,T), 'linear');
    Ss = abs(fft(sig)).^2;  Ss = Ss/(sum(Ss)+eps);
    Sd = abs(fft(du)).^2;   Sd = Sd/(sum(Sd)+eps);
    cv = sum(Ss.*Sd);
    if cv < mn; mn = cv; hmin = h; end
end
hu = min(hmin+1, maxl);
dh = detcoef(Cw,Lw,hu);
ah = appcoef(Cw,Lw,'db5',hu);
NDoF = round(numel(dh)*(1 + sum(dh.^2)/(sum(ah.^2)+eps)));
end


%% =========================================================
%% ============  STAMPA  ===================================
%% =========================================================

function stampa_riepilogo(res, syn)
lab = res.phase_labels;

for nm = {'Globale','Spalla','Tronco'}
    fprintf('      TMCi %-8s ', nm{1});
    for ph = 1:numel(lab)
        fprintf('%s=%.1f  ', abbrev(lab{ph}), mean(res.(nm{1}).TMCi(:,ph),'omitnan'));
    end
    fprintf('\n');
end

fprintf('      Sinergie k_AIC/k_VAF: ');
for ph = 1:numel(syn.phase_labels)
    fprintf('%s=%d/%d  ', abbrev(syn.phase_labels{ph}), ...
            syn.k_AIC(ph), syn.k_VAF(ph));
end
fprintf('\n');
end

function s = abbrev(x)
s = strrep(strrep(strrep(x,'Intero','I'),'Salita','S'),'Discesa','D');
end


%% =========================================================
%  §RandG - DA AGGANCIARE
%  Il RandG ha una struttura eventi diversa (StartR/StopR/StartG/StopG/
%  MidG + i 4 tempi di picco di velocita' calcolati da arricchisci_randg)
%  e 14 fasi invece di 3 per gruppo. E' gestito da elabora_randg.m.
%  Per includerlo qui: aggiungere 'RandG' a `movimenti` e un ramo che
%  chiami elabora_randg al posto di elabora_emg. Serve anche il file
%  marker (Ulna) se i tempi di picco non sono gia' nel file eventi.
%
%  NOTA: in elabora_randg la fase R_Concat concatena due segmenti NON
%  contigui (tra RAndata e RRitorno c'e' tutto il grasp): Kellis va
%  escluso li' e il CoA e' ambiguo.
% =========================================================
