function OUT = test_baseline_segmentata(f_emg, f_ev, lato, T_norm, opts)
%TEST_BASELINE_SEGMENTATA  Come TEST_BASELINE, ma la linea di base NON e' una
%  costante: e' una RAMPA LINEARE A TRATTI (spezzata) sul segnale continuo,
%  ancorata ai PUNTI DI TRANSIZIONE del movimento.
%
%  Rispetto a test_baseline cambia SOLO la stima del tonico (passo 3):
%    test_baseline           : base = median(quiete)      -> UNA costante/muscolo
%    test_baseline_segmentata: base(t) spezzata per muscolo, nodi = eventi + quiete
%  Tutto il resto (lettura, inviluppo, mappatura, taglio, TMCi, sinergie,
%  tabella CONFRONTO) e' IDENTICO -> la colonna SENZA coincide con quella di
%  test_baseline, cambia solo la colonna CON.
%
%  IDEA. Nei punti di transizione la velocita' del marker e' minima/si inverte,
%  quindi il contributo FASICO (scalato con la velocita') e' minimo e l'EMG
%  residua approssima il TONICO. Una spezzata che passa per questi punti segue
%  un tonico NON stazionario (in sez.8 avevi notato il Flessore raddoppiare tra
%  prima e seconda meta') meglio di una costante o di una singola retta.
%  LIMITE: nei muscoli con burst di decelerazione al Mid, il valore lì e' alto;
%  per questo l'ancora di default e' un PERCENTILE BASSO in una finestra attorno
%  al nodo (non il valore del campione). Regolabile con opts.metodo_ancora.
%
%  USO (dal Command Window)
%    OUT = test_baseline_segmentata('S041_Flex_EMG.emt','S041_Flex.emt','R')
%    % RandG: passa i confini delle 4 parti (in secondi) come nodi extra:
%    opts.knot_extra = [t_RA t_GA t_GR t_RR];
%    OUT = test_baseline_segmentata(fe, fv, 'R', 100, opts);
%
%  opts (tutti opzionali)
%    .metodo_ancora : 'percentile'(default) | 'min' | 'valore'
%    .pct           : percentile per 'percentile' (default 10)
%    .win_ms        : semi-finestra per la stima ancora, ms (default 100)
%    .knot_extra    : tempi (s) di nodi aggiuntivi (es. 4 parti RandG). default []
%
%  ATTENZIONE: decomposizione ENTRO soggetto (lab diversi -> non salva il
%  between-group). E la sottrazione va PRIMA della norm. al picco (qui rispettato).

if nargin < 3 || isempty(lato);   lato   = 'R';  end
if nargin < 4 || isempty(T_norm); T_norm = 100;  end
if nargin < 5 || isempty(opts);   opts   = struct; end
if ~isfield(opts,'metodo_ancora'); opts.metodo_ancora = 'percentile'; end
if ~isfield(opts,'pct');           opts.pct = 10;    end
if ~isfield(opts,'win_ms');        opts.win_ms = 100; end
if ~isfield(opts,'knot_extra');    opts.knot_extra = []; end

%% ---------- 1. Caricamento ed elaborazione (identico) ----------
[tempo, emg_raw, nomi, unita] = leggi_emg_semplice(f_emg);
fs = round(1/median(diff(tempo)));
fprintf('EMG: %d canali, %.1f s, fs=%d Hz, %s\n', size(emg_raw,2), tempo(end), fs, unita);

idx     = mappa_mus(nomi);
emg_raw = emg_raw(:, idx);
nomi    = nomi(idx);
emg_rms = inviluppo(emg_raw, fs, 100);

%% ---------- 2. Eventi e finestre di quiete (identico) ----------
EV = leggi_eventi_semplice(f_ev);
if ~isfield(EV, lato)
    error('test_baseline:lato','Lato "%s" non trovato. Presenti: %s', ...
          lato, strjoin(fieldnames(EV), ', '));
end
occupato = false(size(tempo));
lati = fieldnames(EV);
for L = 1:numel(lati)
    e = EV.(lati{L});
    for r = 1:numel(e.start)
        occupato = occupato | (tempo >= e.start(r)-0.3 & tempo <= e.stop(r)+0.3);
    end
end
quiete = ~occupato;
fprintf('finestre di quiete: %.1f s su %.1f s totali (%.0f%%)\n', ...
        sum(quiete)/fs, tempo(end), 100*sum(quiete)/numel(tempo));

%% ---------- 3. LINEA DI BASE SPEZZATA per muscolo ----------
% nodi = tempi eventi del lato scelto (start,mid,stop) + centri delle finestre
%        di quiete + estremi registrazione + eventuali knot_extra (RandG).
e = EV.(lato);
t_ev = [e.start(:); e.mid(:); e.stop(:)];

qd = diff([0; double(quiete(:)); 0]);
r0 = find(qd==1); r1 = find(qd==-1)-1;
t_quiet = zeros(numel(r0),1);
for i = 1:numel(r0), t_quiet(i) = tempo(round((r0(i)+r1(i))/2)); end

anc_t = unique([tempo(1); t_quiet; t_ev; opts.knot_extra(:); tempo(end)]);
anc_t = anc_t(anc_t>=tempo(1) & anc_t<=tempo(end));

win = max(1, round(opts.win_ms*fs/1000));
base_t = zeros(numel(tempo), 8);
for k = 1:8
    a = zeros(numel(anc_t),1);
    for j = 1:numel(anc_t)
        [~, ci] = min(abs(tempo - anc_t(j)));
        i0 = max(1, ci-win); i1 = min(numel(tempo), ci+win);
        w = emg_rms(i0:i1, k); w = w(isfinite(w));
        if isempty(w), a(j) = 0; continue; end
        switch lower(opts.metodo_ancora)
            case 'valore',     a(j) = emg_rms(ci, k);
            case 'min',        a(j) = min(w);
            case 'percentile', a(j) = pctl(w, opts.pct);
            otherwise, error('metodo_ancora non riconosciuto');
        end
    end
    base_t(:,k) = interp1(anc_t, a, tempo, 'linear');
end
base_t = max(base_t, 0);

picchi = max(emg_rms, [], 1, 'omitnan');
fprintf('\n%-11s %9s %9s %9s %9s\n','muscolo','base_min','base_max','picco','rapp.mov');
mask_mov = false(size(tempo));
for r = 1:numel(e.start)
    mask_mov = mask_mov | (tempo >= e.start(r) & tempo <= e.stop(r));
end
for k = 1:8
    liv_mov = mean(emg_rms(mask_mov,k),'omitnan');
    bm = mean(base_t(:,k),'omitnan');
    fprintf('%-11s %9.2f %9.2f %9.2f %9.2f\n', nomi{k}, ...
            min(base_t(:,k)), max(base_t(:,k)), picchi(k), liv_mov/max(bm,eps));
end

%% ---------- 4. Due versioni normalizzate (per-canale, come test_baseline) ---
normA = nan(size(emg_rms));
for k = 1:8
    if picchi(k) > 0; normA(:,k) = emg_rms(:,k)/picchi(k)*100; end
end
emg_sub = max(0, emg_rms - base_t);            % sottrazione della spezzata
picchiB = max(emg_sub, [], 1, 'omitnan');
normB   = nan(size(emg_sub));
for k = 1:8
    if picchiB(k) > 0; normB(:,k) = emg_sub(:,k)/picchiB(k)*100; end
end
OUT.frac_clip = mean(emg_rms < base_t, 1);     % diagnostica misfit per muscolo

%% ---------- 5. Segmentazione e indici (identico) ----------
fasi = {'Intero','Salita','Discesa'};
RIS = struct();
for v = 1:2
    if v==1; NRM = normA; tag='SENZA'; else; NRM = normB; tag='CON'; end
    for f = 1:3
        E = nan(T_norm, 8, numel(e.start));
        for r = 1:numel(e.start)
            switch fasi{f}
                case 'Intero';  t0=e.start(r); t1=e.stop(r);
                case 'Salita';  t0=e.start(r); t1=e.mid(r);
                case 'Discesa'; t0=e.mid(r);   t1=e.stop(r);
            end
            E(:,:,r) = taglia(NRM, tempo, t0, t1, T_norm);
        end
        tm = nan(size(E,3),1);
        for r = 1:size(E,3), tm(r) = tmci(squeeze(E(:,:,r)), T_norm); end
        [kA, kV, vaf1] = sinergie(E);
        RIS(v).tag = tag;
        RIS(v).(fasi{f}) = struct('TMCi',mean(tm,'omitnan'), ...
                                  'k_AIC',kA,'k_VAF',kV,'VAF_k1',vaf1);
    end
end

%% ---------- 6. Confronto (identico) ----------
fprintf('\n%s\n  CONFRONTO SEGMENTATA (lato %s, ancora %s)\n%s\n', ...
        repmat('=',1,58), lato, opts.metodo_ancora, repmat('=',1,58));
fprintf('%-10s %-9s %10s %8s %8s %10s\n','fase','versione','TMCi','k_AIC','k_VAF','VAF(k=1)');
for f = 1:3
    for v = 1:2
        S = RIS(v).(fasi{f});
        fprintf('%-10s %-9s %10.2f %8d %8d %10.3f\n', ...
            fasi{f}, RIS(v).tag, S.TMCi, S.k_AIC, S.k_VAF, S.VAF_k1);
    end
    a = RIS(1).(fasi{f}); b = RIS(2).(fasi{f});
    fprintf('%-10s %-9s %+9.1f%% %+8d %+8d %+10.3f\n\n','','delta', ...
        100*(b.TMCi-a.TMCi)/a.TMCi, b.k_AIC-a.k_AIC, b.k_VAF-a.k_VAF, b.VAF_k1-a.VAF_k1);
end

OUT.base_t = base_t; OUT.picchi = picchi; OUT.nomi = nomi;
OUT.senza = RIS(1); OUT.con = RIS(2);
OUT.normA = normA; OUT.normB = normB; OUT.tempo = tempo; OUT.anc_t = anc_t;
end

%% ========================================================= NUOVA
function y = pctl(x, p)
x = sort(x(:)); n = numel(x);
if n==1, y = x; return; end
r = (p/100)*(n-1)+1; lo = floor(r); hi = ceil(r); fr = r-lo;
y = x(lo)*(1-fr) + x(hi)*fr;
end

%% ========================================================= (da test_baseline)
function [tempo, emg, nomi, unita] = leggi_emg_semplice(f)
fid = fopen(f,'r'); righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);
unita = '?';
i = find(cellfun(@(s) ischar(s) && contains(s,'Measure unit'),righe),1);
if ~isempty(i); p=strsplit(righe{i},sprintf('\t')); unita=strtrim(p{end}); end
i_hdr = find(cellfun(@(s) ischar(s) && contains(s,'Frame') && contains(s,'Time'),righe),1);
p = strsplit(righe{i_hdr},sprintf('\t')); p = p(~cellfun(@isempty,strtrim(p)));
nomi = strtrim(p(3:end));
d = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');
tempo = d(:,2); emg = d(:,3:2+numel(nomi));
end

%% =========================================================
function EV = leggi_eventi_semplice(f)
fid = fopen(f,'r'); righe = {};
while ~feof(fid); righe{end+1} = fgetl(fid); end %#ok<AGROW>
fclose(fid);
i_hdr = find(cellfun(@(s) ischar(s) && startsWith(strtrim(s),'Item'),righe),1);
p = strsplit(righe{i_hdr},sprintf('\t')); p = p(~cellfun(@isempty,strtrim(p)));
cols = strtrim(p(2:end));
d = readmatrix(f,'FileType','text','NumHeaderLines',i_hdr,'Delimiter','\t');
d = d(all(isfinite(d(:,1:numel(cols)+1)),2), :);
EV = struct();
for c = 1:numel(cols)
    tok = regexp(cols{c},'^([RL])Start(.*)$','tokens','once');
    if isempty(tok); continue; end
    gr = [tok{1} tok{2}];
    is_ = find(strcmp(cols,[tok{1} 'Stop' tok{2}]),1);
    im_ = find(strcmp(cols,[tok{1} 'Mid'  tok{2}]),1);
    if isempty(is_)||isempty(im_); continue; end
    EV.(gr).start = d(:,c+1); EV.(gr).stop = d(:,is_+1); EV.(gr).mid = d(:,im_+1);
end
end

%% =========================================================
function idx = mappa_mus(nomi)
pat = {'Erector|Thoracic\s*Es','Biceps','Flex.*Carp', ...
       'Deltoideus\s*anterior|Ant.*Deltoid','Rect.*Abdom','Triceps', ...
       'Ext.*Carp','Deltoideus\s*posterior|Post.*Deltoid'};
idx = zeros(1,8);
for k = 1:8
    h = find(~cellfun(@isempty, regexpi(nomi, pat{k}, 'once')));
    if numel(h)~=1; error('mappa: %d match per pattern %d', numel(h), k); end
    idx(k) = h;
end
end

%% =========================================================
function E = inviluppo(raw, fs, win_ms)
win = round(win_ms*fs/1000);
w0 = 2*pi*50/fs; rn = 1-(pi*1/fs);
b_n = [1,-2*cos(w0),1]; a_n = [1,-2*rn*cos(w0),rn^2];
[b,a] = butter(4,[20 300]/(fs/2),'bandpass');
E = nan(size(raw));
for k = 1:size(raw,2)
    s = raw(:,k); s(isnan(s)) = 0;
    s = filtfilt(b_n,a_n,s); s = filtfilt(b,a,s); s = abs(s);
    E(:,k) = sqrt(conv(s.^2, ones(win,1)/win, 'same'));
end
end

%% =========================================================
function S = taglia(N, tempo, t0, t1, T)
S = nan(T, size(N,2));
m = tempo>=t0 & tempo<=t1; seg = N(m,:);
if size(seg,1)<2; return; end
xo = linspace(0,1,size(seg,1)); xn = linspace(0,1,T);
for k = 1:size(N,2)
    c = seg(:,k); c(isnan(c)) = 0;
    S(:,k) = max(0,min(100,interp1(xo,c,xn,'pchip')));
end
end

%% =========================================================
function v = tmci(EMG, T)
p = nchoosek(1:8,2); np = size(p,1);
tf = nan(T,1);
for t = 1:T
    e = EMG(t,:); e = e(isfinite(e));
    if numel(e)<2; continue; end
    ds = 0;
    for i = 1:size(p,1)
        if p(i,1)<=numel(e) && p(i,2)<=numel(e)
            ds = ds + abs(e(p(i,1))-e(p(i,2)));
        end
    end
    d = ds/(100*np);
    C = 1-1/(1+exp(-12*(d-0.5)));
    m = mean(e); mx = max(e);
    if mx>eps; tf(t) = C*m*(m/mx); end
end
v = mean(tf,'omitnan');
end

%% =========================================================
function [kA, kV, vaf1] = sinergie(E)
blocchi = {};
for r = 1:size(E,3)
    X = squeeze(E(:,:,r))';
    if all(~isfinite(X(:))) || max(X(:))<eps; continue; end
    X(~isfinite(X)) = 0; blocchi{end+1} = max(X,0); %#ok<AGROW>
end
if isempty(blocchi); kA=NaN; kV=NaN; vaf1=NaN; return; end
M = [blocchi{:}];
VAF = zeros(7,1);
for k = 1:7
    [W,H] = nnmf(M,k,'replicates',10,'algorithm','mult');
    R = W*H;
    VAF(k) = 1 - sum((M(:)-R(:)).^2)/sum(M(:).^2);
end
vaf1 = VAF(1);
dV = diff([0;VAF]);
kV = find(dV<0.05,1,'first'); if isempty(kV); kV = 7; end
AIC = zeros(7,1);
for k = 1:7
    [W,H] = nnmf(M,k,'replicates',10,'algorithm','mult');
    R = W*H; res = M-R;
    s2 = var(M(:)) + (0.15*movmean(M,round(size(M,2)*0.02),2)).^2;
    AIC(k) = -(-0.5*sum(sum(res.^2./(s2+eps)))) + 8*k + k*round(size(M,2)/10);
end
[~,kA] = min(AIC);
end
