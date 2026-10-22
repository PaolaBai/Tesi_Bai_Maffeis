clear
close all
clc

%% caricamento struct con indici

load('Implementazione_ROM.mat');

% sottocartelle
gruppo = {'Sani', 'Patologici'};
id_sano = {'H002', 'H003', 'H004', 'H005', 'H006', 'H008', 'H009', 'H010', 'H011', 'H013', 'H016', 'H017', 'H018'};
id_patologico = {'S001', 'S004', 'S011', 'S012', 'S013', 'S014', 'S015', 'S025', 'S026', 'S027', 'S028', 'S031', 'S032', 'S034', 'S036', 'S037', 'S041', 'S046', 'S047'};
timepoint_sano = {'T'};
timepoint_patologico = {'T0', 'T1'};
indice1 = {'jerk', 'LDLJ', 'SPARC', 'skewness'};
indice2 = {'angolo_spalla_medio', 'ROM_spalla', 'angolo_gomito_medio', 'ROM_gomito', 'angolo_sagittale_medio', 'ROM_tronco_sagittale', 'angolo_frontale_medio', 'ROM_tronco_frontale', 'angolo_torsione_medio', 'ROM_tronco_torsione'};
task_motori = {'Addu', 'Addu_orizz', 'Flex', 'Circ', 'RandG'};
sottocartelle4 = {'Right', 'Left'};
sottocartelle5 = {'R_avanti', 'R_indietro', 'L_avanti', 'L_indietro'};
sottocartelle6 = {'Reach', 'Grasp'};
sottocartelle_ar = {'Andata', 'Ritorno', 'Totale'};
sottocartelle_ad = {'Accelerazione', 'Decelerazione', 'Totale'};

%%

t_norm = 0:1:100;       % griglia temporale a 101 punti (0% - 100%)
t_norm = t_norm(:).';       % Forziamo a vettore riga (1 x 101)

angolo_target = 'angolo_gomito_medio';

Matrice_Sani_Reach = [];
Matrice_Sani_Grasp = [];

Matrice_Patologici_Reach_affettoT0 = [];
Matrice_Patologici_Grasp_affettoT0 = [];

Matrice_Patologici_Reach_affettoT1 = [];
Matrice_Patologici_Grasp_affettoT1 = [];

info_soggetti = readtable('Tabella lato affetto.xlsx');

%% ESTRAZIONE DINAMICA DAI GRUPPI

for ii = 1:length(gruppo)       % scorro i gruppi
    gruppo_corrente = gruppo{ii};

    if ii == 1      % sono in sani

        for jj = 1:length(id_sano)      % scorro i soggetti
            soggetto_corrente = id_sano{jj};

            for ll = 1:length(task_motori)         % scorro le task
                task_corrente = task_motori{ll};

                if ll == 5         % vale per RandG

                    for mm = 1:length(sottocartelle6)       % scorro dx e sx
                        lato_corrente = sottocartelle6{mm};

                        if mm == 1           % sono in reach

                            for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                tratto_corrente = sottocartelle_ar{oo};

                                if oo == 3      % totale

                                    for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                        accelerazione_corrente = sottocartelle_ad{qq};

                                        if qq == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                    Matrice_Sani_Reach(end+1, :) = ang_101(:).';
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                        elseif mm == 2      % sono in grasp

                            for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                tratto_corrente = sottocartelle_ar{oo};

                                if oo == 3      % totale

                                    for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                        accelerazione_corrente = sottocartelle_ad{qq};

                                        if qq == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                    Matrice_Sani_Grasp(end+1, :) = ang_101(:).';
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    elseif ii == 2      % sono in patologici

        for jj = 1:length(id_patologico)      % scorro i soggetti
            soggetto_corrente = id_patologico{jj};

            riga_soggetto = strcmp(info_soggetti{:, 1}, soggetto_corrente);
            lato_affetto = info_soggetti{riga_soggetto, 2};

            for pp = 1:length(timepoint_patologico)
                timepoint_corrente = timepoint_patologico{pp};

                if pp == 1         % sono al tempo T0

                    for ll = 1:length(task_motori)         % scorro le task
                        task_corrente = task_motori{ll};

                        if ll == 5         % vale per RandG

                            for mm = 1:length(sottocartelle6)       % scorro dx e sx
                                lato_corrente = sottocartelle6{mm};

                                if mm == 1           % sono in reach

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Reach_affettoT0(end+1, :) = ang_101(:).';
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 2      % sono in grasp

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Grasp_affettoT0(end+1, :) = ang_101(:).';
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                elseif pp == 2          % sono al tempo T1

                    for ll = 1:length(task_motori)         % scorro le task
                        task_corrente = task_motori{ll};

                        if ll == 5         % vale per RandG

                            for mm = 1:length(sottocartelle6)       % scorro dx e sx
                                lato_corrente = sottocartelle6{mm};

                                if mm == 1           % sono in reach

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Reach_affettoT1(end+1, :) = ang_101(:).';
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 2      % sono in grasp

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Grasp_affettoT1(end+1, :) = ang_101(:).';
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%% DEFINIZIONE PALETTE COLORI
col_sani  = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3]; % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

% Palette Barre SPM1D
col_bar_Sani_T0 = [0.95, 0.45, 0.10]; % Arancione
col_bar_Sani_T1 = [0.70, 0.45, 0.85]; % Viola chiaro
col_bar_T0_T1   = [0.10, 0.60, 0.20]; % Verde

