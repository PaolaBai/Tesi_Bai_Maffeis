function [SPARC_value] = fun_SPARC(dati)

tempo = dati(:, 1);
pos_x = dati(:, 2);
pos_y = dati(:, 3);
pos_z = dati(:, 4);

fs = 100;
dt = 1/fs;

vx = gradient(pos_x, dt);
vy = gradient(pos_y, dt);
vz = gradient(pos_z, dt);

norma_v = sqrt(vx.^2 + vy.^2 + vz.^2);

%% FFT per ottenere lo spettro V(w) e lo spettro normalizzato V_hat(w)

N = length(norma_v);        % numero di campioni
Nfft = 2^nextpow2(N * 4);       %zero-padding 

V_fft = fft(norma_v, Nfft);
V_fft_pos = abs(V_fft(1: Nfft/2));      % considera solo la metà positiva (teorema dello specchio), V(w)
    
f = (0: (Nfft/2)-1)*(fs/Nfft);         % creazione dell'asse delle frequenze (solo la metà positiva)

V_hat = V_fft_pos/V_fft_pos(1);       % normalizzazione, V_hat(w)=V(w)/V(0)
    
%% ricerca della frequenza di taglio wc

V_soglia = 0.05;    % soglia standard da letteratura, V=5%
wc_max = 20;    % frequenza massima fisiologica (20 Hz)
    
indice_soglia = find(V_hat <= V_soglia, 1);         % trova la prima frequenza in cui lo spettro scende sotto la soglia

if isempty(indice_soglia)       % se non scende mai sotto la soglia
    wc = find(f >= wc_max, 1);         % prende la prima frequenza >= di 20 Hz
else
    % Assicura che non superi comunque i 20 Hz
    wc = min(indice_soglia, find(f >= wc_max, 1));         % se non scende, trova la minore 
end

f_sel = f(1:wc);        % seleziona solo le frequenze e le ampiezze da 0 fino a wc (estremi di integrazione)
V_hat_sel = V_hat(1:wc);
    
%% SPARC
    
w_norm = f_sel / f_sel(end); 
dw_norm = diff(w_norm);         % dw/wc

dV_hat = diff(V_hat_sel);
    
SPARC_value = -sum(sqrt(dw_norm(:).^2 + dV_hat(:).^2));         % devono essere entrambi vettori colonna

end