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
indice2 = {'angolo_spalla_medio', 'ROM_spalla', 'angolo_sagittale_medio', 'ROM_tronco_sagittale', 'angolo_frontale_medio', 'ROM_tronco_frontale', 'angolo_torsione_medio', 'ROM_tronco_torsione'};
task_motori = {'Addu', 'Addu_orizz', 'Flex', 'Circ', 'RandG'};
sottocartelle4 = {'Right', 'Left'};
sottocartelle5 = {'R_avanti', 'R_indietro', 'L_avanti', 'L_indietro'};
sottocartelle6 = {'Reach', 'Grasp'};
sottocartelle_ar = {'Andata', 'Ritorno', 'Totale'};
sottocartelle_ad = {'Accelerazione', 'Decelerazione', 'Totale'};

%%

t_norm = 0:1:100;       % griglia temporale a 101 punti (0% - 100%)
t_norm = t_norm(:).';       % Forziamo a vettore riga (1 x 101)

angolo_target = 'angolo_frontale_medio';

Matrice_Sani_Addu = [];
Matrice_Sani_Addu_orizz = [];
Matrice_Sani_Flex = [];
Matrice_Sani_Circ_avanti = [];
Matrice_Sani_Circ_indietro = [];
Matrice_Sani_Reach = [];

Matrice_Patologici_Addu_affettoT0 = [];
Matrice_Patologici_Addu_orizz_affettoT0 = [];
Matrice_Patologici_Flex_affettoT0 = [];
Matrice_Patologici_Circ_avanti_affettoT0 = [];
Matrice_Patologici_Circ_indietro_affettoT0 = [];
Matrice_Patologici_Reach_affettoT0 = [];

Matrice_Patologici_Addu_affettoT1 = [];
Matrice_Patologici_Addu_orizz_affettoT1 = [];
Matrice_Patologici_Flex_affettoT1 = [];
Matrice_Patologici_Circ_avanti_affettoT1 = [];
Matrice_Patologici_Circ_indietro_affettoT1 = [];
Matrice_Patologici_Reach_affettoT1 = [];

