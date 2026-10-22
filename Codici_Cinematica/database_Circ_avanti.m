clear
close all
clc

%% 

Tabella_Circ = readtable('Tabella Circ.xlsx'); 
info_soggetti = readtable('Tabella lato affetto.xlsx');

num_metriche = 18;
nomi_metriche = {'jerkMean_Andata', 'jerkMean_Ritorno', 'jerkPeak_Andata', 'jerkPeak_Ritorno', 'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno',...
    'Angolo spalla', 'ROM Spalla', 'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

%% DATABASE SANI (DX vs SX)

filtro_T = (string(Tabella_Circ.Timepoint) == "T");
filtro_cicli = (string(Tabella_Circ.Ciclo) == "Media Cicli");
filtro_movimento = contains(string(Tabella_Circ.Lato), "avanti", 'IgnoreCase', true);
tab_grezza_sani = Tabella_Circ(filtro_T & filtro_cicli & filtro_movimento, :);

soggetti_sani = unique(string(tab_grezza_sani.Soggetto));
num_soggetti_sani = length(soggetti_sani);

colonne_Dx = strcat(nomi_metriche, '_Dx');
colonne_Sx = strcat(nomi_metriche, '_Sx');

headers_sani = [{'Soggetto'}, colonne_Dx, colonne_Sx];
dati_sani = cell(num_soggetti_sani, length(headers_sani));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);
    dati_sani{ii, 1} = soggetto_corrente;

    lati = {'Dx', 'Sx'};
    
    for jj = 1:length(lati)
        lato_corrente = lati{jj};

        vals = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, lato_corrente);
        
        idx_inizio = 2 + (jj - 1) * num_metriche;

        for kk = 1:num_metriche
            dati_sani{ii, idx_inizio + kk - 1} = vals(kk);
        end
    end
end

% salvataggio
Database_Sani = cell2table(dati_sani, 'VariableNames', headers_sani);
writetable(Database_Sani, 'Database Sani_Circ avanti.xlsx');

%% DATABASE PATOLOGICI T0 (AFFETTO vs NON AFFETTO)

filtro_T0 = (string(Tabella_Circ.Timepoint) == "T0");
filtro_cicli = (string(Tabella_Circ.Ciclo) == "Media Cicli");
tab_grezza_pat_T0 = Tabella_Circ(filtro_T0 & filtro_cicli & filtro_movimento, :);

num_pat = height(info_soggetti);

colonne_Affetto = strcat(nomi_metriche, '_Affetto');
colonne_NonAffetto = strcat(nomi_metriche, '_NonAffetto');

headers_pat = [{'Soggetto', 'Lato Affetto'}, colonne_Affetto, colonne_NonAffetto];
dati_pat = cell(num_pat, length(headers_pat));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));
    
    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = lato_affetto;
    
    if lato_affetto == "DX"
        lati_ordine = {'Dx', 'Sx'};
    elseif lato_affetto == "SX"
        lati_ordine = {'Sx', 'Dx'};
    end
    
    for jj = 1:length(lati_ordine)
        lato_corrente = lati_ordine{jj};

        vals = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_corrente);
        
        idx_inizio = 3 + (jj - 1) * num_metriche;

        for kk = 1:num_metriche
            dati_pat{ii, idx_inizio + kk - 1} = vals(kk);
        end
    end
end

% salvataggio
Database_Patologici_T0 = cell2table(dati_pat, 'VariableNames', headers_pat);
writetable(Database_Patologici_T0, 'Database Patologici T0_Circ avanti.xlsx');

%% DATABASE PATOLOGICI T1 (AFFETTO vs NON AFFETTO)

filtro_T1 = (string(Tabella_Circ.Timepoint) == "T1");
filtro_cicli = (string(Tabella_Circ.Ciclo) == "Media Cicli");
tab_grezza_pat_T1 = Tabella_Circ(filtro_T1 & filtro_cicli & filtro_movimento, :);

num_pat = height(info_soggetti);

colonne_Affetto = strcat(nomi_metriche, '_Affetto');
colonne_NonAffetto = strcat(nomi_metriche, '_NonAffetto');

