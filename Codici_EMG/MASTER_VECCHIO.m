%% =========================================================
%  MASTER PIPELINE - Elaborazione EMG + Co-attivazione + Sinergie
%  =========================================================
%  Itera su tutti i soggetti (Pazienti e Sani) e per ognuno
%  applica:
%   1. Elaborazione EMG (filtro, inviluppo, normalizzazione)
%   2. Calcolo indici di co-attivazione (TMCi + AA + FWHM + CoA)
%   3. Calcolo numero di attivazioni (K_AIC + K_VAF)
%  Movimenti supportati:
%   Tipo A: Flex, Addu, Addu_orizz  -> 16 canali, 2 gruppi R/L
%   Tipo B: RandG                   -> 16 canali, 2 gruppi annidati
%   Tipo C: Circ                    -> 32 canali, 4 gruppi
%
%  Struttura cartelle attesa:
%   root_dir/
%   ├── Pazienti/
%   │   ├── S001/
%   │   │   ├── S001_Flex_EMG.emt
%   │   │   ├── S001_Addu_EMG.emt
%   │   │   ├── S001_Addu_orizz_EMG.emt
%   │   │   ├── S001_RandG_EMG.emt
%   │   │   └── S001_Circ_EMG.emt
%   │   └── S002/ ...
%   └── Sani/
%       ├── H001/ ...
%       └── H002/ ...
%
%  Output per ogni soggetto: una struct DATA salvata in
%  root_dir/Risultati/<gruppo>/<soggetto>_risultati.mat
% =========================================================

clear; clc; close all;

%% ---------------------------------------------------------
%  *** PARAMETRI DA MODIFICARE ***
% ---------------------------------------------------------
root_dir = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG';   % <-- cartella radice del progetto

% Parametri elaborazione EMG
fs          = 1000;    % [Hz]
win_rms_ms  = 100;     % [ms] finestra RMS
T_norm      = 100;     % campioni per normalizzazione temporale

% Parametri co-attivazione (stessi per tutti i movimenti)
% Divisione fissa in due gruppi da 4 per lato:
% Gruppo 1 (indici locali 1-4): Erettore, Bicipite, Flessore, DeltoideAnt
% Gruppo 2 (indici locali 5-8): Addome, Tricipite, Estensore, DeltoidePos
ext_local  = [1 6 7 8];
flex_local = [2 3 4 5];

% Movimenti e loro tipo
movimenti = {
    'Flex',      'A';
    'Addu',      'A';
    'Addu_orizz','A';
    'RandG',     'B';
    'Circ',      'C';
    };

% Gruppi soggetti
gruppi = {'Patologici', 'Sani'};
% ---------------------------------------------------------

%% ---------------------------------------------------------
%  SETUP CARTELLA RISULTATI
% ---------------------------------------------------------
dir_risultati = fullfile(root_dir, 'Risultati');
for g = 1:length(gruppi)
    dir_g = fullfile(dir_risultati, gruppi{g});
    if ~exist(dir_g,'dir'); mkdir(dir_g); end
end

%% ---------------------------------------------------------
%  STRUTTURA DATI GLOBALE
%  DATA.(gruppo).(soggetto).(movimento) conterra' i risultati
% ---------------------------------------------------------
DATA = struct();

