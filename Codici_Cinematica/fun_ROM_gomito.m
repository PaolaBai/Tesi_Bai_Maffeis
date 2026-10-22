function [angolo_articolare, ROM] = fun_ROM_gomito(posizione_Ulna, posizione_Shoulder, posizione_Elbow)

%% filtraggio Ulna

fs = 100;
fc = 6;         % frequenza di taglio a 6 Hz
frequenza_normalizzata = fc / (fs / 2);
[b, a] = butter(2, frequenza_normalizzata, 'low');      % butter 2 + filtfilt = 4 ordine

posizione_Ulna(isinf(posizione_Ulna)) = NaN;

posizione_Ulna = fillmissing(posizione_Ulna, 'linear', 1, 'EndValues', 'nearest');
posizione_Ulna_filt = filtfilt(b, a, posizione_Ulna);

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

%% vettori braccio e avambraccio
 
v_braccio = posizione_Elbow_filt - posizione_Shoulder_filt; 
v_avambraccio = posizione_Ulna_filt - posizione_Elbow_filt;

%% calcolo angolo

prod_scalare = dot(v_braccio, v_avambraccio, 2);         % prodotto scalare riga per riga

norma_avambraccio = vecnorm(v_avambraccio, 2, 2);         % norma del vettore tronco, come scalare positivo, lungo le righe
norma_braccio = vecnorm(v_braccio, 2, 2);

angolo_articolare = acosd(prod_scalare ./ (norma_braccio .* norma_avambraccio));          % calcolato in gradi (d)

%% calcolo ROM

t_tot = length(posizione_Shoulder_filt);        % devo considerare il minimo iniziale
t = round(t_tot/2);

ROM = max(angolo_articolare) - min(angolo_articolare(1:t));

end