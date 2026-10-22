function [skewness_value] = fun_skewness(dati)

tempo = dati(:, 1);
pos_x = dati(:, 2);
pos_y = dati(:, 3);
pos_z = dati(:, 4);

%% filtraggio

fs = 100;
dt = 1/fs;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine
    
pos_x_filt = filtfilt(b, a, pos_x);
pos_y_filt = filtfilt(b, a, pos_y);
pos_z_filt = filtfilt(b, a, pos_z);

%% margine 5%

vx = gradient(pos_x_filt, dt);
vy = gradient(pos_y_filt, dt);
vz = gradient(pos_z_filt, dt);

norma_v = sqrt(vx.^2 + vy.^2 + vz.^2);
v_peak = max(norma_v);       % velocità di picco

soglia = 0.05 * v_peak;

indici_validi = find(norma_v >= soglia);

frame_0 = indici_validi(1);      % superamento soglia
frame_end = indici_validi(end);     % rientro sotto soglia

pos_x_tagliata = pos_x_filt(frame_0:frame_end);
pos_y_tagliata = pos_y_filt(frame_0:frame_end);
pos_z_tagliata = pos_z_filt(frame_0:frame_end);

%% calcolo dela velocità

vx = gradient(pos_x_tagliata, dt);
vy = gradient(pos_y_tagliata, dt);
vz = gradient(pos_z_tagliata, dt);

norma_v = sqrt(vx.^2 + vy.^2 + vz.^2);

%% calcolo di media e deviazione standard
media_v = mean(norma_v);
std_v = std(norma_v);
N = length(norma_v);

%% calcolo skewness (formula di Fisher-Pearson)

differenze_cubo = (norma_v - media_v).^3;
skewness_value = (sum(differenze_cubo)/N) / (std_v^3);

end