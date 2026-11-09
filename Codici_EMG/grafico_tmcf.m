function OUT = grafico_tmcf(DATA, gruppo, sog, tempo, mov, fase)
%GRAFICO_TMCF  Traccia i profili TMCf (co-attivazione istante per istante) dei
%  7 sottogruppi per un dato soggetto/movimento/fase. Il TMCf e' la curva da
%  cui nasce il TMCi (che ne e' la media temporale).
%
%  USO
%    grafico_tmcf(DATA, 'Patologici', 'S041', 'T0', 'Addu', 'R_Intero')
%    grafico_tmcf(DATA, 'Sani', 'H006', 'T', 'Circ', 'RAvanti_Intero')
%    OUT = grafico_tmcf(...)   % restituisce anche le curve medie [T_norm x 7]
%
%  Traccia, per ogni sottogruppo, la media sui cicli del profilo TMCf, con
%  l'area +/- deviazione standard tra i cicli. In legenda il TMCi (media della
%  curva) di ciascun sottogruppo.

SG_ordine = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};

% --- recupera la struttura del movimento ---
M = DATA.(gruppo).(sog);
if ~isempty(tempo) && isfield(M, tempo); M = M.(tempo); end
if ~isfield(M, mov)
    error('grafico_tmcf:mov','%s non trovato per %s/%s.', mov, sog, tempo);
end
M = M.(mov);

fasi = cellstr(M.phase_labels);
ph = find(strcmp(fasi, fase), 1);
if isempty(ph)
    error('grafico_tmcf:fase','Fase "%s" non trovata. Disponibili: %s', fase, strjoin(fasi, ', '));
end

T_norm = size(M.(SG_ordine{1}).TMCf, 1);
x = linspace(0, 100, T_norm);
col = lines(numel(SG_ordine));

figure('Color','w','Position',[100 100 800 520]); hold on;
curve = nan(T_norm, numel(SG_ordine));
tmci  = nan(1, numel(SG_ordine));
legende = {};

for b = 1:numel(SG_ordine)
    SG = SG_ordine{b};
    if ~isfield(M, SG) || ~isfield(M.(SG),'TMCf'); continue; end
    A = M.(SG).TMCf(:,:,ph);            % [T_norm x n_rep] per questa fase
    if all(isnan(A(:))); continue; end
    mu = riga_nanmean(A);               % media sui cicli  [T_norm x 1]
    sd = riga_nanstd(A);                % dev. std tra i cicli
    curve(:,b) = mu;
    v = mu(isfinite(mu));
    tmci(b) = mean(v);                  % = il TMCi del sottogruppo (media della curva)

    % banda +/- SD
    xf = [x, fliplr(x)];
    yf = [mu' + sd', fliplr(mu' - sd')];
    yf(~isfinite(yf)) = NaN;
    fill(xf, yf, col(b,:), 'FaceAlpha',0.12, 'EdgeColor','none', 'HandleVisibility','off');
    plot(x, mu, 'Color', col(b,:), 'LineWidth', 1.8);
    legende{end+1} = sprintf('%s (TMCi=%.1f)', SG, tmci(b)); %#ok<AGROW>
end

xlabel('% del ciclo'); ylabel('TMCf (co-attivazione istantanea)');
title(sprintf('%s / %s / %s — %s', gruppo, sog, mov, strrep(fase,'_','\_')), ...
      'Interpreter','tex');
legend(legende, 'Location','eastoutside'); grid on; box off;
xlim([0 100]);

OUT.x = x; OUT.curve = curve; OUT.TMCi = tmci; OUT.sottogruppi = SG_ordine;
OUT.fase = fase; OUT.mov = mov;
end

%% --- medie/std sui cicli (dim 2), nan-aware, portabili ---
function m = riga_nanmean(A)
m = nan(size(A,1),1);
for i = 1:size(A,1)
    v = A(i,:); v = v(isfinite(v));
    if ~isempty(v); m(i) = mean(v); end
end
end

function s = riga_nanstd(A)
s = nan(size(A,1),1);
for i = 1:size(A,1)
    v = A(i,:); v = v(isfinite(v));
    if numel(v) > 1; s(i) = std(v); end
end
end
