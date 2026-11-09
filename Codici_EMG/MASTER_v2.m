%% =========================================================
%  MASTER PIPELINE v2 - EMG + Co-attivazione + Sinergie
%  =========================================================
%  NUOVO FORMATO DI INGRESSO (per soggetto e movimento):
%    <mov>_EMG.emt : 8 canali EMG CONTINUI (lato destro), 1000 Hz,
%                    unita' mV, nessun NaN
%    <mov>.emt     : eventi BTS con colonne
%                    (R|L)Start<dir> / (R|L)Stop<dir> / (R|L)Mid<dir>
%
%  DIFFERENZE RISPETTO ALLA v1
%   1. Niente segmentazione da NaN: gli eventi danno Start e Stop.
%   2. Normalizzazione al picco eseguita UNA volta sull'intera
%      registrazione, non per gruppo. Preserva il rapporto di
%      ampiezza tra lato attivo e controlaterale (che nel formato
%      a 32 canali veniva distrutto: il controlaterale al 2% del
%      picco veniva stirato a 100).
%   3. Ogni ripetizione e' divisa al Mid -> 3 fasi:
%        Intero  [Start, Stop]   (ciclo chiuso -> CoA circolare)
%        Salita  [Start, Mid]    (mezza fase   -> CoA lineare)
%        Discesa [Mid,   Stop]   (mezza fase   -> CoA lineare)
%      Il Mid e' stato validato sui dati: coincide con il massimo
%      della coordinata verticale del marker Ulna (scarto < 3 mm).
%   4. Co-attivazione calcolata su 7 SOTTOGRUPPI muscolari.
%   5. Guardia sulla quantizzazione: intercetta gli export a
%      risoluzione insufficiente (es. in V con 3 decimali), che
%      azzerano il segnale ma producono comunque numeri plausibili.
%   6. TMCf corretto (Ranavolo et al. 2015): nessun /100 sull'EMG
%      in ingresso, nessun *100 sul TMCi.
%   7. Rudolph nella variante Don et al. (2007): media invece di
%      somma -> range 0-100% invece di 0-200%.
%
%  AVVERTENZE PER L'INTERPRETAZIONE
%   - Il TMCi NON e' confrontabile tra sottogruppi di N diverso
%     (cc = m/max dipende da N). Confronta sempre lo stesso
%     sottogruppo tra soggetti o gruppi.
%   - Le fasi L su EMG destro sono attivita' CONTROLATERALE
%     (motor overflow), non esecuzione del gesto: il TMCi mantiene
%     significato, gli indici agonista-antagonista no.
%   - Nel Circ i ruoli agonista/antagonista ruotano lungo il ciclo:
%     Kellis (unico indice asimmetrico in M1/M2) e' escluso.
%   - ext/flex e' una partizione ANATOMICA (estensori vs flessori),
%     NON funzionale. In tesi: "gruppo estensore vs gruppo flessore".
%   - Il ritorno/discesa e' eccentrico: l'ampiezza EMG in eccentrica
%     puo' essere minore a parita' di forza (Escamilla et al. 2009).
%     Un TMCi piu' basso in discesa non implica meno co-attivazione.
% =========================================================

clear; clc; close all;

%% ---------------------------------------------------------
%  *** PARAMETRI ***
% ---------------------------------------------------------
root_dir = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG';

win_rms_ms  = 100;    % [ms] finestra RMS
T_norm      = 100;    % campioni per normalizzazione temporale

sinergie_solo_intero = false;   % NNMF solo sulle fasi 'Intero'
                               % (una sinergia e' un pattern sull'intero
                               %  gesto; su mezze fasi ha senso dubbio,
                               %  e il costo computazionale triplica)

movimenti = {'Flex','Addu','Addu_orizz','Circ','RandG'};   % formato standard
% NOTA: RandG (Tipo B) ha una struttura eventi diversa
% (StartR/StartG/StopG/StopR) e va gestito a parte: vedi §RandG in fondo.

gruppi = {'Patologici','Sani'};
% ---------------------------------------------------------