%% ---------------------------------------------------------
%  LOOP PRINCIPALE
% ---------------------------------------------------------
for g = 1:length(gruppi)
    gruppo    = gruppi{g};
    dir_gruppo = fullfile(root_dir, gruppo);

    if ~exist(dir_gruppo,'dir')
        fprintf('Cartella non trovata: %s\n', dir_gruppo);
        continue;
    end

    % Lista soggetti (sottocartelle)
    soggetti = dir(dir_gruppo);
    soggetti = soggetti([soggetti.isdir]);
    soggetti = soggetti(~ismember({soggetti.name},{'.','..'}));

    fprintf('\n%s\n', repmat('=',1,60));
    fprintf('  GRUPPO: %s  (%d soggetti)\n', gruppo, length(soggetti));
    fprintf('%s\n\n', repmat('=',1,60));

    for s = 1:length(soggetti)
        cod_sog   = soggetti(s).name;
        dir_sog   = fullfile(dir_gruppo, cod_sog);

        fprintf('Soggetto: %s\n', cod_sog);
        fprintf('%s\n', repmat('-',1,40));

        % Inizializza struct soggetto
        DATA.(gruppo).(cod_sog) = struct();

        for m = 1:size(movimenti,1)
            mov      = movimenti{m,1};
            tipo     = movimenti{m,2};
            emt_file = fullfile(dir_sog, sprintf('%s_%s_EMG.emt', cod_sog, mov));

            if ~exist(emt_file,'file')
                fprintf('  [%s] File non trovato: %s\n', mov, emt_file);
                continue;
            end

            fprintf('  [%s] Tipo %s\n', mov, tipo);

            try
                %% --- STEP 1: ELABORAZIONE EMG ---
                emg_elab = elabora_emg(emt_file, fs, win_rms_ms, T_norm, tipo);

                %% --- STEP 2: CO-ATTIVAZIONE ---
                risultati = calcola_coattivazione(emg_elab, tipo, ...
                    ext_local, flex_local, T_norm);

                %% --- STEP 3: SINERGIE MUSCOLARI ---
                sinergie = calcola_sinergie(emg_elab, tipo, T_norm);
                risultati.sinergie = sinergie;

                %% --- Salva nella struct ---
                DATA.(gruppo).(cod_sog).(mov) = risultati;

                % Stampa TMCi, sinergie, FHWM e CoA per verifica rapida
                fprintf('    TMCi: ');
                for ph = 1:length(risultati.phase_labels)
                    fprintf('%s=%.4f  ', risultati.phase_labels{ph}, ...
                        mean(risultati.TMCi(:,ph)));
                end

                fprintf('\n    Sinergie (k_AIC / k_VAF): ');
                for ph = 1:length(risultati.phase_labels)
                    fprintf('%s=%d/%d  ', risultati.phase_labels{ph}, ...
                        round(mean(sinergie.k_AIC(:,ph))), ...
                        round(mean(sinergie.k_VAF(:,ph))));
                end
                
                fprintf('\n    FWHM / CoA: ');
                for ph = 1:length(risultati.phase_labels)
                    fprintf('%s=%.1f%%/%.1f%%  ', risultati.phase_labels{ph}, ...
                        mean(risultati.FWHM(:,ph),'omitnan'), ...
                        mean(risultati.CoA(:,ph),'omitnan'));
                end

                fprintf('\n');

            catch err
                fprintf('  ERRORE [%s - %s]: %s\n', cod_sog, mov, err.message);
            end
        end

        % Salva risultati soggetto
        mat_out = fullfile(dir_risultati, gruppo, [cod_sog '_risultati.mat']);
        sog_data = DATA.(gruppo).(cod_sog);
        save(mat_out, 'sog_data', 'cod_sog', 'gruppo');
        fprintf('  Salvato: %s\n\n', mat_out);
    end
end

% Salva struttura globale
save(fullfile(dir_risultati, 'DATA_completo.mat'), 'DATA');
fprintf('\nStruttura globale salvata in: %s\n', ...
    fullfile(dir_risultati,'DATA_completo.mat'));

%% =========================================================
%  FUNZIONE: elabora_emg
%  Pipeline EMG per un file .emt
%  Restituisce struct con emg_norm_t, segmenti, nomi_muscoli
% =========================================================
function out = elabora_emg(emt_file, fs, win_rms_ms, T_norm, tipo)

win_rms = round(win_rms_ms * fs / 1000);

%% Caricamento
dati    = readmatrix(emt_file, 'FileType','text', ...
    'NumHeaderLines',11, 'Delimiter','\t');
tempo   = dati(:,2);
emg_raw = dati(:,3:end);

% Leggi nomi muscoli dall'header
fid   = fopen(emt_file,'r');
lines = {};
while ~feof(fid); lines{end+1} = fgetl(fid); end
fclose(fid);
for i=1:length(lines)
    if contains(lines{i},'Frame') && contains(lines{i},'Time')
        parts = strsplit(lines{i},'\t');
        parts = parts(~cellfun(@isempty,strtrim(parts)));
        nomi_muscoli = parts(3:end);
        break;
    end
