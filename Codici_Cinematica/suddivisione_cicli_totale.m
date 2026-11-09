clear
close all
clc

%% cartella principale e sottocartelle
cartella_principale = 'C:\Users\pao02\OneDrive\Documenti\PoliMi\magistrale\anno 2\2\tesi magistrale\Codici';

%% inizializzazione struct Segmentazione

Segmentazione = struct();

% sottocartelle
gruppo = {'Sani', 'Patologici'};
id_sano = {'H002', 'H003', 'H004', 'H005', 'H006', 'H008', 'H009', 'H010', 'H011', 'H013', 'H016', 'H017', 'H018'};
id_patologico = {'S001', 'S004', 'S011', 'S012', 'S013', 'S014', 'S015', 'S025', 'S026', 'S027', 'S028', 'S031', 'S032', 'S034', 'S036', 'S037', 'S041', 'S046', 'S047'};
timepoint_sano = {'T'};     % timepoint fittizio necessario per avere sottocartelle come patologici
timepoint_patologico = {'T0', 'T1'};
task_motori = {'Addu', 'Addu_orizz', 'Flex', 'Circ', 'RandG'};
sottocartelle1 = {'RUlna', 'LUlna', 'RShoulder', 'LShoulder', 'RElbow', 'LElbow', 'RC7', 'LC7', 'RSacrum', 'LSacrum', ...
    'LShoulder_tDX', 'RShoulder_tSX'};        % vale per Addu, Addu_orizz, Flex
sottocartelle2 = {'RUlna_avanti', 'RUlna_indietro', 'LUlna_avanti', 'LUlna_indietro', 'RShoulder_avanti',...
    'RShoulder_indietro','LShoulder_avanti','LShoulder_indietro', 'RElbow_avanti','RElbow_indietro', 'LElbow_avanti', ...
    'LElbow_indietro','RC7_avanti','RC7_indietro', 'LC7_avanti','LC7_indietro', 'RSacrum_avanti', 'RSacrum_indietro', ...
    'LSacrum_avanti', 'LSacrum_indietro', 'LShoulder_avanti_tDX', 'RShoulder_avanti_tSX', 'LShoulder_indietro_tDX', 'RShoulder_indietro_tSX'};      % vale per Circ
sottocartelle3 = {'Reach_Ulna', 'Grasp_Ulna', 'Reach_Shoulder', 'Grasp_Shoulder', 'Reach_Elbow', 'Grasp_Elbow', ...
    'Reach_C7', 'Grasp_C7', 'Reach_Sacrum', 'Grasp_Sacrum', 'Reach_OtherShoulder', 'Grasp_OtherShoulder'};     % vale per RandG
sottocartelle_ar = {'Andata', 'Ritorno', 'Totale'};
sottocartelle_ad = {'Accelerazione', 'Decelerazione', 'Totale'};

%% segmentazione sani