headers_pat = [{'Soggetto', 'Lato Affetto'}, colonne_Affetto, colonne_NonAffetto];
dati_pat = cell(num_pat, length(headers_pat));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = lato_affetto;

    if lato_affetto == "DX"
        lati_ordine = {'Dx', 'Sx'};
    elseif lato_affetto == "SX"
        lati_ordine = {'Sx', 'Dx'};
    end

    for jj = 1:length(lati_ordine)
        lato_corrente = lati_ordine{jj};

        vals = fun_estrai_metriche_lato(tab_grezza_pat_T1, soggetto_corrente, lato_corrente);

        idx_inizio = 3 + (jj - 1) * num_metriche;

        for kk = 1:num_metriche
            dati_pat{ii, idx_inizio + kk - 1} = vals(kk);
        end
    end
end

% salvataggio
Database_Patologici_T0 = cell2table(dati_pat, 'VariableNames', headers_pat);
writetable(Database_Patologici_T0, 'Database Patologici T1_Circ avanti.xlsx');

%% SANI (Media Dx/Sx) vs PATOLOGICI T0 (Lato Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'Media DX/SX';
    
    vals_Dx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Dx');
    vals_Sx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Sx');
    
    vals_medio = mean([vals_Dx; vals_Sx], 1, 'omitnan');
    
    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_medio(kk);
    end
end

% patologici T0
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));
    
    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_affetto;
    
    vals_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_affetto);
    
    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani vs Patologici affetto T0_Circ avanti.xlsx');

%% SANI (Dx) vs PATOLOGICI T0 (Lato Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'DX';

    vals_Dx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Dx');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_Dx(kk);
    end
end

% patologici T0
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_affetto;

    vals_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani(Dx) vs Patologici affetto T0_Circ avanti.xlsx');

%% SANI (Sx) vs PATOLOGICI T0 (Lato Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'SX';

    vals_Sx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Sx');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_Sx(kk);
    end
end

% patologici T0
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_affetto;

    vals_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani(Sx) vs Patologici affetto T0_Circ avanti.xlsx');

%% SANI (Media Dx/Sx) vs PATOLOGICI T0 (Lato non Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'Media DX/SX';

    vals_Dx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Dx');
    vals_Sx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Sx');

    vals_medio = mean([vals_Dx; vals_Sx], 1, 'omitnan');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_medio(kk);
    end
end

% patologici T0
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    if lato_affetto == "DX"
        lato_non_affetto = "SX";
    elseif lato_affetto == "SX"
        lato_non_affetto = "DX";
    end

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_non_affetto;

    vals_non_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_non_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_non_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani vs Patologici non affetto T0_Circ avanti.xlsx');


%% SANI (Dx) vs PATOLOGICI T0 (Lato non Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'DX';

    vals_Dx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Dx');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_Dx(kk);
    end
end

% patologici T0
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    if lato_affetto == "DX"
        lato_non_affetto = "SX";
    elseif lato_affetto == "SX"
        lato_non_affetto = "DX";
    end

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_non_affetto;

    vals_non_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_non_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_non_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani(Dx) vs Patologici non affetto T0_Circ avanti.xlsx');

%% SANI (Sx) vs PATOLOGICI T0 (Lato non Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'SX';

    vals_Sx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Sx');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_Sx(kk);
    end
end

% patologici T0
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    if lato_affetto == "DX"
        lato_non_affetto = "SX";
    elseif lato_affetto == "SX"
        lato_non_affetto = "DX";
    end

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_non_affetto;

    vals_non_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_non_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_non_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani(Sx) vs Patologici non affetto T0_Circ avanti.xlsx');

%% SANI (Media Dx/Sx) vs PATOLOGICI T1 (Lato Affetto)

filtro_T1 = (string(Tabella_Circ.Timepoint) == "T1");
filtro_cicli = (string(Tabella_Circ.Ciclo) == "Media Cicli");
tab_grezza_pat_T1 = Tabella_Circ(filtro_T1 & filtro_cicli & filtro_movimento, :);

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'Media DX/SX';
    
    vals_Dx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Dx');
    vals_Sx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Sx');
    
    vals_medio = mean([vals_Dx; vals_Sx], 1, 'omitnan');
    
    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_medio(kk);
    end
end

% patologici T1
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));
    
    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_affetto;
    
    vals_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T1, soggetto_corrente, lato_affetto);
    
    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T1 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T1, 'Database Sani vs Patologici T1_Circ avanti.xlsx');

%% SANI (Dx) vs PATOLOGICI T1 (Lato Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'DX';

    vals_Dx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Dx');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_Dx(kk);
    end
end

% patologici T1
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_affetto;

    vals_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T1, soggetto_corrente, lato_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T1 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T1, 'Database Sani(Dx) vs Patologici T1_Circ avanti.xlsx');

%% SANI (Sx) vs PATOLOGICI T1 (Lato Affetto)

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'SX';

    vals_Sx = fun_estrai_metriche_lato(tab_grezza_sani, soggetto_corrente, 'Sx');

    for kk = 1:num_metriche
        dati_sani{ii, 3 + kk} = vals_Sx(kk);
    end
end

% patologici T1
dati_pat = cell(num_pat, length(headers_tot));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2})));

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = 'Patologico';
    dati_pat{ii, 3} = lato_affetto;

    vals_affetto = fun_estrai_metriche_lato(tab_grezza_pat_T1, soggetto_corrente, lato_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T1 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T1, 'Database Sani(Sx) vs Patologici T1_Circ avanti.xlsx');