end

nan_mask   = isnan(emg_raw);
n_muscoli  = size(emg_raw,2);

%% Filtri
BW_notch  = 1;
w0        = 2*pi*50/fs;
r_notch   = 1 - (pi*BW_notch/fs);
b_n       = [1, -2*cos(w0), 1];
a_n       = [1, -2*r_notch*cos(w0), r_notch^2];
[b_bp, a_bp] = butter(4, [20 300]/(fs/2), 'bandpass');

%% Pipeline per ogni canale
emg_rms = nan(size(emg_raw));
for k = 1:n_muscoli
    sig = emg_raw(:,k);
    sig(isnan(sig)) = 0;
    sig = filtfilt(b_n, a_n, sig);
    sig = filtfilt(b_bp, a_bp, sig);
    sig = abs(sig);
    box = ones(win_rms,1)/win_rms;
    sig = sqrt(conv(sig.^2, box, 'same'));
    sig(nan_mask(:,k)) = NaN;
    emg_rms(:,k) = sig;
end

%% Normalizzazione al picco
emg_norm = nan(size(emg_rms));
for k = 1:n_muscoli
    picco = max(emg_rms(:,k),[],'omitnan');
    if picco > 0
        emg_norm(:,k) = (emg_rms(:,k)/picco)*100;
    end
end

%% Segmentazione per tipo
if strcmp(tipo,'C')
    % Tipo C (Circ): 4 gruppi, segmentazione GLOBALE sui 32 canali
    % poi assegna i 20 segmenti ai 4 gruppi in ordine cronologico
    % (5 rep per gruppo: RAvanti=1-5, RIndietro=6-10, LAvanti=11-15, LIndietro=16-20)
    prefissi   = {'RAvanti','RIndietro','LAvanti','LIndietro'};

    % Segmentazione globale sui 32 canali
    segs_all = segmenta_da_nan(emg_raw, tempo);
    fprintf('    Circ: %d segmenti totali trovati\n', size(segs_all,1));

    % Identifica colonne per ogni gruppo
    group_cols = struct();
    for p = 1:4
        pref = prefissi{p};
        group_cols.(pref) = find(cellfun(@(n) startsWith(strtrim(n),pref), nomi_muscoli));
    end
    out.group_cols = group_cols;
    out.prefissi   = prefissi;

    % Assegna segmenti ai gruppi in ordine cronologico
    % e normalizza temporalmente
    for p = 1:4
        pref = prefissi{p};
        cols = group_cols.(pref);
        N    = length(cols);
        % Trova quali segmenti appartengono a questo gruppo
        % cercando campioni non-NaN nelle colonne del gruppo
        cols_p   = group_cols.(pref);
        segs_p   = [];
        for ss = 1:size(segs_all,1)
            mask_ss = tempo >= segs_all(ss,1) & tempo <= segs_all(ss,2);
            if any(~isnan(emg_norm(mask_ss, cols_p(1))))
                segs_p(end+1,:) = segs_all(ss,:); %#ok<AGROW>
            end
        end
        segs = segs_p;
        emg_t    = zeros(T_norm, N, size(segs,1));
        for r = 1:size(segs,1)
            mask = tempo >= segs(r,1) & tempo <= segs(r,2);
            seg  = emg_norm(mask, cols);
            if size(seg,1) < 2; continue; end
            xo = linspace(0,1,size(seg,1));
            xn = linspace(0,1,T_norm);
            for k = 1:N
                col = seg(:,k); col(isnan(col))=0;
                emg_t(:,k,r) = max(0,min(100,interp1(xo,col,xn,'pchip')));
            end
        end
        out.emg_norm_t.(pref) = emg_t;
    end

