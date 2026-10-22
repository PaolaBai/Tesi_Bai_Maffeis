clear
close all
clc

%% caricamento struct con indici

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
sottocartelle4 = {'Right', 'Left'};
sottocartelle5 = {'R_avanti', 'R_indietro', 'L_avanti', 'L_indietro'};
sottocartelle6 = {'Reach', 'Grasp'};
sottocartelle_ar = {'Andata', 'Ritorno', 'Totale'};
sottocartelle_ad = {'Accelerazione', 'Decelerazione', 'Totale'};

%%

t_norm = 0:1:100;       % griglia temporale a 101 punti (0% - 100%)
t_norm = t_norm(:).';       % Forziamo a vettore riga (1 x 101)

angolo_target = 'angolo_spalla_medio';

Matrice_Sani_Addu = [];
Matrice_Sani_Addu_orizz = [];
Matrice_Sani_Flex = [];
Matrice_Sani_Circ_avanti = [];
Matrice_Sani_Circ_indietro = [];
Matrice_Sani_Reach = [];
Matrice_Sani_Grasp = [];

Matrice_Patologici_Addu_affettoT0 = [];
Matrice_Patologici_Addu_orizz_affettoT0 = [];
Matrice_Patologici_Flex_affettoT0 = [];
Matrice_Patologici_Circ_avanti_affettoT0 = [];
Matrice_Patologici_Circ_indietro_affettoT0 = [];
Matrice_Patologici_Reach_affettoT0 = [];
Matrice_Patologici_Grasp_affettoT0 = [];

Matrice_Patologici_Addu_affettoT1 = [];
Matrice_Patologici_Addu_orizz_affettoT1 = [];
Matrice_Patologici_Flex_affettoT1 = [];
Matrice_Patologici_Circ_avanti_affettoT1 = [];
Matrice_Patologici_Circ_indietro_affettoT1 = [];
Matrice_Patologici_Reach_affettoT1 = [];
Matrice_Patologici_Grasp_affettoT1 = [];

info_soggetti = readtable('Tabella lato affetto.xlsx');

%% ESTRAZIONE DINAMICA DAI GRUPPI

