clear
close all
clc

%%

nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro', 'Reach', 'Grasp'};

nomi_indici = {'jerkMean_Acc_Andata', 'jerkMean_Dec_Andata', 'jerkMean_Andata', 'jerkMean_Acc_Ritorno', 'jerkMean_Dec_Ritorno', 'jerkMean_Ritorno',...
    'jerkPeak_Acc_Andata', 'jerkPeak_Dec_Andata', 'jerkPeak_Andata', 'jerkPeak_AccRitorno', 'jerkPeak_Dec_Ritorno', 'jerkPeak_Ritorno',...
    'LDLJ_Acc_Andata', 'LDLJ_Dec_Andata', 'LDLJ_Andata', 'LDLJ_Acc_Ritorno', 'LDLJ_Dec_Ritorno', 'LDLJ_Ritorno', 'SPARC_Acc_Andata', 'SPARC_Dec_Andata', 'SPARC_Andata',...
    'SPARC_Acc_Ritorno', 'SPARC_Dec_Ritorno', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', 'Angolo gomito', 'ROM_gomito',...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

n_task = length(nomi_task);
n_indici = length(nomi_indici);

prefisso_file = 'AS_SanivsT0Affetto_';
matrice_heatmap = zeros(n_indici, n_task);

%%

for ii = 1:n_task
    task_corrente = nomi_task{ii};
    file_corrente = sprintf('%s%s.xlsx', prefisso_file, task_corrente);

    if exist(file_corrente, 'file')
        tabella_excel = readtable(file_corrente);

        parametro = string(tabella_excel.Parametro);
        asterisco = string(tabella_excel.Sani);        % da cambiare a seconda della colonna

        for jj = 1:n_indici
            parametro_corrente = nomi_indici{jj};

            idx = find(strcmp(parametro, parametro_corrente));

            if ~isempty(idx)
                testo_dato = asterisco(idx(1));

                if contains(testo_dato, '*')
                    matrice_heatmap(jj, ii) = 2;        % significativo
                else 
                    matrice_heatmap(jj, ii) = 1;        % non significativo
                end
            else
                matrice_heatmap(jj, ii) = 0;        % manca l'indice
            end
        end
    end
end

%% Creazione della Heatmap con grafico ad immagini (imagesc)

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
    'XTick', 1:n_task, 'XTickLabel', strrep(nomi_task, '_', ' '), ...
    'YTick', 1:n_indici, 'YTickLabel', strrep(nomi_indici, '_', ' '), ...
    'TickLength', [0 0], 'FontSize', 8);

xtickangle(45);
title('Significatività Sani vs Lato Affetto T0', 'FontSize', 11, 'FontWeight', 'bold');

% Griglia Bianca
for x = 0.5:1:(n_task + 0.5)
    line([x x], [0.5 n_indici + 0.5], 'Color', 'w', 'LineWidth', 1.5);
end
for y = 0.5:1:(n_indici + 0.5)
    line([0.5 n_task + 0.5], [y y], 'Color', 'w', 'LineWidth', 1.5);
end

hold off;

exportgraphics(gcf, 'Significatività_SanivsT0Affetto.png', 'Resolution', 300);