elseif strcmp(tipo,'B')
    % Tipo B (RandG): rileva StartR, StartG, StopG, StopR
    % dalle transizioni NaN nei canali R e G separatamente
    r_cols_all = find(cellfun(@(n) startsWith(strtrim(n),'R '), nomi_muscoli));
    g_cols_all = find(cellfun(@(n) startsWith(strtrim(n),'G '), nomi_muscoli));

    % Leggi transizioni NaN per R e G
    r_nan_prev = true; g_nan_prev = true; t_prev = 0;
    StartR=[]; StopR=[]; StartG=[]; StopG=[];
    for i = 1:length(tempo)
        r_nan = all(isnan(emg_raw(i, r_cols_all)));
        g_nan = all(isnan(emg_raw(i, g_cols_all)));
        if r_nan_prev && ~r_nan;  StartR(end+1) = tempo(i);  end %#ok<AGROW>
        if ~r_nan_prev && r_nan;  StopR(end+1)  = t_prev;    end %#ok<AGROW>
        if g_nan_prev && ~g_nan;  StartG(end+1) = tempo(i);  end %#ok<AGROW>
        if ~g_nan_prev && g_nan;  StopG(end+1)  = t_prev;    end %#ok<AGROW>
        r_nan_prev = r_nan; g_nan_prev = g_nan; t_prev = tempo(i);
    end
    if ~r_nan_prev; StopR(end+1) = tempo(end); end
    if ~g_nan_prev; StopG(end+1) = tempo(end); end

    n_rep = length(StartR);
    fprintf('    RandG: %d ripetizioni rilevate\n', n_rep);

    % Per ogni ripetizione estrai le due fasi e normalizza a T_norm campioni
    % Fase 1 — Reaching: StartR->StartG + StopG->StopR (concatenati)
    % Fase 2 — Grasping: StartG->StopG
    emg_reach = zeros(T_norm, 8, n_rep);
    emg_grasp = zeros(T_norm, 8, n_rep);

    for r = 1:n_rep
        % Reaching: concatena andata e ritorno
        mask_a = tempo >= StartR(r) & tempo <= StartG(r);
        mask_b = tempo >= StopG(r)  & tempo <= StopR(r);
        seg_reach = [emg_norm(mask_a, r_cols_all); ...
            emg_norm(mask_b, r_cols_all)];

        % Grasping
        mask_g  = tempo >= StartG(r) & tempo <= StopG(r);
        seg_grasp = emg_norm(mask_g, r_cols_all);

        % Normalizzazione temporale
        for k = 1:8
            % Reaching
            col = seg_reach(:,k); col(isnan(col))=0;
            xo  = linspace(0,1,size(seg_reach,1));
            emg_reach(:,k,r) = max(0,min(100, ...
                interp1(xo,col,linspace(0,1,T_norm),'pchip')));
            % Grasping
            col = seg_grasp(:,k); col(isnan(col))=0;
            xo  = linspace(0,1,size(seg_grasp,1));
            emg_grasp(:,k,r) = max(0,min(100, ...
                interp1(xo,col,linspace(0,1,T_norm),'pchip')));
        end
    end

    out.emg_reach = emg_reach;   % [T_norm x 8 x n_rep]
    out.emg_grasp = emg_grasp;   % [T_norm x 8 x n_rep]
    out.StartR = StartR(:); out.StartG = StartG(:);
    out.StopG  = StopG(:);  out.StopR  = StopR(:);

else
    % Tipo A: Flex, Addu, Addu_orizz — gruppi R/L alternati
    segs  = segmenta_da_nan(emg_raw, tempo);
    n_rep = size(segs,1);
    emg_t = zeros(T_norm, n_muscoli, n_rep);
    for r = 1:n_rep
        mask = tempo >= segs(r,1) & tempo <= segs(r,2);
        seg  = emg_norm(mask,:);
        if size(seg,1) < 2; continue; end
        xo = linspace(0,1,size(seg,1));
        xn = linspace(0,1,T_norm);
        for k = 1:n_muscoli
            col = seg(:,k); col(isnan(col))=0;
            emg_t(:,k,r) = max(0,min(100,interp1(xo,col,xn,'pchip')));
        end
    end
    out.emg_norm_t = emg_t;
    out.segmenti   = segs;
