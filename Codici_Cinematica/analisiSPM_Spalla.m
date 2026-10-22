clear; clc; close all;

%% 1. PARAMETRI GENERALI
inputFile = 'Dati_SPM_Spalla.xlsx';

% Lista dei 3 confronti da eseguire in sequenza
lista_confronti = {'Sani_vs_T0', 'Sani_vs_T1', 'T0_vs_T1'};

% Lista dei 6 task per la spalla
elenco_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro', 'Reach'};

alpha = 0.05;

if ~isfile(inputFile)
    error('File %s non trovato. Esegui prima lo script Genera_Dati_SPM_Completi.m!', inputFile);
end

T = readtable(inputFile, 'Sheet', 'SPM_ALL', 'VariableNamingRule', 'preserve');

%% 2. LOOP SUI CONFRONTI (Sani vs T0, Sani vs T1, T0 vs T1)
for c_idx = 1:length(lista_confronti)
    confronto = lista_confronti{c_idx};
    
    Task_Out          = {};
    Confronto_Out     = {};
    Significativo_Out = {};
    N_Cluster_Out     = [];
    Range_Percent_Out = {};
    P_Value_Out       = {};
    Direzione_Out     = {};

    %% 3. LOOP SU TUTTI E 6 I TASK PER LA SPALLA
    for k = 1:length(elenco_task)
        task_curr = elenco_task{k};
        
        T_task = T(string(T.Task) == task_curr, :);
        
        if isempty(T_task)
            continue;
        end
        
        % Selezione della logica e del test in base al confronto
        switch confronto
            case 'Sani_vs_T0'
                Y_A = calcola_curve_medie_soggetti(T_task, 'Sano');
                Y_B = calcola_curve_medie_soggetti(T_task, 'T0');
                spm = spm1d.stats.ttest2(Y_B, Y_A);
                label_A = 'T0'; label_B = 'Sani';
                
            case 'Sani_vs_T1'
                Y_A = calcola_curve_medie_soggetti(T_task, 'Sano');
                Y_B = calcola_curve_medie_soggetti(T_task, 'T1');
                spm = spm1d.stats.ttest2(Y_B, Y_A);
                label_A = 'T1'; label_B = 'Sani';
                
            case 'T0_vs_T1'
                [Y_A, Y_B] = calcola_curve_appaiate_T0_T1(T_task);
                spm = spm1d.stats.ttest_paired(Y_A, Y_B);
                label_A = 'T0'; label_B = 'T1';
        end
        
        % Inferenza SPM1D
        spmi = spm.inference(alpha, 'two_tailed', true, 'interp', true);
        
        % ----------------------------------------------------
        % GENERAZIONE E SALVATAGGIO GRAFICO CON "_Spalla"
        % ----------------------------------------------------
        figSPM = figure('Color', 'w', 'Visible', 'off');
        
        spmi.plot();
        spmi.plot_threshold_label();
        spmi.plot_p_values();
        
        xlabel('Ciclo di Movimento (%)', 'FontSize', 11, 'FontWeight', 'bold');
        ylabel('SPM {t}', 'FontSize', 11, 'FontWeight', 'bold');
        title(sprintf('SPM1D Spalla: %s (%s)', strrep(task_curr, '_', ' '), strrep(confronto, '_', ' ')), ...
              'FontSize', 12, 'FontWeight', 'bold');
        
        grid on; box off;
        
        % Nome del grafico con _Spalla
        nome_grafico = sprintf('Grafico_SPM_Spalla_%s_%s.png', task_curr, confronto);
        exportgraphics(figSPM, nome_grafico, 'Resolution', 300);
        close(figSPM);
        
        % ----------------------------------------------------
        % POPOLAMENTO TABELLA RISULTATI
        % ----------------------------------------------------
        Task_Out{end+1, 1}      = task_curr;
        Confronto_Out{end+1, 1} = confronto;
        
        if spmi.h0reject
            Significativo_Out{end+1, 1} = 'SI';
            N_Cluster_Out(end+1, 1)     = spmi.nClusters;
            
            str_range = "";
            str_p = "";
            str_dir = "";
            
            for cl_idx = 1:spmi.nClusters
                cl = spmi.clusters{cl_idx};
                
                start_p = cl.endpoints(1);
                end_p   = cl.endpoints(2);
                
                str_range = str_range + sprintf('[%.1f%% - %.1f%%]', start_p, end_p);
                str_p     = str_p + sprintf('p = %.3f', cl.P);
                
                if cl.csign > 0
                    str_dir = str_dir + sprintf('%s > %s', label_A, label_B);
                else
                    str_dir = str_dir + sprintf('%s < %s', label_A, label_B);
                end
                
                if cl_idx < spmi.nClusters
                    str_range = str_range + " ; ";
                    str_p     = str_p + " ; ";
                    str_dir   = str_dir + " ; ";
                end
            end
            
            Range_Percent_Out{end+1, 1} = char(str_range);
            P_Value_Out{end+1, 1}       = char(str_p);
            Direzione_Out{end+1, 1}     = char(str_dir);
        else
            Significativo_Out{end+1, 1} = 'NO';
            N_Cluster_Out(end+1, 1)     = 0;
            Range_Percent_Out{end+1, 1} = 'N.S.';
            P_Value_Out{end+1, 1}       = 'N.S.';
            Direzione_Out{end+1, 1}     = 'N.S.';
        end
    end

    %% 4. CREAZIONE E SALVATAGGIO EXCEL CON "_Spalla"
    T_risultati = table(Task_Out, Confronto_Out, Significativo_Out, N_Cluster_Out, ...
                        Range_Percent_Out, P_Value_Out, Direzione_Out, ...
                        'VariableNames', {'Task', 'Confronto', 'Significativo', 'N_Cluster', ...
                                          'Range_Ciclo_Percent', 'P_Value', 'Direzione'});

    output_summary = sprintf('Risultati_SPM_Spalla_%s.xlsx', confronto);
    writetable(T_risultati, output_summary);
