function OUT = grafico_pesi_prototipi(PROTO, mov, fase)
%GRAFICO_PESI_PROTOTIPI  Barre orizzontali dei pesi muscolari di ciascun
%  prototipo sano (colonne di Wref ottenute dal clustering).
%
%  USO
%    grafico_pesi_prototipi(PROTO, 'Addu', 'R_Intero')
%    grafico_pesi_prototipi(PROTO, 'RandG', 'Completo_Intero')
%
%    grafico_pesi_prototipi(PROTO_roh, 'Addu', 'R_Intero'); usando
%    l'articolo di roh et al.
%
%    OUT = grafico_pesi_prototipi(...)   % restituisce anche Wref e prevalenza
%
%  Un pannello per prototipo (ordinati per condivisione), con gli 8 muscoli in
%  barre orizzontali. Nel titolo la prevalenza (in quanti sani compare).

nomi_mus = {'Erettore','Bicipite','Flessore','Delt.Ant', ...
            'Addome','Tricipite','Estensore','Delt.Post'};

if ~isfield(PROTO, mov) || ~isfield(PROTO.(mov), fase)
    error('grafico_pesi_prototipi:proto', ...
        'PROTO non ha %s / %s. Movimenti/fasi disponibili: vedi fieldnames(PROTO).', mov, fase);
end
P = PROTO.(mov).(fase);
W = P.Wref;                      % [8 x nCluster]
if isempty(W); error('grafico_pesi_prototipi:vuoto','Wref vuota per %s/%s.', mov, fase); end

prev  = []; if isfield(P,'prevalenza'); prev = P.prevalenza; end
nsani = NaN; if isfield(P,'n_sani');    nsani = P.n_sani;    end

% --- filtro prevalenza >= 50% (coerente con confronta_con_prototipo) ---
prevalenza_min = 0.50;
if ~isempty(prev) && ~isnan(nsani)
    keep = (prev(:) / nsani) >= prevalenza_min;
    W    = W(:, keep);
    prev = prev(keep);
end
if isempty(W) || size(W,2)==0
    error('grafico_pesi_prototipi:nessuno', ...
        'Nessun prototipo con prevalenza >= %.0f%% per %s/%s.', 100*prevalenza_min, mov, fase);
end
k = size(W,2);

col = [0.11 0.62 0.46];          % verde (coerente col tema sinergie)

figs = [];
for i = 1:k
    figs(i) = figure('Color','w','Position',[80+30*i 80+30*i 380 460]); %#ok<AGROW>
    barh(1:8, W(:,i), 'FaceColor', col, 'EdgeColor','none');
    set(gca,'YDir','reverse','YTick',1:8,'YTickLabel',nomi_mus,'FontSize',10);
    xlim([0 max(0.01,max(W(:)))*1.1]); xlabel('peso');
    if ~isempty(prev) && i <= numel(prev) && ~isnan(nsani)
        ttl = sprintf('%s / %s — Proto %d  (%d/%d sani)', ...
              mov, strrep(fase,'_','\_'), i, prev(i), nsani);
    else
        ttl = sprintf('%s / %s — Proto %d', mov, strrep(fase,'_','\_'), i);
    end
    title(ttl, 'FontWeight','normal','FontSize',11);
    box off;
end

OUT.Wref = W; OUT.prevalenza = prev; OUT.n_sani = nsani;
OUT.muscoli = nomi_mus; OUT.mov = mov; OUT.fase = fase; OUT.figure = figs;
end
