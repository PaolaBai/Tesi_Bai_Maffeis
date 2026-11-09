function OUT = outlier_tmci(DATA, movimento, lato_paz)
%OUTLIER_TMCI  Identifica i soggetti outlier del TMCi (media della curva TMCf)
%  con il criterio IQR 1.5 (Q1-1.5*IQR, Q3+1.5*IQR), lo STESSO usato in
%  tmcf_gruppo_spm, ed ELENCA quali sono (nome soggetto) per ogni gruppo,
%  sottogruppo e fase intera. Serve a verificare la corrispondenza con gli
%  outlier rimossi in JASP.
%
%  USO
%    outlier_tmci(DATA, 'Addu', lato_paz)
%    outlier_tmci(DATA, 'Circ', lato_paz)
%    outlier_tmci(DATA, 'RandG', lato_paz)
%
%  Stampa a schermo l'elenco e restituisce OUT con i dettagli.

if nargin < 3 || isempty(lato_paz); lato_paz = struct(); end
SG_LIST = {'Globale','Tronco','Braccio','Spalla','Gomito','Polso','SpallaGomito'};
GRP = {{'Sani','T'},{'Patologici','T0'},{'Patologici','T1'}};
GNOME = {'Sani','T0','T1'};

[fasi, mov_data] = fasi_intere(movimento);
OUT = struct(); OUT.movimento = movimento; OUT.esclusi = {};

fprintf('\n===== OUTLIER TMCi (IQR 1.5) — %s =====\n', movimento);
for fi = 1:numel(fasi)
    fase = fasi{fi};
    for g = 1:numel(SG_LIST)
        SG = SG_LIST{g};
        for gr = 1:3
            [tmci, sogg] = tmci_gruppo(DATA, GRP{gr}{1}, GRP{gr}{2}, mov_data, fase, SG, lato_paz);
            if numel(tmci) < 4; continue; end   % serve un minimo per l'IQR
            q1 = prctile(tmci,25); q3 = prctile(tmci,75); iqr = q3-q1;
            lo = q1 - 1.5*iqr; hi = q3 + 1.5*iqr;
            out_mask = tmci<lo | tmci>hi;
            if any(out_mask)
                nomi = sogg(out_mask); vals = tmci(out_mask);
                for k=1:numel(nomi)
                    fprintf('  %-6s | %-12s | %-10s | %s  (TMCi=%.2f, soglia=[%.2f, %.2f])\n', ...
                        GNOME{gr}, SG, fase, nomi{k}, vals(k), lo, hi);
                    OUT.esclusi(end+1,:) = {GNOME{gr}, SG, fase, nomi{k}, vals(k)}; %#ok<AGROW>
                end
            end
        end
    end
end
if isempty(OUT.esclusi)
    fprintf('  (nessun outlier trovato)\n');
else
    fprintf('\n  TOTALE outlier (conteggi, un soggetto puo comparire piu volte): %d\n', size(OUT.esclusi,1));
    % elenco soggetti distinti esclusi (almeno una volta)
    distinti = unique(OUT.esclusi(:,4));
    fprintf('  Soggetti distinti coinvolti: %s\n', strjoin(distinti, ', '));
end
fprintf('=============================================\n');
end

%% ---------------------------------------------------------
function [fasi, mov_data] = fasi_intere(movimento)
switch movimento
    case 'RandG'; mov_data='RandG'; fasi={'Completo_Intero'};
    case 'Circ';  mov_data='Circ';  fasi={'RAvanti_Intero','RIndietro_Intero'};
    otherwise;    mov_data=movimento; fasi={'R_Intero'};
end
end

%% ---------------------------------------------------------
function [tmci, sogg_ok] = tmci_gruppo(DATA, gruppo, tempo, mov, fase, SG, lato_paz)
% TMCi per soggetto = media temporale della curva TMCf (stesso dato della SPM).
tmci = []; sogg_ok = {};
if ~isfield(DATA,gruppo); return; end
sogg=fieldnames(DATA.(gruppo)); is_sano=strcmpi(gruppo,'Sani'); is_randg=strcmpi(mov,'RandG');
for s=1:numel(sogg)
    Snm=sogg{s}; fs=fase;
    if ~is_sano && ~is_randg && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L'); fs=regexprep(fase,'^R','L'); end
    st=DATA.(gruppo).(Snm);
    if ~isfield(st,tempo)||~isstruct(st.(tempo))||~isfield(st.(tempo),mov); continue; end
    M=st.(tempo).(mov); if ~isfield(M,SG)||~isfield(M.(SG),'TMCf'); continue; end
    lab=cellstr(M.phase_labels); ph=find(strcmp(lab,fs),1); if isempty(ph); continue; end
    A=M.(SG).TMCf(:,:,ph); if all(isnan(A(:))); continue; end
    % media sui cicli -> curva, poi media temporale -> TMCi del soggetto
    curva=riga_nanmean(A);
    v=mean(curva(isfinite(curva)));
    if isfinite(v); tmci(end+1)=v; sogg_ok{end+1}=Snm; end %#ok<AGROW>
end
tmci=tmci(:);
end

function m = riga_nanmean(A)
m=nan(size(A,1),1);
for i=1:size(A,1); v=A(i,:); v=v(isfinite(v)); if ~isempty(v); m(i)=mean(v); end; end
end
