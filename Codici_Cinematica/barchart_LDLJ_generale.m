clear
close all
clc

%% ANDATA

media_sani = [];
media_T0   = [];
media_T1   = [];
std_sani   = [];
std_T0     = [];
std_T1     = [];

%% Addu
Db_sani_Addu = readtable('Database Sani_Addu.xlsx');
Db_patologici_Addu = readtable('Database Patologici lato affetto (T0 vs T1)_Addu.xlsx');

indice_sani = [Db_sani_Addu.LDLJ_Andata_Dx; Db_sani_Addu.LDLJ_Andata_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Addu.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Addu.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Addu_orizz
Db_sani_Addu_orizz = readtable('Database Sani_Addu orizz.xlsx');
Db_patologici_Addu_orizz = readtable('Database Patologici lato affetto (T0 vs T1)_Addu orizz.xlsx');

indice_sani = [Db_sani_Addu_orizz.LDLJ_Andata_Dx; Db_sani_Addu_orizz.LDLJ_Andata_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Addu_orizz.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Addu_orizz.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Flex
Db_sani_Flex = readtable('Database Sani_Flex.xlsx');
Db_patologici_Flex = readtable('Database Patologici lato affetto (T0 vs T1)_Flex.xlsx');

indice_sani = [Db_sani_Flex.LDLJ_Andata_Dx; Db_sani_Flex.LDLJ_Andata_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Flex.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Flex.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Circ avanti
Db_sani_Circ_avanti = readtable('Database Sani_Circ avanti.xlsx');
Db_patologici_Circ_avanti = readtable('Database Patologici lato affetto (T0 vs T1)_Circ avanti.xlsx');

indice_sani = [Db_sani_Circ_avanti.LDLJ_Andata_Dx; Db_sani_Circ_avanti.LDLJ_Andata_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Circ_avanti.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Circ_avanti.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Circ indietro
Db_sani_Circ_indietro = readtable('Database Sani_Circ indietro.xlsx');
Db_patologici_Circ_indietro = readtable('Database Patologici lato affetto (T0 vs T1)_Circ indietro.xlsx');

indice_sani = [Db_sani_Circ_indietro.LDLJ_Andata_Dx; Db_sani_Circ_indietro.LDLJ_Andata_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Circ_indietro.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Circ_indietro.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Reach
Db_sani_Reach = readtable('Database Sani vs Patologici T0_Reach.xlsx');
Db_patologici_Reach = readtable('Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

indice_sani = Db_sani_Reach.LDLJ_Andata(string(Db_sani_Reach.Gruppo) == "Sano");      % sani dx + sx
indice_T0   = Db_patologici_Reach.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Reach.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% Grasp
Db_sani_Grasp = readtable('Database Sani vs Patologici T0_Grasp.xlsx');
Db_patologici_Grasp = readtable('Database Patologici lato affetto (T0 vs T1)_Grasp.xlsx');

indice_sani = Db_sani_Grasp.LDLJ_Andata(string(Db_sani_Grasp.Gruppo) == "Sano");      % sani dx + sx
indice_T0   = Db_patologici_Grasp.LDLJ_Andata_T0;
indice_T1   = Db_patologici_Grasp.LDLJ_Andata_T1;

media_sani = [media_sani, mean(indice_sani, 'omitnan')];
media_T0   = [media_T0,   mean(indice_T0,   'omitnan')];
media_T1   = [media_T1,   mean(indice_T1,   'omitnan')];
std_sani   = [std_sani,   std(indice_sani,  'omitnan')];
std_T0     = [std_T0,     std(indice_T0,    'omitnan')];
std_T1     = [std_T1,     std(indice_T1,    'omitnan')];

%% significatività
nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro', 'Reach', 'Grasp'};
n_task = length(nomi_task);

prefisso_file = 'AS_';
nome_indice = 'LDLJ_Andata';

sig_SanivsT0 = zeros(1, n_task);
sig_SanivsT1 = zeros(1, n_task);
sig_T0vsT1   = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = nomi_task{tt};

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

%% grafico

nomi_task_label = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro', 'Reach', 'Grasp'};
dati_plot = [media_sani', media_T0', media_T1'];
std_plot  = [std_sani',   std_T0',   std_T1'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);

% 1. Disegno delle Barre Affiancate (3 Barre)
b = bar(dati_plot, 'grouped');
hold on;
b(1).FaceColor = [0.2, 0.6, 0.85]; % Azzurro Sani
b(2).FaceColor = [0.85, 0.3, 0.3];  % Rosso T0
b(3).FaceColor = [0.5, 0.2, 0.6];   % Viola T1

% 2. Calcolo Coordinate X e Inserimento Barre d'Errore
nbars = size(dati_plot, 2);
ngroups = size(dati_plot, 1);
x_pos = zeros(ngroups, nbars);

for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

% 3. TRACCIAMENTO PONTI DI SIGNIFICATIVITÀ COMPATTI SOTTO LE BARRE
offset_base = 0.6;  % Distanza iniziale tra la barra d'errore più bassa e il primo ponte
step_h      = 0.9;  % Distanza tra i ponti sovrapposti
h_tick      = 0.3;  % Altezza delle stanghette verticali del ponte (rivolte verso l'alto rispetto alla riga)

y_min_raggiunto = 0; 

for g = 1:ngroups
    y_base = min(dati_plot(g, :) - std_plot(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    
    % Sani vs T0 (Barra 1 vs Barra 2)
    if sig_SanivsT0(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 1); x2 = x_pos(g, 2);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
    
    % T0 vs T1 (Barra 2 vs Barra 3)
    if sig_T0vsT1(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 2); x2 = x_pos(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
    
    % Sani vs T1 (Barra 1 vs Barra 3)
    if sig_SanivsT1(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos(g, 1); x2 = x_pos(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto = min(y_min_raggiunto, y_line - 0.8);
    end
end

% 4. Formattazione Assi, Titoli e Griglia Orizzontale Fitta
set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25);
ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento del LDLJ Andata ± SD', 'FontSize', 14, 'FontWeight', 'bold');

% Diamo un po' più di margine in basso per la legenda ed i ponti
y_lim_min = floor(y_min_raggiunto - 2.0); 
ylim([y_lim_min, 0.5]);
yticks(y_lim_min:1:0);

% Griglia principale + griglia secondaria SOLO orizzontale
grid on;
set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca;
ax.GridColor = [0.15 0.15 0.15];
ax.GridAlpha = 0.3;
ax.MinorGridColor = [0.2 0.2 0.2];
ax.MinorGridAlpha = 0.2;

% 5. Legenda in basso a sinistra (con margine extra che evita sovrapposizioni)
lgd = legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, ...
    'Location', 'southwest', ...
    'Orientation', 'vertical', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');

hold off;

exportgraphics(gcf, 'LDLJ_Andata.png', 'Resolution', 300);

%% =========================================================================
%% RITORNO
%% =========================================================================

media_sani_R = [];
media_T0_R   = [];
media_T1_R   = [];
std_sani_R   = [];
std_T0_R     = [];
std_T1_R     = [];

%% Addu
Db_sani_Addu = readtable('Database Sani_Addu.xlsx');
Db_patologici_Addu = readtable('Database Patologici lato affetto (T0 vs T1)_Addu.xlsx');

indice_sani = [Db_sani_Addu.LDLJ_Ritorno_Dx; Db_sani_Addu.LDLJ_Ritorno_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Addu.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Addu.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% Addu_orizz
Db_sani_Addu_orizz = readtable('Database Sani_Addu orizz.xlsx');
Db_patologici_Addu_orizz = readtable('Database Patologici lato affetto (T0 vs T1)_Addu orizz.xlsx');

indice_sani = [Db_sani_Addu_orizz.LDLJ_Ritorno_Dx; Db_sani_Addu_orizz.LDLJ_Ritorno_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Addu_orizz.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Addu_orizz.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% Flex
Db_sani_Flex = readtable('Database Sani_Flex.xlsx');
Db_patologici_Flex = readtable('Database Patologici lato affetto (T0 vs T1)_Flex.xlsx');

indice_sani = [Db_sani_Flex.LDLJ_Ritorno_Dx; Db_sani_Flex.LDLJ_Ritorno_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Flex.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Flex.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% Circ avanti
Db_sani_Circ_avanti = readtable('Database Sani_Circ avanti.xlsx');
Db_patologici_Circ_avanti = readtable('Database Patologici lato affetto (T0 vs T1)_Circ avanti.xlsx');

indice_sani = [Db_sani_Circ_avanti.LDLJ_Ritorno_Dx; Db_sani_Circ_avanti.LDLJ_Ritorno_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Circ_avanti.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Circ_avanti.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% Circ indietro
Db_sani_Circ_indietro = readtable('Database Sani_Circ indietro.xlsx');
Db_patologici_Circ_indietro = readtable('Database Patologici lato affetto (T0 vs T1)_Circ indietro.xlsx');

indice_sani = [Db_sani_Circ_indietro.LDLJ_Ritorno_Dx; Db_sani_Circ_indietro.LDLJ_Ritorno_Sx];      % sani dx + sx
indice_T0   = Db_patologici_Circ_indietro.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Circ_indietro.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% Reach
Db_sani_Reach = readtable('Database Sani vs Patologici T0_Reach.xlsx');
Db_patologici_Reach = readtable('Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

indice_sani = Db_sani_Reach.LDLJ_Ritorno(string(Db_sani_Reach.Gruppo) == "Sano");      % sani dx + sx
indice_T0   = Db_patologici_Reach.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Reach.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% Grasp
Db_sani_Grasp = readtable('Database Sani vs Patologici T0_Grasp.xlsx');
Db_patologici_Grasp = readtable('Database Patologici lato affetto (T0 vs T1)_Grasp.xlsx');

indice_sani = Db_sani_Grasp.LDLJ_Ritorno(string(Db_sani_Grasp.Gruppo) == "Sano");      % sani dx + sx
indice_T0   = Db_patologici_Grasp.LDLJ_Ritorno_T0;
indice_T1   = Db_patologici_Grasp.LDLJ_Ritorno_T1;

media_sani_R = [media_sani_R, mean(indice_sani, 'omitnan')];
media_T0_R   = [media_T0_R,   mean(indice_T0,   'omitnan')];
media_T1_R   = [media_T1_R,   mean(indice_T1,   'omitnan')];
std_sani_R   = [std_sani_R,   std(indice_sani,  'omitnan')];
std_T0_R     = [std_T0_R,     std(indice_T0,    'omitnan')];
std_T1_R     = [std_T1_R,     std(indice_T1,    'omitnan')];

%% significatività Ritorno
nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro', 'Reach', 'Grasp'};
n_task = length(nomi_task);

prefisso_file = 'AS_';
nome_indice_R = 'LDLJ_Ritorno';

sig_SanivsT0_R = zeros(1, n_task);
sig_SanivsT1_R = zeros(1, n_task);
sig_T0vsT1_R   = zeros(1, n_task);

for tt = 1:n_task
    suffisso_file = nomi_task{tt};

    file_SanivsT0 = sprintf('%sSanivsT0Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT0, 'file')
        tab = readtable(file_SanivsT0);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice_R));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_SanivsT0_R(tt) = 1;
        end
    end

    file_SanivsT1 = sprintf('%sSanivsT1Affetto_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_SanivsT1, 'file')
        tab = readtable(file_SanivsT1);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice_R));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_SanivsT1_R(tt) = 1;
        end
    end

    file_T0vsT1 = sprintf('%sAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
    if exist(file_T0vsT1, 'file')
        tab = readtable(file_T0vsT1);
        parametro = string(tab.Parametro);
        asterisco = string(tab{:, 2});
        idx = find(strcmpi(parametro, nome_indice_R));
        if ~isempty(idx) && contains(asterisco(idx(1)), '*')
            sig_T0vsT1_R(tt) = 1;
        end
    end
end

%% grafico Ritorno

nomi_task_label = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro', 'Reach', 'Grasp'};
dati_plot_R = [media_sani_R', media_T0_R', media_T1_R'];
std_plot_R  = [std_sani_R',   std_T0_R',   std_T1_R'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);

% 1. Disegno delle Barre Affiancate
b_R = bar(dati_plot_R, 'grouped');
hold on;
b_R(1).FaceColor = [0.2, 0.6, 0.85]; % Azzurro Sani
b_R(2).FaceColor = [0.85, 0.3, 0.3];  % Rosso T0
b_R(3).FaceColor = [0.5, 0.2, 0.6];   % Viola T1

% 2. Coordinate X e Barre d'Errore
nbars = size(dati_plot_R, 2);
ngroups = size(dati_plot_R, 1);
x_pos_R = zeros(ngroups, nbars);

for i = 1:nbars
    x_pos_R(:, i) = b_R(i).XEndPoints;
    errorbar(x_pos_R(:, i), dati_plot_R(:, i), std_plot_R(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

% 3. TRACCIAMENTO PONTI DI SIGNIFICATIVITÀ COMPATTI SOTTO LE BARRE
offset_base = 0.6;  
step_h      = 0.9;  
h_tick      = 0.3;  

y_min_raggiunto_R = 0; 

for g = 1:ngroups
    y_base = min(dati_plot_R(g, :) - std_plot_R(g, :), [], 'omitnan');
    if isnan(y_base), continue; end
    level = 0;
    
    % Sani vs T0
    if sig_SanivsT0_R(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos_R(g, 1); x2 = x_pos_R(g, 2);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto_R = min(y_min_raggiunto_R, y_line - 0.8);
    end
    
    % T0 vs T1
    if sig_T0vsT1_R(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos_R(g, 2); x2 = x_pos_R(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto_R = min(y_min_raggiunto_R, y_line - 0.8);
    end
    
    % Sani vs T1
    if sig_SanivsT1_R(g) == 1
        level = level + 1;
        y_line = y_base - offset_base - (level-1)*step_h;
        x1 = x_pos_R(g, 1); x2 = x_pos_R(g, 3);
        plot([x1, x1, x2, x2], [y_line + h_tick, y_line, y_line, y_line + h_tick], 'k-', 'LineWidth', 1.2);
        text((x1 + x2)/2, y_line - 0.1, '*', 'FontSize', 15, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        y_min_raggiunto_R = min(y_min_raggiunto_R, y_line - 0.8);
    end
end

% 4. Formattazione Assi, Titoli e Griglia Orizzontale Fitta
set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_label, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25);
ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento del LDLJ Ritorno ± SD', 'FontSize', 14, 'FontWeight', 'bold');

y_lim_min_R = floor(y_min_raggiunto_R - 2.0); 
ylim([y_lim_min_R, 0.5]);
yticks(y_lim_min_R:1:0);

grid on;
set(gca, 'YMinorGrid', 'on', 'XMinorGrid', 'off');
ax = gca;
ax.GridColor = [0.15 0.15 0.15];
ax.GridAlpha = 0.3;
ax.MinorGridColor = [0.2 0.2 0.2];
ax.MinorGridAlpha = 0.2;

% 5. Legenda Verticale all'interno del Grafico
lgd = legend([b_R(1), b_R(2), b_R(3)], {'Sani', 'T0', 'T1'}, ...
    'Location', 'southwest', ...
    'Orientation', 'vertical', ...
    'FontSize', 11, ...
    'FontWeight', 'bold');

hold off;

exportgraphics(gcf, 'LDLJ_Ritorno.png', 'Resolution', 300);