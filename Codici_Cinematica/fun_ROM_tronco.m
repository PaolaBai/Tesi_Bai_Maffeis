function [angolo_articolare, ROM] = fun_ROM_tronco(posizione_C7, posizione_Sacrum, posizione_Shoulder, posizione_Elbow)

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

%% vettori tronco e braccio

v_tronco = posizione_Sacrum_filt - posizione_C7_filt; 
v_braccio = posizione_Elbow_filt - posizione_Shoulder_filt; 

%% calcolo angolo

prod_scalare = dot(v_tronco, v_braccio, 2);         % prodotto scalare riga per riga

norma_tronco = vecnorm(v_tronco, 2, 2);         % norma del vettore tronco, come scalare positivo, lungo le righe
norma_braccio = vecnorm(v_braccio, 2, 2);

angolo_articolare = acosd(prod_scalare ./ (norma_tronco .* norma_braccio));          % calcolato in gradi (d)

%% calcolo ROM

t_tot = length(posizione_Shoulder_filt);        % devo considerare il minimo iniziale
t = round(t_tot/2);

ROM = max(angolo_articolare) - min(angolo_articolare(1:t));

end