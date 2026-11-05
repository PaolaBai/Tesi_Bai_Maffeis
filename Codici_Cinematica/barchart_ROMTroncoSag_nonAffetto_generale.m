clear
close all
clc

%% =========================================================================
%% ESTRAZIONE DATI
%% =========================================================================

media_sani = []; media_T0 = []; media_T1 = [];
std_sani   = []; std_T0   = []; std_T1   = [];

% Addu
Db_sani = readtable('Database Sani_Addu.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Addu.xlsx');
ROM_s = [Db_sani.ROMTroncoSagittale_Dx; Db_sani.ROMTroncoSagittale_Sx]; ROM_0 = Db_pato.ROMTroncoSagittale_T0; ROM_1 = Db_pato.ROMTroncoSagittale_T1;
media_sani = [media_sani, mean(ROM_s, 'omitnan')]; media_T0 = [media_T0, mean(ROM_0, 'omitnan')]; media_T1 = [media_T1, mean(ROM_1, 'omitnan')];
std_sani   = [std_sani,   std(ROM_s,  'omitnan')]; std_T0   = [std_T0,   std(ROM_0,  'omitnan')]; std_T1   = [std_T1,   std(ROM_1,  'omitnan')];

% Addu orizz
Db_sani = readtable('Database Sani_Addu orizz.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Addu orizz.xlsx');
ROM_s = [Db_sani.ROMTroncoSagittale_Dx; Db_sani.ROMTroncoSagittale_Sx]; ROM_0 = Db_pato.ROMTroncoSagittale_T0; ROM_1 = Db_pato.ROMTroncoSagittale_T1;
media_sani = [media_sani, mean(ROM_s, 'omitnan')]; media_T0 = [media_T0, mean(ROM_0, 'omitnan')]; media_T1 = [media_T1, mean(ROM_1, 'omitnan')];
std_sani   = [std_sani,   std(ROM_s,  'omitnan')]; std_T0   = [std_T0,   std(ROM_0,  'omitnan')]; std_T1   = [std_T1,   std(ROM_1,  'omitnan')];

% Flex
Db_sani = readtable('Database Sani_Flex.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Flex.xlsx');
ROM_s = [Db_sani.ROMTroncoSagittale_Dx; Db_sani.ROMTroncoSagittale_Sx]; ROM_0 = Db_pato.ROMTroncoSagittale_T0; ROM_1 = Db_pato.ROMTroncoSagittale_T1;
media_sani = [media_sani, mean(ROM_s, 'omitnan')]; media_T0 = [media_T0, mean(ROM_0, 'omitnan')]; media_T1 = [media_T1, mean(ROM_1, 'omitnan')];
std_sani   = [std_sani,   std(ROM_s,  'omitnan')]; std_T0   = [std_T0,   std(ROM_0,  'omitnan')]; std_T1   = [std_T1,   std(ROM_1,  'omitnan')];

% Circ avanti
Db_sani = readtable('Database Sani_Circ avanti.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Circ avanti.xlsx');
ROM_s = [Db_sani.ROMTroncoSagittale_Dx; Db_sani.ROMTroncoSagittale_Sx]; ROM_0 = Db_pato.ROMTroncoSagittale_T0; ROM_1 = Db_pato.ROMTroncoSagittale_T1;
media_sani = [media_sani, mean(ROM_s, 'omitnan')]; media_T0 = [media_T0, mean(ROM_0, 'omitnan')]; media_T1 = [media_T1, mean(ROM_1, 'omitnan')];
std_sani   = [std_sani,   std(ROM_s,  'omitnan')]; std_T0   = [std_T0,   std(ROM_0,  'omitnan')]; std_T1   = [std_T1,   std(ROM_1,  'omitnan')];

% Circ indietro
Db_sani = readtable('Database Sani_Circ indietro.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Circ indietro.xlsx');
ROM_s = [Db_sani.ROMTroncoSagittale_Dx; Db_sani.ROMTroncoSagittale_Sx]; ROM_0 = Db_pato.ROMTroncoSagittale_T0; ROM_1 = Db_pato.ROMTroncoSagittale_T1;
media_sani = [media_sani, mean(ROM_s, 'omitnan')]; media_T0 = [media_T0, mean(ROM_0, 'omitnan')]; media_T1 = [media_T1, mean(ROM_1, 'omitnan')];
std_sani   = [std_sani,   std(ROM_s,  'omitnan')]; std_T0   = [std_T0,   std(ROM_0,  'omitnan')]; std_T1   = [std_T1,   std(ROM_1,  'omitnan')];

%% Significatività
nomi_task_label = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro'};
nomi_task       = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro'};
n_task = length(nomi_task); prefisso_file = 'AS_'; nome_indice = 'ROM Tronco Sagittale';

sig_SanivsT0 = zeros(1, n_task); sig_SanivsT1 = zeros(1, n_task); sig_T0vsT1 = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = nomi_task{tt};
    file_SanivsT0 = sprintf('%sSanivsT0nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT0(tt) = 1; end
    end
    file_SanivsT1 = sprintf('%sSanivsT1nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT1(tt) = 1; end
    end
    file_T0vsT1 = sprintf('%snonAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_T0vsT1(tt) = 1; end
    end
end

%% Grafico
dati_plot = [media_sani', media_T0', media_T1'];
std_plot  = [std_sani',   std_T0',   std_T1'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);
b = bar(dati_plot, 'grouped'); hold on;
b(1).FaceColor = [0.2, 0.6, 0.85]; b(2).FaceColor = [0.85, 0.3, 0.3]; b(3).FaceColor = [0.5, 0.2, 0.6];

nbars = size(dati_plot, 2); ngroups = size(dati_plot, 1); x_pos = zeros(ngroups, nbars);
for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

offset_base = 2; step_h = 4; h_tick = 0.8;
y_ponti_max = max(dati_plot(:) + std_plot(:));

for g = 1:ngroups
    y_base = max(dati_plot(g, :) + std_plot(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    if sig_SanivsT0(g) == 1
        level = level + 1; y_line = y_base + offset_base + (level-1)*step_h;
        plot([x_pos(g,1), x_pos(g,1), x_pos(g,2), x_pos(g,2)], [y_line - h_tick, y_line, y_line, y_line - h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,1) + x_pos(g,2))/2, y_line + 0.3, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        y_ponti_max = max(y_ponti_max, y_line + 2);
    end
    if sig_T0vsT1(g) == 1
        level = level + 1; y_line = y_base + offset_base + (level-1)*step_h;
        plot([x_pos(g,2), x_pos(g,2), x_pos(g,3), x_pos(g,3)], [y_line - h_tick, y_line, y_line, y_line - h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,2) + x_pos(g,3))/2, y_line + 0.3, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        y_ponti_max = max(y_ponti_max, y_line + 2);
    end
    if sig_SanivsT1(g) == 1
        level = level + 1; y_line = y_base + offset_base + (level-1)*step_h;
        plot([x_pos(g,1), x_pos(g,1), x_pos(g,3), x_pos(g,3)], [y_line - h_tick, y_line, y_line, y_line - h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,1) + x_pos(g,3))/2, y_line + 0.3, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        y_ponti_max = max(y_ponti_max, y_line + 2);
    end
end

set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25); ylabel('ROM [°]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento del ROM Tronco Sagittale ± SD, Lato non Affetto', 'FontSize', 14, 'FontWeight', 'bold');

ylim([0, 55]);

grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;

legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'northwest', 'FontSize', 11, 'FontWeight', 'bold');
hold off; exportgraphics(gcf, 'ROM_Tronco_Sagittale_nonAffetto.png', 'Resolution', 300);