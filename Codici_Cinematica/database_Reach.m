clear
close all
clc

%% 

Tabella_RandG = readtable('Tabella RandG.xlsx'); 
info_soggetti = readtable('Tabella lato affetto.xlsx');

num_metriche = 36;
nomi_metriche = {'jerkMean_Acc_Andata', 'jerkMean_Dec_Andata', 'jerkMean_Andata', 'jerkMean_Acc_Ritorno', 'jerkMean_Dec_Ritorno', 'jerkMean_Ritorno',...
    'jerkPeak_Acc_Andata', 'jerkPeak_Dec_Andata', 'jerkPeak_Andata', 'jerkPeak_AccRitorno', 'jerkPeak_Dec_Ritorno', 'jerkPeak_Ritorno',...
    'LDLJ_Acc_Andata', 'LDLJ_Dec_Andata', 'LDLJ_Andata', 'LDLJ_Acc_Ritorno', 'LDLJ_Dec_Ritorno', 'LDLJ_Ritorno', 'SPARC_Acc_Andata', 'SPARC_Dec_Andata', 'SPARC_Andata',...
    'SPARC_Acc_Ritorno', 'SPARC_Dec_Ritorno', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', 'Angolo gomito', 'ROM_gomito',...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};

%% SANI (Dx) vs PATOLOGICI T0 (Lato Affetto)

filtro_T = (string(Tabella_RandG.Timepoint) == "T");
filtro_cicli = (string(Tabella_RandG.Ciclo) == "Media Cicli");
filtro_movimento = contains(string(Tabella_RandG.Lato), "Reach", 'IgnoreCase', true);
tab_grezza_sani = Tabella_RandG(filtro_T & filtro_cicli & filtro_movimento, :);

soggetti_sani = unique(string(tab_grezza_sani.Soggetto));
num_soggetti_sani = length(soggetti_sani);

filtro_T0 = (string(Tabella_RandG.Timepoint) == "T0");
tab_grezza_pat_T0 = Tabella_RandG(filtro_T0 & filtro_cicli & filtro_movimento, :);

num_pat = height(info_soggetti);

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'DX';
    
    vals_Dx = fun_estrai_metriche_lato_RandG(tab_grezza_sani, soggetto_corrente);
    
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
    
    vals_affetto = fun_estrai_metriche_lato_RandG(tab_grezza_pat_T0, soggetto_corrente);
    
    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T0 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T0, 'Database Sani vs Patologici T0_Reach.xlsx');

%% SANI (Media Dx) vs PATOLOGICI T1 (Lato Affetto)

filtro_T1 = (string(Tabella_RandG.Timepoint) == "T1");
tab_grezza_pat_T1 = Tabella_RandG(filtro_T1 & filtro_cicli & filtro_movimento, :);

num_pat = height(info_soggetti);

headers_tot = [{'Soggetto', 'Gruppo', 'Lato'}, nomi_metriche];

% sani
dati_sani = cell(num_soggetti_sani, length(headers_tot));

for ii = 1:num_soggetti_sani
    soggetto_corrente = soggetti_sani(ii);

    dati_sani{ii, 1} = soggetto_corrente;
    dati_sani{ii, 2} = 'Sano';
    dati_sani{ii, 3} = 'DX';
    
    vals_Dx = fun_estrai_metriche_lato_RandG(tab_grezza_sani, soggetto_corrente);
    
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
    
    vals_affetto = fun_estrai_metriche_lato_RandG(tab_grezza_pat_T1, soggetto_corrente);
    
    for kk = 1:num_metriche
        dati_pat{ii, 3 + kk} = vals_affetto(kk);
    end
end

% salvataggio 
dati_sani_vs_pat = [dati_sani; dati_pat];
Database_Sani_vs_Patologi_T1 = cell2table(dati_sani_vs_pat, 'VariableNames', headers_tot);
writetable(Database_Sani_vs_Patologi_T1, 'Database Sani vs Patologici T1_Reach.xlsx');

%% DATABASE PATOLOGICI (lato affetto, T0 vs T1)

colonne_T0 = strcat(nomi_metriche, '_T0');
colonne_T1 = strcat(nomi_metriche, '_T1');

headers_pat = [{'Soggetto', 'Lato Affetto'}, colonne_T0, colonne_T1];
dati_pat = cell(num_pat, length(headers_pat));

for ii = 1:num_pat
    soggetto_corrente = string(info_soggetti{ii, 1});
    lato_affetto  = upper(strip(string(info_soggetti{ii, 2}))); % "DX" o "SX"
    
    dati_pat{ii, 1} = soggetto_corrente;
    dati_pat{ii, 2} = lato_affetto;
    
    vals_T0 = fun_estrai_metriche_lato_RandG(tab_grezza_pat_T0, soggetto_corrente);
    vals_T1 = fun_estrai_metriche_lato_RandG(tab_grezza_pat_T1, soggetto_corrente);
    
    for kk = 1:num_metriche
        dati_pat{ii, 2 + kk} = vals_T0(kk);
    end
    
    for kk = 1:num_metriche
        dati_pat{ii, 2 + num_metriche + kk} = vals_T1(kk);
    end
end

% salvataggio 
Database_Patologici_T0_vs_T1 = cell2table(dati_pat, 'VariableNames', headers_pat);
writetable(Database_Patologici_T0_vs_T1, 'Database Patologici lato affetto (T0 vs T1)_Reach.xlsx');

