function PROTO = tutti_prototipi(DATA, opts)
%TUTTI_PROTOTIPI  Calcola le sinergie prototipo del gruppo sani per TUTTE le
%  fasi Intero (lato R e L) di TUTTI i movimenti, raccogliendole in un'unica
%  struttura navigabile.
%
%  USO
%    PROTO = tutti_prototipi(DATA);
%    PROTO = tutti_prototipi(DATA, struct('soglia',0.80));
%    % accesso:  PROTO.Flex.R_Intero.Wref   PROTO.Circ.LAvanti_Intero.prevalenza
%
%  Fasi calcolate (scoperte dai dati, non cablate):
%    - solo le fasi ATTIVE del lato registrato: i sani sono acquisiti sul lato
%      destro, quindi si tengono solo le fasi Intero che iniziano per 'R'
%      (R_Intero; per il Circ RAvanti_Intero e RIndietro_Intero). Le fasi L
%      (braccio destro fermo) vengono scartate.
%    - per il RandG, SOLO opts.randg_fase (default 'Completo_Intero')
%
%  opts (opzionali): come sinergie_prototipo (.gruppo 'Sani', .tempo 'T',
%    .soglia 0.75), piu' .randg_fase (default 'Completo_Intero').
%
%  OUTPUT
%    PROTO.<movimento>.<fase> = struttura P di sinergie_prototipo.
%    Stampa un riepilogo di cosa ha calcolato (sani e cluster per combinazione).

if nargin < 2, opts = struct; end
if ~isfield(opts,'gruppo'),     opts.gruppo = 'Sani';            end
if ~isfield(opts,'tempo'),      opts.tempo  = 'T';               end
if ~isfield(opts,'soglia'),     opts.soglia = 0.75;              end
if ~isfield(opts,'randg_fase'), opts.randg_fase = 'Completo_Intero'; end

if ~isfield(DATA, opts.gruppo)
    error('tutti_prototipi:gruppo','Gruppo "%s" non trovato in DATA.', opts.gruppo);
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
    error('tutti_prototipi:vuoto','Nessun movimento trovato nei sani (tempo "%s").', opts.tempo);
end

PROTO = struct();
riep = {};
for m = 1:numel(movimenti)
    mov  = movimenti{m};
    fasi = fasi_intero_di(DATA, opts.gruppo, opts.tempo, mov);

    if strcmpi(mov, 'RandG')
        % RandG: solo la fase completa del gesto
        fasi = fasi(strcmp(fasi, opts.randg_fase));
        if isempty(fasi)
            riep{end+1} = sprintf('  %-12s [%s non trovata, saltato]', mov, opts.randg_fase); %#ok<AGROW>
        end
    else
        % Sani registrati SOLO sul lato destro: la fase "attiva" (arto con gli
        % elettrodi in movimento) e' quella R. Le fasi L sono il braccio destro
        % fermo -> non contengono coordinazione, si scartano.
        fasi = fasi(~cellfun(@isempty, regexp(fasi, '^R', 'once')));
    end

    for f = 1:numel(fasi)
        fase = fasi{f};
        try
            P = sinergie_prototipo(DATA, mov, fase, opts);
            PROTO.(mov).(fase) = P;
            riep{end+1} = sprintf('  %-12s %-18s  %2d sani  %2d cluster', ...
                mov, fase, P.n_sani, numel(P.prevalenza)); %#ok<AGROW>
        catch e
            riep{end+1} = sprintf('  %-12s %-18s  [SALTATO: %s]', mov, fase, e.message); %#ok<AGROW>
        end
    end
end

fprintf('\n================= tutti_prototipi =================\n');
if isempty(riep)
    fprintf('  (nessuna fase Intero calcolata)\n');
else
    fprintf('%s\n', riep{:});
end
fprintf('==================================================\n');
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