for ii = 1:length(gruppo)       % scorro i gruppi
    gruppo_corrente = gruppo{ii};

    if ii == 1      % sono in sani

        for jj = 1:length(id_sano)      % scorro i soggetti
            soggetto_corrente = id_sano{jj};

            for ll = 1:length(task_motori)         % scorro le task
                task_corrente = task_motori{ll};

                if ll == 1         % vale per Addu (ll=1)

                    for mm = 1:length(sottocartelle4)       % scorro dx e sx
                        lato_corrente = sottocartelle4{mm};

                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                            tratto_corrente = sottocartelle_ar{oo};

                            if oo == 3      % totale

                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                        vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                        t_orig = linspace(0, 100, length(vettore_ang));         % normalizzazione
                                        ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                        Matrice_Sani_Addu(end+1, :) = ang_101(:).';     % dx + sx
                                    end
                                end
                            end
                        end
                    end

                elseif ll == 2         % vale per Addu_orizz

                    for mm = 1:length(sottocartelle4)       % scorro dx e sx
                        lato_corrente = sottocartelle4{mm};

                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                            tratto_corrente = sottocartelle_ar{oo};

                            if oo == 3      % totale

                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                        vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                        t_orig = linspace(0, 100, length(vettore_ang));
                                        ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                        Matrice_Sani_Addu_orizz(end+1, :) = ang_101(:).';       % dx + sx
                                    end
                                end
                            end
                        end
                    end

                elseif ll == 3         % vale per Flex

                    for mm = 1:length(sottocartelle4)       % scorro dx e sx
                        lato_corrente = sottocartelle4{mm};

                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                            tratto_corrente = sottocartelle_ar{oo};

                            if oo == 3      % totale

                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                        vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                        t_orig = linspace(0, 100, length(vettore_ang));
                                        ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                        Matrice_Sani_Flex(end+1, :) = ang_101(:).';     % dx + sx
                                    end
                                end
                            end
                        end
                    end

                elseif ll == 4         % vale per Circ

                    sensi = {'avanti', 'indietro'};
                    lati = {'R', 'L'};

                    for ss = 1:length(sensi)
                        senso_corrente = sensi{ss};

                        for mm = 1:length(lati)
                            str_lato = lati{mm};

                            lato_corrente = sprintf('%s_%s', str_lato, senso_corrente);

                            for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                tratto_corrente = sottocartelle_ar{oo};

                                if oo == 3      % totale

                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                            vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                            t_orig = linspace(0, 100, length(vettore_ang));
                                            ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                            if strcmp(senso_corrente, 'avanti')
                                                Matrice_Sani_Circ_avanti(end+1, :) = ang_101(:).';         % dx avanti + sx avanti
                                            else
                                                Matrice_Sani_Circ_indietro(end+1, :) = ang_101(:).';         % dx indietro + sx indietro
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end

                elseif ll == 5         % vale per RandG

                    for mm = 1:length(sottocartelle6)       % scorro dx e sx
                        lato_corrente = sottocartelle6{mm};

                        if mm == 1           % sono in reach

                            for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                tratto_corrente = sottocartelle_ar{oo};

                                if oo == 3      % totale

                                    for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                        accelerazione_corrente = sottocartelle_ad{qq};

                                        if qq == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                    Matrice_Sani_Reach(end+1, :) = ang_101(:).';
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            %{
                        elseif mm == 2      % sono in grasp

                            for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                tratto_corrente = sottocartelle_ar{oo};

                                if oo == 3      % totale

                                    for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                        accelerazione_corrente = sottocartelle_ad{qq};

                                        if qq == 3      % totale

                                            for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                nome_ciclo = sprintf('Ciclo_%d', nn);

                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                    Matrice_Sani_Grasp(end+1, :) = ang_101(:).';
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            %}
                        end
                    end
                end
            end
        end

    elseif ii == 2      % sono in patologici

        for jj = 1:length(id_patologico)      % scorro i soggetti
            soggetto_corrente = id_patologico{jj};

            riga_soggetto = strcmp(info_soggetti{:, 1}, soggetto_corrente);
            lato_affetto = info_soggetti{riga_soggetto, 2};

            for pp = 1:length(timepoint_patologico)
                timepoint_corrente = timepoint_patologico{pp};

                if pp == 1         % sono al tempo T0

                    for ll = 1:length(task_motori)         % scorro le task
                        task_corrente = task_motori{ll};

                        if ll == 1         % vale per Addu (ll=1)

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                mm = 1;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_affettoT0(end+1, :) = ang_101(:).';
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                mm = 2;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_affettoT0(end+1, :) = ang_101(:).';
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

                        elseif ll == 2         % vale per Addu_orizz

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                mm = 1;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_orizz_affettoT0(end+1, :) = ang_101(:).';
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                mm = 2;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_orizz_affettoT0(end+1, :) = ang_101(:).';
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

                        elseif ll == 3         % vale per Flex

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                mm = 1;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Flex_affettoT0(end+1, :) = ang_101(:).';
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                mm = 2;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Flex_affettoT0(end+1, :) = ang_101(:).';
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

                        elseif ll == 4         % vale per Circ

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)         % identificazione lato
                                str_lato = 'R';
                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                str_lato = 'L';
                            end

                            sensi = {'avanti', 'indietro'};

                            for ss = 1:length(sensi)
                                senso_corrente = sensi{ss};         % identificazioen senso

                                lato_corrente = sprintf('%s_%s', str_lato, senso_corrente);

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    if strcmp(senso_corrente, 'avanti')
                                                                        Matrice_Patologici_Circ_avanti_affettoT0(end+1, :) = ang_101(:).';
                                                                    else
                                                                        Matrice_Patologici_Circ_indietro_affettoT0(end+1, :) = ang_101(:).';
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

                        elseif ll == 5         % vale per RandG

                            for mm = 1:length(sottocartelle6)       % scorro dx e sx
                                lato_corrente = sottocartelle6{mm};

                                if mm == 1           % sono in reach

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Reach_affettoT0(end+1, :) = ang_101(:).';
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
                                    %{
                                elseif mm == 2      % sono in grasp

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Grasp_affettoT0(end+1, :) = ang_101(:).';
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
                                    %}
                                end
                            end
                        end
                    end

                elseif pp == 2          % sono al tempo T1

                    for ll = 1:length(task_motori)         % scorro le task
                        task_corrente = task_motori{ll};

                        if ll == 1         % vale per Addu (ll=1)

                            lato_corrente = sottocartelle4{mm};

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                mm = 1;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_affettoT1(end+1, :) = ang_101(:).';
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                mm = 2;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_affettoT1(end+1, :) = ang_101(:).';
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

                        elseif ll == 2         % vale per Addu_orizz

                            lato_corrente = sottocartelle4{mm};

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                mm = 1;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_orizz_affettoT1(end+1, :) = ang_101(:).';
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                mm = 2;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Addu_orizz_affettoT1(end+1, :) = ang_101(:).';
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

                        elseif ll == 3         % vale per Flex

                            lato_corrente = sottocartelle4{mm};

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                mm = 1;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Flex_affettoT1(end+1, :) = ang_101(:).';
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                mm = 2;           % sono in dx
                                lato_corrente = sottocartelle4{mm};

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    Matrice_Patologici_Flex_affettoT1(end+1, :) = ang_101(:).';
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

                        elseif ll == 4         % vale per Circ

                            if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)         % identificazione lato
                                str_lato = 'R';
                            elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                str_lato = 'L';
                            end

                            sensi = {'avanti', 'indietro'};

                            for ss = 1:length(sensi)
                                senso_corrente = sensi{ss};         % identificazione senso

                                lato_corrente = sprintf('%s_%s', str_lato, senso_corrente);

                                for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                    tratto_corrente = sottocartelle_ar{oo};

                                    if oo == 3      % totale

                                        for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                            nome_ciclo = sprintf('Ciclo_%d', nn);

                                            if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                    if strcmp(senso_corrente, 'avanti')
                                                                        Matrice_Patologici_Circ_avanti_affettoT1(end+1, :) = ang_101(:).';
                                                                    else
                                                                        Matrice_Patologici_Circ_indietro_affettoT1(end+1, :) = ang_101(:).';
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

                        elseif ll == 5         % vale per RandG

                            for mm = 1:length(sottocartelle6)       % scorro dx e sx
                                lato_corrente = sottocartelle6{mm};

                                if mm == 1           % sono in reach

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Reach_affettoT1(end+1, :) = ang_101(:).';
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
                                    %{
                                elseif mm == 2      % sono in grasp

                                    for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                                        tratto_corrente = sottocartelle_ar{oo};

                                        if oo == 3      % totale

                                            for qq = 1:length(sottocartelle_ad)         % scorro accelerazione, decelerazione, totale
                                                accelerazione_corrente = sottocartelle_ad{qq};

                                                if qq == 3      % totale

                                                    for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                                        nome_ciclo = sprintf('Ciclo_%d', nn);

                                                        if isfield(Database_angoli_articolari.(gruppo_corrente), soggetto_corrente)
                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente), timepoint_corrente)
                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente), task_corrente)
                                                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente), lato_corrente)
                                                                        if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente), tratto_corrente)
                                                                            if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente), accelerazione_corrente)
                                                                                if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente), nome_ciclo)

                                                                                    vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(timepoint_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(accelerazione_corrente).(nome_ciclo).(angolo_target);

                                                                                    t_orig = linspace(0, 100, length(vettore_ang));
                                                                                    ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                                                                    Matrice_Patologici_Grasp_affettoT1(end+1, :) = ang_101(:).';
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
                                    %}
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%% FUNZIONE LOCALE PER ESTRAZIONE AUTOMATICA CLUSTER SPM1D
% (Verrà usata sotto per leggere direttamente i file Excel dei cluster)
estrai_cluster = @(nome_file, task_target) estrai_cluster_spm(nome_file, task_target);

