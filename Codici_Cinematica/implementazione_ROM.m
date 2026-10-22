clear
close all
clc

%% caricamento struct con dati segmentati

load('Suddivisione_cicli_tot.mat');

%% inizializzazione struct di salvataggio

Database_ROM = struct();
Database_angoli_articolari = struct();

% sottocartelle
gruppo = {'Sani', 'Patologici'};
id_sano = {'H002', 'H003', 'H004', 'H005', 'H006', 'H008', 'H009', 'H010', 'H011', 'H013', 'H016', 'H017', 'H018'};
id_patologico = {'S001', 'S004', 'S011', 'S012', 'S013', 'S014', 'S015', 'S025', 'S026', 'S027', 'S028', 'S031', 'S032', 'S034', 'S036', 'S037', 'S041', 'S046', 'S047'};
timepoint_sano = {'T'};     % timepoint fittizio necessario per avere sottocartelle come patologici
timepoint_patologico = {'T0', 'T1'};     % AGGIUNGERE T1
indice = {'angolo_spalla_medio', 'ROM_spalla', 'angolo_gomito_medio', 'ROM_gomito', 'angolo_sagittale_medio', 'ROM_tronco_sagittale', 'angolo_frontale_medio', 'ROM_tronco_frontale', 'angolo_torsione_medio', 'ROM_tronco_torsione'};
task_motori = {'Addu', 'Addu_orizz', 'Flex', 'Circ', 'RandG'};
sottocartelle4 = {'Right', 'Left'};
sottocartelle5 = {'R_avanti', 'R_indietro', 'L_avanti', 'L_indietro'};
sottocartelle6 = {'Reach', 'Grasp'};
sottocartelle_ar = {'Andata', 'Ritorno', 'Totale'};
sottocartelle_ad = {'Accelerazione', 'Decelerazione', 'Totale'};

info_terna = readtable('Tabella assi cartesiani.xlsx');

%% riempimento struct risultati