%% ---------------------------------------------------------
%  SETUP
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

    sog = dir(dir_gruppo);
    sog = sog([sog.isdir]);
    sog = sog(~ismember({sog.name},{'.','..'}));

    fprintf('\n%s\n  GRUPPO: %s  (%d soggetti)\n%s\n\n', ...
        repmat('=',1,64), gruppo, numel(sog), repmat('=',1,64));

    for s = 1:numel(sog)
        cod_sog = sog(s).name;
        dir_sog = fullfile(dir_gruppo, cod_sog);

        fprintf('Soggetto: %s\n%s\n', cod_sog, repmat('-',1,44));
        DATA.(gruppo).(cod_sog) = struct();

        for m = 1:numel(movimenti)
            mov = movimenti{m};

            f_emg = fullfile(dir_sog, sprintf('%s_%s_EMG.emt', cod_sog, mov));
            f_ev  = fullfile(dir_sog, sprintf('%s_%s.emt',     cod_sog, mov));

            if ~exist(f_emg,'file')
                fprintf('  [%s] EMG non trovato\n', mov); continue;
            end
            if ~exist(f_ev,'file')
                fprintf('  [%s] eventi non trovati\n', mov); continue;
            end

            fprintf('  [%s]\n', mov);

            try
                elab = elabora_emg(f_emg, f_ev, win_rms_ms, T_norm,mov);
                res  = calcola_coattivazione(elab, mov, T_norm);
                syn  = calcola_sinergie(elab, T_norm, sinergie_solo_intero);

                res.sinergie = syn;
                DATA.(gruppo).(cod_sog).(mov) = res;

                stampa_riepilogo(res, syn);

            catch err
                fprintf('  ERRORE [%s - %s]: %s\n', cod_sog, mov, err.message);
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

function out = elabora_emg(f_emg, f_ev, win_rms_ms, T_norm,mov)   

% --- 1. Caricamento ---
[tempo, emg_raw, nomi, unita] = leggi_emg(f_emg);
fs = round(1/median(diff(tempo)));

jitter = std(diff(tempo))/median(diff(tempo));
if jitter > 0.01
    warning('elabora_emg:fs_instabile', ...
        'Campionamento non uniforme (jitter %.1f%%): fs=%d Hz potrebbe essere errato', ...
        100*jitter, fs);
end

fprintf('    EMG: %d canali, %.1f s, fs=%d Hz, unita'' %s\n', ...
        size(emg_raw,2), tempo(end), fs, unita);

% --- 2. Guardia quantizzazione ---
n_livelli = controlla_quantizzazione(emg_raw, nomi, unita);

% --- 3. Mappa muscoli -> indici 1-8 (per nome, non per posizione) ---
idx = mappa_muscoli(nomi);
emg_raw = emg_raw(:, idx);
nomi    = nomi(idx);
n_livelli = n_livelli(idx);  % riordina come i muscoli 1-8

% --- 4. Pipeline + normalizzazione al picco (UNA volta, 0-100) ---
[emg_norm, picchi_raw] = elabora_canali(emg_raw, fs, win_rms_ms);
fprintf('    picchi RMS [%s]: ', unita); fprintf('%.4f ', picchi_raw); fprintf('\n');

% --- 5. Eventi ---
EV     = leggi_eventi(f_ev, mov);
gruppi = fieldnames(EV);
if isempty(gruppi); error('Nessun gruppo riconosciuto nel file eventi'); end

% --- 6. Segmentazione: n_gruppi x fasi ---
out.emg = struct();
labels = {}; chiuso = [];

