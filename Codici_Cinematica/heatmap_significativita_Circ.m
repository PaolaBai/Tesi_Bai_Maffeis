clear
close all
clc

%%

nomi_Database1 = {'Sani', 'PatT0', 'PatT1'};

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', ...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

n_Database = length(nomi_Database1);
n_indici = length(nomi_indici);

prefisso_file = 'AS_';
suffisso_file = '_Circ_avanti';
matrice_heatmap = zeros(n_Database, n_indici);

%%

for ii = 1:n_Database
    Database_corrente = nomi_Database1{ii};
    file_corrente = sprintf('%s%s%s.xlsx', prefisso_file, Database_corrente, suffisso_file);

    if exist(file_corrente, 'file')
        tabella_excel = readtable(file_corrente);

        parametro = string(tabella_excel.Parametro);
        asterisco = string(tabella_excel{:, 2});        % controlla la seconda colonna 

        for jj = 1:n_indici
            parametro_corrente = nomi_indici{jj};

            idx = find(strcmp(parametro, parametro_corrente));

            if ~isempty(idx)
                testo_dato = asterisco(idx(1));

                if contains(testo_dato, '*')
                    matrice_heatmap(ii, jj) = 2;        % significativo
                else
                    matrice_heatmap(ii, jj) = 1;        % non significativo
                end
            else
                matrice_heatmap(ii, jj) = 0;        % manca l'indice
            end
        end
    end
end

%% Creazione della Heatmap con grafico ad immagini (imagesc)

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'Skewness_Andata', 'Skewness_Ritorno', 'MA Spalla', 'ROM Spalla', ...
    'MA Tronco Sagittale', 'ROM Tronco Sagittale', 'MA Tronco Frontale', 'ROM Tronco Frontale', 'MA Tronco Torsione', 'ROM Tronco Torsione'};

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.15, 0.1, 0.6, 0.8]);

imagesc(matrice_heatmap);
hold on;

% Mappa Colori e Limiti
colormap([0.88 0.88 0.88;...        % grigio
    0.00 0.20 0.60;...          % blu
    0.85 0.15 0.15]);       % rosso
clim([0 2]);

% Impostazione Assi
set(gca, 'YDir', 'reverse', ...
    'XTick', 1:n_indici, 'XTickLabel', strrep(nomi_indici, '_', ' '), ...
    'YTick', 1:n_Database, 'YTickLabel', strrep(nomi_Database1, '_', ' '), ...
    'TickLength', [0 0], 'FontSize', 8);

xtickangle(45);
title('Significatività Circ avanti', 'FontSize', 11, 'FontWeight', 'bold');

% Griglia Bianca
for x = 0.5:1:(n_indici + 0.5)
    line([x x], [0.5 n_Database + 0.5], 'Color', 'w', 'LineWidth', 1.5);
end
for y = 0.5:1:(n_Database + 0.5)
    line([0.5 n_indici + 0.5], [y y], 'Color', 'w', 'LineWidth', 1.5);
end

hold off;

exportgraphics(gcf, 'Significatività1_Circ_avanti.png', 'Resolution', 300);

%%

nomi_Database2 = {'SanivsT0Affetto', 'SanivsT0nonAffetto', 'SanivsT1Affetto', 'AffettoT0vsT1', 'nonAffettoT0vsT1'};

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', ...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

n_Database = length(nomi_Database2);
n_indici = length(nomi_indici);

prefisso_file = 'AS_';
suffisso_file = '_Circ_avanti';
matrice_heatmap = zeros(n_Database, n_indici);

%%

for ii = 1:n_Database
    Database_corrente = nomi_Database2{ii};
    file_corrente = sprintf('%s%s%s.xlsx', prefisso_file, Database_corrente, suffisso_file);

    if exist(file_corrente, 'file')
        tabella_excel = readtable(file_corrente);

        parametro = string(tabella_excel.Parametro);
        asterisco = string(tabella_excel{:, 2});        % controlla la seconda colonna 

        for jj = 1:n_indici
            parametro_corrente = nomi_indici{jj};

            idx = find(strcmp(parametro, parametro_corrente));

            if ~isempty(idx)
                testo_dato = asterisco(idx(1));

                if contains(testo_dato, '*')
                    matrice_heatmap(ii, jj) = 2;        % significativo
                else
                    matrice_heatmap(ii, jj) = 1;        % non significativo
                end
            else
                matrice_heatmap(ii, jj) = 0;        % manca l'indice
            end
        end
    end
