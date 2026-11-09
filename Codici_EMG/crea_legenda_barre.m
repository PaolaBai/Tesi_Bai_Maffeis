function crea_legenda_barre(nome_file)
% CREA_LEGENDA_BARRE Genera e salva un'immagine con la legenda
% USO:
%   crea_legenda_barre();                 % Mostra solo a schermo
%   crea_legenda_barre('legenda.png');    % Mostra e salva come PNG

% Se l'input 'nome_file' non viene passato, lo imposta vuoto
if nargin < 1 || isempty(nome_file)
    nome_file = ''; 
end

COL_SANI = [0.20 0.60 0.85];   % Azzurro
COL_T0   = [0.85 0.30 0.30];   % Rosso
COL_T1   = [0.50 0.20 0.60];   % Viola

figLeg = figure('Color','w', 'Position',[900 300 240 150], ...
                'Name','Legenda Gruppi', 'MenuBar','none', 'ToolBar','none');
axLeg = axes(figLeg, 'Visible', 'off'); 
hold(axLeg, 'on');

% Traccia elementi bar fittizi
hS = bar(axLeg, NaN, NaN, 'FaceColor', COL_SANI, 'EdgeColor', 'k');
h0 = bar(axLeg, NaN, NaN, 'FaceColor', COL_T0,   'EdgeColor', 'k');
h1 = bar(axLeg, NaN, NaN, 'FaceColor', COL_T1,   'EdgeColor', 'k');

lgd = legend(axLeg, [hS, h0, h1], {'Sani', 'T0', 'T1'}, ...
    'Location', 'none', 'Position', [0.05 0.05 0.9 0.9], ...
    'FontSize', 11, 'Box', 'on', 'Interpreter', 'none');

% Dimensioni icone (rettangoli allungati)
lgd.ItemTokenSize = [60, 10]; 
set(lgd, 'EdgeColor', [0.8 0.8 0.8]);

% --- SALVATAGGIO AUTOMATICO ---
if ~isempty(nome_file)
    exportgraphics(figLeg, nome_file, 'Resolution', 300);
end
end