if strcmpi(mov, 'RandG')
    % Definizione di tutte le 15 sotto-fasi cinematiche
    fasi = {'Intero', ...
            'RAndata', 'RAndata_Acc', 'RAndata_Dec', ...
            'GAndata', 'GAndata_Acc', 'GAndata_Dec', ...
            'GRitorno', 'GRitorno_Acc', 'GRitorno_Dec', ...
            'RRitorno', 'RRitorno_Acc', 'RRitorno_Dec', ...
            'R_Concat', 'G_Concat'};
            
    for k = 1:numel(gruppi)
        gr = gruppi{k};
        ev = EV.(gr);
        nr = numel(ev.startR);
        E = struct();
        for f = 1:numel(fasi); E.(fasi{f}) = nan(T_norm, 8, nr); end
        
        for r = 1:nr
            % 1. Movimento Intero
            E.Intero(:,:,r)       = estrai_fase(emg_norm, tempo, ev.startR(r), ev.stopR(r), T_norm);
            
            % 2. Reaching Andata e relative divisioni
            E.RAndata(:,:,r)      = estrai_fase(emg_norm, tempo, ev.startR(r), ev.startG(r), T_norm);
            E.RAndata_Acc(:,:,r)  = estrai_fase(emg_norm, tempo, ev.startR(r), ev.pkRAnd(r), T_norm);
            E.RAndata_Dec(:,:,r)  = estrai_fase(emg_norm, tempo, ev.pkRAnd(r), ev.startG(r), T_norm);
            
            % 3. Grasping Andata e relative divisioni
            E.GAndata(:,:,r)      = estrai_fase(emg_norm, tempo, ev.startG(r), ev.midG(r), T_norm);
            E.GAndata_Acc(:,:,r)  = estrai_fase(emg_norm, tempo, ev.startG(r), ev.pkGAnd(r), T_norm);
            E.GAndata_Dec(:,:,r)  = estrai_fase(emg_norm, tempo, ev.pkGAnd(r), ev.midG(r), T_norm);
            
            % 4. Grasping Ritorno e relative divisioni
            E.GRitorno(:,:,r)     = estrai_fase(emg_norm, tempo, ev.midG(r), ev.stopG(r), T_norm);
            E.GRitorno_Acc(:,:,r) = estrai_fase(emg_norm, tempo, ev.midG(r), ev.pkGRit(r), T_norm);
            E.GRitorno_Dec(:,:,r) = estrai_fase(emg_norm, tempo, ev.pkGRit(r), ev.stopG(r), T_norm);
            
            % 5. Reaching Ritorno e relative divisioni
            E.RRitorno(:,:,r)     = estrai_fase(emg_norm, tempo, ev.stopG(r), ev.stopR(r), T_norm);
            E.RRitorno_Acc(:,:,r) = estrai_fase(emg_norm, tempo, ev.stopG(r), ev.pkRRit(r), T_norm);
            E.RRitorno_Dec(:,:,r) = estrai_fase(emg_norm, tempo, ev.pkRRit(r), ev.stopR(r), T_norm);
            
            % 6. Concatena: Grasping totale (già temporalmente contiguo)
            E.G_Concat(:,:,r)     = estrai_fase(emg_norm, tempo, ev.startG(r), ev.stopG(r), T_norm);
            
            % 7. Concatena: Reaching (Non contiguo -> T_norm/2 per ogni blocco)
            T1 = round(T_norm/2);
            T2 = T_norm - T1;
            P1 = estrai_fase(emg_norm, tempo, ev.startR(r), ev.startG(r), T1);
            P2 = estrai_fase(emg_norm, tempo, ev.stopG(r), ev.stopR(r), T2);
            E.R_Concat(:,:,r)     = cat(1, P1, P2);
        end
        
        for f = 1:numel(fasi)
            nome = [gr '_' fasi{f}];
            out.emg.(nome) = E.(fasi{f});
            labels{end+1}  = nome;                     %#ok<AGROW>
            chiuso(end+1)  = false; % NESSUN ciclo chiuso per evitare errori CoA
        end
        dur = ev.stopR - ev.startR;
        fprintf('    %-11s %5.2f-%5.2f s | %d rep | dur totale %.2f±%.2f s\n', ...
            gr, ev.startR(1), ev.stopR(end), nr, mean(dur), std(dur));
    end

