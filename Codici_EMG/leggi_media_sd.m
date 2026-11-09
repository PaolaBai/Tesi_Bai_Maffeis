function [mu, sd] = leggi_media_sd(RAW, nome_ex)
%LEGGI_MEDIA_SD  Dal file <mov>_tab.xlsx (formato JASP, separatore decimale punto),
%  restituisce media [1x3] e SD [1x3] per i gruppi {Sani, T0, T1} dell'indice.
%  I valori sono presi dalla tabella "Descriptive Statistics":
%    Sani -> sezione 'Sani vs T0', riga condizione 'sano'
%    T0   -> sezione 'Sani vs T0', riga 'patologico T0'
%    T1   -> sezione 'Sani vs T1', riga 'patologico T1'
%
%  RAW: cell array di stringhe (readcell + to_str). nome_ex: es. 'ampMax_BB'.

mu = nan(1,3); sd = nan(1,3);
[nr,nc] = size(RAW);

% righe di inizio dei confronti
rS0 = trova_riga(RAW, 'Sani vs T0');
rS1 = trova_riga(RAW, 'Sani vs T1');
rT = trova_riga(RAW, 'T0 vs T1'); if isnan(rT); rT=nr+1; end
if isnan(rS1); rS1=nr+1; end

% Sani e T0 dalla sezione Sani vs T0; T1 dalla sezione Sani vs T1
[mu(1),sd(1)] = cerca(RAW, nome_ex, 'sano',          rS0, rS1-1);  % Sani
[mu(2),sd(2)] = cerca(RAW, nome_ex, 'patologico T0', rS0, rS1-1);  % T0
[mu(3),sd(3)] = cerca(RAW, nome_ex, 'patologico T1', rS1, rT-1);   % T1
end

%% ---------------------------------------------------------
function r = trova_riga(RAW, etich)
r = NaN;
for i=1:size(RAW,1)
    if strcmp(RAW{i,1}, etich); r=i; return; end
end
end

%% ---------------------------------------------------------
function [m,s] = cerca(RAW, nome_ex, cond, r0, r1)
% cerca nella sezione [r0,r1] la riga con nome indice=nome_ex e condizione=cond,
% legge Mean (3 colonne dopo l'intestazione 'Mean (arithmetic)') e SD.
m=NaN; s=NaN;
[nr,nc]=size(RAW); if isnan(r0); return; end
r1=min(r1,nr);
for r=r0:r1
    for c=1:nc
        if strcmp(RAW{r,c}, nome_ex)
            % la condizione e' nella colonna successiva
            if c+1<=nc && strcmp(RAW{r,c+1}, cond)
                % Mean = colonna c+3, SD = colonna c+4 (Median c+2, Mean c+3, SD c+4)
                if c+3<=nc; m=num(RAW{r,c+3}); end
                if c+4<=nc; s=num(RAW{r,c+4}); end
                return;
            end
        end
    end
end
end

function v = num(x)
v=NaN; if isempty(x); return; end
if isnumeric(x); v=x; return; end
s=strrep(strtrim(x),',','.'); d=str2double(s); if ~isnan(d); v=d; end
end