%% DATABASE PATOLOGICI (lato affetto, T0 vs T1)

tab_grezza_pat_T0 = Tabella_Circ(filtro_T0 & filtro_cicli & filtro_movimento, :);
tab_grezza_pat_T1 = Tabella_Circ(filtro_T1 & filtro_cicli & filtro_movimento, :);

num_pat = height(info_soggetti);

colonne_T0 = strcat(nomi_metriche, '_T0');
colonne_T1 = strcat(nomi_metriche, '_T1');

headers_pat = [{'Soggetto', 'Lato Affetto'}, colonne_T0, colonne_T1];
dati_pat = cell(num_pat, length(headers_pat));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2}))); % "DX" o "SX"
    
    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = lato_affetto;
    
    vals_T0 = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_affetto);
    
    vals_T1 = fun_estrai_metriche_lato(tab_grezza_pat_T1, soggetto_corrente, lato_affetto);
    
    for kk = 1:num_metriche
        dati_pat{ii, 2 + kk} = vals_T0(kk);
    end
    
    for kk = 1:num_metriche
        dati_pat{ii, 2 + num_metriche + kk} = vals_T1(kk);
    end
end

% salvataggio 
Database_Patologici_T0_vs_T1 = cell2table(dati_pat, 'VariableNames', headers_pat);
writetable(Database_Patologici_T0_vs_T1, 'Database Patologici lato affetto (T0 vs T1)_Circ avanti.xlsx');

%% DATABASE PATOLOGICI (lato non affetto, T0 vs T1)

tab_grezza_pat_T0 = Tabella_Circ(filtro_T0 & filtro_cicli & filtro_movimento, :);
tab_grezza_pat_T1 = Tabella_Circ(filtro_T1 & filtro_cicli & filtro_movimento, :);

num_pat = height(info_soggetti);

colonne_T0 = strcat(nomi_metriche, '_T0');
colonne_T1 = strcat(nomi_metriche, '_T1');

headers_pat = [{'Soggetto', 'Lato Non Affetto'}, colonne_T0, colonne_T1];
dati_pat = cell(num_pat, length(headers_pat));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto = upper(strip(string(info_soggetti{ii, 2}))); % "DX" o "SX"

    if lato_affetto == "DX"
        lato_non_affetto = "SX";
    elseif lato_affetto == "SX"
        lato_non_affetto = "DX";
    end

    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = lato_non_affetto;

    vals_T0 = fun_estrai_metriche_lato(tab_grezza_pat_T0, soggetto_corrente, lato_non_affetto);

    vals_T1 = fun_estrai_metriche_lato(tab_grezza_pat_T1, soggetto_corrente, lato_non_affetto);

    for kk = 1:num_metriche
        dati_pat{ii, 2 + kk} = vals_T0(kk);
    end

    for kk = 1:num_metriche
        dati_pat{ii, 2 + num_metriche + kk} = vals_T1(kk);
    end
end

% salvataggio 
Database_Patologici_T0_vs_T1 = cell2table(dati_pat, 'VariableNames', headers_pat);
writetable(Database_Patologici_T0_vs_T1, 'Database Patologici lato non affetto (T0 vs T1)_Circ avanti.xlsx');