end

out.nomi_muscoli = nomi_muscoli;
out.tipo         = tipo;
out.T_norm       = T_norm;
out.fs           = fs;
end

%% =========================================================
%  FUNZIONE: segmenta_da_nan
%  Estrae onset/offset dai blocchi NaN
% =========================================================
function segs = segmenta_da_nan(emg_mat, tempo)
nan_mask = isnan(emg_mat);
segs     = [];
in_seg   = false;
t_start  = 0;
for i = 1:length(tempo)
    tutti_nan = all(nan_mask(i,:));
    if ~tutti_nan && ~in_seg
        t_start = tempo(i); in_seg = true;
    elseif tutti_nan && in_seg
        segs(end+1,:) = [t_start, tempo(i-1)]; %#ok<AGROW>
        in_seg = false;
    end
end
if in_seg; segs(end+1,:) = [t_start, tempo(end)]; end
end

%% =========================================================
%  FUNZIONE: calcola_coattivazione
%  Calcola TMCi e indici AA per tutti i gruppi
% =========================================================
function res = calcola_coattivazione(elab, tipo, ext_local, flex_local, T_norm)

nomi = elab.nomi_muscoli;
N    = 8;   % muscoli per gruppo

if strcmp(tipo,'C')
    % Tipo C: 4 gruppi
    prefissi     = elab.prefissi;
    phase_labels = prefissi;
    n_phases     = 4;
    % Numero ripetizioni dal primo gruppo
    n_rep = size(elab.emg_norm_t.(prefissi{1}), 3);

    res.TMCi   = zeros(n_rep, n_phases);
    res.Rud    = zeros(n_rep, n_phases);
    res.Kel    = zeros(n_rep, n_phases);
    res.FW     = zeros(n_rep, n_phases);
    res.Unn    = zeros(n_rep, n_phases);
    res.TMCf   = zeros(T_norm, n_rep, n_phases);
    res.FWHM = zeros(n_rep, n_phases);
    res.CoA  = zeros(n_rep, n_phases);

    for ph = 1:n_phases
        emg_t = elab.emg_norm_t.(prefissi{ph});   % [T x N x n_rep]
        for r = 1:n_rep
            EMG = squeeze(emg_t(:,:,r));
            [tmcf, tmci, rud, kel, fw, unn, fwhm, coa] = ...
                 calcola_indici_rep(EMG, N, T_norm, ext_local, flex_local);
            res.TMCf(:,r,ph) = tmcf;
            res.TMCi(r,ph)   = tmci;
            res.Rud(r,ph)    = rud;
            res.Kel(r,ph)    = kel;
            res.FW(r,ph)     = fw;
            res.Unn(r,ph)    = unn;
            res.FWHM(r,ph) = fwhm;      
            res.CoA(r,ph)  = coa;
        end
    end

elseif strcmp(tipo,'B')
    % Tipo B: RandG — fasi temporali Reaching vs Grasping
    % emg_reach e emg_grasp gia' estratte e normalizzate in elabora_emg
    n_rep        = size(elab.emg_reach, 3);
    n_phases     = 2;
    phase_labels = {'Reaching (andata+ritorno)', 'Grasping'};
    phase_data   = {elab.emg_reach, elab.emg_grasp};   % [T x 8 x n_rep]

    res.TMCi   = zeros(n_rep, n_phases);
    res.Rud    = zeros(n_rep, n_phases);
    res.Kel    = zeros(n_rep, n_phases);
    res.FW     = zeros(n_rep, n_phases);
    res.Unn    = zeros(n_rep, n_phases);
    res.TMCf   = zeros(T_norm, n_rep, n_phases);
    res.FWHM = zeros(n_rep, n_phases);
    res.CoA  = zeros(n_rep, n_phases);

    for ph = 1:n_phases
        emg_ph = phase_data{ph};   % [T_norm x 8 x n_rep]
        for r = 1:n_rep
            EMG = squeeze(emg_ph(:,:,r));   % [T_norm x 8]
            [tmcf, tmci, rud, kel, fw, unn, fwhm, coa] = ...
                 calcola_indici_rep(EMG, N, T_norm, ext_local, flex_local);
            res.TMCf(:,r,ph) = tmcf;
            res.TMCi(r,ph)   = tmci;
            res.Rud(r,ph)    = rud;
            res.Kel(r,ph)    = kel;
            res.FW(r,ph)     = fw;
            res.Unn(r,ph)    = unn;
            res.FWHM(r,ph) = fwhm;      
            res.CoA(r,ph)  = coa;
        end
    end


