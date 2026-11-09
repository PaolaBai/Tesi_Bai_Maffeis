clear; clc; close all;

%% 1. CARICAMENTO DATI
load('Implementazione_ROM.mat');
info_soggetti = readtable('Tabella lato affetto.xlsx');

id_sano = {'H002', 'H003', 'H004', 'H005', 'H006', 'H008', 'H009', 'H010', 'H011', 'H013', 'H016', 'H017', 'H018'};
id_patologico = {'S001', 'S004', 'S011', 'S012', 'S013', 'S014', 'S015', 'S025', 'S026', 'S027', 'S028', 'S031', 'S032', 'S034', 'S036', 'S037', 'S041', 'S046', 'S047'};
task_motori = {'Addu', 'Addu_orizz', 'Flex', 'Circ', 'RandG'};
sottocartelle4 = {'Right', 'Left'};

t_norm = 0:100; % 101 punti percentuali (0% - 100%)
angolo_target = 'angolo_spalla_medio';

% Inizializzazione colonne tabella
Task_col     = {};
Soggetto_col = {};
Lato_col     = {};
Ciclo_col    = {};
Istante_col  = [];
Gruppo_col   = {};
Angolo_col   = [];

%% 2. ESTRAZIONE SANI
for jj = 1:length(id_sano)
    sog = id_sano{jj};
    
    for ll = 1:length(task_motori)
        task = task_motori{ll};
        
        if isfield(Database_angoli_articolari.Sani, sog) && ...
           isfield(Database_angoli_articolari.Sani.(sog), task)
            
            % CASO 1: ADDU, ADDU_ORIZZ, FLEX
            if ismember(task, {'Addu', 'Addu_orizz', 'Flex'})
                for mm = 1:length(sottocartelle4)
                    lato = sottocartelle4{mm};
                    if isfield(Database_angoli_articolari.Sani.(sog).(task), lato) && ...
                       isfield(Database_angoli_articolari.Sani.(sog).(task).(lato), 'Totale')
                        
                        cicli = fieldnames(Database_angoli_articolari.Sani.(sog).(task).(lato).Totale);
                        for c = 1:length(cicli)
                            if startsWith(cicli{c}, 'Ciclo_')
                                vettore_ang = Database_angoli_articolari.Sani.(sog).(task).(lato).Totale.(cicli{c}).(angolo_target);
                                t_orig = linspace(0, 100, length(vettore_ang));
                                ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');
                                
                                Task_col     = [Task_col; repmat({task}, 101, 1)];
                                Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                                Lato_col     = [Lato_col; repmat({lato}, 101, 1)];
                                Ciclo_col    = [Ciclo_col; repmat(cicli(c), 101, 1)];
                                Istante_col  = [Istante_col; (0:100)'];
                                Gruppo_col   = [Gruppo_col; repmat({'Sano'}, 101, 1)];
                                Angolo_col   = [Angolo_col; ang_101(:)];
                            end
                        end
                    end
                end
                
            % CASO 2: CIRCONDUZIONI (Circ_avanti e Circ_indietro)
            elseif strcmp(task, 'Circ')
                sensi = {'avanti', 'indietro'};
                lati_c = {'R', 'L'};
                
                for ss = 1:length(sensi)
                    senso_curr = sensi{ss};
                    task_label = ['Circ_' senso_curr];
                    
                    for mm = 1:length(lati_c)
                        lato_folder = sprintf('%s_%s', lati_c{mm}, senso_curr);
                        
                        if isfield(Database_angoli_articolari.Sani.(sog).Circ, lato_folder) && ...
                           isfield(Database_angoli_articolari.Sani.(sog).Circ.(lato_folder), 'Totale')
                            
                            cicli = fieldnames(Database_angoli_articolari.Sani.(sog).Circ.(lato_folder).Totale);
                            for c = 1:length(cicli)
                                if startsWith(cicli{c}, 'Ciclo_')
                                    vettore_ang = Database_angoli_articolari.Sani.(sog).Circ.(lato_folder).Totale.(cicli{c}).(angolo_target);
                                    t_orig = linspace(0, 100, length(vettore_ang));
                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');
                                    
                                    Task_col     = [Task_col; repmat({task_label}, 101, 1)];
                                    Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                                    Lato_col     = [Lato_col; repmat({lato_folder}, 101, 1)];
                                    Ciclo_col    = [Ciclo_col; repmat(cicli(c), 101, 1)];
                                    Istante_col  = [Istante_col; (0:100)'];
                                    Gruppo_col   = [Gruppo_col; repmat({'Sano'}, 101, 1)];
                                    Angolo_col   = [Angolo_col; ang_101(:)];
                                end
                            end
                        end
                    end
                end
                
            % CASO 3: REACH AND GRASP (Reach)
            elseif strcmp(task, 'RandG')
                if isfield(Database_angoli_articolari.Sani.(sog).RandG, 'Reach') && ...
                   isfield(Database_angoli_articolari.Sani.(sog).RandG.Reach, 'Totale') && ...
                   isfield(Database_angoli_articolari.Sani.(sog).RandG.Reach.Totale, 'Totale')
                    
                    cicli = fieldnames(Database_angoli_articolari.Sani.(sog).RandG.Reach.Totale.Totale);
                    for c = 1:length(cicli)
                        if startsWith(cicli{c}, 'Ciclo_')
                            vettore_ang = Database_angoli_articolari.Sani.(sog).RandG.Reach.Totale.Totale.(cicli{c}).(angolo_target);
                            t_orig = linspace(0, 100, length(vettore_ang));
                            ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');
                            
                            Task_col     = [Task_col; repmat({'Reach'}, 101, 1)];
                            Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                            Lato_col     = [Lato_col; repmat({'Reach'}, 101, 1)];
                            Ciclo_col    = [Ciclo_col; repmat(cicli(c), 101, 1)];
                            Istante_col  = [Istante_col; (0:100)'];
                            Gruppo_col   = [Gruppo_col; repmat({'Sano'}, 101, 1)];
                            Angolo_col   = [Angolo_col; ang_101(:)];
                        end
                    end
                end
            end
            
        end
    end
end

%% 3. ESTRAZIONE PATOLOGICI (T0 e T1 - LATO AFFETTO)
timepoints = {'T0', 'T1'};

for jj = 1:length(id_patologico)
    sog = id_patologico{jj};
    riga_soggetto = strcmp(info_soggetti{:, 1}, sog);
    
    if any(riga_soggetto)
        lato_affetto_str = info_soggetti{riga_soggetto, 2};
        is_DX = contains(string(lato_affetto_str), 'DX', 'IgnoreCase', true);
        
        if is_DX
            lato_std = 'Right';
            str_lato_c = 'R';
        else
            lato_std = 'Left';
            str_lato_c = 'L';
        end
        
        for tp = 1:length(timepoints)
            timepoint = timepoints{tp};
            
            for ll = 1:length(task_motori)
                task = task_motori{ll};
                
                if isfield(Database_angoli_articolari.Patologici, sog) && ...
                   isfield(Database_angoli_articolari.Patologici.(sog), timepoint) && ...
                   isfield(Database_angoli_articolari.Patologici.(sog).(timepoint), task)
                    
                    % CASO 1: ADDU, ADDU_ORIZZ, FLEX
                    if ismember(task, {'Addu', 'Addu_orizz', 'Flex'})
                        if isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).(task), lato_std) && ...
                           isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).(task).(lato_std), 'Totale')
                            
                            cicli = fieldnames(Database_angoli_articolari.Patologici.(sog).(timepoint).(task).(lato_std).Totale);
                            for c = 1:length(cicli)
                                if startsWith(cicli{c}, 'Ciclo_')
                                    vettore_ang = Database_angoli_articolari.Patologici.(sog).(timepoint).(task).(lato_std).Totale.(cicli{c}).(angolo_target);
                                    t_orig = linspace(0, 100, length(vettore_ang));
                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');
                                    
                                    Task_col     = [Task_col; repmat({task}, 101, 1)];
                                    Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                                    Lato_col     = [Lato_col; repmat({lato_std}, 101, 1)];
                                    Ciclo_col    = [Ciclo_col; repmat(cicli(c), 101, 1)];
                                    Istante_col  = [Istante_col; (0:100)'];
                                    Gruppo_col   = [Gruppo_col; repmat({timepoint}, 101, 1)];
                                    Angolo_col   = [Angolo_col; ang_101(:)];
                                end
                            end
                        end
                        
                    % CASO 2: CIRCONDUZIONI (Circ_avanti e Circ_indietro)
                    elseif strcmp(task, 'Circ')
                        sensi = {'avanti', 'indietro'};
                        
                        for ss = 1:length(sensi)
                            senso_curr = sensi{ss};
                            task_label = ['Circ_' senso_curr];
                            lato_folder = sprintf('%s_%s', str_lato_c, senso_curr);
                            
                            if isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).Circ, lato_folder) && ...
                               isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).Circ.(lato_folder), 'Totale')
                                
                                cicli = fieldnames(Database_angoli_articolari.Patologici.(sog).(timepoint).Circ.(lato_folder).Totale);
                                for c = 1:length(cicli)
                                    if startsWith(cicli{c}, 'Ciclo_')
                                        vettore_ang = Database_angoli_articolari.Patologici.(sog).(timepoint).Circ.(lato_folder).Totale.(cicli{c}).(angolo_target);
                                        t_orig = linspace(0, 100, length(vettore_ang));
                                        ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');
                                        
                                        Task_col     = [Task_col; repmat({task_label}, 101, 1)];
                                        Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                                        Lato_col     = [Lato_col; repmat({lato_folder}, 101, 1)];
                                        Ciclo_col    = [Ciclo_col; repmat(cicli(c), 101, 1)];
                                        Istante_col  = [Istante_col; (0:100)'];
                                        Gruppo_col   = [Gruppo_col; repmat({timepoint}, 101, 1)];
                                        Angolo_col   = [Angolo_col; ang_101(:)];
                                    end
                                end
                            end
                        end
                        
                    % CASO 3: REACH AND GRASP (Reach)
                    elseif strcmp(task, 'RandG')
                        if isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG, 'Reach') && ...
                           isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.Reach, 'Totale') && ...
                           isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.Reach.Totale, 'Totale')
                            
                            cicli = fieldnames(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.Reach.Totale.Totale);
                            for c = 1:length(cicli)
                                if startsWith(cicli{c}, 'Ciclo_')
                                    vettore_ang = Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.Reach.Totale.Totale.(cicli{c}).(angolo_target);
                                    t_orig = linspace(0, 100, length(vettore_ang));
                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');
                                    
                                    Task_col     = [Task_col; repmat({'Reach'}, 101, 1)];
                                    Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                                    Lato_col     = [Lato_col; repmat({'Reach'}, 101, 1)];
                                    Ciclo_col    = [Ciclo_col; repmat(cicli(c), 101, 1)];
                                    Istante_col  = [Istante_col; (0:100)'];
                                    Gruppo_col   = [Gruppo_col; repmat({timepoint}, 101, 1)];
                                    Angolo_col   = [Angolo_col; ang_101(:)];
                                end
                            end
                        end
                    end
                    
                end
            end
        end
    end
end

%% 4. CREAZIONE TABELLA ED ESPORTAZIONE EXCEL
T_out = table(Task_col, Soggetto_col, Lato_col, Ciclo_col, Istante_col, Gruppo_col, Angolo_col, ...
    'VariableNames', {'Task', 'Soggetto', 'Lato', 'Ciclo', 'Istante', 'Gruppo', 'Angolo_deg'});

output_excel = 'Dati_SPM_Spalla.xlsx';
writetable(T_out, output_excel, 'Sheet', 'SPM_ALL');