for ii = 1:length(gruppo)       % scorro gruppo
    gruppo_corrente = gruppo{ii};
    percorso_gruppo = fullfile(cartella_principale, gruppo_corrente);

    if ii == 1      % sono in sano

        for jj = 1:length(id_sano)          % scorro tra i soggetti
            soggetto_corrente = id_sano{jj};
            percorso_soggetto = fullfile(percorso_gruppo, soggetto_corrente);

            for pp = 1:length(timepoint_sano)
                timepoint_corrente = timepoint_sano{pp};
                percorso_timepoint = fullfile(percorso_soggetto, timepoint_corrente);

                for kk = 1:length(task_motori)          % scorro tra i task
                    task_corrente = task_motori{kk};
                    percorso_task = fullfile(percorso_timepoint, task_corrente);

                    if kk <= 3      % vale per Addu, Addu_orizz, Flex

                        for ll = 1:length(sottocartelle1)            % scorro tra dx e sx
                            lato_corrente = sottocartelle1{ll};

                            if ll == 1      % sono in RUlna

                                file_R_dati = fullfile(percorso_task, ['RUlna_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)         % scorro tra andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2      % sono in LUlna

                                file_L_dati = fullfile(percorso_task, ['LUlna_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 3      % sono in RShoulder

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4      % sono in LShoulder

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5      % sono in RElbow

                                file_R_dati = fullfile(percorso_task, ['RElbow_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 6      % sono in LElbow

                                file_L_dati = fullfile(percorso_task, ['LElbow_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 7      % sono in RC7

                                file_R_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 8      % sono in LC7

                                file_L_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 9      % sono in RSacrum

                                file_R_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 10      % sono in LSacrum

                                file_L_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 11      % sono in LShoulder preso con il tempo di DX

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 12      % sono in RShoulder preso con il tempo di SX

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 4      % vale per Circ

                        for ll = 1:length(sottocartelle2)
                            lato_corrente = sottocartelle2{ll};

                            if ll == 1      % sono in RUlna_avanti

                                file_R_dati = fullfile(percorso_task, ['RUlna_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2      % sono in RUlna_indietro

                                file_R_dati = fullfile(percorso_task, ['RUlna_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 3      % sono in LUlna_avanti

                                file_L_dati = fullfile(percorso_task, ['LUlna_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4      % sono in LUlna_indietro

                                file_L_dati = fullfile(percorso_task, ['LUlna_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5      % sono in RShoulder_avanti

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 6      % sono in RShoulder_indietro

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 7      % sono in LShoulder_avanti

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))       % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 8      % sono in LShoulder_indietro

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 9      % sono in RElbow_avanti

                                file_R_dati = fullfile(percorso_task, ['RElbow_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 10      % sono in RElbow_indietro

                                file_R_dati = fullfile(percorso_task, ['RElbow_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z


                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 11      % sono in LElbow_avanti

                                file_L_dati = fullfile(percorso_task, ['LElbow_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 12      % sono in LElbow_indietro

                                file_L_dati = fullfile(percorso_task, ['LElbow_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 13      % sono in RC7_avanti

                                file_R_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 14      % sono in RC7_indietro

                                file_R_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 15      % sono in LC7_avanti

                                file_L_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 16      % sono in LC7_indietro

                                file_L_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 17      % sono in RSacrum_avanti

                                file_R_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 18      % sono in RSacrum_indietro

                                file_R_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 19      % sono in LSacrum_avanti

                                file_L_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 20      % sono in LSacrum_indietro

                                file_L_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 21      % sono in LShoulder_avanti preso con il tempo di DX

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 22      % sono in RShoulder_avanti preso con il tempo di SX

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 23      % sono in LShoulder_indietro preso con il tempo di DX

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 24      % sono in RShoulder_indietro preso con il tempo di SX

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 5     % vale per RandG

                        for ll = 1:length(sottocartelle3)            % scorro tra Reach e Grasp
                            lato_corrente = sottocartelle3{ll};

                            if ll == 1      % sono in Reach_Ulna

                                file_dati = fullfile(percorso_task, ['Ulna_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_RAndata(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per reach andata (da usare in tutti i reach andata)

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_RRitorno(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per reach ritorno (da usare in tutti i reach ritorno)

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Ulna totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2      % sono in Grasp_Ulna

                                file_dati = fullfile(percorso_task, ['Ulna_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_GAndata(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per grasp andata (da usare in tutti i grasp andata)

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_GRitorno(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per grasp ritorno (da usare in tutti i grasp ritorno)

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Ulna totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 3      % sono in Reach_Shoulder

                                file_dati = fullfile(percorso_task, ['Shoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Shoulder totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4      % sono in Grasp_RShoulder

                                file_dati = fullfile(percorso_task, ['Shoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Shoulder totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5      % sono in Reach_Elbow

                                file_dati = fullfile(percorso_task, ['Elbow_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Elbow totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Elbowr totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Elbow totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 6      % sono in Grasp_Elbow

                                file_dati = fullfile(percorso_task, ['Elbow_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Elbow totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Elbow totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Elbow totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 7      % sono in Reach_C7

                                file_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_C7 totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 8      % sono in Grasp_C7

                                file_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_C7 totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 9      % sono in Reach_Sacrum

                                file_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Sacrum totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 10      % sono in Grasp_Sacrum

                                file_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Sacrum totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 11      % sono in Reach_OtherShoulder

                                file_Ldati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_Rdati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_Ldati, 'file')           % controllo se il file c'è

                                    file_dati = file_Ldati;

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Shoulder totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end

                                elseif exist(file_Rdati, 'file')           % controllo se il file c'è

                                    file_dati = file_Rdati;

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Shoulder totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 12      % sono in Grasp_LShoulder

                                file_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Shoulder totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
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

        %% segmentazione patologici

    elseif ii == 2      % sono in patologico

        for jj = 1:length(id_patologico)          % scorro tra i soggetti
            soggetto_corrente = id_patologico{jj};
            percorso_soggetto = fullfile(percorso_gruppo, soggetto_corrente);

            for pp = 1:length(timepoint_patologico)
                timepoint_corrente = timepoint_patologico{pp};
                percorso_timepoint = fullfile(percorso_soggetto, timepoint_corrente);

                for kk = 1:length(task_motori)          % scorro tra i task
                    task_corrente = task_motori{kk};
                    percorso_task = fullfile(percorso_timepoint, task_corrente);

                    if kk <= 3      % vale per Addu, Addu_orizz, Flex

                        for ll = 1:length(sottocartelle1)            % scorro tra dx e sx
                            lato_corrente = sottocartelle1{ll};

                            if ll == 1      % sono in RUlna

                                file_R_dati = fullfile(percorso_task, ['RUlna_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_cicli, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2      % sono in LUlna

                                file_L_dati = fullfile(percorso_task, ['LUlna_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_cicli, 'file')            % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 3      % sono in RShoulder

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_cicli, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4      % sono in LShoulder

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_cicli, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5      % sono in RElbow

                                file_R_dati = fullfile(percorso_task, ['RElbow_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_cicli, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 6      % sono in LElbow

                                file_L_dati = fullfile(percorso_task, ['LElbow_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_cicli, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 7      % sono in RC7

                                file_R_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_cicli, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 8      % sono in LC7

                                file_L_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_cicli, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 9      % sono in RSacrum

                                file_R_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_cicli, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 10      % sono in LSacrum

                                file_L_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_cicli, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 11      % sono in LShoulder preso con il tempo di DX

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_R_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '.emt']);

                                if exist(file_L_dati, 'file') && exist(file_R_cicli, 'file')           % controllo se il file c'è

                                    L_sp = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli = readmatrix(file_R_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_tot = L_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp(:, 2) > t_mid & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp(:, 2) >= t_start & L_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 12      % sono in RShoulder preso con il tempo di SX

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_L_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '.emt']);

                                if exist(file_R_dati, 'file') && exist(file_L_cicli, 'file')           % controllo se il file c'è

                                    R_sp = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli = readmatrix(file_L_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_tot = R_sp(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp(:, 2) > t_mid & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp(:, 2) >= t_start & R_sp(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 4      % vale per Circ

                        for ll = 1:length(sottocartelle2)
                            lato_corrente = sottocartelle2{ll};

                            if ll == 1      % sono in RUlna_avanti

                                file_R_dati = fullfile(percorso_task, ['RUlna_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2      % sono in RUlna_indietro

                                file_R_dati = fullfile(percorso_task, ['RUlna_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')            % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 3      % sono in LUlna_avanti

                                file_L_dati = fullfile(percorso_task, ['LUlna_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4      % sono in LUlna_indietro

                                file_L_dati = fullfile(percorso_task, ['LUlna_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5      % sono in RShoulder_avanti

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 6      % sono in RShoulder_indietro

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 7      % sono in LShoulder_avanti

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 8      % sono in LShoulder_indietro

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 9      % sono in RElbow_avanti

                                file_R_dati = fullfile(percorso_task, ['RElbow_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 10      % sono in RElbow_indietro

                                file_R_dati = fullfile(percorso_task, ['RElbow_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 11      % sono in LElbow_avanti

                                file_L_dati = fullfile(percorso_task, ['LElbow_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 12      % sono in LElbow_indietro

                                file_L_dati = fullfile(percorso_task, ['LElbow_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 13      % sono in RC7_avanti

                                file_R_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 14      % sono in RC7_indietro

                                file_R_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 15      % sono in LC7_avanti

                                file_L_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 16      % sono in LC7_indietro

                                file_L_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 17      % sono in RSacrum_avanti

                                file_R_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 18      % sono in RSacrum_indietro

                                file_R_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 19      % sono in LSacrum_avanti

                                file_L_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 20      % sono in LSacrum_indietro

                                file_L_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 21      % sono in LShoulder_avanti preso con il tempo di DX

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_R_avanti_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_L_dati, 'file') && exist(file_R_avanti_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli_Circ_avanti = readmatrix(file_R_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 22      % sono in RShoulder_avanti preso con il tempo di SX

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_L_avanti_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_avanti.emt']);

                                if exist(file_R_dati, 'file') && exist(file_L_avanti_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli_Circ_avanti = readmatrix(file_L_avanti_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_avanti(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_avanti(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_avanti(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_avanti(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 23      % sono in LShoulder_indietro preso con il tempo di DX

                                file_L_dati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_R_indietro_cicli = fullfile(percorso_task, ['RCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_L_dati, 'file') && exist(file_R_indietro_cicli, 'file')           % controllo se il file c'è

                                    L_sp_Circ = readmatrix(file_L_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    R_cicli_Circ_indietro = readmatrix(file_R_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_L_Circ_tot = L_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = R_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(L_sp_Circ(:, 2) > t_mid & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(R_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = R_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = R_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(L_sp_Circ(:, 2) >= t_start & L_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_L_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 24      % sono in RShoulder_indietro preso con il tempo di SX

                                file_R_dati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_L_indietro_cicli = fullfile(percorso_task, ['LCicli_', task_corrente, '_indietro.emt']);

                                if exist(file_R_dati, 'file') && exist(file_L_indietro_cicli, 'file')           % controllo se il file c'è

                                    R_sp_Circ = readmatrix(file_R_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    L_cicli_Circ_indietro = readmatrix(file_L_indietro_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_R_Circ_tot = R_sp_Circ(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_mid);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 2          % sono in ritorno

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3
                                                t_mid = L_cicli_Circ_indietro(mm, 4);     % tempo di metà ciclo corrente, nella colonna 4

                                                dati_ciclo = find(R_sp_Circ(:, 2) > t_mid & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end

                                        elseif oo == 3          % sono in totale

                                            for mm = 1:length(L_cicli_Circ_indietro(:, 1))        % scorro i 5 cicli

                                                t_start = L_cicli_Circ_indietro(mm, 2);     % tempo di inizio del ciclo corrente, nella colonna 2
                                                t_stop = L_cicli_Circ_indietro(mm, 3);     % tempo di fine del ciclo corrente, nella colonna 3

                                                dati_ciclo = find(R_sp_Circ(:, 2) >= t_start & R_sp_Circ(:, 2) <= t_stop);       % trovare i dati nel range del ciclo
                                                dati_finali = tab_R_Circ_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 5     % vale per RandG

                        for ll = 1:length(sottocartelle3)            % scorro tra Reach e Grasp
                            lato_corrente = sottocartelle3{ll};

                            if ll == 1      % sono in Reach_Ulna

                                file_dati = fullfile(percorso_task, ['Ulna_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')            % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_RAndata(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per reach andata (da usare in tutti i reach andata)

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_RRitorno(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per reach ritorno (da usare in tutti i reach ritorno)

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Ulna totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2      % sono in Grasp_Ulna

                                file_dati = fullfile(percorso_task, ['Ulna_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_GAndata(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per grasp andata (da usare in tutti i grasp andata)

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        [t_picco, norma_v] = tempo_picco(dati_finali);         % tempo relativo alla velocità di picco dell'ulna
                                                        vettore_GRitorno(mm) = t_picco;      % salvataggio dei tempi di picco (5 valori) di ulna per grasp ritorno (da usare in tutti i grasp ritorno)

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Ulna totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Ulna totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 3      % sono in Reach_Shoulder

                                file_dati = fullfile(percorso_task, ['Shoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Shoulder totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4      % sono in Grasp_Shoulder

                                file_dati = fullfile(percorso_task, ['Shoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Shoulder totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5      % sono in Reach_Elbow

                                file_dati = fullfile(percorso_task, ['Elbow_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Elbow totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Elbowr totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Elbow totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 6      % sono in Grasp_Elbow

                                file_dati = fullfile(percorso_task, ['Elbow_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Elbow totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Elbow totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Elbow totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 7      % sono in Reach_C7

                                file_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_C7 totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 8      % sono in Grasp_C7

                                file_dati = fullfile(percorso_task, ['C7_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_C7 totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_C7 totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 9      % sono in Reach_Sacrum

                                file_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Sacrum totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 10      % sono in Grasp_Sacrum

                                file_dati = fullfile(percorso_task, ['Sacrum_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_dati, 'file')           % controllo se il file c'è

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Sacrum totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Sacrum totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 11      % sono in Reach_OtherShoulder

                                file_Ldati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_Rdati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_Ldati, 'file')            % controllo se il file c'è

                                    file_dati = file_Ldati;

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Shoulder totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end

                                elseif exist(file_Rdati, 'file')            % controllo se il file c'è

                                    file_dati = file_Rdati;

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        t_picco = vettore_RAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_startG);       % dati nel range di decelerazione andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                        t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG);       % dati nel range di andata reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        t_picco = vettore_RRitorno(mm);         % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopR);       % dati nel range di accelerazione ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Reach_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                        t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di ritorno reach
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Reach_Shoulder totale (andata + ritorno)

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startR = cicli_RandG(mm, 2);      % tempo di inizio del reach andata, nella colonna 2
                                                t_startG = cicli_RandG(mm, 4);       % tempo di fine del reach andata, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);      % tempo di inizio del reach ritorno, nella colonna 5
                                                t_stopR = cicli_RandG(mm, 3);       % tempo di fine del reach ritorno, nella colonna 3

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startR & sp_RandG(:, 2) < t_startG | sp_RandG(:, 2) > t_stopG & sp_RandG(:, 2) <= t_stopR);       % dati nel range di reach totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end
                                end

                            elseif ll == 12      % sono in Grasp_LShoulder

                                file_Ldati = fullfile(percorso_task, ['LShoulder_', task_corrente, '.emt']);
                                file_Rdati = fullfile(percorso_task, ['RShoulder_', task_corrente, '.emt']);
                                file_cicli = fullfile(percorso_task, ['Cicli_', task_corrente, '.emt']);

                                if exist(file_Ldati, 'file')           % controllo se il file c'è

                                    file_dati = file_Ldati;

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Shoulder totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
                                            end
                                        end
                                    end

                                elseif exist(file_Rdati, 'file')           % controllo se il file c'è

                                    file_dati = file_Rdati;

                                    sp_RandG = readmatrix(file_dati, 'FileType', 'text', 'NumHeaderLines', 11);          % tolgo le righe di parole
                                    cicli_RandG = readmatrix(file_cicli, 'FileType', 'text', 'NumHeaderLines', 8);
                                    tab_RandG_tot = sp_RandG(:, 2:5);       % estrae la colonna di tempo, x, y, z

                                    for oo = 1:length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 1      % sono in andata

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        t_picco = vettore_GAndata(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) < t_mid);       % dati nel range di decelerazione andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in andata Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_startG = cicli_RandG(mm, 4);     % tempo di inizio del grasp andata, nella colonna 4
                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del grasp, nella colonna 6

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) < t_mid);       % dati nel range di andata grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 2      % sono in ritorno

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 1      % sono in accelerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_picco);       % dati nel range di accelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 2      % sono in decellerazione

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        t_picco = vettore_GRitorno(mm);      % valori di picco trovati in precedenza

                                                        dati_ciclo = find(sp_RandG(:, 2) > t_picco & sp_RandG(:, 2) <= t_stopG);       % dati nel range di decelerazione ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end

                                                elseif qq == 3      % sono in ritorno Grasp_Shoulder totale

                                                    for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                        t_mid = cicli_RandG(mm, 6);     % tempo di mid del ciclo corrente, nella colonna 6
                                                        t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                        dati_ciclo = find(sp_RandG(:, 2) >= t_mid & sp_RandG(:, 2) <= t_stopG);       % dati nel range di ritorno grasp
                                                        dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                        nome_ciclo = sprintf('Ciclo_%d', mm);

                                                        Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = dati_finali;
                                                    end
                                                end
                                            end

                                        elseif oo == 3      % sono in Grasp_Shoulder totale

                                            for mm = 1:length(cicli_RandG(:, 1))        % scorro i 5 cicli

                                                t_startG = cicli_RandG(mm, 4);     % tempo di inizio del ciclo corrente, nella colonna 4
                                                t_stopG = cicli_RandG(mm, 5);     % tempo di fine del ciclo corrente, nella colonna 5

                                                dati_ciclo = find(sp_RandG(:, 2) >= t_startG & sp_RandG(:, 2) <= t_stopG);       % dati nel range di grasp totale
                                                dati_finali = tab_RandG_tot(dati_ciclo, :);

                                                nome_ciclo = sprintf('Ciclo_%d', mm);

                                                Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = dati_finali;
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

%% salvataggio struct

save('Suddivisione_cicli_tot.mat', 'Segmentazione');