else
    % Tipo A: Flex, Addu, Addu_orizz — gruppi R/L alternati
    r_cols = find(cellfun(@(n) startsWith(strtrim(n),'R '), nomi));
    l_cols = find(cellfun(@(n) startsWith(strtrim(n),'L '), nomi));

    n_tot    = size(elab.emg_norm_t, 3);
    n_rep    = floor(n_tot/2);
    n_phases = 2;
    phase_labels = {'Destra','Sinistra'};
    side_cols = {r_cols, l_cols};
    side_reps = {1:n_rep, n_rep+1:n_tot};

    res.TMCi   = zeros(n_rep, n_phases);
    res.Rud    = zeros(n_rep, n_phases);
    res.Kel    = zeros(n_rep, n_phases);
    res.FW     = zeros(n_rep, n_phases);
    res.Unn    = zeros(n_rep, n_phases);
    res.TMCf   = zeros(T_norm, n_rep, n_phases);
    res.FWHM = zeros(n_rep, n_phases);
    res.CoA  = zeros(n_rep, n_phases);

    for ph = 1:n_phases
        cols = side_cols{ph};
        reps = side_reps{ph};
        for ri = 1:n_rep
            r   = reps(ri);
            EMG = squeeze(elab.emg_norm_t(:, cols, r));
            [tmcf, tmci, rud, kel, fw, unn, fwhm, coa] = ...
                 calcola_indici_rep(EMG, N, T_norm, ext_local, flex_local);
            res.TMCf(:,ri,ph) = tmcf;
            res.TMCi(ri,ph)   = tmci;
            res.Rud(ri,ph)    = rud;
            res.Kel(ri,ph)    = kel;
            res.FW(ri,ph)     = fw;
            res.Unn(ri,ph)    = unn;
            res.FWHM(ri,ph) = fwhm;     
            res.CoA(ri,ph)  = coa;
        end
    end
end

res.phase_labels = phase_labels;
res.tipo         = tipo;
end

%% =========================================================
%  FUNZIONE: calcola_indici_rep
%  TMCf, TMCi e indici AA per una singola ripetizione
% =========================================================
function [TMCf_vec, TMCi, CI_Rud, CI_Kel, CI_FW, CI_Unn, FWHM, CoA] = ...
         calcola_indici_rep(EMG, N, T_norm, ext_local, flex_local)

pairs = nchoosek(1:N, 2);
np    = size(pairs,1);

TMCf_vec = zeros(T_norm,1);
for t = 1:T_norm
    emg_t    = EMG(t,:);
    diff_sum = 0;
    for p = 1:np
        diff_sum = diff_sum + abs(emg_t(pairs(p,1)) - emg_t(pairs(p,2)));
    end
    d_t   = diff_sum/(100*np);
    C_dt  = 1 - 1/(1+exp(-12*(d_t-0.5)));
    m_t   = sum(emg_t)/N;
    max_e = max(emg_t);
    cc_t  = 0; if max_e>eps; cc_t = m_t/max_e; end
    TMCf_vec(t) = C_dt * m_t * cc_t;
end
TMCi = mean(TMCf_vec);

M1 = mean(EMG(:,ext_local), 2);
M2 = mean(EMG(:,flex_local),2);

% Rudolph
C_rud = zeros(T_norm,1);
for t = 1:T_norm
    dn = max(M1(t),M2(t));
    if dn>eps; C_rud(t)=(min(M1(t),M2(t))/dn)*(M1(t)+M2(t)); end
end
CI_Rud = mean(C_rud);