%% 1. GRAFICO ADDUZIONE (Addu)
media_sani  = mean(Matrice_Sani_Addu, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Addu, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Addu_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Addu_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Addu_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Addu_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

col_sani  = [0.2, 0.6, 0.85]; 
col_patT0 = [0.85, 0.3, 0.3];  
col_patT1 = [0.5, 0.2, 0.6];  
col_bar_Sani_T0 = [0.95, 0.45, 0.1];
col_bar_Sani_T1 = [0.7, 0.45, 0.85];
col_bar_T0_T1   = [0.1, 0.6, 0.2];

% SD
fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

% Curve medie
h1 = plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'DisplayName', 'Sani');
h2 = plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'DisplayName', 'Patologici T0');
h3 = plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'DisplayName', 'Patologici T1');

% TRACCIAMENTO AUTOMATICO BARRE DI SIGNIFICATIVITÀ SPM1D
y_sig1 = -8;  y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', 'Addu', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', 'Addu', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   'Addu', y_sig3, col_bar_T0_T1);

hb1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T0');
hb2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T1');
hb3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4, 'DisplayName', 'Sig. T0 vs T1');

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Spalla [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Addu', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);
legend([h1, h2, h3, hb1, hb2, hb3], 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Spalla_Addu.png', 'Resolution', 300);

%% 2. GRAFICO ADDUZIONE ORIZZONTALE (Addu_orizz)
media_sani  = mean(Matrice_Sani_Addu_orizz, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Addu_orizz, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Addu_orizz_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Addu_orizz_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Addu_orizz_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Addu_orizz_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

h1 = plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'DisplayName', 'Sani');
h2 = plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'DisplayName', 'Patologici T0');
h3 = plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'DisplayName', 'Patologici T1');