%% 1. GRAFICO REACH (SINGOLO)
media_sani  = mean(Matrice_Sani_Reach, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Reach, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Reach_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Reach_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Reach_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Reach_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

% Ombreggiature SD
fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

% Curve Medie
plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D (REACH)
y_sig1 = -8;  y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Gomito_Sani_vs_T0.xlsx', 'Reach', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Gomito_Sani_vs_T1.xlsx', 'Reach', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Gomito_T0_vs_T1.xlsx',   'Reach', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Gomito [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Reach', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);

% Dummy handles per la legenda
h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4.0);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4.0);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4.0);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Gomito_Reach.png', 'Resolution', 300);

%% 2. GRAFICO GRASP (SINGOLO)
media_sani  = mean(Matrice_Sani_Grasp, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Grasp, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Grasp_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Grasp_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Grasp_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Grasp_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

% Ombreggiature SD
fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

% Curve Medie
plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D (GRASP)
y_sig1 = -8;  y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Gomito_Sani_vs_T0.xlsx', 'Grasp', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Gomito_Sani_vs_T1.xlsx', 'Grasp', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Gomito_T0_vs_T1.xlsx',   'Grasp', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Gomito [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Grasp', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);

% Dummy handles per la legenda
h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4.0);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4.0);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4.0);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Gomito_Grasp.png', 'Resolution', 300);

%% 3. GRAFICO UNIFICATO CON BARRE SPM1D
nomi_task = {'Reach', 'Grasp'};
piani_movimento = {'Piano Sagittale', 'Piano Sagittale'};
n_task = length(nomi_task);

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.05, 0.4, 0.60, 0.45]);
t = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

for ii = 1:n_task
    nexttile;
    hold on; grid on;
    task_corrente = nomi_task{ii};
    
    Matrice_Sani = eval(['Matrice_Sani_' task_corrente]);
    Matrice_T0   = eval(['Matrice_Patologici_' task_corrente '_affettoT0']);
    Matrice_T1   = eval(['Matrice_Patologici_' task_corrente '_affettoT1']);
    
    media_sani = mean(Matrice_Sani, 1, 'omitnan'); media_sani = media_sani(:).';
    sd_sani    = std(Matrice_Sani, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
    media_patT0 = mean(Matrice_T0, 1, 'omitnan');  media_patT0 = media_patT0(:).';
    sd_patT0    = std(Matrice_T0, 0, 1, 'omitnan');   sd_patT0 = sd_patT0(:).';
    media_patT1 = mean(Matrice_T1, 1, 'omitnan');  media_patT1 = media_patT1(:).';
    sd_patT1    = std(Matrice_T1, 0, 1, 'omitnan');   sd_patT1 = sd_patT1(:).';
    
    % Ombreggiatura SD
    fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    
    % Curve Medie
    plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.0, 'HandleVisibility', 'off');
    plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    
    % Coordinate Y per le barrette
    y_sig1 = -8;   % Sani vs T0
    y_sig2 = -16;  % Sani vs T1
    y_sig3 = -24;  % T0 vs T1
    
    % TRACCIAMENTO AUTOMATICO DAI FILE EXCEL
    disegna_barre_spm('Risultati_SPM_Gomito_Sani_vs_T0.xlsx', task_corrente, y_sig1, col_bar_Sani_T0);
    disegna_barre_spm('Risultati_SPM_Gomito_Sani_vs_T1.xlsx', task_corrente, y_sig2, col_bar_Sani_T1);
    disegna_barre_spm('Risultati_SPM_Gomito_T0_vs_T1.xlsx',   task_corrente, y_sig3, col_bar_T0_T1);
    
    % Formattazione Assi
    xlim([0 100]);
    ylim([-30, 150]);
    yticks(0:25:150);
    task_pulita = strrep(nomi_task{ii}, '_', ' ');
    title({task_pulita, sprintf('\\fontsize{9}\\rm%s', piani_movimento{ii})}, 'FontSize', 11, 'FontWeight', 'bold');
    hold off;
end

% --- ETICHETTE E LEGENDA UNICA ---
xlabel(t, 'Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(t, 'Angolo Gomito [°]', 'FontSize', 12, 'FontWeight', 'bold');
sgtitle('Traiettorie Angolari Medie del Gomito ± SD', 'FontSize', 13, 'FontWeight', 'bold');

% Dummy handles per la legenda condivisa
hold on;
h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.0);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.0);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.0);
h_b1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4.0);
h_b2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4.0);
h_b3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4.0);

lgd = legend([h1, h2, h3, h_b1, h_b2, h_b3], ...
    {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, ...
    'Orientation', 'horizontal', 'FontSize', 9, 'FontWeight', 'bold');
lgd.Layout.Tile = 'north';

exportgraphics(gcf, 'Angolo_Gomito_unificato_con_SPM.png', 'Resolution', 300);

%% FUNZIONI AUSILIARIE PER LA LETTURA E IL DISEGNO AUTOMATICO DEI CLUSTER
function disegna_barre_spm(nome_file, task_target, y_quota, colore_barra)
    if exist(nome_file, 'file')
        tab = readtable(nome_file);
        idx_task = find(strcmpi(string(tab.Task), task_target));
        
        for k = 1:length(idx_task)
            riga = idx_task(k);
            sig_str = string(tab.Significativo{riga});
            
            if strcmpi(sig_str, 'SI')
                range_str = string(tab.Range_Ciclo_Percent{riga});
                valori = regexp(range_str, '\d+\.?\d*', 'match');
                valori_num = str2double(valori);
                
                for v = 1:2:length(valori_num)
                    if v+1 <= length(valori_num)
                        x_start = valori_num(v);
                        x_end   = valori_num(v+1);
                        plot([x_start, x_end], [y_quota, y_quota], 'Color', colore_barra, 'LineWidth', 4, 'HandleVisibility', 'off');
                    end
                end
            end
        end
    end
end