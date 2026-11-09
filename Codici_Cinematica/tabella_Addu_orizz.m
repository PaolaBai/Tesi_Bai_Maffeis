clear
close all
clc

%% caricamento struct con indici

load('Implementazione_indici.mat');
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
sottocartelle1 = {'RUlna', 'LUlna'};        % vale per Addu, Addu_orizz, Flex
sottocartelle2 = {'Right', 'Left'};
lato = {'Dx', 'Sx'};
sottocartelle_ar = {'Andata', 'Ritorno', 'Totale'};

%% colonne vuote della tabella

Gruppo = {};
Soggetto = {};
Timepoint = {};
Lato = {};
Tratto = {};
Ciclo = {};
jerk_mean = [];
jerk_peak = [];
LDLJ = [];
SPARC = [];
skewness = [];
angolo_spalla_medio = [];
ROM_spalla = [];
angolo_sagittale_medio = [];
ROM_tronco_sagittale = [];
angolo_frontale_medio = [];
ROM_tronco_frontale = [];
angolo_torsione_medio = [];
ROM_tronco_torsione = [];

%% tabella

for ii = 1:length(gruppo)
    gruppo_corrente = gruppo{ii};

    if ii == 1      % sono in sani

        for jj = 1:length(id_sano)
            soggetto_corrente = id_sano{jj};

            for pp = 1:length(timepoint_sano)
                timepoint_corrente = timepoint_sano{pp};

                for kk = 1:length(indice1)
                    indice_corrente = indice1{kk};

                    if kk == 1      % jerk

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                            task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                lato_corrente = sottocartelle1{mm};
                                lato_c = lato{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_jerk_mean = NaN(1, 5);          % vettore di 5 NaN
                                    vettore_jerk_peak = NaN(1, 5);

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_jerk_mean = NaN;        % prealloco NaN per il controllo della task
                                            val_jerk_peak = NaN;

                                            % controllo task1
                                            if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    val_jerk_mean = task1.(lato_corrente).(tratto_corrente).(nome_ciclo)(1);
                                                    val_jerk_peak = task1.(lato_corrente).(tratto_corrente).(nome_ciclo)(2);
                                                    vettore_jerk_mean(nn) = val_jerk_mean;
                                                    vettore_jerk_peak(nn) = val_jerk_peak;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_jerk_mean = NaN;        % prealloco NaN per il controllo della task
                                            val_jerk_peak = NaN;

                                            % controllo task1
                                            if ~isempty(vettore_jerk_mean)
                                                val_jerk_mean = mean(vettore_jerk_mean, 'omitnan');
                                                val_jerk_peak = mean(vettore_jerk_peak, 'omitnan');
                                            end
                                        end

                                        Gruppo{end+1, 1} = gruppo_corrente;         % riempio le prime colonne
                                        Soggetto{end+1, 1} = soggetto_corrente;
                                        Timepoint{end+1, 1} = timepoint_corrente;
                                        Lato{end+1, 1} = lato_c;
                                        Tratto{end+1, 1} = tratto_corrente;
                                        Ciclo{end+1, 1} = nome_ciclo;

                                        jerk_mean(end+1, 1) = val_jerk_mean;
                                        jerk_peak(end+1, 1) = val_jerk_peak;
                                    end
                                end
                            end
                        end

                    elseif kk == 2      % LDLJ

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                            task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                lato_corrente = sottocartelle1{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_LDLJ = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_LDLJ = NaN;         % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    val_LDLJ = task1.(lato_corrente).(tratto_corrente).(nome_ciclo);
                                                    vettore_LDLJ(nn) = val_LDLJ;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_LDLJ = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_LDLJ)
                                                val_LDLJ = mean(vettore_LDLJ, 'omitnan');
                                            end
                                        end

                                        LDLJ(end+1, 1) = val_LDLJ;
                                    end
                                end
                            end
                        end

                    elseif kk == 3      % SPARC

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                            task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                lato_corrente = sottocartelle1{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_SPARC = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_SPARC = NaN;       % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    val_SPARC = task1.(lato_corrente).(tratto_corrente).(nome_ciclo);
                                                    vettore_SPARC(nn) = val_SPARC;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_SPARC = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_SPARC)
                                                val_SPARC = mean(vettore_SPARC, 'omitnan');
                                            end
                                        end

                                        SPARC(end+1, 1) = val_SPARC;
                                    end
                                end
                            end
                        end

                    elseif kk == 4      % sekwness

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                            task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(indice_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                lato_corrente = sottocartelle1{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_skewness = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_skewness = NaN;         % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    val_skewness = task1.(lato_corrente).(tratto_corrente).(nome_ciclo);
                                                    vettore_skewness(nn) = val_skewness;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_skewness = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_skewness)
                                                val_skewness = mean(vettore_skewness, 'omitnan');
                                            end
                                        end

                                        skewness(end+1, 1) = val_skewness;
                                    end
                                end
                            end
                        end
                    end
                end

                for kk = 1:length(indice2)          % angoli e ROM
                    indice_corrente = indice2{kk};

                    if kk == 1      % angolo spalla

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_angolo_spalla = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_angolo_spalla = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_angolo_spalla = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_angolo_spalla(nn) = val_angolo_spalla;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_angolo_spalla = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_angolo_spalla)
                                                val_angolo_spalla = mean(vettore_angolo_spalla, 'omitnan');
                                            end
                                        end

                                        angolo_spalla_medio(end+1, 1) = val_angolo_spalla;
                                    end
                                end
                            end
                        end

                    elseif kk == 2      % ROM spalla

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_ROM_spalla = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_ROM_spalla = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_ROM_spalla = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_ROM_spalla(nn) = val_ROM_spalla;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_ROM_spalla = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_ROM_spalla)
                                                val_ROM_spalla = mean(vettore_ROM_spalla, 'omitnan');
                                            end
                                        end

                                        ROM_spalla(end+1, 1) = val_ROM_spalla;
                                    end
                                end
                            end
                        end

                    elseif kk == 3      % angolo tronco sagittale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_angolo_tronco = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_angolo_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_angolo_tronco(nn) = val_angolo_tronco;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_angolo_tronco)
                                                val_angolo_tronco = mean(vettore_angolo_tronco, 'omitnan');
                                            end
                                        end

                                        angolo_sagittale_medio(end+1, 1) = val_angolo_tronco;
                                    end
                                end
                            end
                        end

                    elseif kk == 4      % ROM tronco sagittale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_ROM_tronco = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_ROM_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_ROM_tronco(nn) = val_ROM_tronco;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_ROM_tronco)
                                                val_ROM_tronco = mean(vettore_ROM_tronco, 'omitnan');
                                            end
                                        end

                                        ROM_tronco_sagittale(end+1, 1) = val_ROM_tronco;
                                    end
                                end
                            end
                        end

                    elseif kk == 5      % angolo tronco frontale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_angolo_tronco = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_angolo_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_angolo_tronco(nn) = val_angolo_tronco;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_angolo_tronco)
                                                val_angolo_tronco = mean(vettore_angolo_tronco, 'omitnan');
                                            end
                                        end

                                        angolo_frontale_medio(end+1, 1) = val_angolo_tronco;
                                    end
                                end
                            end
                        end

                    elseif kk == 6      % ROM tronco frontale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_ROM_tronco = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_ROM_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_ROM_tronco(nn) = val_ROM_tronco;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_ROM_tronco)
                                                val_ROM_tronco = mean(vettore_ROM_tronco, 'omitnan');
                                            end
                                        end

                                        ROM_tronco_frontale(end+1, 1) = val_ROM_tronco;
                                    end
                                end
                            end
                        end

                    elseif kk == 7      % angolo tronco torsione

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_angolo_tronco = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_angolo_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_angolo_tronco(nn) = val_angolo_tronco;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_angolo_tronco)
                                                val_angolo_tronco = mean(vettore_angolo_tronco, 'omitnan');
                                            end
                                        end

                                        angolo_torsione_medio(end+1, 1) = val_angolo_tronco;
                                    end
                                end
                            end
                        end

                    elseif kk == 8      % ROM tronco torsione

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), 'Addu_orizz')      % controlla che esiste
                            task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).Addu_orizz;

                            for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                lato_corrente = sottocartelle2{mm};

                                for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                    tratto_corrente = sottocartelle_ar{oo};

                                    vettore_ROM_tronco = NaN(1, 5);          % vettore di 5 NaN

                                    for nn = 1:6

                                        if nn <= 5      % 5 cicli
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task2
                                            if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                    sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                    val_ROM_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                    vettore_ROM_tronco(nn) = val_ROM_tronco;
                                                end
                                            end

                                        elseif nn == 6      % media cicli
                                            nome_ciclo = sprintf('Media Cicli');

                                            val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                            % controllo task1
                                            if ~isempty(vettore_ROM_tronco)
                                                val_ROM_tronco = mean(vettore_ROM_tronco, 'omitnan');
                                            end
                                        end

                                        ROM_tronco_torsione(end+1, 1) = val_ROM_tronco;
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

        for jj = 1:length(id_patologico)
            soggetto_corrente = id_patologico{jj};

            for pp = 1:length(timepoint_patologico)
                timepoint_corrente = timepoint_patologico{pp};

                for kk = 1:length(indice1)
                    indice_corrente = indice1{kk};

                    if kk == 1      % jerk

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                                task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                    lato_corrente = sottocartelle1{mm};
                                    lato_c = lato{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_jerk_mean = NaN(1, 5);          % vettore di 5 NaN
                                        vettore_jerk_peak = NaN(1, 5);

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_jerk_mean = NaN;        % prealloco NaN per il controllo della task
                                                val_jerk_peak = NaN;

                                                % controllo task1
                                                if isfield(task1, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            val_jerk_mean = task1.(lato_corrente).(tratto_corrente).(nome_ciclo)(1);
                                                            val_jerk_peak = task1.(lato_corrente).(tratto_corrente).(nome_ciclo)(2);
                                                            vettore_jerk_mean(nn) = val_jerk_mean;
                                                            vettore_jerk_peak(nn) = val_jerk_peak;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_jerk_mean = NaN;        % prealloco NaN per il controllo della task
                                                val_jerk_peak = NaN;

                                                % controllo task1
                                                if ~isempty(vettore_jerk_mean)
                                                    val_jerk_mean = mean(vettore_jerk_mean, 'omitnan');
                                                    val_jerk_peak = mean(vettore_jerk_peak, 'omitnan');
                                                end
                                            end

                                            Gruppo{end+1, 1} = gruppo_corrente;         % riempio le prime colonne
                                            Soggetto{end+1, 1} = soggetto_corrente;
                                            Timepoint{end+1, 1} = timepoint_corrente;
                                            Lato{end+1, 1} = lato_c;
                                            Tratto{end+1, 1} = tratto_corrente;
                                            Ciclo{end+1, 1} = nome_ciclo;

                                            jerk_mean(end+1, 1) = val_jerk_mean;
                                            jerk_peak(end+1, 1) = val_jerk_peak;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 2      % LDLJ

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                                task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                    lato_corrente = sottocartelle1{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_LDLJ = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_LDLJ = NaN;         % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if isfield(task1, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            val_LDLJ = task1.(lato_corrente).(tratto_corrente).(nome_ciclo);
                                                            vettore_LDLJ(nn) = val_LDLJ;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_LDLJ = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_LDLJ)
                                                    val_LDLJ = mean(vettore_LDLJ, 'omitnan');
                                                end
                                            end

                                            LDLJ(end+1, 1) = val_LDLJ;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 3      % SPARC

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                                task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                    lato_corrente = sottocartelle1{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_SPARC = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_SPARC = NaN;       % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if isfield(task1, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            val_SPARC = task1.(lato_corrente).(tratto_corrente).(nome_ciclo);
                                                            vettore_SPARC(nn) = val_SPARC;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_SPARC = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_SPARC)
                                                    val_SPARC = mean(vettore_SPARC, 'omitnan');
                                                end
                                            end

                                            SPARC(end+1, 1) = val_SPARC;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 4      % sekwness

                        if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente), 'Addu_orizz')      % controlla che esiste
                                task1 = Database_indici.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(indice_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle1)       % scorro dx, sx
                                    lato_corrente = sottocartelle1{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_skewness = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_skewness = NaN;         % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if isfield(task1, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task1.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task1.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            val_skewness = task1.(lato_corrente).(tratto_corrente).(nome_ciclo);
                                                            vettore_skewness(nn) = val_skewness;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_skewness = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_skewness)
                                                    val_skewness = mean(vettore_skewness, 'omitnan');
                                                end
                                            end

                                            skewness(end+1, 1) = val_skewness;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                for kk = 1:length(indice2)
                    indice_corrente = indice2{kk};

                    if kk == 1      % angolo spalla

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_angolo_spalla = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_angolo_spalla = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_angolo_spalla = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_angolo_spalla(nn) = val_angolo_spalla;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_angolo_spalla = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_angolo_spalla)
                                                    val_angolo_spalla = mean(vettore_angolo_spalla, 'omitnan');
                                                end
                                            end

                                            angolo_spalla_medio(end+1, 1) = val_angolo_spalla;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 2      % ROM spalla

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_ROM_spalla = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_ROM_spalla = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_ROM_spalla = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_ROM_spalla(nn) = val_ROM_spalla;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_ROM_spalla = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_ROM_spalla)
                                                    val_ROM_spalla = mean(vettore_ROM_spalla, 'omitnan');
                                                end
                                            end

                                            ROM_spalla(end+1, 1) = val_ROM_spalla;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 3      % angolo tronco sagittale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_angolo_tronco = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_angolo_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_angolo_tronco(nn) = val_angolo_tronco;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_angolo_tronco)
                                                    val_angolo_tronco = mean(vettore_angolo_tronco, 'omitnan');
                                                end
                                            end

                                            angolo_sagittale_medio(end+1, 1) = val_angolo_tronco;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 4      % ROM tronco sagittale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_ROM_tronco = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_ROM_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_ROM_tronco(nn) = val_ROM_tronco;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_ROM_tronco)
                                                    val_ROM_tronco = mean(vettore_ROM_tronco, 'omitnan');
                                                end
                                            end

                                            ROM_tronco_sagittale(end+1, 1) = val_ROM_tronco;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 5      % angolo tronco frontale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_angolo_tronco = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_angolo_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_angolo_tronco(nn) = val_angolo_tronco;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_angolo_tronco)
                                                    val_angolo_tronco = mean(vettore_angolo_tronco, 'omitnan');
                                                end
                                            end

                                            angolo_frontale_medio(end+1, 1) = val_angolo_tronco;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 6      % ROM tronco frontale

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_ROM_tronco = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_ROM_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_ROM_tronco(nn) = val_ROM_tronco;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_ROM_tronco)
                                                    val_ROM_tronco = mean(vettore_ROM_tronco, 'omitnan');
                                                end
                                            end

                                            ROM_tronco_frontale(end+1, 1) = val_ROM_tronco;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 7      % angolo tronco torsione

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_angolo_tronco = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_angolo_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_angolo_tronco(nn) = val_angolo_tronco;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_angolo_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_angolo_tronco)
                                                    val_angolo_tronco = mean(vettore_angolo_tronco, 'omitnan');
                                                end
                                            end

                                            angolo_torsione_medio(end+1, 1) = val_angolo_tronco;
                                        end
                                    end
                                end
                            end
                        end

                    elseif kk == 8      % ROM tronco torsione

                        if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)           % controlla che timepiont esiste
                            if isfield(Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), 'Addu_orizz')      % controlla che esiste
                                task2 = Database_ROM.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).Addu_orizz;

                                for mm = 1:length(sottocartelle2)       % scorro dx, sx
                                    lato_corrente = sottocartelle2{mm};

                                    for oo = 1:length(sottocartelle_ar)     % scorro andata, ritorno, totale
                                        tratto_corrente = sottocartelle_ar{oo};

                                        vettore_ROM_tronco = NaN(1, 5);          % vettore di 5 NaN

                                        for nn = 1:6

                                            if nn <= 5      % 5 cicli
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task2
                                                if isfield(task2, lato_corrente)      % controlla che lati esistono
                                                    if isfield(task2.(lato_corrente), tratto_corrente)      % controlla che tratti esistono
                                                        if isfield(task2.(lato_corrente).(tratto_corrente), nome_ciclo)         % controlla che i cicli esistano

                                                            sottocartella = fieldnames(task2.(lato_corrente).(tratto_corrente).(nome_ciclo));

                                                            val_ROM_tronco = task2.(lato_corrente).(tratto_corrente).(nome_ciclo).(sottocartella{kk});
                                                            vettore_ROM_tronco(nn) = val_ROM_tronco;
                                                        end
                                                    end
                                                end

                                            elseif nn == 6      % media cicli
                                                nome_ciclo = sprintf('Media Cicli');

                                                val_ROM_tronco = NaN;        % prealloco NaN per il controllo della task

                                                % controllo task1
                                                if ~isempty(vettore_ROM_tronco)
                                                    val_ROM_tronco = mean(vettore_ROM_tronco, 'omitnan');
                                                end
                                            end

                                            ROM_tronco_torsione(end+1, 1) = val_ROM_tronco;
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

%% genera la tabella

Tabella_Addu_orizz = table(Gruppo, Soggetto, Timepoint, Lato, Tratto, Ciclo, jerk_mean, jerk_peak, LDLJ, SPARC, skewness, angolo_spalla_medio, ROM_spalla, angolo_sagittale_medio, ROM_tronco_sagittale, angolo_frontale_medio, ROM_tronco_frontale, angolo_torsione_medio, ROM_tronco_torsione, ...
    'VariableNames', {'Gruppo', 'Soggetto', 'Timepoint', 'Lato', 'Tratto', 'Ciclo', 'jerkMean', 'jerkPeak', 'LDLJ', 'SPARC', 'skewness', 'Angolo spalla medio', 'ROM spalla', 'Angolo sagittale tronco medio', 'ROM tronco sagittale', 'Angolo frontale tronco medio', 'ROM tronco frontale', 'Angolo torsione tronco medio', 'ROM tronco torsione'});

%% esportazione tabella in excel

nome_file_excel = 'Tabella Addu_orizz.xlsx';
writetable(Tabella_Addu_orizz, nome_file_excel);