% TRACCIAMENTO AUTOMATICO BARRE DI SIGNIFICATIVITÀ SPM1D
y_sig1 = -8; y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', 'Addu_orizz', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', 'Addu_orizz', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   'Addu_orizz', y_sig3, col_bar_T0_T1);

hb1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T0');
hb2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T1');
hb3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4, 'DisplayName', 'Sig. T0 vs T1');

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Spalla [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Addu orizz', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);
legend([h1, h2, h3, hb1, hb2, hb3], 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Spalla_Addu_orizz.png', 'Resolution', 300);

%% 3. GRAFICO FLESSIONE (Flex)
media_sani  = mean(Matrice_Sani_Flex, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Flex, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Flex_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Flex_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Flex_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Flex_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

h1 = plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'DisplayName', 'Sani');
h2 = plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'DisplayName', 'Patologici T0');
h3 = plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'DisplayName', 'Patologici T1');

% TRACCIAMENTO AUTOMATICO BARRE DI SIGNIFICATIVITÀ SPM1D
y_sig1 = -8; y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', 'Flex', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', 'Flex', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   'Flex', y_sig3, col_bar_T0_T1);

hb1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T0');
hb2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T1');
hb3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4, 'DisplayName', 'Sig. T0 vs T1');

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Spalla [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Flex', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);
legend([h1, h2, h3, hb1, hb2, hb3], 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Spalla_Flex.png', 'Resolution', 300);

%% 4. GRAFICO CIRCONDUZIONE AVANTI (Circ_avanti)
media_sani  = mean(Matrice_Sani_Circ_avanti, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Circ_avanti, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Circ_avanti_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Circ_avanti_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Circ_avanti_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Circ_avanti_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

h1 = plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'DisplayName', 'Sani');
h2 = plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'DisplayName', 'Patologici T0');
h3 = plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'DisplayName', 'Patologici T1');

