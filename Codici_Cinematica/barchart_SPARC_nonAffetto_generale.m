clear
close all
clc

%% =========================================================================
%% 1. ESTRAZIONE DATI - ANDATA
%% =========================================================================

media_sani_A = []; media_T0_A = []; media_T1_A = [];
std_sani_A   = []; std_T0_A   = []; std_T1_A   = [];

% Addu
Db_sani = readtable('Database Sani_Addu.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Addu.xlsx');
idx_s = [Db_sani.SPARC_Andata_Dx; Db_sani.SPARC_Andata_Sx]; idx_0 = Db_pato.SPARC_Andata_T0; idx_1 = Db_pato.SPARC_Andata_T1;
media_sani_A = [media_sani_A, mean(idx_s, 'omitnan')]; media_T0_A = [media_T0_A, mean(idx_0, 'omitnan')]; media_T1_A = [media_T1_A, mean(idx_1, 'omitnan')];
std_sani_A   = [std_sani_A, std(idx_s, 'omitnan')];     std_T0_A   = [std_T0_A, std(idx_0, 'omitnan')];     std_T1_A   = [std_T1_A, std(idx_1, 'omitnan')];

% Addu orizz
Db_sani = readtable('Database Sani_Addu orizz.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Addu orizz.xlsx');
idx_s = [Db_sani.SPARC_Andata_Dx; Db_sani.SPARC_Andata_Sx]; idx_0 = Db_pato.SPARC_Andata_T0; idx_1 = Db_pato.SPARC_Andata_T1;
media_sani_A = [media_sani_A, mean(idx_s, 'omitnan')]; media_T0_A = [media_T0_A, mean(idx_0, 'omitnan')]; media_T1_A = [media_T1_A, mean(idx_1, 'omitnan')];
std_sani_A   = [std_sani_A, std(idx_s, 'omitnan')];     std_T0_A   = [std_T0_A, std(idx_0, 'omitnan')];     std_T1_A   = [std_T1_A, std(idx_1, 'omitnan')];

% Flex
Db_sani = readtable('Database Sani_Flex.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Flex.xlsx');
idx_s = [Db_sani.SPARC_Andata_Dx; Db_sani.SPARC_Andata_Sx]; idx_0 = Db_pato.SPARC_Andata_T0; idx_1 = Db_pato.SPARC_Andata_T1;
media_sani_A = [media_sani_A, mean(idx_s, 'omitnan')]; media_T0_A = [media_T0_A, mean(idx_0, 'omitnan')]; media_T1_A = [media_T1_A, mean(idx_1, 'omitnan')];
std_sani_A   = [std_sani_A, std(idx_s, 'omitnan')];     std_T0_A   = [std_T0_A, std(idx_0, 'omitnan')];     std_T1_A   = [std_T1_A, std(idx_1, 'omitnan')];

% Circ avanti
Db_sani = readtable('Database Sani_Circ avanti.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Circ avanti.xlsx');
idx_s = [Db_sani.SPARC_Andata_Dx; Db_sani.SPARC_Andata_Sx]; idx_0 = Db_pato.SPARC_Andata_T0; idx_1 = Db_pato.SPARC_Andata_T1;
media_sani_A = [media_sani_A, mean(idx_s, 'omitnan')]; media_T0_A = [media_T0_A, mean(idx_0, 'omitnan')]; media_T1_A = [media_T1_A, mean(idx_1, 'omitnan')];
std_sani_A   = [std_sani_A, std(idx_s, 'omitnan')];     std_T0_A   = [std_T0_A, std(idx_0, 'omitnan')];     std_T1_A   = [std_T1_A, std(idx_1, 'omitnan')];