%{
Matrice_Sani_Addu_SX = [];
Matrice_Sani_Addu_orizz_SX = [];
Matrice_Sani_Flex_SX = [];
Matrice_Sani_Circ_avanti_SX = [];
Matrice_Sani_Circ_indietro_SX = [];
Matrice_Sani_Reach_SX = [];

Matrice_Patologici_Addu_affettoT0_SX = [];
Matrice_Patologici_Addu_orizz_affettoT0_SX = [];
Matrice_Patologici_Flex_affettoT0_SX = [];
Matrice_Patologici_Circ_avanti_affettoT0_SX = [];
Matrice_Patologici_Circ_indietro_affettoT0_SX = [];
Matrice_Patologici_Reach_affettoT0_SX = [];

Matrice_Patologici_Addu_affettoT1_SX = [];
Matrice_Patologici_Addu_orizz_affettoT1_SX = [];
Matrice_Patologici_Flex_affettoT1_SX = [];
Matrice_Patologici_Circ_avanti_affettoT1_SX = [];
Matrice_Patologici_Circ_indietro_affettoT1_SX = [];
Matrice_Patologici_Reach_affettoT1_SX = [];
%}

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

                                        if mm == 1     % dx
                                            Matrice_Sani_Addu(end+1, :) = ang_101(:).';
                                        elseif mm == 2     % sx
                                            Matrice_Sani_Addu(end+1, :) = - ang_101(:).';
                                        end
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

                                        if mm == 1     % dx
                                            Matrice_Sani_Addu_orizz(end+1, :) = ang_101(:).';
                                        elseif mm == 2     % sx
                                            Matrice_Sani_Addu_orizz(end+1, :) = - ang_101(:).';
                                        end
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

                                        if mm == 1     % dx
                                            Matrice_Sani_Flex(end+1, :) = ang_101(:).';
                                        elseif mm == 2     % sx
                                            Matrice_Sani_Flex(end+1, :) = - ang_101(:).';
                                        end
                                    end
                                end
                            end
                        end
                    end

                elseif ll == 4         % vale per Circ

                    for mm = 1:length(sottocartelle5)       % scorro dx e sx
                        lato_corrente = sottocartelle5{mm};

                        for oo = 1:length(sottocartelle_ar)         % scorro andata e ritorno
                            tratto_corrente = sottocartelle_ar{oo};

                            if oo == 3      % totale

                                for nn = 1:5        % scorro i 5 cicli          % DA CAMBIARE SE NON CI SONO TUTTI E 5 I CICLI
                                    nome_ciclo = sprintf('Ciclo_%d', nn);

                                    if isfield(Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente), nome_ciclo)

                                        vettore_ang = Database_angoli_articolari.(gruppo_corrente).(soggetto_corrente).(task_corrente).(lato_corrente).(tratto_corrente).(nome_ciclo).(angolo_target);

                                        t_orig = linspace(0, 100, length(vettore_ang));
                                        ang_101 = interp1(t_orig, vettore_ang, t_norm, 'spline');

                                        if mm == 1     % dx_avanti
                                            Matrice_Sani_Circ_avanti(end+1, :) = ang_101(:).';
                                        elseif mm == 2     % dx_indietro
                                            Matrice_Sani_Circ_indietro(end+1, :) = ang_101(:).';
                                        elseif mm == 3     % sx_avanti
                                            Matrice_Sani_Circ_avanti(end+1, :) = - ang_101(:).';
                                        elseif mm == 4     % sx_indietro
                                            Matrice_Sani_Circ_indietro(end+1, :) = - ang_101(:).';
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

                                                                    Matrice_Patologici_Addu_affettoT0(end+1, :) = - ang_101(:).';
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

                                                                    Matrice_Patologici_Addu_orizz_affettoT0(end+1, :) = - ang_101(:).';
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

                                                                    Matrice_Patologici_Flex_affettoT0(end+1, :) = - ang_101(:).';
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

                                                                    if strcmp(lato_corrente, 'R_avanti')
                                                                        Matrice_Patologici_Circ_avanti_affettoT0(end+1, :) = ang_101(:).';
                                                                    elseif strcmp(lato_corrente, 'R_indietro')
                                                                        Matrice_Patologici_Circ_indietro_affettoT0(end+1, :) = ang_101(:).';
                                                                    elseif strcmp(lato_corrente, 'L_avanti')
                                                                        Matrice_Patologici_Circ_avanti_affettoT0(end+1, :) = - ang_101(:).';
                                                                    elseif strcmp(lato_corrente, 'L_indietro')
                                                                        Matrice_Patologici_Circ_indietro_affettoT0(end+1, :) = - ang_101(:).';
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

                            for mm = 1:length(sottocartelle6)       % scorro reach e grasp
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

                                                                                    if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                                                                        Matrice_Patologici_Reach_affettoT0(end+1, :) = ang_101(:).';
                                                                                    elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                                                                        Matrice_Patologici_Reach_affettoT0(end+1, :) = - ang_101(:).';
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

                                                                    Matrice_Patologici_Addu_affettoT1(end+1, :) = - ang_101(:).';
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

                                                                    Matrice_Patologici_Addu_orizz_affettoT1(end+1, :) = - ang_101(:).';
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

                                                                    Matrice_Patologici_Flex_affettoT1(end+1, :) = - ang_101(:).';
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

                                                                    if strcmp(lato_corrente, 'R_avanti')
                                                                        Matrice_Patologici_Circ_avanti_affettoT1(end+1, :) = ang_101(:).';
                                                                    elseif strcmp(lato_corrente, 'R_indietro')
                                                                        Matrice_Patologici_Circ_indietro_affettoT1(end+1, :) = ang_101(:).';
                                                                    elseif strcmp(lato_corrente, 'L_avanti')
                                                                        Matrice_Patologici_Circ_avanti_affettoT1(end+1, :) = - ang_101(:).';
                                                                    elseif strcmp(lato_corrente, 'L_indietro')
                                                                        Matrice_Patologici_Circ_indietro_affettoT1(end+1, :) = - ang_101(:).';
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

                                                                                    if contains(string(lato_affetto), 'DX', 'IgnoreCase', true)
                                                                                        Matrice_Patologici_Reach_affettoT1(end+1, :) = ang_101(:).';
                                                                                    elseif contains(string(lato_affetto), 'SX', 'IgnoreCase', true)
                                                                                        Matrice_Patologici_Reach_affettoT1(end+1, :) = - ang_101(:).';
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
        end
    end
end

%% DEFINIZIONE PALETTE COLORI
col_sani  = [0.2, 0.6, 0.85]; % Blu
col_patT0 = [0.85, 0.3, 0.3]; % Rosso
col_patT1 = [0.5, 0.2, 0.6];  % Viola

% Palette Barre SPM1D
col_bar_Sani_T0 = [0.95, 0.45, 0.10]; % Arancione (Sani vs T0)
col_bar_Sani_T1 = [0.70, 0.45, 0.85]; % Viola chiaro (Sani vs T1)
col_bar_T0_T1   = [0.10, 0.60, 0.20]; % Verde (T0 vs T1)