else
    % --- LOGICA STANDARD (Flex, Addu, Circ...) ---
    fasi   = {'Intero','Salita','Discesa'};
    for k = 1:numel(gruppi)
        gr = gruppi{k};
        ev = EV.(gr);
        nr = numel(ev.start);
        bad = ~(ev.start < ev.mid & ev.mid < ev.stop);
        if any(bad)
            warning('elabora_emg:mid','%s: Mid fuori range nelle rep %s', gr, mat2str(find(bad)'));
        end
        E = struct();
        for f = 1:3; E.(fasi{f}) = nan(T_norm, 8, nr); end
        for r = 1:nr
            E.Intero(:,:,r)  = estrai_fase(emg_norm, tempo, ev.start(r), ev.stop(r), T_norm);
            E.Salita(:,:,r)  = estrai_fase(emg_norm, tempo, ev.start(r), ev.mid(r),  T_norm);
            E.Discesa(:,:,r) = estrai_fase(emg_norm, tempo, ev.mid(r),   ev.stop(r), T_norm);
        end
        for f = 1:3
            nome = [gr '_' fasi{f}];
            out.emg.(nome) = E.(fasi{f});
            labels{end+1}  = nome;                     %#ok<AGROW>
            chiuso(end+1)  = strcmp(fasi{f},'Intero'); %#ok<AGROW>
        end
        dur = ev.stop - ev.start;
        psa = 100*(ev.mid - ev.start)./dur;
        fprintf('    %-11s %5.2f-%5.2f s | %d rep | dur %.2f±%.2f s | salita %.0f%%±%.0f%%\n', ...
            gr, ev.start(1), ev.stop(end), nr, mean(dur), std(dur), mean(psa), std(psa));
    end
end
out.phase_labels = labels;
out.ciclo_chiuso = logical(chiuso);
out.nomi_muscoli = nomi;
end

%% ---------------------------------------------------------
function [tempo, emg, nomi, unita] = leggi_emg(f)
fid = fopen(f,'r');
if fid<0; error('File non trovato: %s', f); end
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
%  Guardia: un export in V con 3 decimali quantizza la sEMG a
%  ~1 mV e azzera il segnale. Va intercettato PRIMA di filtrare:
%  altrimenti la normalizzazione al picco stira il rumore di
%  quantizzazione fino a 100 e produce numeri plausibili da dati
%  vuoti (fallimento silenzioso).
function n = controlla_quantizzazione(emg_raw, nomi, unita)
n = arrayfun(@(k) numel(unique(emg_raw(~isnan(emg_raw(:,k)),k))), 1:size(emg_raw,2));

% Unita' sbagliata: fatale a prescindere dai livelli.
% Un export in V con 3 decimali quantizza la sEMG a ~1 mV e la azzera.
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
        fprintf('    ~  %s: canale debole (%d livelli) - verrà stirato a 100%% dalla normalizzazione\n', ...
                nomi{k}, n(k));
    end
end
end

%% ---------------------------------------------------------
%  Mappa i canali sugli indici 1-8 per NOME (robusto all'ordine
%  di export). Ordine target:
%    1 Erettore  2 Bicipite  3 Flessore  4 DeltoideAnt
%    5 Addome    6 Tricipite 7 Estensore 8 DeltoidePos
function idx = mappa_muscoli(nomi)
chiavi = {'Erector','Biceps','Flexor carpi','Deltoideus anterior', ...
          'Rectus abdominis','Triceps','Extensor carpi','Deltoideus posterior'};
idx = zeros(1,8);
for k = 1:8
    hit = find(contains(nomi, chiavi{k}, 'IgnoreCase', true));
    if numel(hit) ~= 1
        error('mappa_muscoli:ambiguo', ...
          'Muscolo "%s": trovate %d corrispondenze nei nomi canale.', chiavi{k}, numel(hit));
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

w0 = 2*pi*50/fs;  rn = 1-(pi*1/fs);
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

picchi_raw = max(emg_rms, [], 1, 'omitnan');   % mV, PRIMA della normalizzazione

emg_norm = nan(size(emg_rms));
for k = 1:n
    pk = picchi_raw(k);
    if pk > 0; emg_norm(:,k) = (emg_rms(:,k)/pk)*100; end
end
end

%% ---------------------------------------------------------
%  Legge eventi BTS. Ricava i gruppi dai nomi di colonna:
%    'RStartAvanti' -> 'RAvanti' | 'RStart' -> 'R'
%  Funziona sia con un file a 12 colonne (4 gruppi, Circ) sia con
%  un file a 6 colonne (2 gruppi, Tipo A).
function EV = leggi_eventi(f, mov)
fid = fopen(f,'r');
if fid<0; error('File non trovato: %s', f); end
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

if strcmpi(mov, 'RandG')
    % --- LETTURA EVENTI TIPO B (RandG) ---
    % Usa i nomi colonna ricavati dal file: StartR, StopR, PkRAnd, ecc.
    idx_startR = find(strcmp(cols, 'StartR'), 1);
    idx_stopR  = find(strcmp(cols, 'StopR'), 1);
    idx_startG = find(strcmp(cols, 'StartG'), 1);
    idx_stopG  = find(strcmp(cols, 'StopG'), 1);
    idx_midG   = find(strcmp(cols, 'MidG'), 1);
    idx_pkRAnd = find(strcmp(cols, 'PkRAnd'), 1);
    idx_pkGAnd = find(strcmp(cols, 'PkGAnd'), 1);
    idx_pkGRit = find(strcmp(cols, 'PkGRit'), 1);
    idx_pkRRit = find(strcmp(cols, 'PkRRit'), 1);
    
    if ~isempty(idx_startR)
        EV.RandG.startR = d(:, idx_startR + 1);
        EV.RandG.stopR  = d(:, idx_stopR + 1);
        EV.RandG.startG = d(:, idx_startG + 1);
        EV.RandG.stopG  = d(:, idx_stopG + 1);
        EV.RandG.midG   = d(:, idx_midG + 1);
        EV.RandG.pkRAnd = d(:, idx_pkRAnd + 1);
        EV.RandG.pkGAnd = d(:, idx_pkGAnd + 1);
        EV.RandG.pkGRit = d(:, idx_pkGRit + 1);
        EV.RandG.pkRRit = d(:, idx_pkRRit + 1);
    end
else
    % --- LETTURA EVENTI STANDARD ---
    for c = 1:numel(cols)
        tok = regexp(cols{c},'^([RL])Start(.*)$','tokens','once');
        if isempty(tok); continue; end
        gr = [tok{1} tok{2}];
        i_stop = find(strcmp(cols,[tok{1} 'Stop' tok{2}]),1);
        i_mid  = find(strcmp(cols,[tok{1} 'Mid'  tok{2}]),1);
        
        if isempty(i_stop) || isempty(i_mid)
            warning('leggi_eventi:incompleto','Gruppo %s: Stop o Mid mancante',gr); continue;
        end
        EV.(gr).start = d(:,c+1);
        EV.(gr).stop  = d(:,i_stop+1);
        EV.(gr).mid   = d(:,i_mid+1);
    end
end
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


%% =========================================================
%% ============  CO-ATTIVAZIONE  ===========================
%% =========================================================

%  Sottogruppi. ext/flex ereditati per intersezione dalla
%  partizione globale estensori [1 6 7 8] / flessori [2 3 4 5].
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

SG    = definisci_sottogruppi();
nomiG = fieldnames(SG);
labels = elab.phase_labels;
np_ph  = numel(labels);

% Kellis: unico indice ASIMMETRICO in M1/M2, quindi l'unico
% invalidato dall'inversione dei ruoli lungo il ciclo -> escluso
% per la circonduzione.
use_kellis = true;

n_rep = size(elab.emg.(labels{1}), 3);

for g = 1:numel(nomiG)
    nm = nomiG{g};
    res.(nm).TMCi = nan(n_rep,np_ph);
    res.(nm).FWHM = nan(n_rep,np_ph);
    res.(nm).CoA  = nan(n_rep,np_ph);
    res.(nm).Rud  = nan(n_rep,np_ph);
    res.(nm).Kel  = nan(n_rep,np_ph);
    res.(nm).Kel_ok     = false(n_rep,np_ph);   
    res.(nm).Kel_scambi = nan(n_rep,np_ph);     
    res.(nm).FW   = nan(n_rep,np_ph);
    res.(nm).Unn  = nan(n_rep,np_ph);
    res.(nm).TMCf = nan(T_norm,n_rep,np_ph);
    res.(nm).N    = numel(SG.(nm).mus);
end

for ph = 1:np_ph
    E  = elab.emg.(labels{ph});
    nr = size(E,3);
    cc = elab.ciclo_chiuso(ph);     % CoA circolare solo su 'Intero'
    for r = 1:nr
        R = calcola_indici_rep(squeeze(E(:,:,r)), T_norm, SG, use_kellis, cc);
        for g = 1:numel(nomiG)
            nm = nomiG{g};
            res.(nm).TMCi(r,ph)   = R.(nm).TMCi;
            res.(nm).FWHM(r,ph)   = R.(nm).FWHM;
            res.(nm).CoA(r,ph)    = R.(nm).CoA;
            res.(nm).Rud(r,ph)    = R.(nm).Rud;
            res.(nm).Kel(r,ph)    = R.(nm).Kel;
            res.(nm).Kel_ok(r,ph)     = R.(nm).Kel_ok;
            res.(nm).Kel_scambi(r,ph) = R.(nm).Kel_scambi;
            res.(nm).FW(r,ph)     = R.(nm).FW;
            res.(nm).Unn(r,ph)    = R.(nm).Unn;
            res.(nm).TMCf(:,r,ph) = R.(nm).TMCf;
        end
    end
end

res.phase_labels  = labels;
res.ciclo_chiuso  = elab.ciclo_chiuso;
res.sottogruppi   = nomiG;
res.movimento     = mov;
res.kellis_valido = use_kellis;
res.nomi_muscoli  = elab.nomi_muscoli;
end

%% ---------------------------------------------------------
%  Indici per UNA ripetizione, su TUTTI i sottogruppi.
%  EMG in ingresso: [T_norm x 8], scala 0-100.
function R = calcola_indici_rep(EMG, T_norm, SG, use_kellis, ciclo_chiuso)

nomi = fieldnames(SG);
R    = struct();

for g = 1:numel(nomi)
    nm  = nomi{g};
    mus = SG.(nm).mus;
    E   = EMG(:,mus);

    % ---------- TMCf (Ranavolo et al. 2015) ----------
    % TMCf = C(d(t)) * m(t) * cc(t), con EMG in 0-100.
    % NB: nessun /100 sull'EMG e nessun *100 sul TMCi:
    % il range 0-100 e' ereditato dalla scala dell'input.
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
    R.(nm).Kel = indice_kellis(M1,M2);              % SEMPRE calcolato

    % Validita' di Kellis: e' asimmetrico in M1/M2, quindi ha senso solo
    % se i ruoli estensore/flessore restano stabili nella fase. Contiamo
    % le inversioni di dominanza (M1><M2): poche = ruoli fissi = Kellis
    % legittimo; molte = ruoli che ruotano = Kellis e' solo "frazione
    % estensori/totale", non l'indice agonista-antagonista in senso stretto.
    d = sign(M1 - M2);
    d = d(d~=0);
    n_scambi = sum(abs(diff(d))>0);
    R.(nm).Kel_scambi = n_scambi;
    R.(nm).Kel_ok     = use_kellis && (n_scambi <= 2);
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
%  Immune a scala e topologia.
function fwhm = calcola_FWHM(curva, T)
mx = max(curva,[],'omitnan');
if ~isfinite(mx) || mx < eps; fwhm = NaN; return; end
fwhm = 100*sum(curva >= mx/2)/T;
end

%% ---------------------------------------------------------
%  CoA. ciclo_chiuso=true  -> statistica circolare (atan2),
%       valida solo se t=T e' adiacente a t=1 (fasi 'Intero').
%       ciclo_chiuso=false -> baricentro lineare, per le mezze
%       fasi dove t=1 e t=T sono posizioni OPPOSTE.
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

function syn = calcola_sinergie(elab, T_norm, solo_intero)

dVAF_thr   = 0.05;   % guadagno marginale minimo per aggiungere una sinergia
n_rep_nnmf = 10;      % repliche NNMF (inizializzazioni random)
N          = 8;       % muscoli

labels = elab.phase_labels;
if solo_intero
    labels = labels(elab.ciclo_chiuso);
end
np_ph = numel(labels);

% Output: una sinergia per fase (non piu' per ripetizione)
syn.k_AIC        = nan(1, np_ph);
syn.k_VAF        = nan(1, np_ph);
syn.W            = cell(1, np_ph);   % [8 x k]  colonne a norma 1
syn.C            = cell(1, np_ph);   % [k x (T_norm*n_rep)]
syn.VAF_curve    = cell(1, np_ph);
syn.AIC_curve    = cell(1, np_ph);
syn.VAF_scelto   = nan(1, np_ph);    % VAF al k selezionato da AIC
syn.n_rep_usate  = nan(1, np_ph);
syn.EMG_cat = cell(1, np_ph);
syn.phase_labels = labels;

for ph = 1:np_ph
    E_all = elab.emg.(labels{ph});          % [T_norm x 8 x n_rep]
    n_rep = size(E_all, 3);

    % --- Concatenazione delle ripetizioni nel tempo ---
    % [T x 8 x rep] -> [8 x (T*rep)], scartando le ripetizioni vuote
    blocchi = {};
    for r = 1:n_rep
        Er = squeeze(E_all(:,:,r))';        % [8 x T_norm]
        if all(~isfinite(Er(:))) || max(Er(:)) < eps; continue; end
        Er(~isfinite(Er)) = 0;
        blocchi{end+1} = max(Er, 0);        %#ok<AGROW>
    end
    if isempty(blocchi); continue; end

    EMG = [blocchi{:}];                     % [8 x (T_norm*n_rep_valide)]
    syn.n_rep_usate(ph) = numel(blocchi);
    T_cat = size(EMG, 2);
    syn.EMG_cat{ph} = EMG;

    if max(EMG(:)) < eps; continue; end

    % --- NNMF per k = 1..N-1 ---
    VAF = zeros(N-1,1);  AIC = zeros(N-1,1);
    Wb  = cell(N-1,1);   Cb  = cell(N-1,1);

    for k = 1:N-1
        [Wk, Ck, ~] = nnmf(EMG, k, 'replicates', n_rep_nnmf, 'algorithm', 'mult');

        % Normalizzazione: ogni colonna di W a norma 1, H riscalata
        % in modo che W*H resti invariato.
        for i = 1:k
            nrm = norm(Wk(:,i));
            if nrm > eps
                Wk(:,i) = Wk(:,i) / nrm;
                Ck(i,:) = Ck(i,:) * nrm;
            end
        end

        Wb{k} = Wk;  Cb{k} = Ck;
        Mh    = Wk * Ck;
        VAF(k) = 1 - sum((EMG(:)-Mh(:)).^2) / sum(EMG(:).^2);
        AIC(k) = calcola_AIC(EMG, Mh, Ck, k, N, T_cat);
    end

    % --- Selezione del rank ---
    dVAF = diff([0; VAF(:)]);
    kv   = find(dVAF < dVAF_thr, 1, 'first');
    if isempty(kv); kv = N; end
    [~, ka] = min(AIC);

    syn.k_VAF(ph)      = kv;
    syn.k_AIC(ph)      = ka;
    syn.W{ph}          = Wb{ka};
    syn.C{ph}          = Cb{ka};
    syn.VAF_curve{ph}  = VAF;
    syn.AIC_curve{ph}  = AIC;
    syn.VAF_scelto(ph) = VAF(ka);
end
end

%% ---------------------------------------------------------
%  AIC modificato con rumore signal-dependent (Ranaldi et al.)
%  c_cv = 0.15: CV del rumore. Supportato dalla relazione
%  sigma ~ mu verificata empiricamente su EMG da Devarajan &
%  Cheung (2014): log(SD) vs log(media) con pendenza ~1
%  (R2adj 0.85-0.91), coerente con un modello gamma.
function aic = calcola_AIC(M, M_hat, C_syn, k, N_mus, T)
c_cv       = 0.15;
sigma2_M   = var(M(:));
S_smooth   = movmean(M, round(T*0.1), 2);
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

fprintf('    TMCi (Globale): ');
for ph = 1:numel(lab)
    fprintf('%s=%.1f  ', lab{ph}, mean(res.Globale.TMCi(:,ph),'omitnan'));
end
fprintf('\n    TMCi (Spalla):  ');
for ph = 1:numel(lab)
    fprintf('%s=%.1f  ', lab{ph}, mean(res.Spalla.TMCi(:,ph),'omitnan'));
end
fprintf('\n    TMCi (Tronco):  ');
for ph = 1:numel(lab)
    fprintf('%s=%.1f  ', lab{ph}, mean(res.Tronco.TMCi(:,ph),'omitnan'));
end
fprintf('\n    Sinergie k_AIC/k_VAF: ');
for ph = 1:numel(syn.phase_labels)
    fprintf('%s=%d/%d  ', syn.phase_labels{ph}, ...
        round(mean(syn.k_AIC(:,ph),'omitnan')), ...
        round(mean(syn.k_VAF(:,ph),'omitnan')));
end
fprintf('\n');
end