% Circ indietro
Db_sani = readtable('Database Sani_Circ indietro.xlsx'); Db_pato = readtable('Database Patologici lato non affetto (T0 vs T1)_Circ indietro.xlsx');
idx_s = [Db_sani.SPARC_Andata_Dx; Db_sani.SPARC_Andata_Sx]; idx_0 = Db_pato.SPARC_Andata_T0; idx_1 = Db_pato.SPARC_Andata_T1;
media_sani_A = [media_sani_A, mean(idx_s, 'omitnan')]; media_T0_A = [media_T0_A, mean(idx_0, 'omitnan')]; media_T1_A = [media_T1_A, mean(idx_1, 'omitnan')];
std_sani_A   = [std_sani_A, std(idx_s, 'omitnan')];     std_T0_A   = [std_T0_A, std(idx_0, 'omitnan')];     std_T1_A   = [std_T1_A, std(idx_1, 'omitnan')];

%% Significatività Andata
nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro'};
n_task = length(nomi_task); prefisso_file = 'AS_'; nome_indice_A = 'SPARC_Andata';
sig_SanivsT0_A = zeros(1, n_task); sig_SanivsT1_A = zeros(1, n_task); sig_T0vsT1_A = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = nomi_task{tt};
    file_SanivsT0 = sprintf('%sSanivsT0nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0); idx = find(strcmpi(string(tab.Parametro), nome_indice_A));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT0_A(tt) = 1; end
    end
    file_SanivsT1 = sprintf('%sSanivsT1nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice_A));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT1_A(tt) = 1; end
    end
    file_T0vsT1 = sprintf('%snonAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice_A));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_T0vsT1_A(tt) = 1; end
    end
end

%% =========================================================================
%% 2. ESTRAZIONE DATI - RITORNO
%% =========================================================================

media_sani_R = []; media_T0_R = []; media_T1_R = [];
std_sani_R   = []; std_T0_R   = []; std_T1_R   = [];

% Addu
idx_s = [Db_sani.SPARC_Ritorno_Dx; Db_sani.SPARC_Ritorno_Sx]; idx_0 = Db_pato.SPARC_Ritorno_T0; idx_1 = Db_pato.SPARC_Ritorno_T1;
media_sani_R = [media_sani_R, mean(idx_s, 'omitnan')]; media_T0_R = [media_T0_R, mean(idx_0, 'omitnan')]; media_T1_R = [media_T1_R, mean(idx_1, 'omitnan')];
std_sani_R   = [std_sani_R, std(idx_s, 'omitnan')];     std_T0_R   = [std_T0_R, std(idx_0, 'omitnan')];     std_T1_R   = [std_T1_R, std(idx_1, 'omitnan')];

% Addu orizz
Db_sani_o = readtable('Database Sani_Addu orizz.xlsx'); Db_pato_o = readtable('Database Patologici lato non affetto (T0 vs T1)_Addu orizz.xlsx');
idx_s = [Db_sani_o.SPARC_Ritorno_Dx; Db_sani_o.SPARC_Ritorno_Sx]; idx_0 = Db_pato_o.SPARC_Ritorno_T0; idx_1 = Db_pato_o.SPARC_Ritorno_T1;
media_sani_R = [media_sani_R, mean(idx_s, 'omitnan')]; media_T0_R = [media_T0_R, mean(idx_0, 'omitnan')]; media_T1_R = [media_T1_R, mean(idx_1, 'omitnan')];
std_sani_R   = [std_sani_R, std(idx_s, 'omitnan')];     std_T0_R   = [std_T0_R, std(idx_0, 'omitnan')];     std_T1_R   = [std_T1_R, std(idx_1, 'omitnan')];

% Flex
Db_sani_f = readtable('Database Sani_Flex.xlsx'); Db_pato_f = readtable('Database Patologici lato non affetto (T0 vs T1)_Flex.xlsx');
idx_s = [Db_sani_f.SPARC_Ritorno_Dx; Db_sani_f.SPARC_Ritorno_Sx]; idx_0 = Db_pato_f.SPARC_Ritorno_T0; idx_1 = Db_pato_f.SPARC_Ritorno_T1;
media_sani_R = [media_sani_R, mean(idx_s, 'omitnan')]; media_T0_R = [media_T0_R, mean(idx_0, 'omitnan')]; media_T1_R = [media_T1_R, mean(idx_1, 'omitnan')];
std_sani_R   = [std_sani_R, std(idx_s, 'omitnan')];     std_T0_R   = [std_T0_R, std(idx_0, 'omitnan')];     std_T1_R   = [std_T1_R, std(idx_1, 'omitnan')];

% Circ avanti
Db_sani_ca = readtable('Database Sani_Circ avanti.xlsx'); Db_pato_ca = readtable('Database Patologici lato non affetto (T0 vs T1)_Circ avanti.xlsx');
idx_s = [Db_sani_ca.SPARC_Ritorno_Dx; Db_sani_ca.SPARC_Ritorno_Sx]; idx_0 = Db_pato_ca.SPARC_Ritorno_T0; idx_1 = Db_pato_ca.SPARC_Ritorno_T1;
media_sani_R = [media_sani_R, mean(idx_s, 'omitnan')]; media_T0_R = [media_T0_R, mean(idx_0, 'omitnan')]; media_T1_R = [media_T1_R, mean(idx_1, 'omitnan')];
std_sani_R   = [std_sani_R, std(idx_s, 'omitnan')];     std_T0_R   = [std_T0_R, std(idx_0, 'omitnan')];     std_T1_R   = [std_T1_R, std(idx_1, 'omitnan')];

% Circ indietro
Db_sani_ci = readtable('Database Sani_Circ indietro.xlsx'); Db_pato_ci = readtable('Database Patologici lato non affetto (T0 vs T1)_Circ indietro.xlsx');
idx_s = [Db_sani_ci.SPARC_Ritorno_Dx; Db_sani_ci.SPARC_Ritorno_Sx]; idx_0 = Db_pato_ci.SPARC_Ritorno_T0; idx_1 = Db_pato_ci.SPARC_Ritorno_T1;
media_sani_R = [media_sani_R, mean(idx_s, 'omitnan')]; media_T0_R = [media_T0_R, mean(idx_0, 'omitnan')]; media_T1_R = [media_T1_R, mean(idx_1, 'omitnan')];
std_sani_R   = [std_sani_R, std(idx_s, 'omitnan')];     std_T0_R   = [std_T0_R, std(idx_0, 'omitnan')];     std_T1_R   = [std_T1_R, std(idx_1, 'omitnan')];

%% Significatività Ritorno
nome_indice_R = 'SPARC_Ritorno';
sig_SanivsT0_R = zeros(1, n_task); sig_SanivsT1_R = zeros(1, n_task); sig_T0vsT1_R = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = nomi_task{tt};
    file_SanivsT0 = sprintf('%sSanivsT0nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0); idx = find(strcmpi(string(tab.Parametro), nome_indice_R));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT0_R(tt) = 1; end
    end
    file_SanivsT1 = sprintf('%sSanivsT1nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice_R));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT1_R(tt) = 1; end
    end
    file_T0vsT1 = sprintf('%snonAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice_R));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_T0vsT1_R(tt) = 1; end
    end
end

%% =========================================================================
%% 3. CALCOLO SCALA VERTICALE UNIFORME PER ENTRAMBI I GRAFICI
%% =========================================================================

dati_A = [media_sani_A', media_T0_A', media_T1_A']; std_A = [std_sani_A', std_T0_A', std_T1_A'];
dati_R = [media_sani_R', media_T0_R', media_T1_R']; std_R = [std_sani_R', std_T0_R', std_T1_R'];

min_val = min([dati_A(:) - std_A(:); dati_R(:) - std_R(:)], [], 'omitnan');
if isnan(min_val) || min_val >= 0, min_val = -10; end

y_lim_min_globale = floor(min_val - 4.5);
yticks_comuni = y_lim_min_globale:1:0;
nomi_task_label = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro'};

%% =========================================================================
%% 4. GRAFICO ANDATA
%% =========================================================================

figure('Color', [1 1 1], 'Position', [100 100 950 550]);
b = bar(dati_A, 'grouped'); hold on;
b(1).FaceColor = [0.2, 0.6, 0.85]; b(2).FaceColor = [0.85, 0.3, 0.3]; b(3).FaceColor = [0.5, 0.2, 0.6];

nbars = size(dati_A, 2); ngroups = size(dati_A, 1); x_pos = zeros(ngroups, nbars);
for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_A(:, i), std_A(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

offset_base = 0.6; step_h = 0.9; h_tick = 0.3;
for g = 1:ngroups
    y_base = min(dati_A(g, :) - std_A(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    if sig_SanivsT0_A(g) == 1
        level = level + 1; y_line = y_base - offset_base - (level-1)*step_h;
        plot([x_pos(g,1), x_pos(g,1), x_pos(g,2), x_pos(g,2)], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,1) + x_pos(g,2))/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
    if sig_T0vsT1_A(g) == 1
        level = level + 1; y_line = y_base - offset_base - (level-1)*step_h;
        plot([x_pos(g,2), x_pos(g,2), x_pos(g,3), x_pos(g,3)], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,2) + x_pos(g,3))/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
    if sig_SanivsT1_A(g) == 1
        level = level + 1; y_line = y_base - offset_base - (level-1)*step_h;
        plot([x_pos(g,1), x_pos(g,1), x_pos(g,3), x_pos(g,3)], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,1) + x_pos(g,3))/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
end

set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25); ylabel('SPARC', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento dello SPARC Andata ± SD, Lato non Affetto', 'FontSize', 14, 'FontWeight', 'bold');
ylim([-3, 0.5]); yticks(yticks_comuni);
grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;
legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'southwest', 'FontSize', 11, 'FontWeight', 'bold');
hold off; exportgraphics(gcf, 'SPARC_Andata_nonAffetto.png', 'Resolution', 300);

%% =========================================================================
%% 5. GRAFICO RITORNO
%% =========================================================================

figure('Color', [1 1 1], 'Position', [100 100 950 550]);
b = bar(dati_R, 'grouped'); hold on;
b(1).FaceColor = [0.2, 0.6, 0.85]; b(2).FaceColor = [0.85, 0.3, 0.3]; b(3).FaceColor = [0.5, 0.2, 0.6];

for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_R(:, i), std_R(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

for g = 1:ngroups
    y_base = min(dati_R(g, :) - std_R(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    if sig_SanivsT0_R(g) == 1
        level = level + 1; y_line = y_base - offset_base - (level-1)*step_h;
        plot([x_pos(g,1), x_pos(g,1), x_pos(g,2), x_pos(g,2)], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,1) + x_pos(g,2))/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
    if sig_T0vsT1_R(g) == 1
        level = level + 1; y_line = y_base - offset_base - (level-1)*step_h;
        plot([x_pos(g,2), x_pos(g,2), x_pos(g,3), x_pos(g,3)], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,2) + x_pos(g,3))/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
    if sig_SanivsT1_R(g) == 1
        level = level + 1; y_line = y_base - offset_base - (level-1)*step_h;
        plot([x_pos(g,1), x_pos(g,1), x_pos(g,3), x_pos(g,3)], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x_pos(g,1) + x_pos(g,3))/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    end
end

set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25); ylabel('SPARC', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento dello SPARC Ritorno ± SD, Lato non Affetto', 'FontSize', 14, 'FontWeight', 'bold');
ylim([-3, 0.5]); yticks(yticks_comuni);
grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;
legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'southwest', 'FontSize', 11, 'FontWeight', 'bold');
hold off; exportgraphics(gcf, 'SPARC_Ritorno_nonAffetto.png', 'Resolution', 300);