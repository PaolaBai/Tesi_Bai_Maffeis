function esporta_template(mat_file, out_dir, lato_paz)
%ESPORTA_TEMPLATE  Genera 5 file Excel (uno per movimento), 2 fogli ciascuno:
%    'Dati'  : una riga per (soggetto x fase x ciclo)
%    'Medie' : una riga per (soggetto x fase)  [media sui cicli]
%
%  USO
%    esporta_template(DATA, 'C:\...\Tabelle', lato_paz)
%    esporta_template('C:\...\DATA.mat', 'C:\...\Tabelle', lato_paz)
%
%  Blocchi: 7 sottogruppi x 9 indici (TMCi Rud Kel Kel_ok Kel_scambi FW Unn
%  FWHM CoA) + 3 colonne sinergie: k_AIC, k_VAF, k_VAF90.
%
%  EVIDENZIAZIONE LATO SONDE: vengono colorate le righe della fase registrata
%  dall'arto con gli elettrodi. Sani = sempre lato destro (verde chiaro);
%  pazienti = lato affetto da lato_paz (rosso chiaro). Richiede Excel (ActiveX).

if ischar(mat_file) || isstring(mat_file)
    S = load(mat_file);
    if isfield(S,'DATA'); DATA = S.DATA; else, f = fieldnames(S); DATA = S.(f{1}); end
else
    DATA = mat_file;
end
if ~exist(out_dir,'dir'); mkdir(out_dir); end
if nargin < 3 || isempty(lato_paz); lato_paz = struct(); end

% colori evidenziazione (RGB -> intero Excel = R + G*256 + B*65536)
COL_SANO = 198 + 239*256 + 206*65536;   % verde chiaro
COL_PAZ  = 255 + 199*256 + 206*65536;   % rosso chiaro

SG_ordine = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
SG_titoli = {'GLOBALE','TRONCO','BRACCIO','SPALLA','GOMITO','POLSO','SPALLA-GOMITO'};
indici    = {'TMCi','Rud','Kel','Kel_ok','Kel_scambi','FW','Unn','FWHM','CoA'};
movimenti = {'Addu','Addu_orizz','Flex','Circ','RandG'};