end

%% Creazione della Heatmap con grafico ad immagini (imagesc)

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'Skewness_Andata', 'Skewness_Ritorno', 'MA Spalla', 'ROM Spalla', ...
    'MA Tronco Sagittale', 'ROM Tronco Sagittale', 'MA Tronco Frontale', 'ROM Tronco Frontale', 'MA Tronco Torsione', 'ROM Tronco Torsione'};

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.15, 0.1, 0.6, 0.8]);

imagesc(matrice_heatmap);
hold on;

% Mappa Colori e Limiti
colormap([0.88 0.88 0.88;...        % grigio
    0.00 0.20 0.60;...          % blu
    0.85 0.15 0.15]);       % rosso
clim([0 2]);

% Impostazione Assi
set(gca, 'YDir', 'reverse', ...
    'XTick', 1:n_indici, 'XTickLabel', strrep(nomi_indici, '_', ' '), ...
    'YTick', 1:n_Database, 'YTickLabel', strrep(nomi_Database2, '_', ' '), ...
    'TickLength', [0 0], 'FontSize', 8);

xtickangle(45);
title('Significatività Circ avanti', 'FontSize', 11, 'FontWeight', 'bold');

% Griglia Bianca
for x = 0.5:1:(n_indici + 0.5)
    line([x x], [0.5 n_Database + 0.5], 'Color', 'w', 'LineWidth', 1.5);
end
for y = 0.5:1:(n_Database + 0.5)
    line([0.5 n_indici + 0.5], [y y], 'Color', 'w', 'LineWidth', 1.5);
end

hold off;

exportgraphics(gcf, 'Significatività_Circ_avanti.png', 'Resolution', 300);

%%

nomi_Database1 = {'Sani', 'PatT0', 'PatT1'};

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', ...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

n_Database = length(nomi_Database1);
n_indici = length(nomi_indici);

prefisso_file = 'AS_';
suffisso_file = '_Circ_indietro';
matrice_heatmap = zeros(n_Database, n_indici);

%%

for ii = 1:n_Database
    Database_corrente = nomi_Database1{ii};
    file_corrente = sprintf('%s%s%s.xlsx', prefisso_file, Database_corrente, suffisso_file);

    if exist(file_corrente, 'file')
        tabella_excel = readtable(file_corrente);

        parametro = string(tabella_excel.Parametro);
        asterisco = string(tabella_excel{:, 2});        % controlla la seconda colonna 

        for jj = 1:n_indici
            parametro_corrente = nomi_indici{jj};

            idx = find(strcmp(parametro, parametro_corrente));

            if ~isempty(idx)
                testo_dato = asterisco(idx(1));

                if contains(testo_dato, '*')
                    matrice_heatmap(ii, jj) = 2;        % significativo
                else
                    matrice_heatmap(ii, jj) = 1;        % non significativo
                end
            else
                matrice_heatmap(ii, jj) = 0;        % manca l'indice
            end
        end
    end
end

%% Creazione della Heatmap con grafico ad immagini (imagesc)

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'Skewness_Andata', 'Skewness_Ritorno', 'MA Spalla', 'ROM Spalla', ...
    'MA Tronco Sagittale', 'ROM Tronco Sagittale', 'MA Tronco Frontale', 'ROM Tronco Frontale', 'MA Tronco Torsione', 'ROM Tronco Torsione'};

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.15, 0.1, 0.6, 0.8]);

imagesc(matrice_heatmap);
hold on;

% Mappa Colori e Limiti
colormap([0.88 0.88 0.88;...        % grigio
    0.00 0.20 0.60;...          % blu
    0.85 0.15 0.15]);       % rosso
