function sig = leggi_ttest(RAW, nome_ex)
%LEGGI_TTEST  Dato il contenuto di un file <mov>_tab.xlsx (formato JASP grezzo) e
%  il nome di un indice, restituisce [1x3] logico: significativo (p<0.05 al t-test
%  di Student) nei confronti {Sani vs T0, Sani vs T1, T0 vs T1}.
%  Legge SOLO la riga 'Student' (ignora Mann-Whitney). "< .001" -> significativo.
%
%  RAW: cell array di stringhe (gia' letto con readcell + to_str).
%  nome_ex: es. 'ampMax_BB', 'TMCi_Globale_Andata', 'kAIC_Totale', 'VAF'.

sig = false(1,3);
[nr,nc] = size(RAW);

% --- righe di inizio dei 3 confronti ---
conf = {'Sani vs T0','Sani vs T1','T0 vs T1'};
rconf = nan(1,3);
for r = 1:nr
    for k = 1:3
        if strcmp(RAW{r,1}, conf{k}); rconf(k) = r; end
    end
end

for k = 1:3
    if isnan(rconf(k)); continue; end
    r0 = rconf(k);
    % fine intervallo = inizio del confronto successivo (o fine file)
    succ = rconf(rconf > r0); r1 = nr; if ~isempty(succ); r1 = min(succ)-1; end
    % cerco nell'intervallo la riga "Student" dell'indice nome_ex
    for r = r0:r1
        for c = 1:nc
            if ~strcmp(RAW{r,c}, 'Student'); continue; end
            % il nome indice e' a sinistra nella stessa riga (prima cella con '_')
            nome = '';
            for cc = c-1:-1:1
                cell_cc = RAW{r,cc};
                if ischar(cell_cc) && ~isempty(cell_cc) && contains(cell_cc, '_'); nome = cell_cc; break; end
            end
            if ~strcmp(nome, nome_ex); continue; end
            % trovo la colonna header 'p' del blocco (qualche riga sopra, stessa area)
            cp = NaN;
            for rh = r-1:-1:max(r-6,1)
                for cc = c:min(c+5,nc)
                    if strcmp(RAW{rh,cc}, 'p'); cp = cc; break; end
                end
                if ~isnan(cp); break; end
            end
            if isnan(cp); continue; end
            p = parse_p(RAW{r,cp});
            if ~isnan(p) && p < 0.05; sig(k) = true; end
        end
    end
end
end

%% ---------------------------------------------------------
function p = parse_p(s)
% converte il p-value JASP ("< .001", ".036", "0,05", o numero) in numero.
p = NaN;
if isempty(s); return; end
if isnumeric(s); if isscalar(s)&&~isnan(s); p=s; end; return; end
s = strtrim(s);
if startsWith(s,'<'); p = 0.0001; return; end   % < .001 -> significativo
if startsWith(s,'>'); p = 1; return; end
s = strrep(s, ',', '.');
v = str2double(s);
if ~isnan(v); p = v; end
end