for im = 1:numel(movimenti)
    mov = movimenti{im};
    R = righe_movimento(mov);
    if isempty(R); fprintf('[%s] nessuno schema, saltato\n', mov); continue; end

    switch mov
        case 'Circ'
            key_hdr = {'Gruppo','Soggetto','Timepoint','Lato','Direzione','Tratto','Ciclo'}; nkey = 7;
        case 'RandG'
            key_hdr = {'Gruppo','Soggetto','Timepoint','Lato','Tratto','Fase','Ciclo'}; nkey = 7;
        otherwise
            key_hdr = {'Gruppo','Soggetto','Timepoint','Lato','Tratto','Ciclo'}; nkey = 6;
    end
    keyM_hdr = key_hdr(1:end-1);
    nkeyM = nkey - 1;

    n_ind_tot = numel(SG_ordine)*numel(indici);
    col_syn   = nkey  + n_ind_tot + 1;
    ncol      = nkey  + n_ind_tot + 3;      % 3 colonne sinergie
    col_synM  = nkeyM + n_ind_tot + 1;
    ncolM     = nkeyM + n_ind_tot + 3;

    C  = intestazioni(ncol,  nkey,  key_hdr,  SG_ordine, SG_titoli, indici, col_syn);
    CM = intestazioni(ncolM, nkeyM, keyM_hdr, SG_ordine, SG_titoli, indici, col_synM);

    hiC = zeros(0,2);   % [riga_excel, isPaziente] righe da evidenziare (Dati)
    hiCM = zeros(0,2);  % idem (Medie)

    gruppi = fieldnames(DATA);
    for ig = 1:numel(gruppi)
        G = gruppi{ig};
        is_sano = strcmpi(G,'Sani');
        sogg = fieldnames(DATA.(G));
        for is = 1:numel(sogg)
            Snm = sogg{is};
            % --- lato con le sonde per questo soggetto ---
            if is_sano
                probe = 'R';
            elseif isfield(lato_paz, Snm)
                probe = upper(lato_paz.(Snm));
            else
                probe = '';    % lato ignoto -> nessuna evidenziazione
            end
            isPaz = ~is_sano;

            tps = fieldnames(DATA.(G).(Snm));
            for itp = 1:numel(tps)
                TP = tps{itp};
                if ~isstruct(DATA.(G).(Snm).(TP)); continue; end
                if ~isfield(DATA.(G).(Snm).(TP), mov); continue; end
                M = DATA.(G).(Snm).(TP).(mov);
                fasi = cellstr(M.phase_labels);

                primo = true;
                for ir = 1:numel(R)
                    rr = R(ir);
                    ph = find(strcmp(fasi, rr.fase), 1);
                    ncicli = 5;
                    if ~isempty(ph); ncicli = size(M.(SG_ordine{1}).TMCi, 1); end

                    is_probe = riga_sonde(rr.fase, probe, mov);

                    % ---- foglio DATI ----
                    for cic = 1:ncicli
                        row = cell(1,ncol);
                        if primo && cic==1; row{1}=G; row{2}=Snm; row{3}=TP; primo=false; end
                        if cic==1
                            row{4}=rr.lato;
                            if nkey==7; row{5}=rr.c2; row{6}=rr.c3; else; row{5}=rr.c2; end
                        end
                        row{nkey} = sprintf('Ciclo_%d', cic);
                        for b = 1:numel(SG_ordine)
                            base = nkey + (b-1)*numel(indici);
                            for k = 1:numel(indici)
                                v = val_indice(M, SG_ordine{b}, indici{k}, ph, cic);
                                if ~isempty(v); row{base+k} = v; end
                            end
                        end
                        [ka,kv,kv90] = leggi_k(M, rr.fase);
                        row{col_syn}=ka; row{col_syn+1}=kv; row{col_syn+2}=kv90;
                        C(end+1,:) = row; %#ok<AGROW>
                        if is_probe; hiC(end+1,:) = [size(C,1), isPaz]; end %#ok<AGROW>
                    end

                    % ---- foglio MEDIE ----
                    rowM = cell(1,ncolM);
                    rowM{1}=G; rowM{2}=Snm; rowM{3}=TP; rowM{4}=rr.lato;
                    if nkeyM>=6; rowM{5}=rr.c2; rowM{6}=rr.c3; elseif nkeyM==5; rowM{5}=rr.c2; end
                    for b = 1:numel(SG_ordine)
                        base = nkeyM + (b-1)*numel(indici);
                        for k = 1:numel(indici)
                            v = media_indice(M, SG_ordine{b}, indici{k}, ph);
                            if ~isempty(v); rowM{base+k} = v; end
                        end
                    end
                    [ka,kv,kv90] = leggi_k(M, rr.fase);
                    rowM{col_synM}=ka; rowM{col_synM+1}=kv; rowM{col_synM+2}=kv90;
                    CM(end+1,:) = rowM; %#ok<AGROW>
                    if is_probe; hiCM(end+1,:) = [size(CM,1), isPaz]; end %#ok<AGROW>
                end
            end
        end
    end

    out = fullfile(out_dir, [mov '.xlsx']);
    if exist(out,'file'); delete(out); end
    writecell(C,  out, 'Sheet', 'Dati');
    writecell(CM, out, 'Sheet', 'Medie');
    merge_titoli(out, 'Dati',  nkey,  numel(SG_ordine), numel(indici), col_syn);
    merge_titoli(out, 'Medie', nkeyM, numel(SG_ordine), numel(indici), col_synM);
    colora_lato(out, 'Dati',  hiC,  ncol,  COL_SANO, COL_PAZ);
    colora_lato(out, 'Medie', hiCM, ncolM, COL_SANO, COL_PAZ);
    fprintf('[%s] scritto: %s  (Dati %d righe, Medie %d righe)\n', mov, out, size(C,1), size(CM,1));
end
end

%% =========================================================
function tf = riga_sonde(fase, probe, mov)
% Vero se la fase e' quella registrata dall'arto con le sonde.
% RandG: acquisito solo con l'arto affetto -> tutte le righe sono "sonde".
if strcmpi(mov,'RandG'); tf = true; return; end
if isempty(probe); tf = false; return; end
tf = ~isempty(regexp(fase, ['^' probe], 'once'));   % fase inizia con R o L = lato
end

%% =========================================================
function C = intestazioni(ncol, nkey, key_hdr, SG_ordine, SG_titoli, indici, col_syn)
C = cell(0, ncol);
r1 = cell(1,ncol); r1{col_syn}='SINERGIE';
for b = 1:numel(SG_ordine); r1{ nkey+(b-1)*numel(indici)+1 } = SG_titoli{b}; end
C(end+1,:)=r1;
r2 = cell(1,ncol); r2(1:nkey)=key_hdr;
for b = 1:numel(SG_ordine); r2( nkey+(b-1)*numel(indici)+(1:numel(indici)) ) = indici; end
r2{col_syn}='k_AIC'; r2{col_syn+1}='k_VAF'; r2{col_syn+2}='k_VAF90';
C(end+1,:)=r2;
end

function v = val_indice(M, SG, nm, ph, cic)
v = [];
if isfield(M,SG) && isfield(M.(SG),nm) && ~isempty(ph)
    A = M.(SG).(nm);
    if cic <= size(A,1); v = double(A(cic,ph)); end
end
end

function v = media_indice(M, SG, nm, ph)
v = [];
if isfield(M,SG) && isfield(M.(SG),nm) && ~isempty(ph)
    v = mean(double(M.(SG).(nm)(:,ph)), 1, 'omitnan');
end
end