for ii = 1:length(gruppo)       % scorro i gruppi
    gruppo_corrente = gruppo{ii};

    if ii == 1      % sono in sani

        for jj = 1:length(id_sano)      % scorro i soggetti
            soggetto_corrente = id_sano{jj};

            for pp = 1:length(timepoint_sano)
                timepoint_corrente = timepoint_sano{pp};

                for ll = 1:length(task_motori)         % scorro le task
                    task_corrente = task_motori{ll};

                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                        if ll == 1 || ll == 3          % vale per Addu (ll=1), Flex (ll=3)

                            for mm = 1:length(sottocartelle4)       % scorro dx e sx
                                lato_corrente = sottocartelle4{mm};

                                if mm == 1           % sono in dx

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    task_C7 = percorso_task.RC7;
                                                    task_Sacrum = percorso_task.RSacrum;
                                                    task_Shoulder = percorso_task.RShoulder;
                                                    task_RShoulder = percorso_task.RShoulder;
                                                    task_LShoulder = percorso_task.LShoulder_tDX;
                                                    task_Elbow = percorso_task.RElbow;

                                                    if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                        if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 2           % sono in sx

                                    for oo = 1:length(sottocartelle_ar)         % scotto andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    task_C7 = percorso_task.LC7;
                                                    task_Sacrum = percorso_task.LSacrum;
                                                    task_Shoulder = percorso_task.LShoulder;
                                                    task_RShoulder = percorso_task.RShoulder_tSX;
                                                    task_LShoulder = percorso_task.LShoulder;
                                                    task_Elbow = percorso_task.LElbow;

                                                    if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                        if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
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

                        elseif ll == 2          % vale per Addu_orizz (ll=2)

                            for mm = 1:length(sottocartelle4)       % scorro dx e sx
                                lato_corrente = sottocartelle4{mm};

                                if mm == 1           % sono in dx

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    task_RShoulder = percorso_task.RShoulder;
                                                    task_LShoulder = percorso_task.LShoulder_tDX;
                                                    task_Shoulder = percorso_task.RShoulder;
                                                    task_Elbow = percorso_task.RElbow;
                                                    task_C7 = percorso_task.RC7;
                                                    task_Sacrum = percorso_task.RSacrum;

                                                    if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                        if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_spalle(pos_LShoulder, pos_RShoulder, pos_Shoulder, pos_Elbow);      % vettore spalle da dx a sx
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 2           % sono in sx

                                    for oo = 1:length(sottocartelle_ar)         % scotto andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    task_RShoulder = percorso_task.RShoulder_tSX;
                                                    task_LShoulder = percorso_task.LShoulder;
                                                    task_Shoulder = percorso_task.LShoulder;
                                                    task_Elbow = percorso_task.LElbow;
                                                    task_C7 = percorso_task.LC7;
                                                    task_Sacrum = percorso_task.LSacrum;

                                                    if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                        if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_spalle(pos_RShoulder, pos_LShoulder, pos_Shoulder, pos_Elbow);      % vettore spalle da sx a dx
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
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

                        elseif ll == 4       % vale per Circ

                            for mm = 1:length(sottocartelle5)       % scorro dx e sx, avanti e indietro
                                lato_corrente = sottocartelle5{mm};

                                if mm == 1           % sono in R_avanti

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    if isfield(percorso_task, 'RC7_avanti') && isfield(percorso_task, 'RSacrum_avanti') && isfield(percorso_task, 'RShoulder_avanti') && isfield(percorso_task, 'LShoulder_avanti_tDX') && isfield(percorso_task, 'RElbow_avanti')

                                                        task_C7 = percorso_task.RC7_avanti;
                                                        task_Sacrum = percorso_task.RSacrum_avanti;
                                                        task_Shoulder = percorso_task.RShoulder_avanti;
                                                        task_RShoulder = percorso_task.RShoulder_avanti;
                                                        task_LShoulder = percorso_task.LShoulder_avanti_tDX;
                                                        task_Elbow = percorso_task.RElbow_avanti;

                                                        if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 2           % sono in R_indietro

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    if isfield(percorso_task, 'RC7_indietro') && isfield(percorso_task, 'RSacrum_indietro') && isfield(percorso_task, 'RShoulder_indietro') && isfield(percorso_task, 'LShoulder_indietro_tDX') && isfield(percorso_task, 'RElbow_indietro')

                                                        task_C7 = percorso_task.RC7_indietro;
                                                        task_Sacrum = percorso_task.RSacrum_indietro;
                                                        task_Shoulder = percorso_task.RShoulder_indietro;
                                                        task_RShoulder = percorso_task.RShoulder_indietro;
                                                        task_LShoulder = percorso_task.LShoulder_indietro_tDX;
                                                        task_Elbow = percorso_task.RElbow_indietro;

                                                        if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 3           % sono in L_avanti

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    if isfield(percorso_task, 'LC7_avanti') && isfield(percorso_task, 'LSacrum_avanti') && isfield(percorso_task, 'LShoulder_avanti') && isfield(percorso_task, 'RShoulder_avanti_tSX') && isfield(percorso_task, 'LElbow_avanti')

                                                        task_C7 = percorso_task.LC7_avanti;
                                                        task_Sacrum = percorso_task.LSacrum_avanti;
                                                        task_Shoulder = percorso_task.LShoulder_avanti;
                                                        task_RShoulder = percorso_task.RShoulder_avanti_tSX;
                                                        task_LShoulder = percorso_task.LShoulder_avanti;
                                                        task_Elbow = percorso_task.LElbow_avanti;

                                                        if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 4           % sono in L_indietro

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                    percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                    if isfield(percorso_task, 'LC7_indietro') && isfield(percorso_task, 'LSacrum_indietro') && isfield(percorso_task, 'LShoulder_indietro') && isfield(percorso_task, 'RShoulder_indietro_tSX') && isfield(percorso_task, 'LElbow_indietro')

                                                        task_C7 = percorso_task.LC7_indietro;
                                                        task_Sacrum = percorso_task.LSacrum_indietro;
                                                        task_Shoulder = percorso_task.LShoulder_indietro;
                                                        task_RShoulder = percorso_task.RShoulder_indietro_tSX;
                                                        task_LShoulder = percorso_task.LShoulder_indietro;
                                                        task_Elbow = percorso_task.LElbow_indietro;

                                                        if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                            pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                            pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                            [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);

                                                            angolo_spalla_mean = mean(angolo_spalla);
                                                            angolo_sagittale_mean = mean(angolo_sagittale);
                                                            angolo_frontale_mean = mean(angolo_frontale);
                                                            angolo_torsione_mean = mean(angolo_torsione);

                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                    Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
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

                        elseif ll == 5       % vale per RandG

                            for mm = 1:length(sottocartelle6)       % scorro reach e grasp
                                lato_corrente = sottocartelle6{mm};

                                if mm == 1           % sono in reach

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                            percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                            task_C7 = percorso_task.Reach_C7;
                                                            task_Sacrum = percorso_task.Reach_Sacrum;
                                                            task_Shoulder = percorso_task.Reach_Shoulder;
                                                            task_OtherShoulder = percorso_task.Reach_OtherShoulder;
                                                            task_Elbow = percorso_task.Reach_Elbow;
                                                            task_Ulna = percorso_task.Reach_Ulna;

                                                            if isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_OtherShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo) && isfield(task_Ulna.(tratto_corrente), nome_ciclo)

                                                                pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_OtherShoulder = task_OtherShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Ulna = task_Ulna.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                                [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_OtherShoulder, pos_Shoulder);
                                                                [angolo_gomito, ROM_gomito] = fun_ROM_gomito(pos_Ulna, pos_Shoulder, pos_Elbow);

                                                                angolo_spalla_mean = mean(angolo_spalla);
                                                                angolo_sagittale_mean = mean(angolo_sagittale);
                                                                angolo_frontale_mean = mean(angolo_frontale);
                                                                angolo_torsione_mean = mean(angolo_torsione);
                                                                angolo_gomito_mean = mean(angolo_gomito);

                                                                for kk = 1:length(indice)
                                                                    indice_corrente = indice{kk};

                                                                    if kk == 1
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                    elseif kk == 2
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                    elseif kk == 3
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito;

                                                                    elseif kk == 4
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_gomito;
                                                                    
                                                                    elseif kk == 5
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                    elseif kk == 6
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                    elseif kk == 7
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                    elseif kk == 8
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                    elseif kk == 9
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                    elseif kk == 10
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif mm == 2           % sono in grasp

                                    for oo = length(sottocartelle_ar)
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                            percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                            task_Ulna = percorso_task.Grasp_Ulna;
                                                            task_Shoulder = percorso_task.Grasp_Shoulder;
                                                            task_OtherShoulder = percorso_task.Grasp_OtherShoulder;
                                                            task_Elbow = percorso_task.Grasp_Elbow;

                                                            if isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_OtherShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_Ulna.(tratto_corrente), nome_ciclo)

                                                                pos_Ulna = task_Ulna.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_OtherShoulder = task_OtherShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                [angolo_gomito, ROM_gomito] = fun_ROM_gomito(pos_Ulna, pos_Shoulder, pos_Elbow);

                                                                angolo_gomito_mean = mean(angolo_gomito);

                                                                for kk = 1:length(indice)
                                                                    indice_corrente = indice{kk};

                                                                    if kk == 3
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito;

                                                                    elseif kk == 4
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_gomito;
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

    elseif ii == 2      % sono in patologici

        for jj = 1:length(id_patologico)      % scorro i soggetti
            soggetto_corrente = id_patologico{jj};

            riga_soggetto = strcmp(info_terna{:, 1}, soggetto_corrente);

            for pp = 1:length(timepoint_patologico)
                timepoint_corrente = timepoint_patologico{pp};

                terna = info_terna{riga_soggetto, 1+pp};

                for ll = 1:length(task_motori)         % scorro le task
                    task_corrente = task_motori{ll};

                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)      % controlla che timepoint esistono
                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                            if ll == 1 || ll == 3          % vale per Addu (ll=1), Flex (ll=3)

                                for mm = 1:length(sottocartelle4)       % scorro dx e sx
                                    lato_corrente = sottocartelle4{mm};

                                    if mm == 1           % sono in dx

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'RC7') && isfield(percorso_task, 'RSacrum') && isfield(percorso_task, 'RShoulder') && isfield(percorso_task, 'LShoulder_tDX') && isfield(percorso_task, 'RElbow')

                                                            task_C7 = percorso_task.RC7;
                                                            task_Sacrum = percorso_task.RSacrum;
                                                            task_Shoulder = percorso_task.RShoulder;
                                                            task_RShoulder = percorso_task.RShoulder;
                                                            task_LShoulder = percorso_task.LShoulder_tDX;
                                                            task_Elbow = percorso_task.RElbow;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                                if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                                    pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                    [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);

                                                                    if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    end

                                                                    angolo_spalla_mean = mean(angolo_spalla);
                                                                    angolo_sagittale_mean = mean(angolo_sagittale);
                                                                    angolo_frontale_mean = mean(angolo_frontale);
                                                                    angolo_torsione_mean = mean(angolo_torsione);

                                                                    for kk = 1:length(indice)
                                                                        indice_corrente = indice{kk};

                                                                        if kk == 1
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                        elseif kk == 2
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                        elseif kk == 5
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                        elseif kk == 6
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                        elseif kk == 7
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                        elseif kk == 8
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                        elseif kk == 9
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                        elseif kk == 10
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif mm == 2           % sono in sx

                                        for oo = 1:length(sottocartelle_ar)         % scotto andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'LC7') && isfield(percorso_task, 'LSacrum') && isfield(percorso_task, 'LShoulder') && isfield(percorso_task, 'RShoulder_tSX') && isfield(percorso_task, 'LElbow')

                                                            task_C7 = percorso_task.LC7;
                                                            task_Sacrum = percorso_task.LSacrum;
                                                            task_Shoulder = percorso_task.LShoulder;
                                                            task_RShoulder = percorso_task.RShoulder_tSX;
                                                            task_LShoulder = percorso_task.LShoulder;
                                                            task_Elbow = percorso_task.LElbow;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                                if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                                    pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                    [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);
                                                                    
                                                                    if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    end

                                                                    angolo_spalla_mean = mean(angolo_spalla);
                                                                    angolo_sagittale_mean = mean(angolo_sagittale);
                                                                    angolo_frontale_mean = mean(angolo_frontale);
                                                                    angolo_torsione_mean = mean(angolo_torsione);

                                                                    for kk = 1:length(indice)
                                                                        indice_corrente = indice{kk};

                                                                        if kk == 1
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                        elseif kk == 2
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                        elseif kk == 5
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                        elseif kk == 6
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                        elseif kk == 7
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                        elseif kk == 8
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                        elseif kk == 9
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                        elseif kk == 10
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                        end
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif ll == 2          % vale per Addu_orizz (ll=2)

                                for mm = 1:length(sottocartelle4)       % scorro dx e sx
                                    lato_corrente = sottocartelle4{mm};

                                    if mm == 1           % sono in dx

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'RC7') && isfield(percorso_task, 'RSacrum') && isfield(percorso_task, 'RShoulder') && isfield(percorso_task, 'LShoulder_tDX') && isfield(percorso_task, 'RElbow')

                                                            task_RShoulder = percorso_task.RShoulder;
                                                            task_LShoulder = percorso_task.LShoulder_tDX;
                                                            task_Shoulder = percorso_task.RShoulder;
                                                            task_Elbow = percorso_task.RElbow;
                                                            task_C7 = percorso_task.RC7;
                                                            task_Sacrum = percorso_task.RSacrum;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                                if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                                    pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                    [angolo_spalla, ROM_spalla] = fun_ROM_spalle(pos_LShoulder, pos_RShoulder, pos_Shoulder, pos_Elbow);      % vettore spalle da dx a sx

                                                                    if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    end

                                                                    angolo_spalla_mean = mean(angolo_spalla);
                                                                    angolo_sagittale_mean = mean(angolo_sagittale);
                                                                    angolo_frontale_mean = mean(angolo_frontale);
                                                                    angolo_torsione_mean = mean(angolo_torsione);

                                                                    for kk = 1:length(indice)
                                                                        indice_corrente = indice{kk};

                                                                        if kk == 1
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                        elseif kk == 2
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                        elseif kk == 5
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                        elseif kk == 6
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                        elseif kk == 7
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                        elseif kk == 8
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                        elseif kk == 9
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                        elseif kk == 10
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                        end
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif mm == 2           % sono in sx

                                        for oo = 1:length(sottocartelle_ar)         % scotto andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'LC7') && isfield(percorso_task, 'LSacrum') && isfield(percorso_task, 'LShoulder') && isfield(percorso_task, 'RShoulder_tSX') && isfield(percorso_task, 'LElbow')

                                                            task_RShoulder = percorso_task.RShoulder_tSX;
                                                            task_LShoulder = percorso_task.LShoulder;
                                                            task_Shoulder = percorso_task.LShoulder;
                                                            task_Elbow = percorso_task.LElbow;
                                                            task_C7 = percorso_task.LC7;
                                                            task_Sacrum = percorso_task.LSacrum;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)
                                                                if ~isempty(task_RShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_LShoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Shoulder.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Elbow.(tratto_corrente).(nome_ciclo)) && ~isempty(task_C7.(tratto_corrente).(nome_ciclo)) && ~isempty(task_Sacrum.(tratto_corrente).(nome_ciclo))

                                                                    pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                    pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                    [angolo_spalla, ROM_spalla] = fun_ROM_spalle(pos_RShoulder, pos_LShoulder, pos_Shoulder, pos_Elbow);      % vettore spalle da sx a dx

                                                                    if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                        [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                    end

                                                                    angolo_spalla_mean = mean(angolo_spalla);
                                                                    angolo_sagittale_mean = mean(angolo_sagittale);
                                                                    angolo_frontale_mean = mean(angolo_frontale);
                                                                    angolo_torsione_mean = mean(angolo_torsione);

                                                                    for kk = 1:length(indice)
                                                                        indice_corrente = indice{kk};

                                                                        if kk == 1
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                        elseif kk == 2
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                        elseif kk == 5
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                        elseif kk == 6
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                        elseif kk == 7
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                        elseif kk == 8
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                        elseif kk == 9
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                            Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                        elseif kk == 10
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                        end
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif ll == 4       % vale per Circ

                                for mm = 1:length(sottocartelle5)       % scorro dx e sx, avanti e indietro
                                    lato_corrente = sottocartelle5{mm};

                                    if mm == 1           % sono in R_avanti

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'RC7_avanti') && isfield(percorso_task, 'RSacrum_avanti') && isfield(percorso_task, 'RShoulder_avanti') && isfield(percorso_task, 'LShoulder_avanti_tDX') && isfield(percorso_task, 'RElbow_avanti')

                                                            task_C7 = percorso_task.RC7_avanti;
                                                            task_Sacrum = percorso_task.RSacrum_avanti;
                                                            task_Shoulder = percorso_task.RShoulder_avanti;
                                                            task_RShoulder = percorso_task.RShoulder_avanti;
                                                            task_LShoulder = percorso_task.LShoulder_avanti_tDX;
                                                            task_Elbow = percorso_task.RElbow_avanti;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                                pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);

                                                                if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                end

                                                                angolo_spalla_mean = mean(angolo_spalla);
                                                                angolo_sagittale_mean = mean(angolo_sagittale);
                                                                angolo_frontale_mean = mean(angolo_frontale);
                                                                angolo_torsione_mean = mean(angolo_torsione);

                                                                for kk = 1:length(indice)
                                                                    indice_corrente = indice{kk};

                                                                    if kk == 1
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                    elseif kk == 2
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                    elseif kk == 5
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                    elseif kk == 6
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                    elseif kk == 7
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                    elseif kk == 8
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                    elseif kk == 9
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                    elseif kk == 10
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif mm == 2           % sono in R_indietro

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'RC7_indietro') && isfield(percorso_task, 'RSacrum_indietro') && isfield(percorso_task, 'RShoulder_indietro') && isfield(percorso_task, 'LShoulder_indietro_tDX') && isfield(percorso_task, 'RElbow_indietro')

                                                            task_C7 = percorso_task.RC7_indietro;
                                                            task_Sacrum = percorso_task.RSacrum_indietro;
                                                            task_Shoulder = percorso_task.RShoulder_indietro;
                                                            task_RShoulder = percorso_task.RShoulder_indietro;
                                                            task_LShoulder = percorso_task.LShoulder_indietro_tDX;
                                                            task_Elbow = percorso_task.RElbow_indietro;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                                pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);

                                                                if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                end

                                                                angolo_spalla_mean = mean(angolo_spalla);
                                                                angolo_sagittale_mean = mean(angolo_sagittale);
                                                                angolo_frontale_mean = mean(angolo_frontale);
                                                                angolo_torsione_mean = mean(angolo_torsione);

                                                                for kk = 1:length(indice)
                                                                    indice_corrente = indice{kk};

                                                                    if kk == 1
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                    elseif kk == 2
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                    elseif kk == 5
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                    elseif kk == 6
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                    elseif kk == 7
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                    elseif kk == 8
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                    elseif kk == 9
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                    elseif kk == 10
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif mm == 3           % sono in L_avanti

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'LC7_avanti') && isfield(percorso_task, 'LSacrum_avanti') && isfield(percorso_task, 'LShoulder_avanti') && isfield(percorso_task, 'RShoulder_avanti_tSX') && isfield(percorso_task, 'LElbow_avanti')

                                                            task_C7 = percorso_task.LC7_avanti;
                                                            task_Sacrum = percorso_task.LSacrum_avanti;
                                                            task_Shoulder = percorso_task.LShoulder_avanti;
                                                            task_RShoulder = percorso_task.RShoulder_avanti_tSX;
                                                            task_LShoulder = percorso_task.LShoulder_avanti;
                                                            task_Elbow = percorso_task.LElbow_avanti;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                                pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);

                                                                if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                end

                                                                angolo_spalla_mean = mean(angolo_spalla);
                                                                angolo_sagittale_mean = mean(angolo_sagittale);
                                                                angolo_frontale_mean = mean(angolo_frontale);
                                                                angolo_torsione_mean = mean(angolo_torsione);

                                                                for kk = 1:length(indice)
                                                                    indice_corrente = indice{kk};

                                                                    if kk == 1
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                    elseif kk == 2
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                    elseif kk == 5
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                    elseif kk == 6
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                    elseif kk == 7
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                    elseif kk == 8
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                    elseif kk == 9
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                    elseif kk == 10
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif mm == 4           % sono in L_indietro

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                        percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                        if isfield(percorso_task, 'LC7_indietro') && isfield(percorso_task, 'LSacrum_indietro') && isfield(percorso_task, 'LShoulder_indietro') && isfield(percorso_task, 'RShoulder_indietro_tSX') && isfield(percorso_task, 'LElbow_indietro')

                                                            task_C7 = percorso_task.LC7_indietro;
                                                            task_Sacrum = percorso_task.LSacrum_indietro;
                                                            task_Shoulder = percorso_task.LShoulder_indietro;
                                                            task_RShoulder = percorso_task.RShoulder_indietro_tSX;
                                                            task_LShoulder = percorso_task.LShoulder_indietro;
                                                            task_Elbow = percorso_task.LElbow_indietro;

                                                            if isfield(task_RShoulder.(tratto_corrente), nome_ciclo) && isfield(task_LShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                                pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_RShoulder = task_RShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_LShoulder = task_LShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);

                                                                if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z+', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                    [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                end

                                                                angolo_spalla_mean = mean(angolo_spalla);
                                                                angolo_sagittale_mean = mean(angolo_sagittale);
                                                                angolo_frontale_mean = mean(angolo_frontale);
                                                                angolo_torsione_mean = mean(angolo_torsione);

                                                                for kk = 1:length(indice)
                                                                    indice_corrente = indice{kk};

                                                                    if kk == 1
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                    elseif kk == 2
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                    elseif kk == 5
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                    elseif kk == 6
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                    elseif kk == 7
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                    elseif kk == 8
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                    elseif kk == 9
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                        Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                    elseif kk == 10
                                                                        Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                    end
                                                                end
                                                            end

                                                        else
                                                            for kk = 1:length(indice)
                                                                indice_corrente = indice{kk};

                                                                if kk == 1
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 2
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 5
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 6
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 7
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 8
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 9
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                elseif kk == 10
                                                                    Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif ll == 5       % vale per RandG

                                for mm = 1:length(sottocartelle6)       % scorro reach e grasp
                                    lato_corrente = sottocartelle6{mm};

                                    if mm == 1           % sono in reach

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                    accelerazione_corrente = sottocartelle_ad{qq};

                                                    if qq == 3      % totale

                                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                                percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                                if isfield(percorso_task, 'Reach_C7') && isfield(percorso_task, 'Reach_Sacrum') && isfield(percorso_task, 'Reach_Shoulder') && isfield(percorso_task, 'Reach_OtherShoulder') && isfield(percorso_task, 'Reach_Elbow')

                                                                    task_C7 = percorso_task.Reach_C7;
                                                                    task_Sacrum = percorso_task.Reach_Sacrum;
                                                                    task_Shoulder = percorso_task.Reach_Shoulder;
                                                                    task_OtherShoulder = percorso_task.Reach_OtherShoulder;
                                                                    task_Elbow = percorso_task.Reach_Elbow;
                                                                    task_Ulna = percorso_task.Reach_Ulna;

                                                                    if isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_OtherShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_C7.(tratto_corrente), nome_ciclo) && isfield(task_Sacrum.(tratto_corrente), nome_ciclo)

                                                                        pos_C7 = task_C7.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_Sacrum = task_Sacrum.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_OtherShoulder = task_OtherShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_Ulna = task_Ulna.(tratto_corrente).(nome_ciclo)(:, 2:4);


                                                                        [angolo_spalla, ROM_spalla] = fun_ROM_tronco(pos_C7, pos_Sacrum, pos_Shoulder, pos_Elbow);

                                                                        [angolo_gomito, ROM_gomito] = fun_ROM_gomito(pos_Ulna, pos_Shoulder, pos_Elbow);

                                                                        angolo_gomito_mean = mean(angolo_gomito);

                                                                        if contains(string(terna), 'X+', 'IgnoreCase', true)
                                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_X(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                        elseif contains(string(terna), 'X-', 'IgnoreCase', true)
                                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Xmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                        elseif contains(string(terna), 'Z', 'IgnoreCase', true)
                                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Z(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                        elseif contains(string(terna), 'Z-', 'IgnoreCase', true)
                                                                            [angolo_sagittale, ROM_tronco_sagittale, angolo_frontale, ROM_tronco_frontale, angolo_torsione, ROM_tronco_torsione] = fun_angolo_tronco_Zmeno(pos_C7, pos_Sacrum, pos_LShoulder, pos_RShoulder);
                                                                        end

                                                                        angolo_spalla_mean = mean(angolo_spalla);
                                                                        angolo_sagittale_mean = mean(angolo_sagittale);
                                                                        angolo_frontale_mean = mean(angolo_frontale);
                                                                        angolo_torsione_mean = mean(angolo_torsione);

                                                                        for kk = 1:length(indice)
                                                                            indice_corrente = indice{kk};

                                                                            if kk == 1
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla_mean;
                                                                                Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_spalla;

                                                                            elseif kk == 2
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_spalla;

                                                                            elseif kk == 3
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito_mean;
                                                                                Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito;

                                                                            elseif kk == 4
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_gomito;
                                                                            
                                                                            elseif kk == 5
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale_mean;
                                                                                Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_sagittale;

                                                                            elseif kk == 6
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_sagittale;

                                                                            elseif kk == 7
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale_mean;
                                                                                Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_frontale;

                                                                            elseif kk == 8
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_frontale;

                                                                            elseif kk == 9
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione_mean;
                                                                                Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_torsione;

                                                                            elseif kk == 10
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_tronco_torsione;
                                                                            end
                                                                        end
                                                                    end

                                                                else
                                                                    for kk = 1:length(indice)
                                                                        indice_corrente = indice{kk};

                                                                        if kk == 1
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 2
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 3
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 4
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 5
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 6
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 7
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 8
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 9
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 10
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif mm == 2           % sono in grasp

                                        for oo = length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            if oo == 3      % totale

                                                for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                    accelerazione_corrente = sottocartelle_ad{qq};

                                                    if qq == 3      % totale

                                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)

                                                                percorso_task = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente);
                                                                if isfield(percorso_task, 'Grasp_Ulna') && isfield(percorso_task, 'Grasp_Shoulder') && isfield(percorso_task, 'Grasp_OtherShoulder') && isfield(percorso_task, 'Grasp_Elbow')

                                                                    task_Ulna = percorso_task.Grasp_Ulna;
                                                                    task_Shoulder = percorso_task.Grasp_Shoulder;
                                                                    task_OtherShoulder = percorso_task.Grasp_OtherShoulder;
                                                                    task_Elbow = percorso_task.Grasp_Elbow;

                                                                    if isfield(task_Shoulder.(tratto_corrente), nome_ciclo) && isfield(task_OtherShoulder.(tratto_corrente), nome_ciclo) && isfield(task_Elbow.(tratto_corrente), nome_ciclo) && isfield(task_Ulna.(tratto_corrente), nome_ciclo)

                                                                        pos_Ulna = task_Ulna.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_Shoulder = task_Shoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_OtherShoulder = task_OtherShoulder.(tratto_corrente).(nome_ciclo)(:, 2:4);
                                                                        pos_Elbow = task_Elbow.(tratto_corrente).(nome_ciclo)(:, 2:4);

                                                                        [angolo_gomito, ROM_gomito] = fun_ROM_gomito(pos_Ulna, pos_Shoulder, pos_Elbow);

                                                                        angolo_gomito_mean = mean(angolo_spalla);

                                                                        for kk = 1:length(indice)
                                                                            indice_corrente = indice{kk};

                                                                            if kk == 3
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito_mean;
                                                                                Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = angolo_gomito;

                                                                            elseif kk == 4
                                                                                Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(indice_corrente) = ROM_gomito;
                                                                    
                                                                            end
                                                                        end
                                                                    end

                                                                else
                                                                    for kk = 1:length(indice)
                                                                        indice_corrente = indice{kk};

                                                                        if kk == 1
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 2
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 3
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 4
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 5
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 6
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 7
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 8
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 9
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;

                                                                        elseif kk == 10
                                                                            Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(indice_corrente) = NaN;
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

%% salvataggio struct

save('Implementazione_ROM.mat', 'Database_ROM', 'Database_angoli_articolari');