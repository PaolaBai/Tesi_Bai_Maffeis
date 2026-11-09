function PROTO = tutti_prototipi_roh(DATA, opts)
%TUTTI_PROTOTIPI_ROH  Come tutti_prototipi, ma col metodo di Roh et al. (2015)
%  (cluster_roh: distanza euclidea, linkage Ward, numero di cluster = minimo con
%  <=1 sinergia per soggetto). Calcola i prototipi sani per TUTTE le fasi Intero
%  del lato registrato (R) di TUTTI i movimenti.
%
%  USO
%    PROTO_roh = tutti_prototipi_roh(DATA);
%    % accesso:  PROTO.Flex.R_Intero.Wref   PROTO.Circ.RAvanti_Intero.prevalenza
%
%  Fasi calcolate (scoperte dai dati, non cablate):
%    - solo le fasi ATTIVE del lato registrato (sani = destro): le fasi Intero
%      che iniziano per 'R' (R_Intero; Circ: RAvanti_Intero, RIndietro_Intero).
%    - per il RandG, SOLO opts.randg_fase (default 'Completo_Intero').
%
%  opts (opzionali): .gruppo ('Sani'), .tempo ('T'), .kmax (30),
%    .randg_fase ('Completo_Intero').
%
%  OUTPUT
%    PROTO.<movimento>.<fase> = struttura P di cluster_roh (stessa forma di
%    tutti_prototipi -> intercambiabile con le funzioni a valle).

if nargin < 2, opts = struct; end
if ~isfield(opts,'gruppo'),     opts.gruppo = 'Sani';            end
if ~isfield(opts,'tempo'),      opts.tempo  = 'T';               end
if ~isfield(opts,'randg_fase'), opts.randg_fase = 'Completo_Intero'; end

if ~isfield(DATA, opts.gruppo)
    error('tutti_prototipi_roh:gruppo','Gruppo "%s" non trovato in DATA.', opts.gruppo);
end
sani = fieldnames(DATA.(opts.gruppo));

% --- scopri i movimenti presenti nei sani ---
movimenti = {};
for s = 1:numel(sani)
    st = DATA.(opts.gruppo).(sani{s});
    if ~isfield(st, opts.tempo); continue; end
    movimenti = union(movimenti, fieldnames(st.(opts.tempo)));
end
movimenti = movimenti(:)';
if isempty(movimenti)
    error('tutti_prototipi_roh:vuoto','Nessun movimento trovato nei sani (tempo "%s").', opts.tempo);
end

PROTO = struct();
riep = {};
for m = 1:numel(movimenti)
    mov  = movimenti{m};
    fasi = fasi_intero_di(DATA, opts.gruppo, opts.tempo, mov);

    if strcmpi(mov, 'RandG')
        fasi = fasi(strcmp(fasi, opts.randg_fase));
        if isempty(fasi)
            riep{end+1} = sprintf('  %-12s [%s non trovata, saltato]', mov, opts.randg_fase); %#ok<AGROW>
        end
    else
        % sani registrati SOLO a destra: si tengono le fasi Intero che iniziano per 'R'
        fasi = fasi(~cellfun(@isempty, regexp(fasi, '^R', 'once')));
    end

    for f = 1:numel(fasi)
        fase = fasi{f};
        try
            P = cluster_roh(DATA, mov, fase, opts);
            PROTO.(mov).(fase) = P;
            riep{end+1} = sprintf('  %-12s %-18s  %2d sani  %2d cluster', ...
                mov, fase, P.n_sani, P.n_cluster); %#ok<AGROW>
        catch e
            riep{end+1} = sprintf('  %-12s %-18s  [SALTATO: %s]', mov, fase, e.message); %#ok<AGROW>
        end
    end
end

fprintf('\n============= tutti_prototipi_roh (Roh 2015) =============\n');
if isempty(riep)
    fprintf('  (nessuna fase Intero calcolata)\n');
else
    fprintf('%s\n', riep{:});
end
fprintf('==========================================================\n');
end

%% ---------------------------------------------------------
function fasi = fasi_intero_di(DATA, gruppo, tempo, mov)
% Fasi '..._Intero' lette dalle phase_labels del primo sano che ha il movimento.
fasi = {};
sani = fieldnames(DATA.(gruppo));
for s = 1:numel(sani)
    st = DATA.(gruppo).(sani{s});
    if ~isfield(st, tempo); continue; end
    st = st.(tempo);
    if ~isfield(st, mov); continue; end
    M = st.(mov);
    if ~isfield(M, 'sinergie'); continue; end
    lab  = cellstr(M.sinergie.phase_labels);
    fasi = lab(~cellfun(@isempty, regexp(lab, '_Intero$', 'once')));
    return;   % basta il primo sano che ha il movimento
end
end
