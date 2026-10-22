clear
close all
clc

%% caricamento struct con dati segmentati

load('Suddivisione_cicli_tot.mat');

%% inizializzazione struct di salvataggio

Database_indici = struct();

% sottocartelle
gruppo = {'Sani', 'Patologici'};
id_sano = {'H002', 'H003', 'H004', 'H005', 'H006', 'H008', 'H009', 'H010', 'H011', 'H013', 'H016', 'H017', 'H018'};
id_patologico = {'S001', 'S004', 'S011', 'S012', 'S013', 'S014', 'S015', 'S025', 'S026', 'S027', 'S028', 'S031', 'S032', 'S034', 'S036', 'S037', 'S041', 'S046', 'S047'};
timepoint_sano = {'T'};
timepoint_patologico = {'T0', 'T1'};
indice = {'jerk', 'LDLJ', 'SPARC', 'skewness'};     % AGGIUNGERE ANGOLI E ROM
task_motori = {'Addu', 'Addu_orizz', 'Flex', 'Circ', 'RandG'};
sottocartelle1 = {'RUlna', 'LUlna'};        % vale per Addu, Addu_orizz, Flex
sottocartelle2 = {'RUlna_avanti', 'RUlna_indietro', 'LUlna_avanti', 'LUlna_indietro'};      % vale per Circ
sottocartelle3 = {'Reach_Ulna', 'Grasp_Ulna'};     % vale per RandG
sottocartelle_ar = {'Andata', 'Ritorno'};
sottocartelle_ad = {'Accelerazione', 'Decelerazione', 'Totale'};

%% riempimento struct risultati

