clear
close all
clc

%% ANDATA

media_T0_pct = [];
media_T1_pct = [];
std_T0 = [];
std_T1 = [];

%% Addu

Db_sani_Addu = readtable('Database Sani_Addu.xlsx');
Db_patologici_Addu = readtable('Database Patologici lato affetto (T0 vs T1)_Addu.xlsx');

indice_sani = [Db_sani_Addu.SPARC_Andata_Dx; Db_sani_Addu.SPARC_Andata_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Addu.SPARC_Andata_T0;
indice_T1 = Db_patologici_Addu.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Addu_orizz

Db_sani_Addu_orizz = readtable('Database Sani_Addu orizz.xlsx');
Db_patologici_Addu_orizz = readtable('Database Patologici lato affetto (T0 vs T1)_Addu orizz.xlsx');

indice_sani = [Db_sani_Addu_orizz.SPARC_Andata_Dx; Db_sani_Addu_orizz.SPARC_Andata_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Addu_orizz.SPARC_Andata_T0;
indice_T1 = Db_patologici_Addu_orizz.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Flex

Db_sani_Flex = readtable('Database Sani_Flex.xlsx');
Db_patologici_Flex = readtable('Database Patologici lato affetto (T0 vs T1)_Flex.xlsx');

indice_sani = [Db_sani_Flex.SPARC_Andata_Dx; Db_sani_Flex.SPARC_Andata_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Flex.SPARC_Andata_T0;
indice_T1 = Db_patologici_Flex.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Circ avanti

Db_sani_Circ_avanti = readtable('Database Sani_Circ avanti.xlsx');
Db_patologici_Circ_avanti = readtable('Database Patologici lato affetto (T0 vs T1)_Circ avanti.xlsx');

indice_sani = [Db_sani_Circ_avanti.SPARC_Andata_Dx; Db_sani_Circ_avanti.SPARC_Andata_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Circ_avanti.SPARC_Andata_T0;
indice_T1 = Db_patologici_Circ_avanti.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Circ indietro

Db_sani_Circ_indietro = readtable('Database Sani_Circ indietro.xlsx');
Db_patologici_Circ_indietro = readtable('Database Patologici lato affetto (T0 vs T1)_Circ indietro.xlsx');

indice_sani = [Db_sani_Circ_indietro.SPARC_Andata_Dx; Db_sani_Circ_indietro.SPARC_Andata_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Circ_indietro.SPARC_Andata_T0;
indice_T1 = Db_patologici_Circ_indietro.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Reach

Db_sani_Reach = readtable('Database Sani vs Patologici T0_Reach.xlsx');
Db_patologici_Reach = readtable('Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

indice_sani = Db_sani_Reach.SPARC_Andata(string(Db_sani_Reach.Gruppo) == "Sano");      % sani dx + sx
indice_T0 = Db_patologici_Reach.SPARC_Andata_T0;
indice_T1 = Db_patologici_Reach.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Grasp

Db_sani_Grasp = readtable('Database Sani vs Patologici T0_Grasp.xlsx');
Db_patologici_Grasp = readtable('Database Patologici lato affetto (T0 vs T1)_Grasp.xlsx');

indice_sani = Db_sani_Grasp.SPARC_Andata(string(Db_sani_Grasp.Gruppo) == "Sano");      % sani dx + sx
indice_T0 = Db_patologici_Grasp.SPARC_Andata_T0;
indice_T1 = Db_patologici_Grasp.SPARC_Andata_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% significatività

nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro', 'Reach', 'Grasp'};
n_task = length(nomi_task);

prefisso_file = 'AS_';
nome_indice = 'SPARC_Andata';

sig_SanivsT0 = zeros(1, n_task);
sig_SanivsT1 = zeros(1, n_task);
sig_T0vsT1 = zeros(1, n_task);

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

nomi_task = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro', 'Reach', 'Grasp'};
dati_plot = [media_T0_pct', media_T1_pct'];
std_plot  = [std_T0', std_T1'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);

% 1. Disegno delle Barre Affiancate
b = bar(dati_plot, 'grouped');
hold on;
b(1).FaceColor = [0.85, 0.3, 0.3];  % Rosso T0
b(2).FaceColor = [0.5, 0.2, 0.6];   % Viola T1

% 2. Calcolo Coordinate X e Inserimento Barre d'Errore
nbars = size(dati_plot, 2);
ngroups = size(dati_plot, 1);
x_pos = zeros(ngroups, nbars);

for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

% 3. Linea Target Controllo Sano (100%)
yline(100, '--', 'Color', [0.2, 0.6, 0.85], ...
    'LineWidth', 2, 'FontSize', 11, 'FontWeight', 'bold', 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'left');
text(2, 200, '--- Target Controllo Sano (100%)', ...
    'Color', [0.2, 0.6, 0.85], ...
    'FontSize', 11, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left');

% 4. TRACCIAMENTO ASTERISCHI SULLE SINGOLE BARRE (vs Sani)
offset_singolo = 3; % Distanza verticale sopra la barra d'errore
for g = 1:ngroups
    % Asterisco per T0 vs Sani
    if sig_SanivsT0(g) == 1
        y_top = dati_plot(g, 1) + std_plot(g, 1) + offset_singolo;
        text(x_pos(g, 1), y_top, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'Color', [0.85, 0.3, 0.3]);
    end
    
    % Asterisco per T1 vs Sani
    if sig_SanivsT1(g) == 1
        y_top = dati_plot(g, 2) + std_plot(g, 2) + offset_singolo;
        text(x_pos(g, 2), y_top, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'Color', [0.5, 0.2, 0.6]);
    end
end

% 5. TRACCIAMENTO PONTE DI SIGNIFICATIVITÀ TRA COPPIE (T0 vs T1)
for g = 1:ngroups
    if sig_T0vsT1(g) == 1
        % Trova l'altezza massima tra le due barre d'errore del gruppo
        y_max = max(dati_plot(g, 1) + std_plot(g, 1), dati_plot(g, 2) + std_plot(g, 2));
        
        y_line = y_max + 10;  % Altezza del ponte sopra le barre
        h_tick = 2;           % Altezza dei trattini verticali del ponte
        x1 = x_pos(g, 1);
        x2 = x_pos(g, 2);
        
        % Disegno del ponte ┌─── * ───┐
        plot([x1, x1, x2, x2], [y_line - h_tick, y_line, y_line, y_line - h_tick], 'k-', 'LineWidth', 1.2);
        
        % Asterisco al centro del ponte
        text((x1 + x2)/2, y_line + 1, '*', 'FontSize', 14, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
end

% 6. Formattazione Assi e Titoli 
set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25);
ylabel('SPARC (% del Sano)', 'FontSize', 12, 'FontWeight', 'bold');
title('Recupero dello SPARC Andata (% del Controllo Sano) ± SD', 'FontSize', 14, 'FontWeight', 'bold');
ylim([0, 210]);
yticks(0:20:200);
grid on;

% 7. Legenda 
lgd = legend([b(1), b(2)], {'T0', 'T1'}, 'Location', 'northwest', 'FontSize', 11);
set(lgd, 'FontWeight', 'bold');

hold off;

exportgraphics(gcf, 'SPARC_Andata.png', 'Resolution', 300);


%% RITORNO

media_T0_pct = [];
media_T1_pct = [];
std_T0 = [];
std_T1 = [];

%% Addu

Db_sani_Addu = readtable('Database Sani_Addu.xlsx');
Db_patologici_Addu = readtable('Database Patologici lato affetto (T0 vs T1)_Addu.xlsx');

indice_sani = [Db_sani_Addu.SPARC_Ritorno_Dx; Db_sani_Addu.SPARC_Ritorno_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Addu.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Addu.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Addu_orizz

Db_sani_Addu_orizz = readtable('Database Sani_Addu orizz.xlsx');
Db_patologici_Addu_orizz = readtable('Database Patologici lato affetto (T0 vs T1)_Addu orizz.xlsx');

indice_sani = [Db_sani_Addu_orizz.SPARC_Ritorno_Dx; Db_sani_Addu_orizz.SPARC_Ritorno_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Addu_orizz.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Addu_orizz.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Flex

Db_sani_Flex = readtable('Database Sani_Flex.xlsx');
Db_patologici_Flex = readtable('Database Patologici lato affetto (T0 vs T1)_Flex.xlsx');

indice_sani = [Db_sani_Flex.SPARC_Ritorno_Dx; Db_sani_Flex.SPARC_Ritorno_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Flex.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Flex.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Circ avanti

Db_sani_Circ_avanti = readtable('Database Sani_Circ avanti.xlsx');
Db_patologici_Circ_avanti = readtable('Database Patologici lato affetto (T0 vs T1)_Circ avanti.xlsx');

indice_sani = [Db_sani_Circ_avanti.SPARC_Ritorno_Dx; Db_sani_Circ_avanti.SPARC_Ritorno_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Circ_avanti.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Circ_avanti.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Circ indietro

Db_sani_Circ_indietro = readtable('Database Sani_Circ indietro.xlsx');
Db_patologici_Circ_indietro = readtable('Database Patologici lato affetto (T0 vs T1)_Circ indietro.xlsx');

indice_sani = [Db_sani_Circ_indietro.SPARC_Ritorno_Dx; Db_sani_Circ_indietro.SPARC_Ritorno_Sx];      % sani dx + sx
indice_T0 = Db_patologici_Circ_indietro.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Circ_indietro.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Reach

Db_sani_Reach = readtable('Database Sani vs Patologici T0_Reach.xlsx');
Db_patologici_Reach = readtable('Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

indice_sani = Db_sani_Reach.SPARC_Ritorno(string(Db_sani_Reach.Gruppo) == "Sano");      % sani dx + sx
indice_T0 = Db_patologici_Reach.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Reach.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% Grasp

Db_sani_Grasp = readtable('Database Sani vs Patologici T0_Grasp.xlsx');
Db_patologici_Grasp = readtable('Database Patologici lato affetto (T0 vs T1)_Grasp.xlsx');

indice_sani = Db_sani_Grasp.SPARC_Ritorno(string(Db_sani_Grasp.Gruppo) == "Sano");      % sani dx + sx
indice_T0 = Db_patologici_Grasp.SPARC_Ritorno_T0;
indice_T1 = Db_patologici_Grasp.SPARC_Ritorno_T1;

% calcolo media sani e valori normalizzati sui sani 
media_indice_sani = mean(indice_sani, 'omitnan');

indice_T0_pct = (indice_T0./ media_indice_sani) * 100;
indice_T1_pct = (indice_T1./ media_indice_sani) * 100;

media_T0_pct = [media_T0_pct, mean(indice_T0_pct, 'omitnan')];
media_T1_pct = [media_T1_pct, mean(indice_T1_pct, 'omitnan')];
std_T0 = [std_T0, std(indice_T0_pct, 'omitnan')];
std_T1 = [std_T1, std(indice_T1_pct, 'omitnan')];

%% significatività

nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro', 'Reach', 'Grasp'};
n_task = length(nomi_task);

prefisso_file = 'AS_';
nome_indice = 'SPARC_Ritorno';

sig_SanivsT0 = zeros(1, n_task);
sig_SanivsT1 = zeros(1, n_task);
sig_T0vsT1 = zeros(1, n_task);

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

nomi_task = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro', 'Reach', 'Grasp'};
dati_plot = [media_T0_pct', media_T1_pct'];
std_plot  = [std_T0', std_T1'];

figure('Color', [1 1 1], 'Position', [100 100 950 550]);

% 1. Disegno delle Barre Affiancate
b = bar(dati_plot, 'grouped');
hold on;
b(1).FaceColor = [0.85, 0.3, 0.3];  % Rosso T0
b(2).FaceColor = [0.5, 0.2, 0.6];   % Viola T1

% 2. Calcolo Coordinate X e Inserimento Barre d'Errore
nbars = size(dati_plot, 2);
ngroups = size(dati_plot, 1);
x_pos = zeros(ngroups, nbars);

for i = 1:nbars
    x_pos(:, i) = b(i).XEndPoints;
    errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6); 
end

% 3. Linea Target Controllo Sano (100%)
yline(100, '--', 'Color', [0.2, 0.6, 0.85], ...
    'LineWidth', 2, 'FontSize', 11, 'FontWeight', 'bold', 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'left');
text(2, 200, '--- Target Controllo Sano (100%)', ...
    'Color', [0.2, 0.6, 0.85], ...
    'FontSize', 11, ...
    'FontWeight', 'bold', ...
    'HorizontalAlignment', 'left');

% 4. TRACCIAMENTO ASTERISCHI SULLE SINGOLE BARRE (vs Sani)
offset_singolo = 3; % Distanza verticale sopra la barra d'errore
for g = 1:ngroups
    % Asterisco per T0 vs Sani
    if sig_SanivsT0(g) == 1
        y_top = dati_plot(g, 1) + std_plot(g, 1) + offset_singolo;
        text(x_pos(g, 1), y_top, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'Color', [0.85, 0.3, 0.3]);
    end
    
    % Asterisco per T1 vs Sani
    if sig_SanivsT1(g) == 1
        y_top = dati_plot(g, 2) + std_plot(g, 2) + offset_singolo;
        text(x_pos(g, 2), y_top, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'Color', [0.5, 0.2, 0.6]);
    end
end

% 5. TRACCIAMENTO PONTE DI SIGNIFICATIVITÀ TRA COPPIE (T0 vs T1)
for g = 1:ngroups
    if sig_T0vsT1(g) == 1
        % Trova l'altezza massima tra le due barre d'errore del gruppo
        y_max = max(dati_plot(g, 1) + std_plot(g, 1), dati_plot(g, 2) + std_plot(g, 2));
        
        y_line = y_max + 10;  % Altezza del ponte sopra le barre
        h_tick = 2;           % Altezza dei trattini verticali del ponte
        x1 = x_pos(g, 1);
        x2 = x_pos(g, 2);
        
        % Disegno del ponte ┌─── * ───┐
        plot([x1, x1, x2, x2], [y_line - h_tick, y_line, y_line, y_line - h_tick], 'k-', 'LineWidth', 1.2);
        
        % Asterisco al centro del ponte
        text((x1 + x2)/2, y_line + 1, '*', 'FontSize', 14, 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
end

% 6. Formattazione Assi e Titoli 
set(gca, 'XTick', 1:ngroups, 'XTickLabel', nomi_task, 'FontSize', 11, 'FontWeight', 'bold');
xtickangle(25);
ylabel('SPARC (% del Sano)', 'FontSize', 12, 'FontWeight', 'bold');
title('Recupero dello SPARC Ritorno (% del Controllo Sano) ± SD', 'FontSize', 14, 'FontWeight', 'bold');
ylim([0, 210]);
yticks(0:20:200);
grid on;

% 7. Legenda 
lgd = legend([b(1), b(2)], {'T0', 'T1'}, 'Location', 'northwest', 'FontSize', 11);
set(lgd, 'FontWeight', 'bold');

hold off;

exportgraphics(gcf, 'SPARC_Ritorno.png', 'Resolution', 300);