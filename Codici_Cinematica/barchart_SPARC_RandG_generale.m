clear
close all
clc

%% =========================================================================
%% 1. ESTRAZIONE DATI - ANDATA
%% =========================================================================

media_sani_A = []; media_T0_A = []; media_T1_A = [];
std_sani_A   = []; std_T0_A   = []; std_T1_A   = [];

Db_sani_Reach = readtable('Database Sani vs Patologici T0_Reach.xlsx');
Db_patologici_Reach = readtable('Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

% Reach acc
indice_sani = Db_sani_Reach.SPARC_Acc_Andata(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.SPARC_Acc_Andata_T0;
indice_T1   = Db_patologici_Reach.SPARC_Acc_Andata_T1;
media_sani_A = [media_sani_A, mean(indice_sani, 'omitnan')]; media_T0_A = [media_T0_A, mean(indice_T0, 'omitnan')]; media_T1_A = [media_T1_A, mean(indice_T1, 'omitnan')];
std_sani_A   = [std_sani_A, std(indice_sani, 'omitnan')];     std_T0_A   = [std_T0_A, std(indice_T0, 'omitnan')];     std_T1_A   = [std_T1_A, std(indice_T1, 'omitnan')];

% Reach dec
indice_sani = Db_sani_Reach.SPARC_Dec_Andata(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.SPARC_Dec_Andata_T0;
indice_T1   = Db_patologici_Reach.SPARC_Dec_Andata_T1;
media_sani_A = [media_sani_A, mean(indice_sani, 'omitnan')]; media_T0_A = [media_T0_A, mean(indice_T0, 'omitnan')]; media_T1_A = [media_T1_A, mean(indice_T1, 'omitnan')];
std_sani_A   = [std_sani_A, std(indice_sani, 'omitnan')];     std_T0_A   = [std_T0_A, std(indice_T0, 'omitnan')];     std_T1_A   = [std_T1_A, std(indice_T1, 'omitnan')];

Db_sani_Grasp = readtable('Database Sani vs Patologici T0_Grasp.xlsx');
Db_patologici_Grasp = readtable('Database Patologici lato affetto (T0 vs T1)_Grasp.xlsx');

% Grasp acc
indice_sani = Db_sani_Grasp.SPARC_Acc_Andata(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.SPARC_Acc_Andata_T0;
indice_T1   = Db_patologici_Grasp.SPARC_Acc_Andata_T1;
media_sani_A = [media_sani_A, mean(indice_sani, 'omitnan')]; media_T0_A = [media_T0_A, mean(indice_T0, 'omitnan')]; media_T1_A = [media_T1_A, mean(indice_T1, 'omitnan')];
std_sani_A   = [std_sani_A, std(indice_sani, 'omitnan')];     std_T0_A   = [std_T0_A, std(indice_T0, 'omitnan')];     std_T1_A   = [std_T1_A, std(indice_T1, 'omitnan')];

% Grasp dec
indice_sani = Db_sani_Grasp.SPARC_Dec_Andata(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.SPARC_Dec_Andata_T0;
indice_T1   = Db_patologici_Grasp.SPARC_Dec_Andata_T1;
media_sani_A = [media_sani_A, mean(indice_sani, 'omitnan')]; media_T0_A = [media_T0_A, mean(indice_T0, 'omitnan')]; media_T1_A = [media_T1_A, mean(indice_T1, 'omitnan')];
std_sani_A   = [std_sani_A, std(indice_sani, 'omitnan')];     std_T0_A   = [std_T0_A, std(indice_T0, 'omitnan')];     std_T1_A   = [std_T1_A, std(indice_T1, 'omitnan')];

%% Significatività Andata
nomi_task_label  = {'Reach Acc', 'Reach Dec', 'Grasp Acc', 'Grasp Dec'};
task_file_suffix = {'Reach', 'Reach', 'Grasp', 'Grasp'}; 
indici_parametro_A = {'SPARC_Acc_Andata', 'SPARC_Dec_Andata', 'SPARC_Acc_Andata', 'SPARC_Dec_Andata'}; 

n_task = length(nomi_task_label);
prefisso_file = 'AS_';

sig_SanivsT0_A = zeros(1, n_task); sig_SanivsT1_A = zeros(1, n_task); sig_T0vsT1_A = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = task_file_suffix{tt};
    nome_indice   = indici_parametro_A{tt};
    
    file_SanivsT0 = sprintf('%sSanivsT0Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT0_A(tt) = 1; end
    end
    file_SanivsT1 = sprintf('%sSanivsT1Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT1_A(tt) = 1; end
    end
    file_T0vsT1 = sprintf('%sAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_T0vsT1_A(tt) = 1; end
    end
end

%% =========================================================================
%% 2. ESTRAZIONE DATI - RITORNO
%% =========================================================================

media_sani_R = []; media_T0_R = []; media_T1_R = [];
std_sani_R   = []; std_T0_R   = []; std_T1_R   = [];

% Reach acc
indice_sani = Db_sani_Reach.SPARC_Acc_Ritorno(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.SPARC_Acc_Ritorno_T0;
indice_T1   = Db_patologici_Reach.SPARC_Acc_Ritorno_T1;
media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')]; media_T0_R = [media_T0_R, mean(indice_T0, 'omitnan')]; media_T1_R = [media_T1_R, mean(indice_T1, 'omitnan')];
std_sani_R   = [std_sani_R, std(indice_sani, 'omitnan')];     std_T0_R   = [std_T0_R, std(indice_T0, 'omitnan')];     std_T1_R   = [std_T1_R, std(indice_T1, 'omitnan')];

% Reach dec
indice_sani = Db_sani_Reach.SPARC_Dec_Ritorno(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.SPARC_Dec_Ritorno_T0;
indice_T1   = Db_patologici_Reach.SPARC_Dec_Ritorno_T1;
media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')]; media_T0_R = [media_T0_R, mean(indice_T0, 'omitnan')]; media_T1_R = [media_T1_R, mean(indice_T1, 'omitnan')];
std_sani_R   = [std_sani_R, std(indice_sani, 'omitnan')];     std_T0_R   = [std_T0_R, std(indice_T0, 'omitnan')];     std_T1_R   = [std_T1_R, std(indice_T1, 'omitnan')];

% Grasp acc
indice_sani = Db_sani_Grasp.SPARC_Acc_Ritorno(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.SPARC_Acc_Ritorno_T0;
indice_T1   = Db_patologici_Grasp.SPARC_Acc_Ritorno_T1;
media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')]; media_T0_R = [media_T0_R, mean(indice_T0, 'omitnan')]; media_T1_R = [media_T1_R, mean(indice_T1, 'omitnan')];
std_sani_R   = [std_sani_R, std(indice_sani, 'omitnan')];     std_T0_R   = [std_T0_R, std(indice_T0, 'omitnan')];     std_T1_R   = [std_T1_R, std(indice_T1, 'omitnan')];

% Grasp dec
indice_sani = Db_sani_Grasp.SPARC_Dec_Ritorno(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.SPARC_Dec_Ritorno_T0;
indice_T1   = Db_patologici_Grasp.SPARC_Dec_Ritorno_T1;
media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')]; media_T0_R = [media_T0_R, mean(indice_T0, 'omitnan')]; media_T1_R = [media_T1_R, mean(indice_T1, 'omitnan')];
std_sani_R   = [std_sani_R, std(indice_sani, 'omitnan')];     std_T0_R   = [std_T0_R, std(indice_T0, 'omitnan')];     std_T1_R   = [std_T1_R, std(indice_T1, 'omitnan')];

%% Significatività Ritorno
indici_parametro_R = {'SPARC_Acc_Ritorno', 'SPARC_Dec_Ritorno', 'SPARC_Acc_Ritorno', 'SPARC_Dec_Ritorno'};
sig_SanivsT0_R = zeros(1, n_task); sig_SanivsT1_R = zeros(1, n_task); sig_T0vsT1_R = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = task_file_suffix{tt};
    nome_indice   = indici_parametro_R{tt};
    
    file_SanivsT0 = sprintf('%sSanivsT0Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT0_R(tt) = 1; end
    end
    file_SanivsT1 = sprintf('%sSanivsT1Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice));
        if ~isempty(idx) && contains(string(tab{idx(1), 2}), '*'), sig_SanivsT1_R(tt) = 1; end
    end
    file_T0vsT1 = sprintf('%sAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1); idx = find(strcmpi(string(tab.Parametro), nome_indice));
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

y_lim_min_globale = floor(min_val - 4.5); % Margine comune per ponti e legenda
yticks_comuni = y_lim_min_globale:1:0;

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

offset_base = 0.4; step_h = 0.4; h_tick = 0.1;
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
title('Andamento dello SPARC Andata ± SD, Reach and Grasp', 'FontSize', 14, 'FontWeight', 'bold');
ylim([-3.5, 0.5]); yticks(yticks_comuni);
grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;
legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'southwest', 'FontSize', 11, 'FontWeight', 'bold');
hold off; exportgraphics(gcf, 'SPARC_Andata_RandG.png', 'Resolution', 300);

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
title('Andamento dello SPARC Ritorno ± SD, Reach and Grasp', 'FontSize', 14, 'FontWeight', 'bold');
ylim([-3.5, 0.5]); yticks(yticks_comuni);
grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;
legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'southwest', 'FontSize', 11, 'FontWeight', 'bold');
hold off; exportgraphics(gcf, 'SPARC_Ritorno_RandG.png', 'Resolution', 300);