% Kellis
dK     = trapz(M1)+trapz(M2);
CI_Kel = 100*trapz(M1)/(dK+eps);

% Falconer & Winter
I_tot  = trapz(M1+M2);
I_ant  = trapz(M1.*double(M1<M2))+trapz(M2.*double(M1>=M2));
CI_FW  = 100*(2*I_ant)/(I_tot+eps);

% Unnithan
CI_Unn = 100*trapz(min(M1,M2))/(trapz(max(M1,M2))+eps);

% FWHM e CoA sulla curva TMCf
FWHM = calcola_FWHM(TMCf_vec, T_norm);
CoA  = calcola_CoA(TMCf_vec, T_norm);

end

%% =========================================================
%  FUNZIONE: calcola_sinergie
% =========================================================
function syn = calcola_sinergie(elab, tipo, T_norm)

VAF_thr      = 0.90;
n_replicates = 10;

if strcmp(tipo,'C')
    prefissi     = elab.prefissi;
    n_phases     = 4;
    phase_labels = prefissi;
    get_emg      = @(ph,r) squeeze(elab.emg_norm_t.(prefissi{ph})(:,:,r));
    n_rep        = size(elab.emg_norm_t.(prefissi{1}), 3);
elseif strcmp(tipo,'B')
    n_phases     = 2;
    phase_labels = {'Reaching','Grasping'};
    phase_data   = {elab.emg_reach, elab.emg_grasp};
    get_emg      = @(ph,r) squeeze(phase_data{ph}(:,:,r));
    n_rep        = size(elab.emg_reach, 3);
else
    r_cols   = find(cellfun(@(n) startsWith(strtrim(n),'R '), elab.nomi_muscoli));
    l_cols   = find(cellfun(@(n) startsWith(strtrim(n),'L '), elab.nomi_muscoli));
    n_tot    = size(elab.emg_norm_t, 3);
    n_rep    = floor(n_tot/2);
    n_phases = 2;
    phase_labels = {'Destra','Sinistra'};
    side_cols    = {r_cols, l_cols};
    side_reps    = {1:n_rep, n_rep+1:n_tot};
    get_emg      = @(ph,r) squeeze(elab.emg_norm_t(:, side_cols{ph}, side_reps{ph}(r)));
end

N = 8;

syn.k_AIC      = zeros(n_rep, n_phases);
syn.k_VAF      = zeros(n_rep, n_phases);
syn.W          = cell(n_phases, n_rep);
syn.C          = cell(n_phases, n_rep);
syn.VAF_curve  = cell(n_phases, n_rep);
syn.AIC_curve  = cell(n_phases, n_rep);
syn.phase_labels = phase_labels;

for ph = 1:n_phases
    for r = 1:n_rep
        EMG = get_emg(ph, r)';
        EMG = max(EMG, 0);
        if max(EMG(:)) < eps
            syn.k_AIC(r,ph) = NaN;
            syn.k_VAF(r,ph) = NaN;
            continue;
        end
        EMG_max = max(EMG, [], 2);
        EMG_max(EMG_max < eps) = 1;
        EMG_n = EMG ./ EMG_max;

        VAF_k  = zeros(N-1,1);
        AIC_k  = zeros(N-1,1);
        W_best = cell(N-1,1);
        C_best = cell(N-1,1);

        for k = 1:N-1
            [W_k, C_k, ~] = nnmf(EMG_n, k, ...
                'replicates', n_replicates, ...
                'algorithm',  'mult');
            W_best{k} = W_k;
            C_best{k} = C_k;
            M_hat     = W_k * C_k;
            VAF_k(k)  = 1 - sum(sum((EMG_n-M_hat).^2)) / ...
                sum(sum(EMG_n.^2));
            AIC_k(k)  = calcola_AIC(EMG_n, M_hat, W_k, C_k, k, N, T_norm);
        end

        k_vaf = find(VAF_k >= VAF_thr, 1, 'first');
        if isempty(k_vaf); k_vaf = N; end
        [~, k_aic] = min(AIC_k);

        syn.k_VAF(r,ph)     = k_vaf;
        syn.k_AIC(r,ph)     = k_aic;
        syn.W{ph,r}         = W_best{k_aic};
        syn.C{ph,r}         = C_best{k_aic};
        syn.VAF_curve{ph,r} = VAF_k;
        syn.AIC_curve{ph,r} = AIC_k;
    end