end

%% ============================================================
% FUNZIONI DI SUPPORTO (DEFINITE UNA SOLA VOLTA IN FONDO)
%% ============================================================

function Y_mean = calcola_curve_medie_soggetti(T_sub, gruppo_str)
    T_grp = T_sub(string(T_sub.Gruppo) == gruppo_str, :);
    soggetti = unique(string(T_grp.Soggetto), 'stable');
    nSog = numel(soggetti);
    Y_mean = nan(nSog, 101);
    
    for s = 1:nSog
        T_sog = T_grp(string(T_grp.Soggetto) == soggetti(s), :);
        for t = 0:100
            Y_mean(s, t+1) = mean(T_sog.Angolo_deg(T_sog.Istante == t), 'omitnan');
        end
    end
end

function [Y_T0_mean, Y_T1_mean] = calcola_curve_appaiate_T0_T1(T_sub)
    sog_T0 = unique(string(T_sub.Soggetto(string(T_sub.Gruppo) == "T0")), 'stable');
    sog_T1 = unique(string(T_sub.Soggetto(string(T_sub.Gruppo) == "T1")), 'stable');
    soggetti = intersect(sog_T0, sog_T1, 'stable');
    nSog = numel(soggetti);
    
    Y_T0_mean = nan(nSog, 101);
    Y_T1_mean = nan(nSog, 101);
    
    for s = 1:nSog
        T_T0 = T_sub(string(T_sub.Soggetto) == soggetti(s) & string(T_sub.Gruppo) == "T0", :);
        T_T1 = T_sub(string(T_sub.Soggetto) == soggetti(s) & string(T_sub.Gruppo) == "T1", :);
        for t = 0:100
            Y_T0_mean(s, t+1) = mean(T_T0.Angolo_deg(T_T0.Istante == t), 'omitnan');
            Y_T1_mean(s, t+1) = mean(T_T1.Angolo_deg(T_T1.Istante == t), 'omitnan');
        end
    end
end