function seg = converti_eventi_randg(f_in, f_out, opts)
%CONVERTI_EVENTI_RANDG  Traduce gli eventi RandG nel formato Start/Mid/Stop
%  leggibile da test_baseline / test_baseline_segmentata / test_baseline_simultanea,
%  SENZA modificare quelle funzioni.
%
%  Il RandG ha eventi StartR/StopR/StartG/StopG/MidG (R=reach, G=grasp), che il
%  lettore standard (regexp ^([RL])Start...) non riconosce. Questo adattatore li
%  legge e riscrive i 4 SEGMENTI del gesto come 4 gruppi in formato standard:
%
%     RAndata  [StartR → StartG]   braccio dal fianco all'oggetto   (concentrico)
%     GAndata  [StartG → MidG]     afferra e porta al petto         (mantenimento+carico)
%     GRitorno [MidG   → StopG]    riporta l'oggetto in posizione   (mantenimento+carico)
%     RRitorno [StopG  → StopR]    braccio di nuovo al fianco       (ECCENTRICO)
%
%  R_Concat (RAndata+RRitorno) NON viene generato: è discontinuo e non adatto
%  alla scomposizione tonico/fasico.
%
%  USO
%    converti_eventi_randg('S041_RandG.emt', 'S041_RandG_seg.emt');
%    % poi, sul file tradotto, con le tre funzioni:
%    test_baseline('S041_RandG_EMG.emt','S041_RandG_seg.emt','RRA');   % RAndata
%    test_baseline_simultanea('S041_RandG_EMG.emt','S041_RandG_seg.emt','RGA',100,struct('Wn',1/100));
%
%  Lati (gruppi) da usare:  RAndata→'RRA'  GAndata→'RGA'  GRitorno→'RGR'  RRitorno→'RRR'
%
%  NB: Mid di ciascun segmento = punto medio temporale (quindi Salita/Discesa
%  sono due metà). Se hai i tempi di picco velocità da arricchisci_randg, puoi
%  passarli in opts.peak (vedi sotto) per far coincidere Salita/Discesa con Acc/Dec.

if nargin < 3, opts = struct; end

% ===== MAPPATURA COLONNE — modifica QUI se i nomi nel tuo file differiscono =====
COL = struct('StartR','StartR', 'StopR','StopR', ...
             'StartG','StartG', 'StopG','StopG', 'MidG','MidG');
% ================================================================================

% --- lettura file eventi RandG (stessa logica di leggi_eventi_semplice) ---
fid = fopen(f_in,'r');
if fid < 0, error('converti_eventi_randg:apertura','Impossibile aprire: %s', f_in); end
righe = {}; while ~feof(fid), righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);
i_hdr = find(cellfun(@(s) ischar(s) && startsWith(strtrim(s),'Item'), righe), 1);
if isempty(i_hdr)
    error('converti_eventi_randg:hdr','Intestazione "Item" non trovata in %s', f_in);
end
p = strsplit(righe{i_hdr}, sprintf('\t')); p = p(~cellfun(@isempty, strtrim(p)));
cols = strtrim(p(2:end));
d = readmatrix(f_in,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');

% --- verifica presenza delle 5 colonne evento ---
need = {COL.StartR, COL.StartG, COL.MidG, COL.StopG, COL.StopR};
for k = 1:numel(need)
    if isempty(find(strcmp(cols, need{k}), 1))
        error('converti_eventi_randg:colonna', ...
          ['Colonna "%s" non trovata.\nColonne presenti: %s\n' ...
           'Correggi la struttura COL in cima alla funzione.'], need{k}, strjoin(cols, ', '));
    end
end
getcol = @(name) d(:, find(strcmp(cols, name), 1) + 1);
tSR = getcol(COL.StartR); tSG = getcol(COL.StartG); tMG = getcol(COL.MidG);
tPG = getcol(COL.StopG);  tPR = getcol(COL.StopR);

% --- righe valide (tutti i 5 eventi finiti) ---
ok = isfinite(tSR) & isfinite(tSG) & isfinite(tMG) & isfinite(tPG) & isfinite(tPR);
tSR=tSR(ok); tSG=tSG(ok); tMG=tMG(ok); tPG=tPG(ok); tPR=tPR(ok);
n = numel(tSR);
if n == 0, error('converti_eventi_randg:vuoto','Nessuna ripetizione valida.'); end

% --- 4 segmenti ---
suff = {'RA','GA','GR','RR'};
nome = {'RAndata','GAndata','GRitorno','RRitorno'};
S = {tSR, tSG, tMG, tPG};       % start di ciascun segmento
E = {tSG, tMG, tPG, tPR};       % stop  di ciascun segmento

% --- diagnostica + controllo ordinamento ---
fprintf('RandG: %d ripetizioni valide\n', n);
fprintf('%-10s %-6s %11s %8s\n','segmento','lato','durata_med','dur<=0');
for k = 1:4
    dur = E{k} - S{k};
    fprintf('%-10s %-6s %11.3f %8d\n', nome{k}, ['R' suff{k}], mean(dur), sum(dur<=0));
    if any(dur <= 0)
        warning('converti_eventi_randg:ordine', ...
          'Segmento %s ha durate <=0: la mappatura degli eventi potrebbe essere errata.', nome{k});
    end
end

% --- Mid per segmento (punto medio, oppure picchi se forniti in opts.peak) ---
MID = cell(1,4);
for k = 1:4, MID{k} = (S{k} + E{k})/2; end
if isfield(opts,'peak') && iscell(opts.peak) && numel(opts.peak)==4
    for k = 1:4
        if ~isempty(opts.peak{k}) && numel(opts.peak{k})==n, MID{k} = opts.peak{k}(:); end
    end
end

% --- scrittura file eventi in formato standard (Start/Stop/Mid per 4 gruppi) ---
hdr = {'Item'}; M = (1:n)';
for k = 1:4
    hdr = [hdr, {['RStart' suff{k}]}, {['RStop' suff{k}]}, {['RMid' suff{k}]}]; %#ok<AGROW>
    M   = [M, S{k}(:), E{k}(:), MID{k}(:)]; %#ok<AGROW>
end
fid = fopen(f_out,'w');
if fid < 0, error('converti_eventi_randg:scrittura','Impossibile scrivere: %s', f_out); end
fprintf(fid, 'BTS ASCII format (RandG segmentato)\n');
fprintf(fid, '%s\n', strjoin(hdr, sprintf('\t')));
for r = 1:n
    fprintf(fid, '%d', M(r,1));
    fprintf(fid, '\t%.6f', M(r,2:end));
    fprintf(fid, '\n');
end
fclose(fid);

fprintf('\nScritto: %s  (4 gruppi, R_Concat escluso)\n', f_out);
fprintf('Lati da usare:  RAndata→''RRA''  GAndata→''RGA''  GRitorno→''RGR''  RRitorno→''RRR''\n');
fprintf('Promemoria: RRitorno (RRR) è la discesa ECCENTRICA (leggila con cautela, frac.neg alta attesa).\n');

if nargout > 0
    seg = struct('nome',nome,'lato',cellfun(@(x)['R' x],suff,'uni',0),'start',S,'stop',E,'mid',MID);
end
end
