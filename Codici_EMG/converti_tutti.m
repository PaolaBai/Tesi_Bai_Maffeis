%% =========================================================
%  CONVERTITORE  ASCII (.txt) + eventi separati  ->  .emt per MASTER v2 /
%  v3
%  
% converti_tutti('C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\Creazione emt','C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG')
% 
% 
%  STRUTTURA SORGENTE ATTESA
%    <root_in>/<cod_sog>/<mov>/  contiene:
%       *.txt          EMG grezzo, 8 canali, colonna Time in s
%                      (fs qualsiasi: viene rilevato dai dati)
%       RCicli_*.emt   eventi lato R  (RStart/RStop/RMid)
%       LCicli_*.emt   eventi lato L  (LStart/LStop/LMid)
%
%  STRUTTURA OUTPUT PRODOTTA
%    <root_out>/<gruppo>/<cod_sog>/
%       <cod_sog>_<mov>_EMG.emt   formato BTS 'Emg tracks', nomi canonici
%       <cod_sog>_<mov>.emt       eventi UNITI in un solo file
%
%  COSA FA
%   - rileva fs dalla colonna tempo e lo scrive nell'header
%   - rinomina i canali nella nomenclatura canonica -> mappa_muscoli
%     nel MASTER non va toccata
%   - riordina i canali secondo la numerazione 1-8 del progetto
%   - unisce i due file eventi (R e L) in uno solo
%   - NON tocca i valori: nessun filtro, nessuna normalizzazione,
%     nessun ricampionamento. Conversione di formato, non di dati.
%
%  NOTA fs: i dati esistono a 1000 Hz (.emt) e 2000 Hz (ASCII). Il
%  MASTER rileva fs dalla colonna tempo: con fs hardcoded a 1000 su
%  dati a 2000 Hz la banda 20-300 diventerebbe 40-600 e il notch a 50
%  cadrebbe a 100, senza dare errore. Verificato empiricamente: gli
%  indici differiscono di <0.3% tra le due frequenze.
%
%  NOTA RandG: escluso. Ha 4 marker (StartR/StartG/StopG/StopR) invece
%  di 3 e fasi diverse (Reaching/Grasping, non Intero/Salita/Discesa).
%
%  USO
%    converti_tutti('C:\...\Sorgenti', 'C:\...\DATI EMG')
%    converti_ascii('C:\...\S041\Addu', 'C:\...\DATI EMG\Patologici\S041', 'S041', 'Addu')
% =========================================================


%% =========================================================
%  BATCH: tutti i soggetti, tutti i movimenti
% =========================================================
function converti_tutti(root_in, root_out)
mov = {'Flex','Addu','Addu_orizz','Circ','RandG'};

sog = dir(root_in);
sog = sog([sog.isdir]);
sog = sog(~ismember({sog.name},{'.','..'}));

if isempty(sog)
    error('Nessuna cartella soggetto trovata in %s', root_in);
end

for s = 1:numel(sog)
    cod = sog(s).name;

    % Gruppo dal codice: S* -> Patologici, H* -> Sani
    if startsWith(cod,'S','IgnoreCase',true)
        gruppo = 'Patologici';
    elseif startsWith(cod,'H','IgnoreCase',true)
        gruppo = 'Sani';
    else
        fprintf('\n=== %s: gruppo non deducibile dal codice, SALTATO ===\n', cod);
        continue;
    end

    dir_sog = fullfile(root_in, cod);
    
    % Cerca i tempi (es. T0, T1) dentro la cartella del soggetto
    tempi = dir(dir_sog);
    tempi = tempi([tempi.isdir]);
    tempi = tempi(~ismember({tempi.name},{'.','..'}));
    
    if isempty(tempi)
        % Fallback: se non ci sono sottocartelle T0/T1, prova a leggerli direttamente
        tempi = struct('name', {''}); 
    end

    for t = 1:numel(tempi)
        tempo_str = tempi(t).name;
        
        if ~isempty(tempo_str)
            dir_mov_base = fullfile(dir_sog, tempo_str);
            dir_out_finale = fullfile(root_out, gruppo, cod, tempo_str);
            fprintf('\n=== %s (%s) [%s] ===\n', cod, gruppo, tempo_str);
        else
            dir_mov_base = dir_sog;
            dir_out_finale = fullfile(root_out, gruppo, cod);
            fprintf('\n=== %s (%s) ===\n', cod, gruppo);
        end

        for m = 1:numel(mov)
            dir_in_mov = fullfile(dir_mov_base, mov{m});
            if ~exist(dir_in_mov,'dir')
                fprintf('  [%s] cartella assente\n', mov{m}); continue;
            end
            try
                converti_ascii(dir_in_mov, dir_out_finale, cod, mov{m});
            catch err
                fprintf('  [%s] SALTATO: %s\n', mov{m}, err.message);
            end
        end
    end
end
end


