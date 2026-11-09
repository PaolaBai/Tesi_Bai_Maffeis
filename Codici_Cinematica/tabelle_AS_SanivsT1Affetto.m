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

Database_AS = readcell('AS_SanivsT1Affetto.xlsx');

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
    colonnaPvalue = colonnaResults + 4;
    rigaMean = rigaDescriptive + 7;      % media
    rigaSD = rigaDescriptive + 8;       % SD

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

        valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + (nn - 1) * 2 + 2}), ',', '.'));
        valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + (nn - 1) * 2 + 2}), ',', '.'));

        if abs(valMean) > 1000, valMean = valMean / 1000; end
        if abs(valSD) > 1000, valSD = valSD / 1000; end

        vettoreSani{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
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

        valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + (nn - 1) * 2 + 1}), ',', '.'));
        valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + (nn - 1) * 2 + 1}), ',', '.'));

        if abs(valMean) > 1000, valMean = valMean / 1000; end
        if abs(valSD) > 1000, valSD = valSD / 1000; end

        vettoreT1{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
    end

    tabellaFinale = table(nomi_indici(:), vettoreSani(:), vettoreT1(:), ...
        'VariableNames', {'Parametro', 'Sani', 'T1 Affetto'});

    nome_tabella = sprintf('AS_SanivsT1Affetto_%s.xlsx', nomeTask);
    writetable(tabellaFinale, nome_tabella);
end

%% Reach

vettoreSani = cell(n_indici_Reach, 1);
vettoreT1 = cell(n_indici_Reach, 1);
vettore_Pvalue = cell(n_indici_Reach, 1);

colonnaResults = colonneResults(6);         % Reach al posto 6
nomeTask = 'Reach';

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
colonnaPvalue = colonnaResults + 4;
rigaMean = rigaDescriptive + 7;      % media
rigaSD = rigaDescriptive + 8;       % SD

for ll = 1:n_indici_Reach
    rigaCorrenteP = rigaPvalue + (ll - 1) * 2;
    vettore_Pvalue{ll} = string(Database_AS{rigaCorrenteP, colonnaPvalue});
end

for nn = 1:n_indici_Reach
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

    valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + (nn - 1) * 2 + 2}), ',', '.'));
    valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + (nn - 1) * 2 + 2}), ',', '.'));

    if abs(valMean) > 1000, valMean = valMean / 1000; end
    if abs(valSD) > 1000, valSD = valSD / 1000; end

    vettoreSani{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
end

for nn = 1:n_indici_Reach
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

    valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + (nn - 1) * 2 + 1}), ',', '.'));
    valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + (nn - 1) * 2 + 1}), ',', '.'));

    if abs(valMean) > 1000, valMean = valMean / 1000; end
    if abs(valSD) > 1000, valSD = valSD / 1000; end

    vettoreT1{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
end

tabellaFinale = table(nomi_indici_Reach(:), vettoreSani(:), vettoreT1(:), ...
    'VariableNames', {'Parametro', 'Sani', 'T1 Affetto'});

nome_tabella = sprintf('AS_SanivsT1Affetto_%s.xlsx', nomeTask);
writetable(tabellaFinale, nome_tabella);

%% Grasp

vettoreSani = cell(n_indici_Grasp, 1);
vettoreT1 = cell(n_indici_Grasp, 1);
vettore_Pvalue = cell(n_indici_Grasp, 1);

colonnaResults = colonneResults(7);         % Grasp al posto 7
nomeTask = 'Grasp';

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
colonnaPvalue = colonnaResults + 4;
rigaMean = rigaDescriptive + 7;      % media
rigaSD = rigaDescriptive + 8;       % SD

for ll = 1:n_indici_Grasp
    rigaCorrenteP = rigaPvalue + (ll - 1) * 2;
    vettore_Pvalue{ll} = string(Database_AS{rigaCorrenteP, colonnaPvalue});
end

for nn = 1:n_indici_Grasp
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

    valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + (nn - 1) * 2 + 2}), ',', '.'));
    valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + (nn - 1) * 2 + 2}), ',', '.'));

    if abs(valMean) > 1000, valMean = valMean / 1000; end
    if abs(valSD) > 1000, valSD = valSD / 1000; end

    vettoreSani{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
end

for nn = 1:n_indici_Grasp
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

    valMean = str2double(replace(string(Database_AS{rigaMean, colonnaResults + (nn - 1) * 2 + 1}), ',', '.'));
    valSD = str2double(replace(string(Database_AS{rigaSD, colonnaResults + (nn - 1) * 2 + 1}), ',', '.'));

    if abs(valMean) > 1000, valMean = valMean / 1000; end
    if abs(valSD) > 1000, valSD = valSD / 1000; end

    vettoreT1{nn} = sprintf('%.2f (%.2f)%s', valMean, valSD, asterisco);
end

tabellaFinale = table(nomi_indici_Grasp(:), vettoreSani(:), vettoreT1(:), ...
    'VariableNames', {'Parametro', 'Sani', 'T1 Affetto'});

nome_tabella = sprintf('AS_SanivsT1Affetto_%s.xlsx', nomeTask);
writetable(tabellaFinale, nome_tabella);