% TRACCIAMENTO AUTOMATICO BARRE DI SIGNIFICATIVITÀ SPM1D
y_sig1 = -8; y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', 'Circ_avanti', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', 'Circ_avanti', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   'Circ_avanti', y_sig3, col_bar_T0_T1);

hb1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T0');
hb2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T1');
hb3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4, 'DisplayName', 'Sig. T0 vs T1');

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Spalla [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Circ avanti', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);
legend([h1, h2, h3, hb1, hb2, hb3], 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Spalla_Circ_avanti.png', 'Resolution', 300);

%% 5. GRAFICO CIRCONDUZIONE INDIETRO (Circ_indietro)
media_sani  = mean(Matrice_Sani_Circ_indietro, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Circ_indietro, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Circ_indietro_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Circ_indietro_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Circ_indietro_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Circ_indietro_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

h1 = plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'DisplayName', 'Sani');
h2 = plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'DisplayName', 'Patologici T0');
h3 = plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'DisplayName', 'Patologici T1');

% TRACCIAMENTO AUTOMATICO BARRE DI SIGNIFICATIVITÀ SPM1D
y_sig1 = -8; y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', 'Circ_indietro', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', 'Circ_indietro', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   'Circ_indietro', y_sig3, col_bar_T0_T1);

hb1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T0');
hb2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T1');
hb3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4, 'DisplayName', 'Sig. T0 vs T1');

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Spalla [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Circ indietro', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);
legend([h1, h2, h3, hb1, hb2, hb3], 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Spalla_Circ_indietro.png', 'Resolution', 300);

%% 6. GRAFICO REACH (Reach)
media_sani  = mean(Matrice_Sani_Reach, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Reach, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Reach_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Reach_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Reach_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Reach_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

h1 = plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'DisplayName', 'Sani');
h2 = plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'DisplayName', 'Patologici T0');
h3 = plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'DisplayName', 'Patologici T1');

% TRACCIAMENTO AUTOMATICO BARRE DI SIGNIFICATIVITÀ SPM1D
y_sig1 = -8; y_sig2 = -16; y_sig3 = -24;

disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', 'Reach', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', 'Reach', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   'Reach', y_sig3, col_bar_T0_T1);

hb1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T0');
hb2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4, 'DisplayName', 'Sig. Sani vs T1');
hb3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4, 'DisplayName', 'Sig. T0 vs T1');

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Articolare Spalla [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Reach', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-30, 150]);
yticks(0:25:150);
legend([h1, h2, h3, hb1, hb2, hb3], 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Spalla_Reach.png', 'Resolution', 300);

%% 7. GRAFICO UNIFICATO CON BARRE DI SIGNIFICATIVITÀ SPM1D
nomi_task = {'Addu', 'Addu_orizz', 'Circ_avanti', 'Circ_indietro', 'Flex', 'Reach'};
piani_movimento = {'Piano Frontale', 'Piano Trasverso', 'Piano Sagittale', 'Piano Sagittale', 'Piano Sagittale', 'Piano Sagittale'};
n_task = length(nomi_task);

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.05, 0.05, 0.85, 0.85]);
t = tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

