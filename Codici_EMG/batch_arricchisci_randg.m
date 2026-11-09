function batch_arricchisci_randg(root_sorgenti, root_dati)
%BATCH_ARRICCHISCI_RANDG  Esegue arricchisci_randg su TUTTI i soggetti e
%  timepoint in autonomia: trova da solo i file sorgente (Cicli_RandG e
%  Ulna_RandG) e scrive il file eventi arricchito <cod>_RandG.emt nella
%  cartella timepoint di DATI EMG, dove il MASTER lo cerca.
%
%  USO (dal Command Window)
%    batch_arricchisci_randg                       % usa i percorsi di default
%    batch_arricchisci_randg(root_sorgenti, root_dati)
%
%  COME TROVA LE SORGENTI
%    Cerca ricorsivamente sotto root_sorgenti una cartella che contenga sia
%    *Cicli*RandG* sia *Ulna*RandG* e il cui percorso contenga il codice
%    soggetto (e, se il soggetto ha piu' di un timepoint, anche il timepoint).
%    root_sorgenti di default e' la cartella 'Analyzer', che contiene sia le
%    sorgenti sia DATI EMG: cosi' funziona sia se le sorgenti stanno in una
%    cartella a parte, sia se sono gia' accanto ai dati. Se il tuo layout e'
%    diverso, adatta trova_sorgente() in fondo.
%
%  OUTPUT
%    <cod>_RandG.emt (9 colonne) in ...\DATI EMG\<gruppo>\<cod>\<timepoint>\
%    Sovrascrive un eventuale file gia' presente (rigenerazione).

if nargin < 1 || isempty(root_sorgenti)
    root_sorgenti = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer';
end
if nargin < 2 || isempty(root_dati)
    root_dati = 'C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG';
end
if ~exist(root_dati,'dir')
    error('batch_arricchisci_randg:dati','Cartella DATI EMG non trovata: %s', root_dati);
end

gruppi = {'Patologici','Sani'};
n_ok = 0; n_skip = 0; n_err = 0;
skip_list = {}; err_list = {};

fprintf('%s\n BATCH arricchisci_randg\n sorgenti: %s\n dati:     %s\n%s\n', ...
    repmat('=',1,60), root_sorgenti, root_dati, repmat('=',1,60));

for g = 1:numel(gruppi)
    dir_gruppo = fullfile(root_dati, gruppi{g});
    if ~exist(dir_gruppo,'dir')
        fprintf('[%s] cartella assente, saltato\n', gruppi{g}); continue;
    end
    sog = elenca_cartelle(dir_gruppo);
    for s = 1:numel(sog)
        cod = sog{s};
        tps = elenca_cartelle(fullfile(dir_gruppo, cod));
        if isempty(tps)
            fprintf('[%s/%s] nessun timepoint, saltato\n', gruppi{g}, cod); continue;
        end
        for it = 1:numel(tps)
            timepoint = tps{it};
            dir_out   = fullfile(dir_gruppo, cod, timepoint);   % dove il MASTER cerca

            dir_in = trova_sorgente(root_sorgenti, cod, timepoint, numel(tps) > 1);
            etich  = sprintf('%s/%s/%s', gruppi{g}, cod, timepoint);

            if isempty(dir_in)
                fprintf('[SKIP] %s : sorgenti RandG (Cicli+Ulna) non trovate\n', etich);
                n_skip = n_skip + 1; skip_list{end+1} = etich; %#ok<AGROW>
                continue;
            end

            fprintf('[%s]\n  sorgente: %s\n', etich, dir_in);
            try
                arricchisci_randg(dir_in, dir_out, cod);
                n_ok = n_ok + 1;
            catch e
                fprintf('  ERRORE: %s\n', e.message);
                n_err = n_err + 1;
                err_list{end+1} = sprintf('%s : %s', etich, e.message); %#ok<AGROW>
            end
        end
    end
end

fprintf('\n%s\n RIEPILOGO — arricchiti: %d | saltati: %d | errori: %d\n%s\n', ...
    repmat('=',1,60), n_ok, n_skip, n_err, repmat('=',1,60));
if ~isempty(skip_list)
    fprintf(' SALTATI (sorgenti mancanti):\n'); fprintf('   %s\n', skip_list{:});
end
if ~isempty(err_list)
    fprintf(' ERRORI:\n'); fprintf('   %s\n', err_list{:});
end
end

%% ---------------------------------------------------------
function dir_in = trova_sorgente(root, cod, timepoint, usa_tp)
% Restituisce la cartella che contiene i sorgenti RandG (Cicli + Ulna) per il
% soggetto/timepoint dato, cercando ricorsivamente sotto 'root'.
dir_in = '';
cand = cerca_cicli(root);          % ricerca ricorsiva (portabile, no '**')
for i = 1:numel(cand)
    folder = fileparts(cand{i});
    parts  = strsplit(folder, filesep);
    % il percorso deve contenere il codice soggetto come componente
    if ~any(strcmpi(parts, cod)); continue; end
    % se il soggetto ha piu' timepoint, il percorso deve contenere anche il tp
    if usa_tp && ~any(strcmpi(parts, timepoint)); continue; end
    % nella stessa cartella deve esserci anche il marker Ulna
    has_ulna = ~isempty(dir(fullfile(folder, '*Ulna*RandG*.emt'))) || ...
               ~isempty(dir(fullfile(folder, '*Ulna*.emt')));
    if has_ulna; dir_in = folder; return; end
end
end

%% ---------------------------------------------------------
function lst = cerca_cicli(d)
% Elenco ricorsivo dei file *Cicli*RandG* (fallback *Cicli*) sotto 'd'.
lst = {};
here = dir(fullfile(d, '*Cicli*RandG*.emt'));
if isempty(here); here = dir(fullfile(d, '*Cicli*.emt')); end
for i = 1:numel(here); lst{end+1} = fullfile(d, here(i).name); end %#ok<AGROW>
sub = dir(d);
sub = sub([sub.isdir] & ~ismember({sub.name},{'.','..'}));
for i = 1:numel(sub)
    lst = [lst, cerca_cicli(fullfile(d, sub(i).name))]; %#ok<AGROW>
end
end

%% ---------------------------------------------------------
function nomi = elenca_cartelle(d)
x = dir(d);
x = x([x.isdir]);
x = x(~ismember({x.name},{'.','..'}));
nomi = {x.name};
end
