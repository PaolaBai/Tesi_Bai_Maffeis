% grafici a barre (media + SD) indici - RandG

clear
close all
clc

%%

info_soggetti = readtable('Tabella lato affetto.xlsx');
Tabella_RandG = readtable('Tabella RandG.xlsx'); 

%% SPARC reach andata accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Reach', '(SPARC - Andata Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Acc_Reach.png', 'Resolution', 300);

%% SPARC reach andata decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Reach', '(SPARC - Andata Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Dec_Reach.png', 'Resolution', 300);

%% SPARC reach andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Reach', '(SPARC - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Reach.png', 'Resolution', 300);

%% SPARC reach ritorno accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Reach', '(SPARC - Ritorno Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Acc_Reach.png', 'Resolution', 300);

%% SPARC reach ritorno decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Reach', '(SPARC - Ritorno Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Dec_Reach.png', 'Resolution', 300);

%% SPARC reach ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Reach', '(SPARC - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Reach.png', 'Resolution', 300);

%% SPARC grasp andata accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Grasp', '(SPARC - Andata Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Acc_Grasp.png', 'Resolution', 300);

%% SPARC Grasp andata decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Grasp', '(SPARC - Andata Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Dec_Grasp.png', 'Resolution', 300);

%% SPARC Grasp andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Grasp', '(SPARC - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Grasp.png', 'Resolution', 300);

%% SPARC Grasp ritorno accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Grasp', '(SPARC - Ritorno Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Acc_Grasp.png', 'Resolution', 300);

%% SPARC Grasp ritorno decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Grasp', '(SPARC - Ritorno Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Dec_Grasp.png', 'Resolution', 300);

%% SPARC Grasp ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "SPARC");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "SPARC");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "SPARC");


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
title({'Fluidità del Movimento - Grasp', '(SPARC - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Grasp.png', 'Resolution', 300);

%% LDLJ reach andata accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Reach', '(LDLJ - Andata Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Acc_Reach.png', 'Resolution', 300);

%% LDLJ reach andata decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Reach', '(LDLJ - Andata Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Dec_Reach.png', 'Resolution', 300);

%% LDLJ reach andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Reach', '(LDLJ - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Reach.png', 'Resolution', 300);

%% LDLJ reach ritorno accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Reach', '(LDLJ - Ritorno Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritono_Acc_Reach.png', 'Resolution', 300);

%% LDLJ reach ritorno decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Reach', '(LDLJ - Ritorno Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritono_Dec_Reach.png', 'Resolution', 300);

%% LDLJ reach ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Reach', '(LDLJ - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritono_Reach.png', 'Resolution', 300);

%% LDLJ grasp andata accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Grasp', '(LDLJ - Andata Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Acc_Grasp.png', 'Resolution', 300);

%% LDLJ Grasp andata decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Grasp', '(LDLJ - Andata Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Dec_Grasp.png', 'Resolution', 300);

%% LDLJ Grasp andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Grasp', '(LDLJ - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Grasp.png', 'Resolution', 300);

%% LDLJ Grasp ritorno accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Grasp', '(LDLJ - Ritorno Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritorno_Acc_Grasp.png', 'Resolution', 300);

%% LDLJ Grasp ritorno decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Grasp', '(LDLJ - Ritorno Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritorno_Dec_Grasp.png', 'Resolution', 300);

%% LDLJ Grasp ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "LDLJ");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "LDLJ");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "LDLJ");


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
title({'Fluidità del Movimento - Grasp', '(LDLJ - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritorno_Grasp.png', 'Resolution', 300);

%% jerkMean reach andata accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Jerk Medio - Andata Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Acc_Reach.png', 'Resolution', 300);

%% jerkMean reach andata decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Jerk Medio - Andata Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Dec_Reach.png', 'Resolution', 300);

%% jerkMean reach andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Jerk Medio - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Reach.png', 'Resolution', 300);

%% jerkMean reach ritorno accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Jerk Medio - Ritorno Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Acc_Reach.png', 'Resolution', 300);

%% jerkMean reach ritorno decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Jerk Medio - Ritorno Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Dec_Reach.png', 'Resolution', 300);

%% jerkMean reach ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Jerk Medio - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Reach.png', 'Resolution', 300);

%% jerkMean grasp andata accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Jerk Medio - Andata Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Acc_Grasp.png', 'Resolution', 300);

%% jerkMean Grasp andata decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Jerk Medio - Andata Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Dec_Grasp.png', 'Resolution', 300);

%% jerkMean Grasp andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Jerk Medio - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Grasp.png', 'Resolution', 300);

%% jerkMean Grasp ritorno accelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Accelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Jerk Medio - Ritorno Accelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Acc_Grasp.png', 'Resolution', 300);

%% jerkMean Grasp ritorno decelerazione

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Decelerazione";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Jerk Medio - Ritorno Decelerazione)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Dec_Grasp.png', 'Resolution', 300);

%% jerkMean Grasp ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "jerkMean");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "jerkMean");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "jerkMean");


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

ylabel('jerkMean', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Jerk Medio - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Grasp.png', 'Resolution', 300);

%% skewness reach andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "skewness");


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

ylabel('skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Skewness - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Andata_Reach.png', 'Resolution', 300);

%% skewness reach ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Reach";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "skewness");


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

ylabel('skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Reach', '(Skewness - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Ritorno_Reach.png', 'Resolution', 300);

%% skewness Grasp andata totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Andata";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "skewness");


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

ylabel('skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Skewness - Andata Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Andata_Grasp.png', 'Resolution', 300);

%% skewness Grasp ritorno totale

% conversione colonne testuali in categorical
Tabella_RandG.Gruppo = categorical(Tabella_RandG.Gruppo);
Tabella_RandG.Timepoint = categorical(Tabella_RandG.Timepoint);
Tabella_RandG.Ciclo = categorical(Tabella_RandG.Ciclo);
Tabella_RandG.Tratto = categorical(Tabella_RandG.Tratto);

% filtro
filtro_cicli = Tabella_RandG.Ciclo ~= "Media Cicli";
filtro_lato = Tabella_RandG.Lato == "Grasp";
filtro_tratto = Tabella_RandG.Tratto == "Ritorno";
filtro_accelereazione = Tabella_RandG.Accelerazione == "Totale";
Tabella_Filtrata = Tabella_RandG(filtro_cicli & filtro_lato & filtro_tratto & filtro_accelereazione, :);

% tabella sani
filtro_T = Tabella_Filtrata.Timepoint == "T";
tab_T = Tabella_Filtrata(filtro_T, "skewness");

% tabella patologici T0
filtro_T0 = Tabella_Filtrata.Timepoint == "T0";
tab_T0_grezza = Tabella_Filtrata(filtro_T0, :);

tab_T0 = tab_T0_grezza(:, "skewness");

% tabella patologici T1
filtro_T1 = Tabella_Filtrata.Timepoint == "T1";
tab_T1_grezza = Tabella_Filtrata(filtro_T1, :);

tab_T1 = tab_T1_grezza(:, "skewness");


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

ylabel('skewness', 'FontSize', 12, 'FontWeight', 'bold');
legend([h1, h2, h3], 'Location', 'southwest');
title({'Fluidità del Movimento - Grasp', '(Skewness - Ritorno Totale)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Ritorno_Grasp.png', 'Resolution', 300);