%% 1. GRAFICO ADDUZIONE (Addu)
media_sani  = mean(Matrice_Sani_Addu, 1, 'omitnan'); media_sani = media_sani(:).';
sd_sani     = std(Matrice_Sani_Addu, 0, 1, 'omitnan');  sd_sani = sd_sani(:).';
media_patT0 = mean(Matrice_Patologici_Addu_affettoT0, 1, 'omitnan'); media_patT0 = media_patT0(:).';
sd_patT0    = std(Matrice_Patologici_Addu_affettoT0, 0, 1, 'omitnan');  sd_patT0 = sd_patT0(:).';
media_patT1 = mean(Matrice_Patologici_Addu_affettoT1, 1, 'omitnan'); media_patT1 = media_patT1(:).';
sd_patT1    = std(Matrice_Patologici_Addu_affettoT1, 0, 1, 'omitnan');  sd_patT1 = sd_patT1(:).';

figure('Color', 'w');
hold on; grid on;

% Ombreggiature SD
fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');
fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.25, 'HandleVisibility', 'off');

% Curve Medie
plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D
y_sig1 = -8.0; y_sig2 = -9.5; y_sig3 = -11.0;

disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', 'Addu', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', 'Addu', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   'Addu', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Tronco Frontale [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Addu', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-12, 12]);
yticks(-12:4:12);

% Dummy handles per legenda
h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Tronco_Front_Addu.png', 'Resolution', 300);

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

plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D
y_sig1 = -8.0; y_sig2 = -9.5; y_sig3 = -11.0;

disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', 'Addu_orizz', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', 'Addu_orizz', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   'Addu_orizz', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Tronco Frontale [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Addu orizz', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-12, 12]);
yticks(-12:4:12);

h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Tronco_Front_Addu_orizz.png', 'Resolution', 300);

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

plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D
y_sig1 = -8.0; y_sig2 = -9.5; y_sig3 = -11.0;

disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', 'Flex', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', 'Flex', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   'Flex', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Tronco Frontale [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Flex', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-12, 12]);
yticks(-12:4:12);

h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Tronco_Front_Flex.png', 'Resolution', 300);

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

plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D
y_sig1 = -8.0; y_sig2 = -9.5; y_sig3 = -11.0;

disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', 'Circ_avanti', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', 'Circ_avanti', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   'Circ_avanti', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Tronco Frontale [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Circ avanti', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-12, 12]);
yticks(-12:4:12);

h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Tronco_Front_Circ_avanti.png', 'Resolution', 300);

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

plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D
y_sig1 = -8.0; y_sig2 = -9.5; y_sig3 = -11.0;

disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', 'Circ_indietro', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', 'Circ_indietro', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   'Circ_indietro', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Tronco Frontale [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Circ indietro', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-12, 12]);
yticks(-12:4:12);

h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Tronco_Front_Circ_indietro.png', 'Resolution', 300);

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

plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.5, 'HandleVisibility', 'off');
plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.5, 'HandleVisibility', 'off');

% BARRE DI SIGNIFICATIVITÀ AUTOMATICHE SPM1D
y_sig1 = -8.0; y_sig2 = -9.5; y_sig3 = -11.0;

disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', 'Reach', y_sig1, col_bar_Sani_T0);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', 'Reach', y_sig2, col_bar_Sani_T1);
disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   'Reach', y_sig3, col_bar_T0_T1);

xlabel('Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Angolo Tronco Frontale [deg]', 'FontSize', 12, 'FontWeight', 'bold');
title('Andamento Angolare: Reach', 'FontSize', 13, 'FontWeight', 'bold');
xlim([0, 100]);
ylim([-12, 12]);
yticks(-12:4:12);

h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.5);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.5);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.5);
hb1  = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
hb2  = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
hb3  = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

legend([h1, h2, h3, hb1, hb2, hb3], {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, 'Location', 'northeast');
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 11, 'FontName', 'Arial');
exportgraphics(gcf, 'Angolo_Tronco_Front_Reach.png', 'Resolution', 300);

%% 7. GRAFICO UNIFICATO CON BARRE SPM1D (SCALA [-12, +12])
nomi_task = {'Addu', 'Addu_orizz', 'Circ_avanti', 'Circ_indietro', 'Flex', 'Reach'};
n_task = length(nomi_task);