end
end

%% =========================================================
%  FUNZIONE: calcola_AIC
% =========================================================
function aic = calcola_AIC(M, M_hat, ~, C_syn, k, N_mus, T)
c_cv       = 0.15;
sigma2_M   = var(M(:));
S_smooth   = movmean(M, round(T*0.1), 2);
sigma2_SDN = (c_cv * S_smooth).^2;
sigma2_tot = sigma2_M + sigma2_SDN;
residui    = M - M_hat;
logL       = -0.5 * sum(sum(residui.^2 ./ (sigma2_tot + eps)));
NDoF_W     = N_mus * k;
NDoF_C     = 0;
for i = 1:k
    NDoF_C = NDoF_C + stima_dof_wavelet(C_syn(i,:), T);
end
aic = -logL + NDoF_W + NDoF_C;
end

%% =========================================================
%  FUNZIONE: stima_dof_wavelet
% =========================================================
function NDoF = stima_dof_wavelet(sig, T)
max_level = min(6, floor(log2(T)));
try
    [C_wav, L_wav] = wavedec(sig, max_level, 'db5');
catch
    NDoF = round(T / 10);
    return;
end
min_corr = Inf;
h_min    = 1;
for h = 1:max_level
    detail    = detcoef(C_wav, L_wav, h);
    detail_up = interp1(linspace(0,1,length(detail)), detail, ...
        linspace(0,1,T), 'linear');
    S_sig     = abs(fft(sig)).^2;
    S_det     = abs(fft(detail_up)).^2;
    S_sig     = S_sig / (sum(S_sig) + eps);
    S_det     = S_det / (sum(S_det) + eps);
    corr_val  = sum(S_sig .* S_det);
    if corr_val < min_corr
        min_corr = corr_val;
        h_min    = h;
    end
end
h_use    = min(h_min + 1, max_level);
detail_h = detcoef(C_wav, L_wav, h_use);
approx_h = appcoef(C_wav, L_wav, 'db5', h_use);
L_h      = length(detail_h);
P_D      = sum(detail_h.^2);
P_A      = sum(approx_h.^2) + eps;
NDoF     = round(L_h * (1 + P_D/P_A));
end

%% =========================================================
%  FUNZIONE: calcola_FWHM
%  Full Width at Half Maximum (Montante et al. 2024)
%  Somma delle durate di tutti gli intervalli in cui la
%  curva supera meta' del suo valore massimo.
%  Output in % del ciclo (T_norm = 100 -> 1 campione = 1%)
% =========================================================
function fwhm = calcola_FWHM(curva, T_norm)
    max_val = max(curva);
    if max_val < eps
        fwhm = 0;
        return;
    end
    soglia = max_val / 2;
    sopra  = curva >= soglia;
    fwhm   = 100 * sum(sopra) / T_norm;   % % del ciclo
end

%% =========================================================
%  FUNZIONE: calcola_CoA
%  Center of Activity (Fiori et al. 2020; Kibushi et al. 2018)
%  Baricentro angolare della curva trattata come
%  distribuzione circolare (statistica circolare).
%  Output in % del ciclo (0-100)
% =========================================================
function coa = calcola_CoA(curva, T_norm)
    curva = curva(:);                 % vettore colonna
    if max(curva) < eps
        coa = NaN;
        return;
    end

    % Mappa i campioni temporali su angoli 0-2pi
    theta = (1:T_norm)' / T_norm * 2*pi;

    % Componenti del vettore risultante
    A = sum(cos(theta) .* curva);
    B = sum(sin(theta) .* curva);

    % Angolo del baricentro (atan2 gestisce i 4 quadranti)
    coa_rad = atan2(B, A);
    if coa_rad < 0
        coa_rad = coa_rad + 2*pi;
    end

    coa = coa_rad / (2*pi) * 100;      % % del ciclo
end