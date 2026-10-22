% grafici a barre (media + SD) indici - Addu

clear
close all
clc

%%

info_soggetti = readtable('Tabella lato affetto.xlsx');
Tabella_Addu = readtable('Tabella Addu.xlsx'); 

%% SPARC andata

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Andata";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(SPARC - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Andata_Addu.png', 'Resolution', 300);

%% SPARC ritorno

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Ritorno";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(SPARC - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'SPARC_Ritorno_Addu.png', 'Resolution', 300);

%% LDLJ andata

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo  = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Andata";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(LDLJ - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Andata_Addu.png', 'Resolution', 300);

%% LDLJ ritorno

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo  = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Ritorno";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(LDLJ - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'LDLJ_Ritorno_Addu.png', 'Resolution', 300);

%% jerkMean andata

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo  = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Andata";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(Jerk medio - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Andata_Addu.png', 'Resolution', 300);

%% jerkMean ritorno

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo  = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Ritorno";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(Jerk medio - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'jerkMean_Ritorno_Addu.png', 'Resolution', 300);

%% skewness andata

% conversione colonne testuali in categoricalL
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo  = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Andata";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);

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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(Skewness - Andata)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Andata_Addu.png', 'Resolution', 300);

%% skewness ritorno 

% conversione colonne testuali in categorical
Tabella_Addu.Gruppo = categorical(Tabella_Addu.Gruppo);
Tabella_Addu.Timepoint = categorical(Tabella_Addu.Timepoint);
Tabella_Addu.Ciclo  = categorical(Tabella_Addu.Ciclo);
Tabella_Addu.Tratto = categorical(Tabella_Addu.Tratto);

% filtro
filtro_cicli = Tabella_Addu.Ciclo ~= "Media Cicli";
filtro_tratto = Tabella_Addu.Tratto == "Ritorno";
Tabella_Filtrata = Tabella_Addu(filtro_cicli & filtro_tratto, :);


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
    righe_lato = upper(strip(string(tab_T0_grezza.Lato))) == lato_affetto;

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
    righe_lato = upper(strip(string(tab_T1_grezza.Lato))) == lato_affetto;

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
title({'Fluidità del Movimento - Addu', '(Skewness - Ritorno)'}, 'FontSize', 13, 'FontWeight', 'bold');

y_min = min(medie - dev_std) * 1.15;
y_max = max([0, max(medie + dev_std) * 1.1]);
ylim([y_min, y_max]);

exportgraphics(gcf, 'skewness_Ritorno_Addu.png', 'Resolution', 300);