%% =========================================================
%  CONVERSIONE DI UN SINGOLO MOVIMENTO
% =========================================================
function converti_ascii(dir_in, dir_out, cod_sog, mov)

if ~exist(dir_out,'dir'); mkdir(dir_out); end

%% ---------- 1. EMG ----------
% Dentro una cartella dedicata al movimento c'e' un solo .txt
f_txt = trova_file(dir_in, '*.txt');
if isempty(f_txt); error('Nessun .txt trovato in %s', dir_in); end

[tempo, emg, nomi_orig, unita] = leggi_ascii(f_txt);
fs = round(1/median(diff(tempo)));

fprintf('  [%s] %s\n', mov, nome_file(f_txt));
fprintf('    %d canali, %.2f s, fs=%d Hz, unita'' %s\n', ...
        size(emg,2), tempo(end), fs, unita);

jit = std(diff(tempo))/median(diff(tempo));
if jit > 0.01
    warning('converti_ascii:fs_instabile', ...
        'Campionamento non uniforme (jitter %.1f%%): fs=%d potrebbe essere errato', ...
        100*jit, fs);
end

% Riordina e rinomina secondo la numerazione di progetto
[idx, nomi_can] = mappa_e_rinomina(nomi_orig);
emg = emg(:, idx);

for k = 1:8
    fprintf('      %d. %-34s <- %s\n', k, nomi_can{k}, nomi_orig{idx(k)});
end

f_out_emg = fullfile(dir_out, sprintf('%s_%s_EMG.emt', cod_sog, mov));
scrivi_emt_emg(f_out_emg, tempo, emg, nomi_can, unita, fs);
fprintf('    -> %s\n', nome_file(f_out_emg));

% Il RandG ha uno schema eventi diverso (StartR/StopR/StartG/StopG/MidG,
% + i tempi di picco calcolati dal marker). Lo gestisce arricchisci_randg:
% qui va saltato, altrimenti sovrascrive il file eventi a 9 colonne.
if strcmpi(mov,'RandG')
    fprintf('    eventi: gestiti da arricchisci_randg\n');
    return
end

%% ---------- 2. Eventi ----------
% Nella cartella del movimento gli eventi sono gia' isolati: basta
% filtrare i .emt di tipo 'Event sequences'.
cand = dir(fullfile(dir_in,'*.emt'));
COLS = {}; DATI = {};

for f = 1:numel(cand)
    fp = fullfile(cand(f).folder, cand(f).name);
    if ~contains(fileread(fp),'Event sequences'); continue; end

    [c,d] = leggi_eventi_file(fp);
    COLS  = [COLS, c];      %#ok<AGROW>
    DATI  = [DATI, {d}];    %#ok<AGROW>
    fprintf('    eventi: %-22s -> %s (%d rep)\n', ...
            cand(f).name, strjoin(c,', '), size(d,1));
end

if isempty(COLS)
    error('Nessun file eventi (Event sequences) trovato in %s', dir_in);
end

% Allinea il numero di ripetizioni se R e L ne hanno di diverse
n_rep = max(cellfun(@(d) size(d,1), DATI));
M  = nan(n_rep, numel(COLS));
c0 = 0;
for i = 1:numel(DATI)
    d = DATI{i};
    M(1:size(d,1), c0+(1:size(d,2))) = d;
    c0 = c0 + size(d,2);
end

f_out_ev = fullfile(dir_out, sprintf('%s_%s.emt', cod_sog, mov));
scrivi_emt_eventi(f_out_ev, COLS, M);
fprintf('    -> %s\n', nome_file(f_out_ev));
end


%% =========================================================
%  LETTURA
% =========================================================
function [tempo, emg, nomi, unita] = leggi_ascii(f)

fid = fopen(f,'r','n','UTF-8');
if fid<0; error('Impossibile aprire %s', f); end
righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);

i_hdr = find(cellfun(@(s) ischar(s) && contains(s,'Time'),righe),1);
if isempty(i_hdr); error('Riga di intestazione non trovata in %s', f); end

p = strsplit(righe{i_hdr},sprintf('\t'));
p = p(~cellfun(@isempty,strtrim(p)));

% "R.Ant.Deltoid(uV):" -> "R.Ant.Deltoid"
nomi = strtrim(regexprep(p(2:end),'\(.*?\)\s*:?\s*$',''));

tok   = regexp(p{2},'\((.*?)\)','tokens','once');
unita = 'uV';
if ~isempty(tok)
    unita = tok{1};
    unita = strrep(unita, char(956), 'u');   % micro greco -> u
    unita = strrep(unita, char(181), 'u');   % micro sign  -> u
end

d     = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');
tempo = d(:,1);
emg   = d(:,2:1+numel(nomi));

ok    = isfinite(tempo);
tempo = tempo(ok);
emg   = emg(ok,:);
end

