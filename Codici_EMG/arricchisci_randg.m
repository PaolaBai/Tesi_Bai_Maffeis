function arricchisci_randg(dir_in, dir_out, cod_sog)
%ARRICCHISCI_RANDG  Calcola i tempi di picco di velocita' del RandG e li
%  aggiunge al file eventi.
%
%  USO (funzione: chiamare dal Command Window, NON premere Run)
%    arricchisci_randg(dir_in, dir_out, cod_sog)
%
%  INPUT (nella cartella dir_in)
%    Cicli_RandG.emt   eventi: StartR / StopR / StartG / StopG / MidG
%    Ulna_RandG.emt    marker 3D del polso, X/Y/Z in m
%
%  OUTPUT (in dir_out)
%    <cod_sog>_RandG.emt   eventi a 9 colonne:
%      StartR StopR StartG StopG MidG PkRAnd PkGAnd PkGRit PkRRit
%
%  Il file EMG NON serve qui: i tempi di picco si ricavano dal solo
%  marker. L'EMG entra nel MASTER, che leggera' questo file eventi e
%  ricavera' le 14 fasi dai 9 tempi.
%
%  PERCHE' UN FILE EVENTI E NON 14 SEGMENTI
%  Le fasi Acc/Dec sono contenute nei gruppi interi: RAndata_Acc e
%  RAndata_Dec SONO RAndata tagliata in due. Scriverle come segmenti
%  separati in un .emt significherebbe duplicare i campioni e rendere
%  ambigua la normalizzazione al picco. Con i soli tempi non c'e'
%  duplicazione: il MASTER legge intervalli diversi dallo stesso
%  segnale continuo, e normalizza ciascuna fase a T_norm separatamente.
%
%  LE 14 FASI RICAVABILI DAI 9 TEMPI
%    RAndata      [StartR, StartG]     RAndata_Acc  [StartR, PkRAnd]
%    GAndata      [StartG, MidG]       RAndata_Dec  [PkRAnd, StartG]
%    GRitorno     [MidG,   StopG]      GAndata_Acc  [StartG, PkGAnd]
%    RRitorno     [StopG,  StopR]      GAndata_Dec  [PkGAnd, MidG]
%    G_Concat     [StartG, StopG]      GRitorno_Acc [MidG,   PkGRit]
%    R_Concat     [StartR,StartG] +    GRitorno_Dec [PkGRit, StopG]
%                 [StopG, StopR]       RRitorno_Acc [StopG,  PkRRit]
%                                      RRitorno_Dec [PkRRit, StopR]
%
%  PARAMETRI (coerenti con tempo_picco.m)
%    Butterworth ordine 2 + filtfilt = 4 ordine effettivo, taglio 6 Hz,
%    velocita' tangenziale 3D. Il filtraggio PRIMA della derivata e'
%    necessario: derivare amplifica il rumore, e su marker a 100 Hz un
%    profilo grezzo e' inutilizzabile.
%
%  NOTA su MidG: verificato sui dati che coincide con il MINIMO di
%  velocita' del grasp (scarto 0.1-0.4 s su 5 rep). E' l'istante della
%  presa, non un mid temporale arbitrario.
%
%  ESEMPIO
%    arricchisci_randg('C:\Tesi\Sorgenti\S041\RandG', ...
%                      'C:\Tesi\DATI EMG\Patologici\S041', 'S041')

if nargin < 3
    error('arricchisci_randg:argomenti', ...
      'Servono 3 argomenti: dir_in, dir_out, cod_sog. Ricevuti: %d.', nargin);
end
if ~exist(dir_in,'dir');  error('Cartella non trovata: %s', dir_in); end
if ~exist(dir_out,'dir'); mkdir(dir_out); end

%% ---------- 1. Eventi ----------
f_ev = trova(dir_in, '*Cicli*RandG*.emt');
if isempty(f_ev); f_ev = trova(dir_in, '*Cicli*.emt'); end
if isempty(f_ev); error('File eventi (Cicli) non trovato in %s', dir_in); end

