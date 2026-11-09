function OUT = griglia_sinergie(DATA, mov, fase, lato_paz, out_dir, opts)
%GRIGLIA_SINERGIE  Griglia dei pesi muscolari delle sinergie, tutte ALLINEATE
%  alle mean synergies dei sani (matching col massimo prodotto scalare).
%
%  LAYOUT (una immagine per movimento/fase):
%    riga 1        = MODELLO (mean synergies dei sani)           [nero]
%    righe seguenti= tutti i SANI allineati                      [verde]
%    poi           = tutti i PAZIENTI allineati                  [rosso]
%                    per chi ha T0 e T1: prima la riga T0, poi T1
%    colonne       = i k moduli (k = moda dei k_AIC dei sani), allineati
%
%  USO
%    griglia_sinergie(DATA, 'Addu', 'R_Intero', lato_paz, 'C:\...\Figure')
%
%  Pazienti: lato affetto via lato_paz (swap R->L); RandG nessuno swap.
%  opts: .gruppo_sani ('Sani') .gruppo_paz ('Patologici') .tempo_sani ('T')

if nargin < 6, opts = struct; end
if ~isfield(opts,'gruppo_sani'), opts.gruppo_sani='Sani'; end
if ~isfield(opts,'gruppo_paz'),  opts.gruppo_paz='Patologici'; end
if ~isfield(opts,'tempo_sani'),  opts.tempo_sani='T'; end
if nargin < 5 || isempty(out_dir); out_dir = pwd; end
if ~exist(out_dir,'dir'); mkdir(out_dir); end

MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};
COL_MOD=[0 0 0]; COL_SANO=[0.11 0.62 0.46]; COL_PAZ=[0.80 0.20 0.20];
is_randg = strcmpi(mov,'RandG');

% --- 1. k = moda dei k_AIC dei sani ---
kref = moda_kAIC(DATA, opts.gruppo_sani, opts.tempo_sani, mov, fase);
if isnan(kref) || kref<1; error('griglia_sinergie:k','k non determinabile per %s/%s.', mov, fase); end

% --- 2. mean synergies dei sani (modello) ---
Wmod = mean_synergies(DATA, opts.gruppo_sani, opts.tempo_sani, mov, fase, kref);
if isempty(Wmod); error('griglia_sinergie:modello','Impossibile costruire le mean synergies.'); end

% --- 3. raccogli le righe: modello, sani, pazienti (allineati) ---
RIGHE = {};   % ogni elemento: struct(.W [8xk], .lab, .col)
RIGHE{end+1} = struct('W',Wmod,'lab','MODELLO','col',COL_MOD);

% sani
sani = fieldnames(DATA.(opts.gruppo_sani));
for s=1:numel(sani)
    W = estrai_allineata(DATA, opts.gruppo_sani, sani{s}, opts.tempo_sani, mov, fase, kref, Wmod, false, lato_paz, is_randg);
    if ~isempty(W); RIGHE{end+1} = struct('W',W,'lab',sani{s},'col',COL_SANO); end %#ok<AGROW>
end
% pazienti: in ordine, T0 poi T1
paz = fieldnames(DATA.(opts.gruppo_paz));
for pz=1:numel(paz)
    for TP = {'T0','T1'}
        tp = TP{1};
        W = estrai_allineata(DATA, opts.gruppo_paz, paz{pz}, tp, mov, fase, kref, Wmod, true, lato_paz, is_randg);
        if ~isempty(W)
            RIGHE{end+1} = struct('W',W,'lab',sprintf('%s_%s',paz{pz},tp),'col',COL_PAZ); %#ok<AGROW>
        end
    end
end

% --- 4. disegna la griglia ---
nR = numel(RIGHE);
fig = figure('Color','w','Position',[40 40 200*kref+160 max(120*nR,300)],'Visible','off');
for r = 1:nR
    for c = 1:kref
        ax = subplot(nR, kref, (r-1)*kref + c);
        barh(1:8, RIGHE{r}.W(:,c), 'FaceColor', RIGHE{r}.col, 'EdgeColor','none');
        set(ax,'YDir','reverse','XTick',[],'YTick',[]);
        xlim([0 1]); ylim([0.5 8.5]);
        if c==1   % etichetta soggetto a sinistra
            ylabel(strrep(RIGHE{r}.lab,'_','\_'), 'Rotation',0,'HorizontalAlignment','right', ...
                   'FontSize',7,'Color',RIGHE{r}.col,'FontWeight','bold');
        end
        if r==1;  title(sprintf('Modulo %d', c), 'FontSize',9); end
    end
end
try
    sgtitle(sprintf('%s / %s — sinergie allineate (k=%d)   nero=modello, verde=sani, rosso=pazienti', ...
        mov, strrep(fase,'_','\_'), kref), 'FontSize',11);
catch; end