for ii = 1:n_task
    nexttile;
    hold on; grid on;
    task_corrente = nomi_task{ii};
    
    Matrice_Sani = eval(['Matrice_Sani_' task_corrente]);
    Matrice_T0   = eval(['Matrice_Patologici_' task_corrente '_affettoT0']);
    Matrice_T1   = eval(['Matrice_Patologici_' task_corrente '_affettoT1']);
    
    media_sani = mean(Matrice_Sani, 1, 'omitnan'); media_sani = media_sani(:).';
    sd_sani    = std(Matrice_Sani, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
    media_patT0 = mean(Matrice_T0, 1, 'omitnan');  media_patT0 = media_patT0(:).';
    sd_patT0    = std(Matrice_T0, 0, 1, 'omitnan');   sd_patT0 = sd_patT0(:).';
    media_patT1 = mean(Matrice_T1, 1, 'omitnan');  media_patT1 = media_patT1(:).';
    sd_patT1    = std(Matrice_T1, 0, 1, 'omitnan');   sd_patT1 = sd_patT1(:).';
    
    % Ombreggiatura SD
    fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    
    % Tracciamento Curve Medie
    plot(t_norm, media_sani, 'Color', col_sani, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    
    % Coordinate Y per le 3 barrette
    y_sig1 = -8;   % Sani vs T0
    y_sig2 = -16;  % Sani vs T1
    y_sig3 = -24;  % T0 vs T1
    
    % TRACCIAMENTO AUTOMATICO DAI FILE EXCEL
    disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T0.xlsx', task_corrente, y_sig1, col_bar_Sani_T0);
    disegna_barre_spm('Risultati_SPM_Spalla_Sani_vs_T1.xlsx', task_corrente, y_sig2, col_bar_Sani_T1);
    disegna_barre_spm('Risultati_SPM_Spalla_T0_vs_T1.xlsx',   task_corrente, y_sig3, col_bar_T0_T1);
    
    % Formattazione Assi
    xlim([0 100]);
    ylim([-30, 150]);
    yticks(0:25:150);
    task_pulita = strrep(nomi_task{ii}, '_', ' ');
    title({task_pulita, sprintf('\\fontsize{9}\\rm%s', piani_movimento{ii})}, 'FontSize', 11, 'FontWeight', 'bold');
    hold off;
end

% --- ETICHETTE E LEGENDA CONDIVISA ---
xlabel(t, 'Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(t, 'Angolo Spalla [°]', 'FontSize', 12, 'FontWeight', 'bold');
sgtitle('Traiettorie Angolari Medie della Spalla ± SD', 'FontSize', 13, 'FontWeight', 'bold');

% CREAZIONE HANDLE FITTIZI (DUMMY HANDLES) DENTRO LA FIGURA PER LA LEGENDA
hold on;
h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.0);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.0);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.0);
h_b1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 4.0);
h_b2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 4.0);
h_b3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 4.0);

lgd = legend([h1, h2, h3, h_b1, h_b2, h_b3], ...
    {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, ...
    'Orientation', 'horizontal', 'FontSize', 9, 'FontWeight', 'bold');
lgd.Layout.Tile = 'north';

exportgraphics(gcf, 'Angolo_Spalla_unificato_con_SPM.png', 'Resolution', 300);

%% FUNZIONI AUSILIARIE PER LA LETTURA E IL DISEGNO AUTOMATICO DEI CLUSTER
function disegna_barre_spm(nome_file, task_target, y_quota, colore_barra)
    if exist(nome_file, 'file')
        tab = readtable(nome_file);
        % Cerca la riga corrispondente alla task corrente
        idx_task = find(strcmpi(string(tab.Task), task_target));
        
        for k = 1:length(idx_task)
            riga = idx_task(k);
            sig_str = string(tab.Significativo{riga});
            
            if strcmpi(sig_str, 'SI')
                range_str = string(tab.Range_Ciclo_Percent{riga});
                
                % Estrae tutti i numeri decimali presenti nella stringa (es. "61.6" e "83.5")
                valori = regexp(range_str, '\d+\.?\d*', 'match');
                valori_num = str2double(valori);
                
                % Se ci sono coppiette di inizio-fine, le disegna tutte
                for v = 1:2:length(valori_num)
                    if v+1 <= length(valori_num)
                        x_start = valori_num(v);
                        x_end   = valori_num(v+1);
                        plot([x_start, x_end], [y_quota, y_quota], 'Color', colore_barra, 'LineWidth', 4, 'HandleVisibility', 'off');
                    end
                end
            end
        end
    end
end