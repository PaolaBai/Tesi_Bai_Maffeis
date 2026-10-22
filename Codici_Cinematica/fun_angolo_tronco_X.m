function [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(posizione_C7, posizione_Sacrum, posizione_Shoulder_sx, posizione_Shoulder_dx)

%% filtraggio C7

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_C7(isinf(posizione_C7)) = NaN;

posizione_C7 = fillmissing(posizione_C7, 'linear', 1, 'EndValues', 'nearest');
posizione_C7_filt = filtfilt(b, a, posizione_C7);

%% filtraggio Sacrum

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Sacrum(isinf(posizione_Sacrum)) = NaN;

posizione_Sacrum = fillmissing(posizione_Sacrum, 'linear', 1, 'EndValues', 'nearest');
posizione_Sacrum_filt = filtfilt(b, a, posizione_Sacrum);

%% filtraggio Shoulder sx

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Shoulder_sx(isinf(posizione_Shoulder_sx)) = NaN;

posizione_Shoulder_sx = fillmissing(posizione_Shoulder_sx, 'linear', 1, 'EndValues', 'nearest');
posizione_Shoulder_sx_filt = filtfilt(b, a, posizione_Shoulder_sx);

%% filtraggio Shoulder dx

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Shoulder_dx(isinf(posizione_Shoulder_dx)) = NaN;

posizione_Shoulder_dx = fillmissing(posizione_Shoulder_dx, 'linear', 1, 'EndValues', 'nearest');
posizione_Shoulder_dx_filt = filtfilt(b, a, posizione_Shoulder_dx);

%% vettore tronco e spalle

v_tronco = posizione_C7_filt - posizione_Sacrum_filt; 
v_spalle = posizione_Shoulder_sx_filt - posizione_Shoulder_dx_filt;

%% angolo sagittale (XY)

v_tronco_sagittale = [v_tronco(:,1), v_tronco(:,2), zeros(size(v_tronco,1),1)];
angolo_sagittale_generale = atan2d(v_tronco_sagittale(:,1), v_tronco_sagittale(:,2));      % angolo positivo -> inclinazione avanti
angolo_sagittale = angolo_sagittale_generale(:) - angolo_sagittale_generale(1);         % vettore senza baseline

ROM_tronco_sagittale = max(angolo_sagittale) - min(angolo_sagittale);

%% angolo frontale (YZ)

v_tronco_frontale = [zeros(size(v_tronco,1),1), v_tronco(:,2), v_tronco(:,3)];
angolo_frontale_generale = atan2d(v_tronco_frontale(:,3), v_tronco_frontale(:,2));      % angolo positivo -> inclinazione a destra
angolo_frontale = angolo_frontale_generale(:) - angolo_frontale_generale(1);         % vettore senza baseline

ROM_tronco_frontale = max(angolo_frontale) - min(angolo_frontale);

%% angolo torsione (XZ)

v_tronco_torsione = [v_spalle(:,1), zeros(size(v_spalle,1),1), v_spalle(:,3)];
angolo_torsione_generale = - atan2d(v_tronco_torsione(:,1), v_tronco_torsione(:,3));      % angolo positivo -> rotazione oraria
angolo_torsione = angolo_torsione_generale(:) - angolo_torsione_generale(1);         % vettore senza baseline
angolo_torsione = wrapTo180(angolo_torsione);       % correzione wrapping, mantiene l'intervallo giusto [-180, 180]

ROM_tronco_torsione = max(angolo_torsione) - min(angolo_torsione);

end