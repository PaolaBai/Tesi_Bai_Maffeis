clear
close all
clc

%% DEFINIZIONE PARAMETRI GENERALI
nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro'};
nomi_task_plot = {'Addu', 'Addu orizz', 'Flex', 'Circ avanti', 'Circ indietro'};
n_task = length(nomi_task);
tratti = {'Andata', 'Ritorno'};

%% CICLO SUI TRATTI (ANDATA E RITORNO)
for tr = 1:length(tratti)
    tratto_corrente = tratti{tr};
    nome_indice = sprintf('skewness_%s', tratto_corrente);

    media_Sani = []; media_T0 = []; media_T1 = [];
    std_Sani   = []; std_T0   = []; std_T1   = [];

    %% 1. ESTRAZIONE DATI PER OGNI TASK
    for tt = 1:n_task
        task = nomi_task{tt};

        if strcmp(task, 'Reach') || strcmp(task, 'Grasp')
            file_sani = sprintf('Database Sani vs Patologici T0_%s.xlsx', task);
            file_pat  = sprintf('Database Patologici lato non affetto (T0 vs T1)_%s.xlsx', task);

            Db_sani = readtable(file_sani);
            Db_pat  = readtable(file_pat);

            col_sani = nome_indice;
            col_T0   = sprintf('%s_T0', nome_indice);
            col_T1   = sprintf('%s_T1', nome_indice);

            idx_sano = string(Db_sani.Gruppo) == "Sano";
            indice_sani = Db_sani.(col_sani)(idx_sano);
            indice_T0   = Db_pat.(col_T0);
            indice_T1   = Db_pat.(col_T1);
        else
            task_str_sani = strrep(task, '_', ' ');
            file_sani = sprintf('Database Sani_%s.xlsx', task_str_sani);
            file_pat  = sprintf('Database Patologici lato non affetto (T0 vs T1)_%s.xlsx', task_str_sani);

            Db_sani = readtable(file_sani);
            Db_pat  = readtable(file_pat);

            col_dx = sprintf('%s_Dx', nome_indice);
            col_sx = sprintf('%s_Sx', nome_indice);
            col_T0 = sprintf('%s_T0', nome_indice);
            col_T1 = sprintf('%s_T1', nome_indice);

            indice_sani = [Db_sani.(col_dx); Db_sani.(col_sx)];
            indice_T0   = Db_pat.(col_T0);
            indice_T1   = Db_pat.(col_T1);
        end

        media_Sani = [media_Sani, mean(indice_sani, 'omitnan')];
        media_T0   = [media_T0, mean(indice_T0, 'omitnan')];
        media_T1   = [media_T1, mean(indice_T1, 'omitnan')];

        std_Sani = [std_Sani, std(indice_sani, 'omitnan')];
        std_T0   = [std_T0, std(indice_T0, 'omitnan')];
        std_T1   = [std_T1, std(indice_T1, 'omitnan')];
    end

    %% 2. LETTURA SIGNIFICATIVITÀ STATISTICA
    prefisso_file = 'AS_';
    sig_SanivsT0  = zeros(1, n_task);
    sig_SanivsT1  = zeros(1, n_task);
    sig_T0vsT1    = zeros(1, n_task);

    for tt = 1:n_task
        suffisso_file = nomi_task{tt};

        % Sani vs T0
        file_SanivsT0 = sprintf('%sSanivsT0nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
        if exist(file_SanivsT0, 'file')
            tab = readtable(file_SanivsT0);
            parametro = string(tab.Parametro);
            asterisco = string(tab{:, 2});
            idx = find(strcmpi(parametro, nome_indice));
            if ~isempty(idx) && contains(asterisco(idx(1)), '*')
                sig_SanivsT0(tt) = 1;
            end
        end
        %{
        % Sani vs T1
        file_SanivsT1 = sprintf('%sSanivsT1nonAffetto_%s.xlsx', prefisso_file, suffisso_file);
        if exist(file_SanivsT1, 'file')
            tab = readtable(file_SanivsT1);
            parametro = string(tab.Parametro);
            asterisco = string(tab{:, 2});
            idx = find(strcmpi(parametro, nome_indice));
            if ~isempty(idx) && contains(asterisco(idx(1)), '*')
                sig_SanivsT1(tt) = 1;
            end
        end
        %}
        % T0 vs T1
        file_T0vsT1 = sprintf('%snonAffettoT0vsT1_%s.xlsx', prefisso_file, suffisso_file);
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

    %% 3. GENERAZIONE GRAFICO (3 BARRE PER TASK)
    dati_plot = [media_Sani', media_T0', media_T1'];
    std_plot  = [std_Sani', std_T0', std_T1'];

    figure('Color', [1 1 1], 'Position', [100 100 950 550]);

    % Disegno delle 3 barre affiancate
    b = bar(dati_plot, 'grouped');
    hold on;
    b(1).FaceColor = [0.20, 0.60, 0.85]; % Blu Sani
    b(2).FaceColor = [0.85, 0.30, 0.30]; % Rosso T0
    b(3).FaceColor = [0.50, 0.20, 0.60]; % Viola T1

    % Coordinate X e barre d'errore
    nbars   = size(dati_plot, 2);
    ngroups = size(dati_plot, 1);
    x_pos   = zeros(ngroups, nbars);

    for i = 1:nbars
        x_pos(:, i) = b(i).XEndPoints;
        errorbar(x_pos(:, i), dati_plot(:, i), std_plot(:, i), 'k.', 'LineWidth', 1.5, 'CapSize', 6);
    end

    % Calcolo range verticale
    max_val = max(dati_plot(:) + std_plot(:), [], 'omitnan');
    min_val = min(dati_plot(:) - std_plot(:), [], 'omitnan');
    range_y = max_val - min_val;
    if range_y == 0, range_y = 1; end

    %% 4. AFFINAMENTO GRIGLIA, PONTI DI SIGNIFICATIVITÀ E FORMATTAZIONE ASSI
    ax = gca;

    % Label e Titoli
    set(ax, 'XTick', 1:ngroups, 'XTickLabel', nomi_task_plot, 'FontSize', 11, 'FontWeight', 'bold');
    xtickangle(25);
    ylabel(sprintf('Skewness'), 'FontSize', 12, 'FontWeight', 'bold');
    title(sprintf('Andamento della Skewness %s ± SD, Lato non Affetto', tratto_corrente), 'FontSize', 14, 'FontWeight', 'bold');

    % Limiti Y arrotondati con margine per le barrette in alto
    y_min_lim = floor((min_val - range_y * 0.12) * 10) / 10;
    y_max_lim = ceil((max_val + range_y * 0.35) * 10) / 10;
    ylim([y_min_lim, y_max_lim]);

    % Griglia orizzontale fissa ogni 0.2
    yticks(y_min_lim:0.2:y_max_lim);
    set(ax, 'YGrid', 'on', 'YMinorGrid', 'off', 'XGrid', 'off', 'XMinorGrid', 'off');
    ax.GridLineStyle = ':';
    ax.GridAlpha     = 0.45;
    ax.GridColor     = [0.25 0.25 0.25];
    ax.LineWidth     = 0.9;

    % Disegno delle barrette (ponti) di significatività
    h_tick = range_y * 0.015;

    for g = 1:ngroups
        x_sani = x_pos(g, 1);
        x_t0   = x_pos(g, 2);
        x_t1   = x_pos(g, 3);

        % Quota iniziale spostata nettamente sopra (+0.20 * range_y) il top delle barre d'errore
        y_curr = max([dati_plot(g,1)+std_plot(g,1), dati_plot(g,2)+std_plot(g,2), dati_plot(g,3)+std_plot(g,3)]) + range_y * 0.1;

        % Ponte: Sani vs T0
        if sig_SanivsT0(g) == 1
            plot([x_sani, x_sani, x_t0, x_t0], [y_curr - h_tick, y_curr, y_curr, y_curr - h_tick], 'k-', 'LineWidth', 1.2);
            text((x_sani + x_t0)/2, y_curr + range_y*0.03, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Clipping', 'off');
            y_curr = y_curr + range_y * 0.12;
        end

        % Ponte: Sani vs T1
        if sig_SanivsT1(g) == 1
            plot([x_sani, x_sani, x_t1, x_t1], [y_curr - h_tick, y_curr, y_curr, y_curr - h_tick], 'k-', 'LineWidth', 1.2);
            text((x_sani + x_t1)/2, y_curr + range_y*0.03, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Clipping', 'off');
            y_curr = y_curr + range_y * 0.12;
        end

        % Ponte: T0 vs T1
        if sig_T0vsT1(g) == 1
            plot([x_t0, x_t0, x_t1, x_t1], [y_curr - h_tick, y_curr, y_curr, y_curr - h_tick], 'k-', 'LineWidth', 1.2);
            text((x_t0 + x_t1)/2, y_curr + range_y*0.03, '*', 'FontSize', 16, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'Clipping', 'off');
        end
    end

    % Legenda in alto a sinistra
    lgd = legend([b(1), b(2), b(3)], {'Sani', 'T0', 'T1'}, 'Location', 'northwest', 'FontSize', 11);
    set(lgd, 'FontWeight', 'bold');

    hold off;

    % Salvataggio automatico delle immagini
    nome_file_out = sprintf('skewness_%s.png', tratto_corrente);
    exportgraphics(gcf, nome_file_out, 'Resolution', 300);
end