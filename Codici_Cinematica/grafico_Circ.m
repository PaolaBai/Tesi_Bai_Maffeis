% grafici a barre (media + SD) indici - Circ

clear
close all
clc

%%

info_soggetti = readtable('Tabella lato affetto.xlsx');
Tabella_Circ = readtable('Tabella Circ.xlsx'); 

%% SPARC andata avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "SPARC");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.SPARC,  'omitnan');
    mean(tab_T0.SPARC, 'omitnan');
    mean(tab_T1.SPARC, 'omitnan')
];

dev_std = [
    std(tab_T.SPARC,  'omitnan');
    std(tab_T0.SPARC, 'omitnan');
    std(tab_T1.SPARC, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('SPARC', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ avanti', '(SPARC - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_avanti_Circ.png', 'Resolution', 300);

%% SPARC ritorno avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "SPARC");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.SPARC,  'omitnan');
    mean(tab_T0.SPARC, 'omitnan');
    mean(tab_T1.SPARC, 'omitnan')
    ];

dev_std = [
    std(tab_T.SPARC,  'omitnan');
    std(tab_T0.SPARC, 'omitnan');
    std(tab_T1.SPARC, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('SPARC', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ avanti', '(SPARC - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_avanti_Circ.png', 'Resolution', 300);

%% SPARC andata indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "SPARC");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.SPARC,  'omitnan');
    mean(tab_T0.SPARC, 'omitnan');
    mean(tab_T1.SPARC, 'omitnan')
];

dev_std = [
    std(tab_T.SPARC,  'omitnan');
    std(tab_T0.SPARC, 'omitnan');
    std(tab_T1.SPARC, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('SPARC', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ indietro', '(SPARC - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_indietro_Circ.png', 'Resolution', 300);

%% SPARC ritorno indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "SPARC");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.SPARC,  'omitnan');
    mean(tab_T0.SPARC, 'omitnan');
    mean(tab_T1.SPARC, 'omitnan')
    ];

dev_std = [
    std(tab_T.SPARC,  'omitnan');
    std(tab_T0.SPARC, 'omitnan');
    std(tab_T1.SPARC, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('SPARC', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ indietro', '(SPARC - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_indietro_Circ.png', 'Resolution', 300);

%% LDLJ andata avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "LDLJ");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.LDLJ,  'omitnan');
    mean(tab_T0.LDLJ, 'omitnan');
    mean(tab_T1.LDLJ, 'omitnan')
];

dev_std = [
    std(tab_T.LDLJ,  'omitnan');
    std(tab_T0.LDLJ, 'omitnan');
    std(tab_T1.LDLJ, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = min(medie - dev_std) * 1.1;
y_max = max([0, max(medie + dev_std) * 1.1]);
range_y = y_max - y_min;
step_y  = range_y / 6;
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ avanti', '(LDLJ - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_avanti_Circ.png', 'Resolution', 300);

%% LDLJ ritorno avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "LDLJ");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.LDLJ,  'omitnan');
    mean(tab_T0.LDLJ, 'omitnan');
    mean(tab_T1.LDLJ, 'omitnan')
    ];

dev_std = [
    std(tab_T.LDLJ,  'omitnan');
    std(tab_T0.LDLJ, 'omitnan');
    std(tab_T1.LDLJ, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = min(medie - dev_std) * 1.1;
y_max = max([0, max(medie + dev_std) * 1.1]);
range_y = y_max - y_min;
step_y  = range_y / 6;
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ avanti', '(LDLJ - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritorno_avanti_Circ.png', 'Resolution', 300);

%% LDLJ andata indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "LDLJ");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.LDLJ,  'omitnan');
    mean(tab_T0.LDLJ, 'omitnan');
    mean(tab_T1.LDLJ, 'omitnan')
];

dev_std = [
    std(tab_T.LDLJ,  'omitnan');
    std(tab_T0.LDLJ, 'omitnan');
    std(tab_T1.LDLJ, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = min(medie - dev_std) * 1.1;
y_max = max([0, max(medie + dev_std) * 1.1]);
range_y = y_max - y_min;
step_y  = range_y / 6;
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ indietro', '(LDLJ - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_indietro_Circ.png', 'Resolution', 300);

%% LDLJ ritorno indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "LDLJ");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.LDLJ,  'omitnan');
    mean(tab_T0.LDLJ, 'omitnan');
    mean(tab_T1.LDLJ, 'omitnan')
    ];

dev_std = [
    std(tab_T.LDLJ,  'omitnan');
    std(tab_T0.LDLJ, 'omitnan');
    std(tab_T1.LDLJ, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = min(medie - dev_std) * 1.1;
y_max = max([0, max(medie + dev_std) * 1.1]);
range_y = y_max - y_min;
step_y  = range_y / 6;
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('LDLJ', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ indietro', '(LDLJ - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritorno_indietro_Circ.png', 'Resolution', 300);

%% jerkMean andata avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "jerkMean");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.jerkMean,  'omitnan');
    mean(tab_T0.jerkMean, 'omitnan');
    mean(tab_T1.jerkMean, 'omitnan')
    ];

dev_std = [
    std(tab_T.jerkMean,  'omitnan');
    std(tab_T0.jerkMean, 'omitnan');
    std(tab_T1.jerkMean, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = -1;
y_max = max([0, max(medie + dev_std) * 1.1]);
step_y = round(y_max / 6, 0); 
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('JerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'northeast');
title({'Fluidità del Movimento - Circ avanti', '(Jerk medio - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_avanti_Circ.png', 'Resolution', 300);

%% jerkMean ritorno avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "jerkMean");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.jerkMean,  'omitnan');
    mean(tab_T0.jerkMean, 'omitnan');
    mean(tab_T1.jerkMean, 'omitnan')
    ];

dev_std = [
    std(tab_T.jerkMean,  'omitnan');
    std(tab_T0.jerkMean, 'omitnan');
    std(tab_T1.jerkMean, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = -1;
y_max = max([0, max(medie + dev_std) * 1.1]);
step_y = round(y_max / 6, 0); 
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('JerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'northeast');
title({'Fluidità del Movimento - Circ avanti', '(Jerk medio - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_avanti_Circ.png', 'Resolution', 300);

%% jerkMean andata indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "jerkMean");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.jerkMean,  'omitnan');
    mean(tab_T0.jerkMean, 'omitnan');
    mean(tab_T1.jerkMean, 'omitnan')
    ];

dev_std = [
    std(tab_T.jerkMean,  'omitnan');
    std(tab_T0.jerkMean, 'omitnan');
    std(tab_T1.jerkMean, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = -1;
y_max = max([0, max(medie + dev_std) * 1.1]);
step_y = round(y_max / 6, 0); 
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('JerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'northeast');
title({'Fluidità del Movimento - Circ indietro', '(Jerk medio - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_indietro_Circ.png', 'Resolution', 300);

%% jerkMean ritorno indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "jerkMean");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.jerkMean,  'omitnan');
    mean(tab_T0.jerkMean, 'omitnan');
    mean(tab_T1.jerkMean, 'omitnan')
    ];

dev_std = [
    std(tab_T.jerkMean,  'omitnan');
    std(tab_T0.jerkMean, 'omitnan');
    std(tab_T1.jerkMean, 'omitnan')
    ];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

y_min = -1;
y_max = max([0, max(medie + dev_std) * 1.1]);
step_y = round(y_max / 6, 0); 
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('JerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'northeast');
title({'Fluidità del Movimento - Circ indietro', '(Jerk medio - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_indietro_Circ.png', 'Resolution', 300);

%% skewness andata avanti

% conversione colonne testuali in categoricalL
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "skewness");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.skewness,  'omitnan');
    mean(tab_T0.skewness, 'omitnan');
    mean(tab_T1.skewness, 'omitnan')
];

dev_std = [
    std(tab_T.skewness,  'omitnan');
    std(tab_T0.skewness, 'omitnan');
    std(tab_T1.skewness, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('Skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ avanti', '(Skewness - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Andata_avanti_Circ.png', 'Resolution', 300);

%% skewness ritorno avanti

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "skewness");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.skewness,  'omitnan');
    mean(tab_T0.skewness, 'omitnan');
    mean(tab_T1.skewness, 'omitnan')
];

dev_std = [
    std(tab_T.skewness,  'omitnan');
    std(tab_T0.skewness, 'omitnan');
    std(tab_T1.skewness, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('Skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ avanti', '(Skewness - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Ritorno_avanti_Circ.png', 'Resolution', 300);

%% skewness andata indietro

% conversione colonne testuali in categoricalL
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Andata";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "skewness");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.skewness,  'omitnan');
    mean(tab_T0.skewness, 'omitnan');
    mean(tab_T1.skewness, 'omitnan')
];

dev_std = [
    std(tab_T.skewness,  'omitnan');
    std(tab_T0.skewness, 'omitnan');
    std(tab_T1.skewness, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('Skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ indietro', '(Skewness - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Andata_indietro_Circ.png', 'Resolution', 300);

%% skewness ritorno indietro

% conversione colonne testuali in categorical
Tabella_Circ.Gruppo = categorical(Tabella_Circ.Gruppo);
Tabella_Circ.Timepoint = categorical(Tabella_Circ.Timepoint);
Tabella_Circ.Ciclo  = categorical(Tabella_Circ.Ciclo);
Tabella_Circ.Tratto = categorical(Tabella_Circ.Tratto);

% filtro
filtro_cicli = Tabella_Circ.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Circ.Tratto == "Ritorno";
filtro_movimento = contains(string(Tabella_Circ.Lato), "indietro", 'IgnoreCase', true);
Tabella_Filtrata = Tabella_Circ(filtro_cicli & filtro_tratto & filtro_movimento, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);
filtro_lato_affetto = false(height(tab_T0_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T0_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T0_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T0 = tab_T0_grezza(filtro_lato_affetto, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);
filtro_lato_affetto = false(height(tab_T1_grezza), 1);

for ii = 1:height(info_soggetti)
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));      % converte in maiuscolo tutto

    righe_soggetto = string(tab_T1_grezza.Soggetto) == soggetto_corrente;
    righe_lato = startsWith(string(tab_T1_grezza.Lato), lato_affetto, 'IgnoreCase', true);

    filtro_lato_affetto = filtro_lato_affetto | (righe_soggetto & righe_lato);
end

tab_T1 = tab_T1_grezza(filtro_lato_affetto, "skewness");


% calcolo media e SD per gruppo sullo SPARC
medie = [
    mean(tab_T.skewness,  'omitnan');
    mean(tab_T0.skewness, 'omitnan');
    mean(tab_T1.skewness, 'omitnan')
];

dev_std = [
    std(tab_T.skewness,  'omitnan');
    std(tab_T0.skewness, 'omitnan');
    std(tab_T1.skewness, 'omitnan')
];

x_coords   = [1, 2, 3];
timepoint  = {'T', 'T0', 'T1'};

% grafico
figure();
hold on;
grid on;

col_sani = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3];  % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

h1 = bar(1, medie(1), 0.5, 'FaceColor', col_sani,  'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Sani');
h2 = bar(2, medie(2), 0.5, 'FaceColor', col_patT0, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T0');
h3 = bar(3, medie(3), 0.5, 'FaceColor', col_patT1, 'EdgeColor', 'k', 'LineWidth', 1, 'DisplayName', 'Patologici T1');
errorbar(x_coords, medie, dev_std, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

step_y = 0.1; 
y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
yticks_custom = floor(y_min/step_y)*step_y : step_y : ceil(y_max/step_y)*step_y;
set(gca, 'XTick', x_coords, 'XTickLabel', timepoint, 'XLim', [0.3, 3.7],...
    'YTick', yticks_custom, 'YMinorTick', 'on', 'YGrid', 'on', 'YMinorGrid', 'on', 'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, 'GridLineStyle', '-', 'MinorGridLineStyle', ':', ...
    'FontSize', 12, 'FontName', 'Arial', 'FontWeight', 'bold', 'Box', 'off', 'TickDir', 'out', 'LineWidth', 1.1);

ylabel('Skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Circ indietro', '(Skewness - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Ritorno_inditro_Circ.png', 'Resolution', 300);
