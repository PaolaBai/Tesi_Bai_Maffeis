clear
close all
clc

%%

nomi_indici = {'jerkMean_Andata', 'jerkMean_Ritorno', 'jerkPeak_Andata', 'jerkPeak_Ritorno', 'LDLJ_Andata', 'LDLJ_Ritorno', 'SPARC_Andata', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno',...
    'Angolo spalla', 'ROM Spalla', 'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};
n_indici = length(nomi_indici);
nomi_task = {'Addu', 'Addu_orizz', 'Flex', 'Circ_avanti', 'Circ_indietro'};

nomi_indici_Reach = {'jerkMean_Acc_Andata', 'jerkMean_Dec_Andata', 'jerkMean_Andata', 'jerkMean_Acc_Ritorno', 'jerkMean_Dec_Ritorno', 'jerkMean_Ritorno',...
    'jerkPeak_Acc_Andata', 'jerkPeak_Dec_Andata', 'jerkPeak_Andata', 'jerkPeak_AccRitorno', 'jerkPeak_Dec_Ritorno', 'jerkPeak_Ritorno',...
    'LDLJ_Acc_Andata', 'LDLJ_Dec_Andata', 'LDLJ_Andata', 'LDLJ_Acc_Ritorno', 'LDLJ_Dec_Ritorno', 'LDLJ_Ritorno', 'SPARC_Acc_Andata', 'SPARC_Dec_Andata', 'SPARC_Andata',...
    'SPARC_Acc_Ritorno', 'SPARC_Dec_Ritorno', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo spalla', 'ROM Spalla', 'Angolo gomito', 'ROM_gomito',...
    'Angolo tronco sagittale', 'ROM tronco sagittale', 'Angolo tronco frontale', 'ROM tronco frontale', 'Angolo tronco torsione', 'ROM tronco torsione'};
n_indici_Reach = length(nomi_indici_Reach);

nomi_indici_Grasp = {'jerkMean_Acc_Andata', 'jerkMean_Dec_Andata', 'jerkMean_Andata', 'jerkMean_Acc_Ritorno', 'jerkMean_Dec_Ritorno', 'jerkMean_Ritorno',...
    'jerkPeak_Acc_Andata', 'jerkPeak_Dec_Andata', 'jerkPeak_Andata', 'jerkPeak_AccRitorno', 'jerkPeak_Dec_Ritorno', 'jerkPeak_Ritorno',...
    'LDLJ_Acc_Andata', 'LDLJ_Dec_Andata', 'LDLJ_Andata', 'LDLJ_Acc_Ritorno', 'LDLJ_Dec_Ritorno', 'LDLJ_Ritorno', 'SPARC_Acc_Andata', 'SPARC_Dec_Andata', 'SPARC_Andata',...
    'SPARC_Acc_Ritorno', 'SPARC_Dec_Ritorno', 'SPARC_Ritorno', 'skewness_Andata', 'skewness_Ritorno', 'Angolo gomito', 'ROM_gomito'};
n_indici_Grasp = length(nomi_indici_Grasp);

%% 

Database_AS = readcell('AS_Sani.xlsx');

tabellaFinale = table();

% cerco le colonne con Results
[numRighe, numColonne] = size(Database_AS);
colonneResults = [];

for ii = 1:numColonne
    testoCella = string(Database_AS{1, ii});
    if startsWith(testoCella, 'Results', 'IgnoreCase', true)
        colonneResults(end+1) = ii;
    end
end

%% Addu, Addu_orizz, Flex, Circ_avanti, Circ_indietro

for tt = 1:length(nomi_task)
    colonnaResults = colonneResults(tt);
    nomeTask = nomi_task{tt};

    % cerco la riga con Assumption Checks
    rigaAssumption = -1;
    for jj = 1:size(Database_AS, 1)
        testoCella = string(Database_AS{jj, colonnaResults});
        if contains(testoCella, 'Assumption Checks', 'IgnoreCase', true)
            rigaAssumption = jj;
            break;
        end
    end

    % cerco la riga con Descriptive Statistics
    rigaDescriptive = -1;
    for mm = 1:size(Database_AS, 1)
        testoCella = string(Database_AS{mm, colonnaResults});
        if contains(testoCella, 'Descriptive Statistics', 'IgnoreCase', true)
            rigaDescriptive = mm;
            break;
        end
    end

    rigaPvalue = 5;         % prima riga student
    colonnaPvalue = colonnaResults + 7;
    rigaMean = rigaDescriptive + 6;      % media
    rigaSD = rigaDescriptive + 7;       % SD

    for ll = 1:n_indici
        rigaCorrenteP = rigaPvalue + (ll - 1) * 2;
        vettore_Pvalue{ll} = string(Database_AS{rigaCorrenteP, colonnaPvalue});
    end

    for nn = 1:n_indici
        pCella = Database_AS{rigaPvalue + (nn-1)*2, colonnaPvalue};
        pStr = replace(string(pCella), ',', '.');
        matchNumero = regexp(pStr, '\d*\.?\d+', 'match');

        pValue = NaN;
        if ~isempty(matchNumero)
            pValue = str2double(matchNumero{1});
        end

        asterisco = '';
        if ~isnan(pValue) && pValue < 0.05
            asterisco = ' *';
        end

        valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + nn}), ',', '.'));
        valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + nn}), ',', '.'));

        if abs(valMean) > 1000, valMean = valMean / 1000; end
        if abs(valSD) > 1000, valSD = valSD / 1000; end

        vettoreDX{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
    end

    for nn = 1:n_indici
        pCella = Database_AS{rigaPvalue + (nn-1)*2, colonnaPvalue};
        pStr = replace(string(pCella), ',', '.');
        matchNumero = regexp(pStr, '\d*\.?\d+', 'match');

        pValue = NaN;
        if ~isempty(matchNumero)
            pValue = str2double(matchNumero{1});
        end

        asterisco = '';
        if ~isnan(pValue) && pValue < 0.05
            asterisco = ' *';
        end

        valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + n_indici + nn}), ',', '.'));
        valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + n_indici + nn}), ',', '.'));

        if abs(valMean) > 1000, valMean = valMean / 1000; end
        if abs(valSD) > 1000, valSD = valSD / 1000; end

        vettoreSX{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
    end

    tabellaFinale = table(nomi_indici(:), vettoreDX(:), vettoreSX(:), vettore_Pvalue(:), ...
        'VariableNames', {'Parametro', 'DX', 'SX', 'pValue'});

    nome_tabella = sprintf('AS_Sani_%s.xlsx', nomeTask);
    writetable(tabellaFinale, nome_tabella);
end