%% ---------------------------------------------------------
%  Mappa i canali sulla numerazione di progetto e restituisce i nomi
%  canonici. Copre entrambe le nomenclature incontrate:
%    .emt : 'Right Erector spinae longissimus'
%    .txt : 'R.Thoracic Es'
%
%  ATTENZIONE: nel .emt il canale 7 era 'Extensor carpi ULNARIS', nel
%  .txt e' 'Ext.Carp.RAD.' (radiale). Sono muscoli diversi. Il pattern
%  'Ext.*Carp' li accetta entrambi e li rinomina in 'Right Extensor
%  carpi', NASCONDENDO la discrepanza. Chiarire quale sia il montaggio
%  reale prima di scriverlo in Metodi.
function [idx, nomi_can] = mappa_e_rinomina(nomi)

pat = {'Erector|Thoracic\s*Es', ...
       'Biceps', ...
       'Flex.*Carp', ...
       'Deltoideus\s*anterior|Ant.*Deltoid', ...
       'Rect.*Abdom', ...
       'Triceps', ...
       'Ext.*Carp', ...
       'Deltoideus\s*posterior|Post.*Deltoid'};

nomi_can = {'Right Erector spinae longissimus', ...
            'Right Biceps brachii caput longus', ...
            'Right Flexor carpi radialis', ...
            'Right Deltoideus anterior', ...
            'Right Rectus abdominis', ...
            'Right Triceps brachii caput longus', ...
            'Right Extensor carpi', ...
            'Right Deltoideus posterior'};

idx = zeros(1,8);
for k = 1:8
    hit = find(~cellfun(@isempty, regexpi(nomi, pat{k}, 'once')));
    if numel(hit) ~= 1
        error('mappa_e_rinomina:ambiguo', ...
          'Pattern "%s": %d corrispondenze in {%s}', ...
          pat{k}, numel(hit), strjoin(nomi,' | '));
    end
    idx(k) = hit;
end
end

%% ---------------------------------------------------------
function [cols, dati] = leggi_eventi_file(f)

fid = fopen(f,'r');
if fid<0; error('Impossibile aprire %s', f); end
righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);

i_hdr = find(cellfun(@(s) ischar(s) && startsWith(strtrim(s),'Item'),righe),1);
if isempty(i_hdr); error('Intestazione eventi non trovata in %s', f); end

p    = strsplit(righe{i_hdr},sprintf('\t'));
p    = p(~cellfun(@isempty,strtrim(p)));
cols = strtrim(p(2:end));

d    = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');
d    = d(all(isfinite(d(:,1:numel(cols)+1)),2), :);
dati = d(:,2:1+numel(cols));    % scarta la colonna 'Item'
end


%% =========================================================
%  SCRITTURA .emt (formato BTS)
% =========================================================
function scrivi_emt_emg(f, tempo, emg, nomi, unita, fs)

fid = fopen(f,'w');
if fid<0; error('Impossibile scrivere %s', f); end

fprintf(fid,'BTS ASCII format\n\n');
fprintf(fid,'Type:          Emg tracks\n');
fprintf(fid,'Measure unit:  %s\n\n', unita);
fprintf(fid,'Tracks:        %d\n', size(emg,2));
fprintf(fid,'Frequency:     %d Hz\n', fs);
fprintf(fid,'Frames:        %d\n', numel(tempo));
fprintf(fid,'Start time:    %.3f\n\n', tempo(1));

fprintf(fid,' Frame\t Time');
fprintf(fid,'\t%s', nomi{:});
fprintf(fid,'\t\n');

% %.6f: il sorgente ha 5 decimali -> nessuna perdita di precisione
for i = 1:numel(tempo)
    fprintf(fid,'%6d\t%9.4f', i, tempo(i));
    fprintf(fid,'\t%12.6f', emg(i,:));
    fprintf(fid,'\t\n');
end
fclose(fid);
end

%% ---------------------------------------------------------
function scrivi_emt_eventi(f, cols, M)

fid = fopen(f,'w');
if fid<0; error('Impossibile scrivere %s', f); end

fprintf(fid,'BTS ASCII format\n\n');
fprintf(fid,'Type:          Event sequences\n');
fprintf(fid,'Measure unit:  s\n\n');
fprintf(fid,'Sequences:     %d\n\n', numel(cols));

fprintf(fid,' Item');
fprintf(fid,'\t%10s', cols{:});
fprintf(fid,'\t\n');

for i = 1:size(M,1)
    fprintf(fid,'%5d', i);
    for c = 1:size(M,2)
        if isfinite(M(i,c))
            fprintf(fid,'\t%10.3f', M(i,c));
        else
            fprintf(fid,'\t%10s','');
        end
    end
    fprintf(fid,'\t\n');
end
fclose(fid);
end


%% =========================================================
%  UTILITY
% =========================================================
function f = trova_file(d, pat)
c = dir(fullfile(d,pat));
if isempty(c); f = ''; else; f = fullfile(c(1).folder, c(1).name); end
end

function n = nome_file(f)
[~,b,e] = fileparts(f);
n = [b e];
end
