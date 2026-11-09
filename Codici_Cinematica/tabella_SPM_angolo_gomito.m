clear; clc; close all;

%% 1. CARICAMENTO DATI BASE
load('Implementazione_ROM.mat');
info_soggetti = readtable('Tabella lato affetto.xlsx');

id_sano = {'H002', 'H003', 'H004', 'H005', 'H006', 'H008', 'H009', 'H010', 'H011', 'H013', 'H016', 'H017', 'H018'};
id_patologico = {'S001', 'S004', 'S011', 'S012', 'S013', 'S014', 'S015', 'S025', 'S026', 'S027', 'S028', 'S031', 'S032', 'S034', 'S036', 'S037', 'S041', 'S046', 'S047'};

angolo_target = 'angolo_gomito_medio';
excel_filename = 'Dati_SPM_Gomito.xlsx';
t_norm = 0:100;

Task_col = {}; Soggetto_col = {}; Lato_col = {}; Ciclo_col = {}; 
Istante_col = []; Gruppo_col = {}; Angolo_col = [];

%% 2. ESTRAZIONE SANI (solo RandG -> Reach e Grasp)
for jj = 1:length(id_sano)
    sog = id_sano{jj};
    if isfield(Database_angoli_articolari.Sani, sog) && isfield(Database_angoli_articolari.Sani.(sog), 'RandG')
        sub_tasks = {'Reach', 'Grasp'};
        for st = 1:length(sub_tasks)
            sub_t = sub_tasks{st};
            if isfield(Database_angoli_articolari.Sani.(sog).RandG, sub_t) && ...
                    isfield(Database_angoli_articolari.Sani.(sog).RandG.(sub_t), 'Totale') && ...
                    isfield(Database_angoli_articolari.Sani.(sog).RandG.(sub_t).Totale, 'Totale')

                cicli = fieldnames(Database_angoli_articolari.Sani.(sog).RandG.(sub_t).Totale.Totale);
                for c = 1:length(cicli)
                    if startsWith(cicli{c}, 'Ciclo_')
                        vettore_ang = Database_angoli_articolari.Sani.(sog).RandG.(sub_t).Totale.Totale.(cicli{c}).(angolo_target);
                        ang_101 = interp1(linspace(0,100,length(vettore_ang)), vettore_ang, t_norm, 'spline');

                        Task_col = [Task_col; repmat({sub_t}, 101, 1)]; Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                        Lato_col = [Lato_col; repmat({sub_t}, 101, 1)]; Ciclo_col = [Ciclo_col; repmat(cicli(c), 101, 1)];
                        Istante_col = [Istante_col; (0:100)']; Gruppo_col = [Gruppo_col; repmat({'Sano'}, 101, 1)];
                        Angolo_col = [Angolo_col; ang_101(:)];
                    end
                end
            end
        end
    end
end

%% 3. ESTRAZIONE PATOLOGICI (T0 e T1)
timepoints = {'T0', 'T1'};
for jj = 1:length(id_patologico)
    sog = id_patologico{jj};
    riga_soggetto = strcmp(info_soggetti{:, 1}, sog);
    if any(riga_soggetto)
        for tp = 1:length(timepoints)
            timepoint = timepoints{tp};
            if isfield(Database_angoli_articolari.Patologici, sog) && ...
                    isfield(Database_angoli_articolari.Patologici.(sog), timepoint) && ...
                    isfield(Database_angoli_articolari.Patologici.(sog).(timepoint), 'RandG')

                sub_tasks = {'Reach', 'Grasp'};
                for st = 1:length(sub_tasks)
                    sub_t = sub_tasks{st};
                    if isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG, sub_t) && ...
                            isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.(sub_t), 'Totale') && ...
                            isfield(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.(sub_t).Totale, 'Totale')

                        cicli = fieldnames(Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.(sub_t).Totale.Totale);
                        for c = 1:length(cicli)
                            if startsWith(cicli{c}, 'Ciclo_')
                                vettore_ang = Database_angoli_articolari.Patologici.(sog).(timepoint).RandG.(sub_t).Totale.Totale.(cicli{c}).(angolo_target);
                                ang_101 = interp1(linspace(0,100,length(vettore_ang)), vettore_ang, t_norm, 'spline');

                                Task_col = [Task_col; repmat({sub_t}, 101, 1)]; Soggetto_col = [Soggetto_col; repmat({sog}, 101, 1)];
                                Lato_col = [Lato_col; repmat({sub_t}, 101, 1)]; Ciclo_col = [Ciclo_col; repmat(cicli(c), 101, 1)];
                                Istante_col = [Istante_col; (0:100)']; Gruppo_col = [Gruppo_col; repmat({timepoint}, 101, 1)];
                                Angolo_col = [Angolo_col; ang_101(:)];
                            end
                        end
                    end
                end
            end
        end
    end
end

%% 4. SALVATAGGIO
T_out = table(Task_col, Soggetto_col, Lato_col, Ciclo_col, Istante_col, Gruppo_col, Angolo_col, ...
    'VariableNames', {'Task', 'Soggetto', 'Lato', 'Ciclo', 'Istante', 'Gruppo', 'Angolo_deg'});
writetable(T_out, excel_filename, 'Sheet', 'SPM_ALL');
fprintf('File %s creato con successo!\n', excel_filename);