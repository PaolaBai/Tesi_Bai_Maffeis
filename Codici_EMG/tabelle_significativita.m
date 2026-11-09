function OUT = tabelle_significativita(xlsx_file, out_dir)
%TABELLE_SIGNIFICATIVITA  Legge il file Excel dei 3 confronti (Sani vs T0,
%  Sani vs T1, T0 vs T1) e genera tabelle-riassunto colorate secondo la
%  significativita' statistica (asterisco nei valori).
%
%  8 tabelle (immagini), 3 righe (i confronti) x colonne (gli indici):
%    Tab 1  = valori base (ampMax, media[, onset]) + sinergie (k*, VAF)
%    Tab 2-8= co-contrazione, una per sottogruppo (Globale, Tronco, ...)
%  Cella ROSSA se l'indice e' significativo in quel confronto, BLU se no.
%
%  USO
%    tabelle_significativita('Addu_tab.xlsx', 'C:\...\Figure')
%    tabelle_significativita('RandG_G_tab.xlsx', 'C:\...\Figure')
%
%  Rileva automaticamente indici, sottogruppi e fasi (gestisce sia i movimenti
%  normali a 3 fasi sia il RandG a 6 fasi).

if nargin < 2 || isempty(out_dir); out_dir = pwd; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

ROSSO = [0.85 0.15 0.15];    % significativo
BLU   = [0.00 0.20 0.60];    % non significativo
GRIGIO= [0.88 0.88 0.88];    % intestazioni

% --- 1. leggi tutto il foglio come celle (testo) ---
% readcell e' piu' affidabile di xlsread su MATLAB recenti; fallback a xlsread.
try
    RAW = readcell(xlsx_file);
catch
    [~,~,RAW] = xlsread(xlsx_file);
end
RAW = cellfun(@to_str, RAW, 'UniformOutput', false);
[nr, nc] = size(RAW);

% --- 2. trova i 3 confronti (righe dove compare "... vs ...") ---
conf_nomi = {}; conf_righe = [];
for r = 1:nr
    for c = 1:nc
        s = RAW{r,c};
        if ~isempty(s) && contains(s, ' vs ')
            conf_nomi{end+1} = s; conf_righe(end+1) = r; %#ok<AGROW>
        end
    end
end
if numel(conf_righe) < 1; error('tabelle_significativita:conf','Nessun confronto trovato.'); end

% --- 3. per ogni confronto, mappa indice -> significativo? ---
% Estrazione ROBUSTA (indipendente dalla posizione delle colonne): si cerca il
% nome dell'indice in QUALSIASI cella; i valori stanno 2-3 colonne a destra.
prefissi = {'ampMax','media','onset','FWHM','CoA','TMCi','Rud','FW','Kel','Unn','kAIC','kVAF','kVAF90','VAF'};
SIG = containers.Map();   % chiave: "confronto|indice" -> true/false
INDICI = {};              % elenco ordinato indici (senza suffisso _T0/_T1)
for ic = 1:numel(conf_righe)
    r0 = conf_righe(ic);
    r1 = nr; if ic < numel(conf_righe); r1 = conf_righe(ic+1)-1; end
    for r = r0:r1
        for c = 1:nc
            nome = RAW{r,c};
            if isempty(nome) || ~contains(nome,'_'); continue; end
            if ~any(cellfun(@(p) startsWith(nome,[p '_']) || strcmp(nome,p) || startsWith(nome,p), prefissi)); continue; end
            base = regexprep(nome, '_(T0|T1)$', '');
            % significativo se una delle celle-valore a destra (c+2, c+3) contiene '*'
            sig = false;
            for cc = [c+2, c+3]
                if cc <= nc && contains(RAW{r,cc}, '*'); sig = true; end
            end
            key = [conf_nomi{ic} '|' base];
            if isKey(SIG, key); SIG(key) = SIG(key) || sig; else; SIG(key) = sig; end
            if ~any(strcmp(INDICI, base)); INDICI{end+1} = base; end %#ok<AGROW>
        end
    end
end
if isempty(INDICI); error('tabelle_significativita:indici','Nessun indice riconosciuto: controlla la struttura del file.'); end