function [ka,kv,kv90] = leggi_k(M, fase)
ka = []; kv = []; kv90 = [];
if isfield(M,'sinergie')
    syn = M.sinergie; lab = cellstr(syn.phase_labels);
    j = find(strcmp(lab, fase), 1);
    if ~isempty(j)
        if size(syn.k_AIC,1)==1
            ka=syn.k_AIC(1,j); kv=syn.k_VAF(1,j);
            if isfield(syn,'k_VAF90'); kv90=syn.k_VAF90(1,j); end
        else
            ka=round(mean(syn.k_AIC(:,j),'omitnan')); kv=round(mean(syn.k_VAF(:,j),'omitnan'));
            if isfield(syn,'k_VAF90'); kv90=round(mean(syn.k_VAF90(:,j),'omitnan')); end
        end
    end
end
end

function merge_titoli(out, sheet, nkey, nSG, nind, col_syn)
try
    e = actxserver('Excel.Application'); e.Visible=false;
    wb = e.Workbooks.Open(out); ws = wb.Sheets.Item(sheet);
    for b = 1:nSG
        c0 = nkey + (b-1)*nind + 1;
        rng = ws.Range([col_lettera(c0) '1:' col_lettera(c0+nind-1) '1']);
        rng.Merge; rng.HorizontalAlignment = -4108;
    end
    rng = ws.Range([col_lettera(col_syn) '1:' col_lettera(col_syn+2) '1']);   % SINERGIE su 3 col
    rng.Merge; rng.HorizontalAlignment = -4108;
    wb.Save; wb.Close; e.Quit; delete(e);
catch
end
end

function colora_lato(out, sheet, righe_hi, ncol, colSano, colPaz)
% Colora l'INTERA riga (tutte le colonne 1..ncol) delle righe indicate.
if isempty(righe_hi); return; end
try
    e = actxserver('Excel.Application'); e.Visible=false;
    wb = e.Workbooks.Open(out); ws = wb.Sheets.Item(sheet);
    for i = 1:size(righe_hi,1)
        r = righe_hi(i,1); isPaz = righe_hi(i,2);
        col = colSano; if isPaz; col = colPaz; end
        rng = ws.Range(['A' num2str(r) ':' col_lettera(ncol) num2str(r)]);
        rng.Interior.Color = col;
    end
    wb.Save; wb.Close; e.Quit; delete(e);
catch
end
end

%% =========================================================
function R = righe_movimento(mov)
R = struct('lato',{},'c2',{},'c3',{},'fase',{},'pannello',{});
switch mov
    case {'Addu','Addu_orizz','Flex'}
        lati = {'Dx','R'; 'Sx','L'};
        tratti = {'Andata','Salita'; 'Ritorno','Discesa'; 'Totale','Intero'};
        for l = 1:2
            for t = 1:3
                R(end+1) = mk(lati{l,1}, tratti{t,1}, '', [lati{l,2} '_' tratti{t,2}], 1); %#ok<AGROW>
            end
        end
    case 'Circ'
        lati = {'Dx','R'; 'Sx','L'};
        dirz = {'Avanti','Avanti'; 'Indietro','Indietro'};
        tratti = {'Andata','Salita'; 'Ritorno','Discesa'; 'Totale','Intero'};
        for l = 1:2
            for d = 1:2
                for t = 1:3
                    fase = [lati{l,2} dirz{d,2} '_' tratti{t,2}];
                    R(end+1) = mk(lati{l,1}, dirz{d,1}, tratti{t,1}, fase, 1); %#ok<AGROW>
                end
            end
        end
    case 'RandG'
        blocchi = { ...
            'R','Andata', 'Intero','RAndata_Intero';   ...
            'R','Andata', 'Acc',   'RAndata_Salita';   ...
            'R','Andata', 'Dec',   'RAndata_Discesa';  ...
            'R','Ritorno','Intero','RRitorno_Intero';  ...
            'R','Ritorno','Acc',   'RRitorno_Salita';  ...
            'R','Ritorno','Dec',   'RRitorno_Discesa'; ...
            'G','Andata', 'Intero','GAndata_Intero';   ...
            'G','Andata', 'Acc',   'GAndata_Salita';   ...
            'G','Andata', 'Dec',   'GAndata_Discesa';  ...
            'G','Ritorno','Intero','GRitorno_Intero';  ...
            'G','Ritorno','Acc',   'GRitorno_Salita';  ...
            'G','Ritorno','Dec',   'GRitorno_Discesa'; ...
            'Tot','Completo','Intero','Completo_Intero' };
        for i = 1:size(blocchi,1)
            R(end+1) = mk(blocchi{i,1}, blocchi{i,2}, blocchi{i,3}, blocchi{i,4}, 1); %#ok<AGROW>
        end
end
end

function s = mk(lato,c2,c3,fase,pann)
s = struct('lato',lato,'c2',c2,'c3',c3,'fase',fase,'pannello',pann);
end

function L = col_lettera(n)
L = '';
while n > 0
    r = mod(n-1,26); L = [char(65+r) L]; n = floor((n-1)/26); %#ok<AGROW>
end
end