clim([0 2]);

% Impostazione Assi
set(gca, 'YDir', 'reverse', ...
    'XTick', 1:n_indici, 'XTickLabel', strrep(nomi_indici, '_', ' '), ...
    'YTick', 1:n_Database, 'YTickLabel', strrep(nomi_Database1, '_', ' '), ...
    'TickLength', [0 0], 'FontSize', 8);

xtickangle(45);
title('Significatività Circ indietro', 'FontSize', 11, 'FontWeight', 'bold');

% Griglia Bianca
for x = 0.5:1:(n_indici + 0.5)
    line([x x], [0.5 n_Database + 0.5], 'Color', 'w', 'LineWidth', 1.5);
end
for y = 0.5:1:(n_Database + 0.5)
    line([0.5 n_indici + 0.5], [y y], 'Color', 'w', 'LineWidth', 1.5);
end

hold off;

exportgraphics(gcf, 'Significatività1_Circ_indietro.png', 'Resolution', 300);

%%

nomi_Database2 = {'SanivsT0Affetto', 'SanivsT0nonAffetto', 'SanivsT1Affetto', 'AffettoT0vsT1', 'nonAffettoT0vsT1'};

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', ...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

n_Database = length(nomi_Database2);
n_indici = length(nomi_indici);

prefisso_file = 'AS_';
suffisso_file = '_Circ_indietro';
matrice_heatmap = zeros(n_Database, n_indici);

%%

for ii = 1:n_Database
    Database_corrente = nomi_Database2{ii};
    file_corrente = sprintf('%s%s%s.xlsx', prefisso_file, Database_corrente, suffisso_file);

    if exist(file_corrente, 'file')
        tabella_excel = readtable(file_corrente);

        parametro = string(tabella_excel.Parametro);
        asterisco = string(tabella_excel{:, 2});        % controlla la seconda colonna 

        for jj = 1:n_indici
            parametro_corrente = nomi_indici{jj};

            idx = find(strcmp(parametro, parametro_corrente));

            if ~isempty(idx)
                testo_dato = asterisco(idx(1));

                if contains(testo_dato, '*')
                    matrice_heatmap(ii, jj) = 2;        % significativo
                else
                    matrice_heatmap(ii, jj) = 1;        % non significativo
                end
            else
                matrice_heatmap(ii, jj) = 0;        % manca l'indice
            end
        end
    end
end

%% Creazione della Heatmap con grafico ad immagini (imagesc)

nomi_indici = {'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'Skewness_Andata', 'Skewness_Ritorno', 'MA Spalla', 'ROM Spalla', ...
    'MA Tronco Sagittale', 'ROM Tronco Sagittale', 'MA Tronco Frontale', 'ROM Tronco Frontale', 'MA Tronco Torsione', 'ROM Tronco Torsione'};

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.15, 0.1, 0.6, 0.8]);

imagesc(matrice_heatmap);
hold on;

% Mappa Colori e Limiti
colormap([0.88 0.88 0.88;...        % grigio
    0.00 0.20 0.60;...          % blu
    0.85 0.15 0.15]);       % rosso
clim([0 2]);

% Impostazione Assi
set(gca, 'YDir', 'reverse', ...
    'XTick', 1:n_indici, 'XTickLabel', strrep(nomi_indici, '_', ' '), ...
    'YTick', 1:n_Database, 'YTickLabel', strrep(nomi_Database2, '_', ' '), ...
    'TickLength', [0 0], 'FontSize', 8);

xtickangle(45);
title('Significatività Circ indietro', 'FontSize', 11, 'FontWeight', 'bold');

% Griglia Bianca
for x = 0.5:1:(n_indici + 0.5)
    line([x x], [0.5 n_Database + 0.5], 'Color', 'w', 'LineWidth', 1.5);
end
for y = 0.5:1:(n_Database + 0.5)
    line([0.5 n_indici + 0.5], [y y], 'Color', 'w', 'LineWidth', 1.5);
end

hold off;

exportgraphics(gcf, 'Significatività_Circ_indietro.png', 'Resolution', 300);