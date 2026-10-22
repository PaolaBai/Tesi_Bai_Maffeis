function [angolo_articolare, ROM] = fun_ROM_spalle(posizione_Shoulder_in, posizione_Shoulder_f, posizione_Shoulder, posizione_Elbow)

%% filtraggio Shoulder iniziale

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Shoulder_in(isinf(posizione_Shoulder_in)) = NaN;

posizione_Shoulder_in = fillmissing(posizione_Shoulder_in, 'linear', 1, 'EndValues', 'nearest');
posizione_Shoulder_in_filt = filtfilt(b, a, posizione_Shoulder_in);

%% filtraggio Shoulder finale

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Shoulder_f(isinf(posizione_Shoulder_f)) = NaN;

posizione_Shoulder_f = fillmissing(posizione_Shoulder_f, 'linear', 1, 'EndValues', 'nearest');
posizione_Shoulder_f_filt = filtfilt(b, a, posizione_Shoulder_f);

%% filtraggio Shoulder

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Shoulder(isinf(posizione_Shoulder)) = NaN;

posizione_Shoulder = fillmissing(posizione_Shoulder, 'linear', 1, 'EndValues', 'nearest');
posizione_Shoulder_filt = filtfilt(b, a, posizione_Shoulder);

%% filtraggio Elbow

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Elbow(isinf(posizione_Elbow)) = NaN;

posizione_Elbow = fillmissing(posizione_Elbow, 'linear', 1, 'EndValues', 'nearest');
posizione_Elbow_filt = filtfilt(b, a, posizione_Elbow);

%% vettori spalle e braccio

v_spalle = posizione_Shoulder_f_filt - posizione_Shoulder_in_filt;        
v_braccio = posizione_Elbow_filt - posizione_Shoulder_filt; 

%% calcolo angolo

prod_scalare = dot(v_spalle, v_braccio, 2);         % prodotto scalare riga per riga

norma_spalle = vecnorm(v_spalle, 2, 2);         % norma del vettore tronco, come scalare positivo, lungo le righe
norma_braccio = vecnorm(v_braccio, 2, 2);

angolo_articolare = acosd(prod_scalare ./ (norma_spalle .* norma_braccio));          % calcolato in gradi (d)

%% calcolo ROM

t_tot = length(posizione_Shoulder_filt);        % devo considerare il minimo iniziale
t = round(t_tot/2);

ROM = max(angolo_articolare) - min(angolo_articolare(1:t));

end