[EV, cols_orig] = leggi_eventi(f_ev);
n_rep = numel(EV.StartR);
fprintf('  eventi: %s (%d ripetizioni)\n', nome(f_ev), n_rep);

bad = ~(EV.StartR < EV.StartG & EV.StartG < EV.MidG & ...
        EV.MidG   < EV.StopG  & EV.StopG  < EV.StopR);
if any(bad)
    warning('arricchisci_randg:ordine', ...
        'Marker fuori sequenza nelle rep %s', mat2str(find(bad)'));
end

%% ---------- 2. Marker e profilo di velocita' ----------
f_mrk = trova(dir_in, '*Ulna*RandG*.emt');
if isempty(f_mrk); f_mrk = trova(dir_in, '*Ulna*.emt'); end
if isempty(f_mrk); error('File marker (Ulna) non trovato in %s', dir_in); end

[t_mrk, pos] = leggi_marker(f_mrk);
fs_mrk = round(1/median(diff(t_mrk)));
fprintf('  marker: %s (%.1f s, %d Hz)\n', nome(f_mrk), t_mrk(end), fs_mrk);

v = profilo_velocita(t_mrk, pos, fs_mrk);

%% ---------- 3. Picchi di velocita' ----------
% Un picco per ciascuno dei 4 gruppi, per ciascuna ripetizione
gruppi = {'RAndata','GAndata','GRitorno','RRitorno'};
estremi = { [EV.StartR, EV.StartG], ...
            [EV.StartG, EV.MidG  ], ...
            [EV.MidG,   EV.StopG ], ...
            [EV.StopG,  EV.StopR ] };

PK = nan(n_rep, 4);
PP = nan(n_rep, 4);

fprintf('  picchi di velocita'':\n');
for g = 1:4
    iv = estremi{g};
    for r = 1:n_rep
        [PK(r,g), PP(r,g), n_pk] = picco(t_mrk, v, iv(r,1), iv(r,2));

        % Guardie: il picco fuori dal 15-85% produce una fase troppo
        % corta, che poi viene interpolata a T_norm campioni. Due massimi
        % di prominenza simile significano che max() ne sceglie uno
        % arbitrariamente, e il taglio puo' saltare tra ripetizioni.
        if PP(r,g) < 15 || PP(r,g) > 85
            warning('arricchisci_randg:picco_estremo', ...
                '%s rep%d: picco al %.0f%% della durata', gruppi{g}, r, PP(r,g));
        end
        if n_pk > 1
            warning('arricchisci_randg:picchi_multipli', ...
                '%s rep%d: %d massimi con prominenza >20%% del picco', ...
                gruppi{g}, r, n_pk);
        end
    end
    fprintf('    %-10s %3.0f%% ± %2.0f%% della durata\n', ...
            gruppi{g}, mean(PP(:,g)), std(PP(:,g)));
end

%% ---------- 4. Scrittura ----------
cols = [cols_orig, {'PkRAnd','PkGAnd','PkGRit','PkRRit'}];
M    = [EV.StartR, EV.StopR, EV.StartG, EV.StopG, EV.MidG, PK];

f_out = fullfile(dir_out, sprintf('%s_RandG.emt', cod_sog));
scrivi_eventi(f_out, cols, M);
fprintf('  -> %s  (%d colonne)\n', nome(f_out), numel(cols));
end


%% =========================================================
%  LETTURA
% =========================================================
function [EV, cols_ord] = leggi_eventi(f)

righe = leggi_righe(f);
i_hdr = find(cellfun(@(s) ischar(s) && startsWith(strtrim(s),'Item'), righe), 1);
if isempty(i_hdr); error('Intestazione eventi non trovata in %s', f); end

p    = strsplit(righe{i_hdr}, sprintf('\t'));
p    = p(~cellfun(@isempty, strtrim(p)));
cols = strtrim(p(2:end));

d = readmatrix(f, 'FileType','text', 'NumHeaderLines', i_hdr, 'Delimiter','\t');
d = d(all(isfinite(d(:,1:numel(cols)+1)),2), :);

cols_ord = {'StartR','StopR','StartG','StopG','MidG'};
EV = struct();
for k = 1:numel(cols_ord)
    c = find(strcmpi(cols, cols_ord{k}), 1);
    if isempty(c)
        error('arricchisci_randg:colonna', ...
            'Colonna "%s" non trovata. Presenti: {%s}', ...
            cols_ord{k}, strjoin(cols, ', '));
    end
    EV.(cols_ord{k}) = d(:, c+1);    % +1: la colonna 1 e' 'Item'
end
end

%% ---------------------------------------------------------
function [tempo, pos] = leggi_marker(f)

righe = leggi_righe(f);
i_hdr = find(cellfun(@(s) ischar(s) && contains(s,'Frame') && contains(s,'Time'), righe), 1);
if isempty(i_hdr); error('Intestazione marker non trovata in %s', f); end

d     = readmatrix(f, 'FileType','text', 'NumHeaderLines', i_hdr, 'Delimiter','\t');
tempo = d(:,2);
pos   = d(:,3:5);

ok    = all(isfinite([tempo pos]), 2);
tempo = tempo(ok);
pos   = pos(ok,:);
end

%% ---------------------------------------------------------
function righe = leggi_righe(f)
fid = fopen(f,'r');
if fid < 0; error('Impossibile aprire %s', f); end
righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);
end


%% =========================================================
%  VELOCITA'
% =========================================================
function v = profilo_velocita(tempo, pos, fs)
% Parametri di tempo_picco.m: butter(2) + filtfilt = 4 ordine effettivo,
% taglio 6 Hz, velocita' tangenziale 3D.
fc    = 6;
[b,a] = butter(2, fc/(fs/2), 'low');
pf    = zeros(size(pos));
for k = 1:3
    pf(:,k) = filtfilt(b, a, pos(:,k));
end
vv = zeros(size(pf));
for k = 1:3
    vv(:,k) = gradient(pf(:,k), 1/fs);
end
v  = sqrt(sum(vv.^2, 2));
end

%% ---------------------------------------------------------
function [t_pk, p_pk, n_pk] = picco(tempo, v, t0, t1)
m  = tempo >= t0 & tempo <= t1;
tt = tempo(m);
vv = v(m);
if numel(vv) < 3
    t_pk = (t0+t1)/2; p_pk = 50; n_pk = 0; return;
end
[~, i]  = max(vv);
t_pk = tt(i);
p_pk = 100*(t_pk - t0)/(t1 - t0);
try
    n_pk = numel(findpeaks(vv, 'MinPeakProminence', 0.2*max(vv)));
catch
    n_pk = 1;
end
end


%% =========================================================
%  SCRITTURA
% =========================================================
function scrivi_eventi(f, cols, M)

fid = fopen(f,'w');
if fid < 0; error('Impossibile scrivere %s', f); end

fprintf(fid, 'BTS ASCII format\n\n');
fprintf(fid, 'Type:          Event sequences\n');
fprintf(fid, 'Measure unit:  s\n\n');
fprintf(fid, 'Sequences:     %d\n\n', numel(cols));

fprintf(fid, ' Item');
fprintf(fid, '\t%10s', cols{:});
fprintf(fid, '\t\n');

for i = 1:size(M,1)
    fprintf(fid, '%5d', i);
    for c = 1:size(M,2)
        if isfinite(M(i,c))
            fprintf(fid, '\t%10.3f', M(i,c));
        else
            fprintf(fid, '\t%10s', '');
        end
    end
    fprintf(fid, '\t\n');
end
fclose(fid);
end


%% =========================================================
%  UTILITY
% =========================================================
function f = trova(d, pat)
c = dir(fullfile(d, pat));
if isempty(c); f = ''; else; f = fullfile(c(1).folder, c(1).name); end
end

function n = nome(f)
[~,b,e] = fileparts(f);
n = [b e];
end
