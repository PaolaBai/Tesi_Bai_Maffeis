clear
close all
clc

%% =========================================================================
%% 1. ANDATA - REACH & GRASP
%% =========================================================================

media_sani = []; media_T0 = []; media_T1 = [];
std_sani   = []; std_T0   = []; std_T1   = [];

%% Reach acc
Db_sani_Reach = readtable('Database Sani vs Patologici T0_Reach.xlsx');
Db_patologici_Reach = readtable('Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

indice_sani = Db_sani_Reach.LDLJ_Acc_Andata(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.LDLJ_Acc_Andata_T0;
indice_T1   = Db_patologici_Reach.LDLJ_Acc_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Reach dec
indice_sani = Db_sani_Reach.LDLJ_Dec_Andata(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.LDLJ_Dec_Andata_T0;
indice_T1   = Db_patologici_Reach.LDLJ_Dec_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Grasp acc
Db_sani_Grasp = readtable('Database Sani vs Patologici T0_Grasp.xlsx');
Db_patologici_Grasp = readtable('Database Patologici lato affetto (T0 vs T1)_Grasp.xlsx');

indice_sani = Db_sani_Grasp.LDLJ_Acc_Andata(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.LDLJ_Acc_Andata_T0;
indice_T1   = Db_patologici_Grasp.LDLJ_Acc_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Grasp dec
indice_sani = Db_sani_Grasp.LDLJ_Dec_Andata(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.LDLJ_Dec_Andata_T0;
indice_T1   = Db_patologici_Grasp.LDLJ_Dec_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Significatività (Andata)
nomi_task_label  = {'Reach Acc', 'Reach Dec', 'Grasp Acc', 'Grasp Dec'};
task_file_suffix = {'Reach', 'Reach', 'Grasp', 'Grasp'}; 
indici_parametro = {'LDLJ_Acc_Andata', 'LDLJ_Dec_Andata', 'LDLJ_Acc_Andata', 'LDLJ_Dec_Andata'}; 

n_task = length(nomi_task_label);
prefisso_file = 'AS_';

sig_SanivsT0 = zeros(1, n_task);
sig_SanivsT1 = zeros(1, n_task);
sig_T0vsT1   = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = task_file_suffix{tt};
    nome_indice   = indici_parametro{tt};
    
    file_SanivsT0 = sprintf('%sSanivsT0Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_SanivsT0(tt) = 1;
        end
    end
    
    file_SanivsT1 = sprintf('%sSanivsT1Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_SanivsT1(tt) = 1;
        end
    end
    
    file_T0vsT1 = sprintf('%sAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_T0vsT1(tt) = 1;
        end
    end
end

%% Grafico Andata
dati_plot = [media_sani', media_T0', media_T1'];
std_plot  = [std_sani',   std_T0',   std_T1'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);

b = bar(dati_plot, 'grouped'); hold on;
b(1).FaceColor = [0.2, 0.6, 0.85]; % Azzurro Sani
b(2).FaceColor = [0.85, 0.3, 0.3];  % Rosso T0
b(3).FaceColor = [0.5, 0.2, 0.6];   % Viola T1

nbars = size(dati_plot, 2);
ngroups = size(dati_plot, 1);
x_pos = zeros(ngroups, nbars);

for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

offset_base = 0.6;  
step_h      = 0.9;  
h_tick      = 0.3;  
y_min_raggiunto = 0; 

for g = 1:ngroups
    y_base = min(dati_plot(g, :) - std_plot(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    
    if sig_SanivsT0(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 1); x2 = x_pos(g, 2);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
    if sig_T0vsT1(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 2); x2 = x_pos(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
    if sig_SanivsT1(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 1); x2 = x_pos(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
end

set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25);
ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento del LDLJ Andata ± SD, Reach and Grasp', 'FontSize', 14, 'FontWeight', 'bold');

y_lim_min = floor(y_min_raggiunto - 2.0); 
ylim([-14, 0.5]);
yticks(y_lim_min:1:0);

grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;

lgd = legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'southwest', 'Orientation', 'vertical', 'FontSize', 11, 'FontWeight', 'bold');
hold off;
exportgraphics(gcf, 'LDLJ_Andata_RandG.png', 'Resolution', 300);


%% =========================================================================
%% 2. RITORNO - REACH & GRASP
%% =========================================================================

media_sani = []; media_T0 = []; media_T1 = [];
std_sani   = []; std_T0   = []; std_T1   = [];

%% Reach acc
indice_sani = Db_sani_Reach.LDLJ_Acc_Ritorno(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.LDLJ_Acc_Ritorno_T0;
indice_T1   = Db_patologici_Reach.LDLJ_Acc_Ritorno_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Reach dec
indice_sani = Db_sani_Reach.LDLJ_Dec_Ritorno(string(Db_sani_Reach.Gruppo) == "Sano");
indice_T0   = Db_patologici_Reach.LDLJ_Dec_Ritorno_T0;
indice_T1   = Db_patologici_Reach.LDLJ_Dec_Ritorno_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Grasp acc
indice_sani = Db_sani_Grasp.LDLJ_Acc_Ritorno(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.LDLJ_Acc_Ritorno_T0;
indice_T1   = Db_patologici_Grasp.LDLJ_Acc_Ritorno_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Grasp dec
indice_sani = Db_sani_Grasp.LDLJ_Dec_Ritorno(string(Db_sani_Grasp.Gruppo) == "Sano");
indice_T0   = Db_patologici_Grasp.LDLJ_Dec_Ritorno_T0;
indice_T1   = Db_patologici_Grasp.LDLJ_Dec_Ritorno_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Significatività (Ritorno)
indici_parametro = {'LDLJ_Acc_Ritorno', 'LDLJ_Dec_Ritorno', 'LDLJ_Acc_Ritorno', 'LDLJ_Dec_Ritorno'};

sig_SanivsT0 = zeros(1, n_task);
sig_SanivsT1 = zeros(1, n_task);
sig_T0vsT1   = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = task_file_suffix{tt};
    nome_indice   = indici_parametro{tt};
    
    file_SanivsT0 = sprintf('%sSanivsT0Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_SanivsT0(tt) = 1;
        end
    end
    
    file_SanivsT1 = sprintf('%sSanivsT1Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_SanivsT1(tt) = 1;
        end
    end
    
    file_T0vsT1 = sprintf('%sAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_T0vsT1(tt) = 1;
        end
    end
end

%% Grafico Ritorno
dati_plot = [media_sani', media_T0', media_T1'];
std_plot  = [std_sani',   std_T0',   std_T1'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);

b = bar(dati_plot, 'grouped'); hold on;
b(1).FaceColor = [0.2, 0.6, 0.85]; % Azzurro Sani
b(2).FaceColor = [0.85, 0.3, 0.3];  % Rosso T0
b(3).FaceColor = [0.5, 0.2, 0.6];   % Viola T1

nbars = size(dati_plot, 2);
ngroups = size(dati_plot, 1);
x_pos = zeros(ngroups, nbars);

for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

y_min_raggiunto = 0; 

for g = 1:ngroups
    y_base = min(dati_plot(g, :) - std_plot(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    
    if sig_SanivsT0(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 1); x2 = x_pos(g, 2);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
    if sig_T0vsT1(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 2); x2 = x_pos(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
    if sig_SanivsT1(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 1); x2 = x_pos(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
end

set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25);
ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento del LDLJ Ritorno ± SD, Reach and Grasp', 'FontSize', 14, 'FontWeight', 'bold');

y_lim_min = floor(y_min_raggiunto - 2.0); 
ylim([-14, 0.5]);
yticks(y_lim_min:1:0);

grid on; set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca; ax.GridColor = [0.15 0.15 0.15]; ax.GridAlpha = 0.3; ax.MinorGridColor = [0.2 0.2 0.2]; ax.MinorGridAlpha = 0.2;

lgd = legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'southwest', 'Orientation', 'vertical', 'FontSize', 11, 'FontWeight', 'bold');
hold off;
exportgraphics(gcf, 'LDLJ_Ritorno_RandG.png', 'Resolution', 300);