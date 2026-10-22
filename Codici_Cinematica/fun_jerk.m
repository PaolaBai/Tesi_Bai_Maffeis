function [jerk_mean, jerk_peak] = fun_jerk(dati)

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

%% calcolo jerk

jx = gradient(gradient(gradient(pos_x_tagliata, dt), dt), dt);
jy = gradient(gradient(gradient(pos_y_tagliata, dt), dt), dt);
jz = gradient(gradient(gradient(pos_z_tagliata, dt), dt), dt);

norma_jerk = sqrt(jx.^2 + jy.^2 + jz.^2);

jerk_mean = mean(norma_jerk);
jerk_peak = max(norma_jerk);

end