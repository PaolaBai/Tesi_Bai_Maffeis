function [t_picco, norma_v] = tempo_picco(tabella)

tempo = tabella(:, 1);
pos_x = tabella(:, 2);
pos_y = tabella(:, 3);
pos_z = tabella(:, 4);

%% filtraggio

fs = 100;
dt = 1/fs;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine
    
pos_x_filt = filtfilt(b, a, pos_x);
pos_y_filt = filtfilt(b, a, pos_y);
pos_z_filt = filtfilt(b, a, pos_z);

%% velocità di picco

vx = gradient(pos_x_filt, dt);
vy = gradient(pos_y_filt, dt);
vz = gradient(pos_z_filt, dt);

norma_v = sqrt(vx.^2 + vy.^2 + vz.^2);
[v_peak, idx_peak] = max(norma_v);       % velocità e indice della velocità di picco

t_picco = tempo(idx_peak);

end