figure('Color', 'w', 'Units', 'normalized', 'Position', [0.05, 0.05, 0.85, 0.8]);
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
    media_patT1 = mean(Matrice_T1, 1, 'omitnan'); % o Matrice_T1
    media_patT1 = mean(Matrice_T1, 1, 'omitnan');  media_patT1 = media_patT1(:).';
    sd_patT1    = std(Matrice_T1, 0, 1, 'omitnan');   sd_patT1 = sd_patT1(:).';
    
    % Ombreggiatura SD
    fill([t_norm, fliplr(t_norm)], [media_sani + sd_sani, fliplr(media_sani - sd_sani)], col_sani, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    fill([t_norm, fliplr(t_norm)], [media_patT0 + sd_patT0, fliplr(media_patT0 - sd_patT0)], col_patT0, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    fill([t_norm, fliplr(t_norm)], [media_patT1 + sd_patT1, fliplr(media_patT1 - sd_patT1)], col_patT1, 'EdgeColor', 'none', 'FaceAlpha', 0.20, 'HandleVisibility', 'off');
    
    % Curve Medie
    plot(t_norm, media_sani,  'Color', col_sani,  'LineWidth', 2.0, 'HandleVisibility', 'off');
    plot(t_norm, media_patT0, 'Color', col_patT0, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    plot(t_norm, media_patT1, 'Color', col_patT1, 'LineWidth', 2.0, 'HandleVisibility', 'off');
    
    % Coordinate Y per le barrette di significatività
    y_sig1 = -8.0; % Sani vs T0
    y_sig2 = -9.5; % Sani vs T1
    y_sig3 = -11.0;% T0 vs T1
    
    % TRACCIAMENTO AUTOMATICO DAI FILE EXCEL
    disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T0.xlsx', task_corrente, y_sig1, col_bar_Sani_T0);
    disegna_barre_spm('Risultati_SPM_Tronco_Frontale_Sani_vs_T1.xlsx', task_corrente, y_sig2, col_bar_Sani_T1);
    disegna_barre_spm('Risultati_SPM_Tronco_Frontale_T0_vs_T1.xlsx',   task_corrente, y_sig3, col_bar_T0_T1);
    
    % Formattazione Assi
    xlim([0 100]);
    ylim([-12, 12]);
    yticks(-12:4:12);
    task_pulita = strrep(nomi_task{ii}, '_', ' ');
    title(task_pulita, 'FontSize', 11, 'FontWeight', 'bold');
    hold off;
end

% --- ETICHETTE E LEGENDA UNICA CONDIVISA ---
xlabel(t, 'Ciclo di Movimento (%)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel(t, 'Angolo Tronco [°]', 'FontSize', 12, 'FontWeight', 'bold');
sgtitle('Traiettorie Angolari Medie del Tronco Frontale ± SD', 'FontSize', 13, 'FontWeight', 'bold');

% Dummy handles per la legenda condivisa
hold on;
h1   = plot(nan, nan, 'Color', col_sani,        'LineWidth', 2.0);
h2   = plot(nan, nan, 'Color', col_patT0,       'LineWidth', 2.0);
h3   = plot(nan, nan, 'Color', col_patT1,       'LineWidth', 2.0);
h_b1 = plot(nan, nan, 'Color', col_bar_Sani_T0, 'LineWidth', 3.5);
h_b2 = plot(nan, nan, 'Color', col_bar_Sani_T1, 'LineWidth', 3.5);
h_b3 = plot(nan, nan, 'Color', col_bar_T0_T1,   'LineWidth', 3.5);

lgd = legend([h1, h2, h3, h_b1, h_b2, h_b3], ...
    {'Sani', 'Patologici T0', 'Patologici T1', 'Sig. Sani vs T0', 'Sig. Sani vs T1', 'Sig. T0 vs T1'}, ...
    'Orientation', 'horizontal', 'FontSize', 9, 'FontWeight', 'bold');
lgd.Layout.Tile = 'north';

exportgraphics(gcf, 'Angolo_Tronco_frontale_unificato.png', 'Resolution', 300);

%% FUNZIONI AUSILIARIE PER LA LETTURA E IL DISEGNO AUTOMATICO DEI CLUSTER
function disegna_barre_spm(nome_file, task_target, y_quota, colore_barra)
    if exist(nome_file, 'file')
        tab = readtable(nome_file);
        idx_task = find(strcmpi(string(tab.Task), task_target));
        
        for k = 1:length(idx_task)
            riga = idx_task(k);
            sig_str = string(tab.Significativo{riga});
            
            if strcmpi(sig_str, 'SI')
                range_str = string(tab.Range_Ciclo_Percent{riga});
                valori = regexp(range_str, '\d+\.?\d*', 'match');
                valori_num = str2double(valori);
                
                for v = 1:2:length(valori_num)
                    if v+1 <= length(valori_num)
                        x_start = valori_num(v);
                        x_end   = valori_num(v+1);
                        plot([x_start, x_end], [y_quota, y_quota], 'Color', colore_barra, 'LineWidth', 3.5, 'HandleVisibility', 'off');
                    end
                end
            end
        end
    end
end