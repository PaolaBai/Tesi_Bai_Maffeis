function esporta_circ_base(DATA, out_dir, lato_paz)
%ESPORTA_CIRC_BASE  Esporta SOLO i valori base (ampMax, media, onset) delle due
%  circonduzioni (avanti e indietro) in formato JASP (una riga per soggetto,
%  3 fogli: Sani, T0, T1). Legge la fase Intero corretta per ciascuna direzione:
%    Circ_Avanti   -> RAvanti_Intero
%    Circ_Indietro -> RIndietro_Intero
%  Pazienti: swap R->L secondo lato_paz.
%
%  USO
%    esporta_circ_base(DATA, 'C:\Users\simom\OneDrive\Desktop\Circonduzioni base', lato_paz)
%
%  Produce: Circ_Avanti_base.xlsx e Circ_Indietro_base.xlsx

if nargin < 3 || isempty(lato_paz); lato_paz = struct(); end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};
DIR = {'Circ_Avanti','Avanti'; 'Circ_Indietro','Indietro'};   % {nome-file, direzione}
FOGLI = {'Sani','Patologici','T';  'T0','Patologici','T0'; 'T1','Patologici','T1'};
% nota: riga 1 del foglio Sani -> gruppo 'Sani' tempo 'T' (vedi sotto)

% intestazione colonne: ID, Condizione, poi ampMax/media/onset x 8 muscoli
hdr = {'ID','Condizione'};
for vb = {'ampMax','media','onset'}
    for m = 1:numel(MUS); hdr{end+1} = sprintf('%s_%s', vb{1}, MUS{m}); end %#ok<AGROW>
end

for d = 1:size(DIR,1)
    nome_file = DIR{d,1}; direz = DIR{d,2};
    fase_int = sprintf('R%s_Intero', direz);   % RAvanti_Intero / RIndietro_Intero

    % tre fogli
    sheets = {'Sani','T0','T1'};
    specs  = {'Sani','T','sano'; 'Patologici','T0','patologico'; 'Patologici','T1','patologico'};
    out = fullfile(out_dir, [nome_file '_base.xlsx']);
    if exist(out,'file'); delete(out); end

    for sh = 1:3
        gruppo = specs{sh,1}; tempo = specs{sh,2}; cond = specs{sh,3};
        righe = righe_base(DATA, gruppo, tempo, cond, 'Circ', fase_int, MUS, lato_paz, numel(hdr));
        writecell([hdr; righe], out, 'Sheet', sheets{sh});
    end
    fprintf('[esporta_circ_base] scritto: %s (fase %s)\n', out, fase_int);
end
end

%% ---------------------------------------------------------
function righe = righe_base(DATA, gruppo, tempo, cond, mov, fase_int, MUS, lato_paz, ncol)
righe = {};
if ~isfield(DATA, gruppo); return; end
sogg = fieldnames(DATA.(gruppo));
for s = 1:numel(sogg)
    Snm = sogg{s};
    if ~isfield(DATA.(gruppo).(Snm), tempo); continue; end
    st = DATA.(gruppo).(Snm).(tempo);
    if ~isstruct(st) || ~isfield(st, mov); continue; end
    M = st.(mov);
    % swap lato per i pazienti con lato affetto sinistro
    fase = fase_int;
    if ~strcmp(gruppo,'Sani') && isfield(lato_paz,Snm) && strcmpi(lato_paz.(Snm),'L')
        fase = regexprep(fase_int, '^R', 'L');
    end
    if ~isfield(M,'base') || ~isfield(M.base, fase); continue; end
    B = M.base.(fase);
    row = cell(1,ncol); row{1}=Snm; row{2}=cond; col=3;
    for campo = {'amp_max_uV','media_uV','onset_pct'}
        for m = 1:numel(MUS)
            v = NaN;
            if isfield(B,campo{1}) && m<=numel(B.(campo{1})); v = B.(campo{1})(m); end
            row{col} = v; col = col+1;
        end
    end
    righe(end+1,:) = row; %#ok<AGROW>
end
end