% --- 4. suddividi gli indici nelle 8 tabelle ---
sottogr = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
is_base = @(n) any(startsWith(n, {'ampMax','media','onset','kAIC','kVAF','kVAF90','VAF'}));
tab_base = INDICI(cellfun(is_base, INDICI));
TAB = {}; TAB_nomi = {};
TAB{end+1} = tab_base; TAB_nomi{end+1} = 'Base_Sinergie';
for g = 1:numel(sottogr)
    sel = INDICI(cellfun(@(n) contains(n, ['_' sottogr{g} '_']) || endsWith(n, ['_' sottogr{g}]), INDICI));
    if ~isempty(sel); TAB{end+1} = sel; TAB_nomi{end+1} = sottogr{g}; end %#ok<AGROW>
end

% --- 5. disegna e salva ogni tabella ---
OUT.files = {};
[~, base_file] = fileparts(xlsx_file);
for t = 1:numel(TAB)
    cols = TAB{t};
    disegna_tabella(cols, conf_nomi, SIG, ROSSO, BLU, GRIGIO, ...
        sprintf('%s — %s', base_file, TAB_nomi{t}), ...
        fullfile(out_dir, sprintf('%s_%s.png', base_file, TAB_nomi{t})));
    OUT.files{end+1} = fullfile(out_dir, sprintf('%s_%s.png', base_file, TAB_nomi{t}));
    fprintf('[tabella] %s\n', OUT.files{end});
end
OUT.confronti = conf_nomi; OUT.indici = INDICI;
end

%% ---------------------------------------------------------
function disegna_tabella(cols, conf_nomi, SIG, ROSSO, BLU, GRIGIO, titolo, fname)
ncol = numel(cols); nrow = numel(conf_nomi);

fig = figure('Color','w','Position',[30 30 1000 100],'Visible','off');
ax = axes('Position',[0 0 1 1]); axis(ax,'off'); hold(ax,'on');

% --- MARGINI PERFETTI ---
x0 = 0.18;      % Spazio a sinistra per i testi delle righe
y0 = 0.60;      % Spazio IN BASSO per le etichette delle colonne a 45°
y_top = 0.98;   % La tabella inizia in cima alla figura

wcell = (0.98-x0)/ncol; 
hcell = (y_top-y0)/nrow;

% 1. CELLE COLORATE
for r = 1:nrow
    for c = 1:ncol
        key = [conf_nomi{r} '|' cols{c}];
        sig = isKey(SIG,key) && SIG(key);
        col = BLU; if sig; col = ROSSO; end
        
        xc = x0 + (c-1)*wcell; 
        yr = y_top - r*hcell;
        
        rectangle('Position', [xc yr wcell hcell], ...
            'FaceColor', col, 'EdgeColor', 'w', 'LineWidth', 0.5);
    end
end

% 2. INTESTAZIONI RIGHE (perfettamente centrate verticalmente su ciascuna riga)
for r = 1:nrow
    yr = y_top - (r-0.5)*hcell; % FIX: ora usa y_top correttamente!
    text(x0-0.01, yr, conf_nomi{r}, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 9, 'FontWeight', 'bold');
end

% 3. INTESTAZIONI COLONNE (SPOSTATE SOTTO LA TABELLA)
for c = 1:ncol
    xc = x0 + (c-0.5)*wcell;
    
    % FIX: y0 - 0.01 posiziona la scritta sotto la base della tabella
    text(xc, y0 - 0.01, pulisci(cols{c}), ...
        'Rotation', 45, ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', 7, 'Interpreter', 'none');
end

xlim([0 1]); ylim([0 1]);

try
    exportgraphics(fig, fname, 'Resolution', 150); 
catch
    saveas(fig, fname); 
end
close(fig);
end

%% ---------------------------------------------------------
function s = to_str(v)
% converte qualunque tipo di cella (readcell: char/string/double/missing) in stringa
try
    if ischar(v); s = v; return; end
    if isstring(v)
        if ismissing(v); s=''; else; s=char(v); end; return;
    end
    if isnumeric(v)
        if isscalar(v) && ~isnan(v); s = num2str(v); else; s=''; end; return;
    end
    if iscell(v); if isempty(v); s=''; else; s=to_str(v{1}); end; return; end
    % missing, datetime, ecc.
    if all(ismissing(v)); s=''; return; end
    s = char(string(v));
catch
    s = '';
end
end
function n = pulisci(nome)
% accorcia il nome per la testata (toglie il sottogruppo, gia' nel titolo)
n = regexprep(nome, '_(Globale|Tronco|Braccio|Spalla|Gomito|Polso|SpallaGomito)_', '_');
n = regexprep(n, '_(Globale|Tronco|Braccio|Spalla|Gomito|Polso|SpallaGomito)$', '');
end