% --- 5. salva ---
fname = fullfile(out_dir, sprintf('griglia_%s_%s.png', mov, fase));
try
    exportgraphics(fig, fname, 'Resolution', 150);
catch
    saveas(fig, fname);
end
close(fig);
fprintf('[griglia] %s  (%d righe: 1 modello + %d sani + pazienti, k=%d)\n', fname, nR, numel(sani), kref);

OUT.file = fname; OUT.k = kref; OUT.Wmod = Wmod; OUT.n_righe = nR;
OUT.etichette = cellfun(@(x) x.lab, RIGHE, 'UniformOutput', false);
end

%% ---------------------------------------------------------
function W = estrai_allineata(DATA, gruppo, sog, tempo, mov, fase, kref, Wmod, is_paz, lato_paz, is_randg)
% estrae le sinergie del soggetto a kref e le riordina appaiandole a Wmod.
W = [];
fase_s = fase;
if is_paz && ~is_randg && isfield(lato_paz,sog) && strcmpi(lato_paz.(sog),'L')
    fase_s = regexprep(fase,'^R','L');
end
E = prendi_emgcat(DATA, gruppo, sog, tempo, mov, fase_s);
if isempty(E); return; end
[Wc, ~] = nnmf(E, kref, 'replicates', 10, 'algorithm', 'mult');
Wc = normalizza_colonne(Wc);
W  = allinea(Wmod, Wc);        % riordina Wc per matchare Wmod (massimo prodotto scalare)
end

%% ---------------------------------------------------------
function Wref = mean_synergies(DATA, gruppo, tempo, mov, fase, kref)
% modello: matching col massimo prodotto scalare al primo sano + media, norma 1.
Wref = [];
sani = fieldnames(DATA.(gruppo));
Ws = {};
for s=1:numel(sani)
    E = prendi_emgcat(DATA, gruppo, sani{s}, tempo, mov, fase);
    if isempty(E); continue; end
    [W,~] = nnmf(E, kref, 'replicates', 10, 'algorithm', 'mult');
    Ws{end+1} = normalizza_colonne(W); %#ok<AGROW>
end
if numel(Ws)<2; return; end
Wmod = Ws{1}; Acc = Wmod; cnt = 1;
for s=2:numel(Ws); Acc = Acc + allinea(Wmod, Ws{s}); cnt=cnt+1; end
Wref = normalizza_colonne(Acc/cnt);
end

%% ---------------------------------------------------------
function Wapp = allinea(Wmod, W)
% riordina le colonne di W per massimizzare la somma dei prodotti scalari con
% Wmod (assegnazione ottima; matchpairs, fallback greedy).
k = size(Wmod,2); S = Wmod'*W; ord = zeros(1,k);
try
    M = matchpairs(1-S, 1.5);
    for r=1:size(M,1); ord(M(r,1))=M(r,2); end
    if any(ord==0); rest=setdiff(1:k, ord(ord>0)); ord(ord==0)=rest; end
catch
    St=S; for it=1:k; [~,idx]=max(St(:)); [r,c]=ind2sub(size(St),idx); ord(r)=c; St(r,:)=-Inf; St(:,c)=-Inf; end
end
Wapp = W(:, ord);
end

%% ---------------------------------------------------------
function k = moda_kAIC(DATA, gruppo, tempo, mov, fase)
kk=[]; sani=fieldnames(DATA.(gruppo));
for s=1:numel(sani)
    st=DATA.(gruppo).(sani{s});
    if ~isfield(st,tempo)||~isfield(st.(tempo),mov); continue; end
    syn=st.(tempo).(mov).sinergie; lab=cellstr(syn.phase_labels);
    j=find(strcmp(lab,fase),1); if isempty(j); continue; end
    if size(syn.k_AIC,1)==1; kk(end+1)=syn.k_AIC(1,j); else; kk(end+1)=round(mean(syn.k_AIC(:,j),'omitnan')); end %#ok<AGROW>
end
if isempty(kk); k=NaN; else; k=mode(kk); end
end

function E = prendi_emgcat(DATA, gruppo, sog, tempo, mov, fase)
E=[];
if ~isfield(DATA.(gruppo), sog); return; end
ss=DATA.(gruppo).(sog);
if ~isempty(tempo)&&isfield(ss,tempo); tgt=ss.(tempo); else; tgt=ss; end
if ~isfield(tgt,mov); return; end
M=tgt.(mov); if ~isfield(M,'sinergie'); return; end
syn=M.sinergie; if ~isfield(syn,'EMG_cat'); return; end
lab=cellstr(syn.phase_labels); j=find(strcmp(lab,fase),1);
if isempty(j)||j>numel(syn.EMG_cat); return; end
E=syn.EMG_cat{j};
end

function W = normalizza_colonne(W)
for i=1:size(W,2); n=norm(W(:,i)); if n>eps; W(:,i)=W(:,i)/n; end; end
end