for ii = 1:length(gruppo)       % scorro i gruppi
    gruppo_corrente = gruppo{ii};

    if ii == 1      % sono in sani

        for jj = 1:length(id_sano)      % scorro i soggetti
            soggetto_corrente = id_sano{jj};

            for pp = 1:length(timepoint_sano)
                timepoint_corrente = timepoint_sano{pp};

                for kk = 1:length(indice)       % scorro gli indici
                    indice_corrente = indice{kk};

                    if kk == 1       % sono in jerk

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                    for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                        lato_corrente = sottocartelle1{mm};

                                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                    dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                    [jerk_mean, jerk_peak] = fun_jerk(dati_ciclo);
                                                    Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = [jerk_mean, jerk_peak];
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 4       % vale per Circ

                                    for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                        lato_corrente = sottocartelle2{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                        [jerk_mean, jerk_peak] = fun_jerk(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = [jerk_mean, jerk_peak];
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 5       % vale per RandG

                                    for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                        lato_corrente = sottocartelle3{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                        [jerk_mean, jerk_peak] = fun_jerk(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = [jerk_mean, jerk_peak];
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 2       %sono in LDLJ

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                    for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                        lato_corrente = sottocartelle1{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                    dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                    [LDLJ_value] = fun_LDLJ(dati_ciclo);
                                                    Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = LDLJ_value;
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 4       % vale per Circ

                                    for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                        lato_corrente = sottocartelle2{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                        [LDLJ_value] = fun_LDLJ(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = LDLJ_value;
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 5       % vale per RandG

                                    for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                        lato_corrente = sottocartelle3{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                        [LDLJ_value] = fun_LDLJ(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = LDLJ_value;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 3       % sono in SPARC

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                    for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                        lato_corrente = sottocartelle1{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                    dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                    [SPARC_value] = fun_SPARC(dati_ciclo);
                                                    Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = SPARC_value;
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 4       % vale per Circ

                                    for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                        lato_corrente = sottocartelle2{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                        [SPARC_value] = fun_SPARC(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = SPARC_value;
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 5       % vale per RandG

                                    for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                        lato_corrente = sottocartelle3{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                        [SPARC_value] = fun_SPARC(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = SPARC_value;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 4       % sono in skewness

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                    for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                        lato_corrente = sottocartelle1{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                    dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                    [skewness_value] = fun_skewness(dati_ciclo);
                                                    Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = skewness_value;
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 4       % vale per Circ

                                    for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                        lato_corrente = sottocartelle2{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                        dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                        [skewness_value] = fun_skewness(dati_ciclo);
                                                        Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = skewness_value;
                                                    end
                                                end
                                            end
                                        end
                                    end

                                elseif ll == 5       % vale per RandG

                                    for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                        lato_corrente = sottocartelle3{mm};

                                        for oo = 1:length(sottocartelle_ar)
                                            tratto_corrente = sottocartelle_ar{oo};

                                            for qq = 1:length(sottocartelle_ad)
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % no divisione in accelerazione e decelerazione nella skewness

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                            [skewness_value] = fun_skewness(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = skewness_value;
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

        %% patologici

    elseif ii == 2      % sono in patologici

        for jj = 1:length(id_patologico)      % scorro i soggetti
            soggetto_corrente = id_patologico{jj};

            for pp = 1:length(timepoint_patologico)        % scorro T0, T1
                timepoint_corrente = timepoint_patologico{pp};

                for kk = 1:length(indice)       % scorro gli indici
                    indice_corrente = indice{kk};

                    if kk == 1       % sono in jerk

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)      % controlla che timepoint esistono
                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                    if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                        for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                            lato_corrente = sottocartelle1{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [jerk_mean, jerk_peak] = fun_jerk(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = [jerk_mean, jerk_peak];
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 4       % vale per Circ

                                        for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                            lato_corrente = sottocartelle2{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [jerk_mean, jerk_peak] = fun_jerk(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = [jerk_mean, jerk_peak];
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 5       % vale per RandG

                                        for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                            lato_corrente = sottocartelle3{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for qq = 1:length(sottocartelle_ad)
                                                    accelerazione_corrente = sottocartelle_ad{qq};

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                            [jerk_mean, jerk_peak] = fun_jerk(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = [jerk_mean, jerk_peak];
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 2       %sono in LDLJ

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)      % controlla che timepoint esistono
                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                    if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                        for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                            lato_corrente = sottocartelle1{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [LDLJ_value] = fun_LDLJ(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = LDLJ_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 4       % vale per Circ

                                        for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                            lato_corrente = sottocartelle2{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [LDLJ_value] = fun_LDLJ(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = LDLJ_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 5       % vale per RandG

                                        for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                            lato_corrente = sottocartelle3{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for qq = 1:length(sottocartelle_ad)
                                                    accelerazione_corrente = sottocartelle_ad{qq};

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                            [LDLJ_value] = fun_LDLJ(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = LDLJ_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 3       % sono in SPARC

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)      % controlla che timepoint esistono
                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                    if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                        for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                            lato_corrente = sottocartelle1{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [SPARC_value] = fun_SPARC(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = SPARC_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 4       % vale per Circ

                                        for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                            lato_corrente = sottocartelle2{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [SPARC_value] = fun_SPARC(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = SPARC_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 5       % vale per RandG

                                        for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                            lato_corrente = sottocartelle3{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for qq = 1:length(sottocartelle_ad)
                                                    accelerazione_corrente = sottocartelle_ad{qq};

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                            [SPARC_value] = fun_SPARC(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = SPARC_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 4       % sono in skewness

                        for ll = 1: length(task_motori)         % scorro le task
                            task_corrente = task_motori{ll};

                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)      % controlla che timepoint esistono
                                if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)      % controlla che task esistono

                                    if ll <= 3          % vale per Addu (ll=1), Addu_orizz (ll=2), Flex (ll=3)

                                        for mm = 1:length(sottocartelle1)       % scorro dx e sx
                                            lato_corrente = sottocartelle1{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [skewness_value] = fun_skewness(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = skewness_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 4       % vale per Circ

                                        for mm = 1:length(sottocartelle2)       % scorro dx e sx, avanti e indietro
                                            lato_corrente = sottocartelle2{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                                    if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                        if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                            dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo);

                                                            [skewness_value] = fun_skewness(dati_ciclo);
                                                            Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo) = skewness_value;
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                    elseif ll == 5       % vale per RandG

                                        for mm = 1:length(sottocartelle3)       % scorro reach e grasp
                                            lato_corrente = sottocartelle3{mm};

                                            for oo = 1:length(sottocartelle_ar)
                                                tratto_corrente = sottocartelle_ar{oo};

                                                for qq = 1:length(sottocartelle_ad)
                                                    accelerazione_corrente = sottocartelle_ad{qq};

                                                    if qq == 3      % no divisione in accelerazione e decelerazione

                                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                                            if isfield(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo) && ~isempty(Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo))      % controlla che cicli esistono

                                                                dati_ciclo = Segmentazione.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo);

                                                                [skewness_value] = fun_skewness(dati_ciclo);
                                                                Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo) = skewness_value;
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

save('Implementazione_indici.mat', 'Database_indici');
