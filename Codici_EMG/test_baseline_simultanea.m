function OUT = test_baseline_simultanea(f_emg, f_ev, lato, T_norm, opts)
%TEST_BASELINE_SIMULTANEA  Come TEST_BASELINE, ma il tonico NON viene stimato
%  a monte: EMERGE per ESTRAZIONE SIMULTANEA fasico/tonico
%  (d'Avella, Fernandez, Portone & Lacquaniti 2008, JNP 100:1433), versione
%  ridotta a singola condizione. Il meccanismo chiave e' conservato: le forme
%  toniche sono filtrate passa-basso a ogni iterazione, quindi assorbono solo
%  l'andamento LENTO; tutto cio' che e' rapido (burst acc/dec) resta FORZATO nel
%  fasico. Le due famiglie si separano da sole.
%
%  Rispetto a test_baseline cambia SOLO come si ottiene la versione CON: invece
%  di sottrarre una costante, si estrae il tonico nello STESSO spazio della tua
%  sinergie (M = [8 x (T*nrep)], blocchi trasposti/concatenati), e si danno le
%  tue tmci e sinergie al residuo fasico. La colonna SENZA coincide con quella
%  di test_baseline. La NMF usata per SEPARARE fasico/tonico e' locale; il
%  CONTEGGIO delle sinergie resta la tua nnmf.
%
%  RIDUZIONI dichiarate (vedi Discussione tesi):
%    (a) fasico = sinergie SPAZIALI (NMF), non tempo-varianti con onset
%        shiftabile via matching pursuit (2006);
%    (b) singola condizione (niente modulazione ampiezza tra condizioni);
%    (c) Nt scelto dall'utente: la tua segmentazione non ha hold statici per
%        fissarlo alla regola di d'Avella. Il tuo task torna alla postura di
%        partenza -> tonico posturale poco modulato: qui e' un TEST.
%
%  TAGLIO. I dati sono gia' normalizzati in tempo a T campioni/rip.: fc=1/(2*MT)
%  equivale a Wn=1/T di Nyquist, INDIPENDENTE da MT (T=100 -> Wn=0.01).
%
%  USO (dal Command Window)
%    OUT = test_baseline_simultanea('S041_Flex_EMG.emt','S041_Flex.emt','R')
%    opts.Np = 2; opts.lambda = 0.05;   % opzionale
%
%  ATTENZIONE: decomposizione ENTRO soggetto (lab diversi -> non salva il
%  between-group). Uso: pre/post o robustezza della decisione sez.8.

if nargin < 3 || isempty(lato);   lato   = 'R';  end
if nargin < 4 || isempty(T_norm); T_norm = 100;  end
if nargin < 5 || isempty(opts);   opts   = struct; end
def = struct('Np',2,'Nt',1,'lambda',0.05,'max_iter',300,'tol',1e-4,'n_restart',10);
fn = fieldnames(def);
for i=1:numel(fn), if ~isfield(opts,fn{i}), opts.(fn{i})=def.(fn{i}); end, end
% Wn: taglio del tonico (frazione di Nyquist). Default 1/T = profilo
% punto-a-punto (mezza sinusoide, d'Avella fc=1/(2*MT)). Per movimenti
% CICLICI (Circ) la modulazione posturale e' 1 volta/giro -> passare ~2/T,
% altrimenti il low-pass taglia via il tonico del giro.
if ~isfield(opts,'Wn') || isempty(opts.Wn)
    opts.Wn = min(0.99, 1/T_norm);
end

%% ---------- 1. Caricamento ed elaborazione (identico) ----------
[tempo, emg_raw, nomi, unita] = leggi_emg_semplice(f_emg);
fs = round(1/median(diff(tempo)));
fprintf('EMG: %d canali, %.1f s, fs=%d Hz, %s\n', size(emg_raw,2), tempo(end), fs, unita);
idx = mappa_mus(nomi); emg_raw = emg_raw(:, idx); nomi = nomi(idx);
emg_rms = inviluppo(emg_raw, fs, 100);

%% ---------- 2. Eventi (identico) ----------
EV = leggi_eventi_semplice(f_ev);
if ~isfield(EV, lato)
    error('test_baseline:lato','Lato "%s" non trovato. Presenti: %s', ...
          lato, strjoin(fieldnames(EV), ', '));
end
e = EV.(lato);

%% ---------- 3. Normalizzazione (SENZA, per-canale come test_baseline) ----
picchi = max(emg_rms, [], 1, 'omitnan');
normA = nan(size(emg_rms));
for k = 1:8
    if picchi(k) > 0; normA(:,k) = emg_rms(:,k)/picchi(k)*100; end
end

%% ---------- 4-5. Per fase: SENZA (=E_A) e CON (residuo fasico) ----------
fasi = {'Intero','Salita','Discesa'};
RIS = struct(); INFO = struct();
for f = 1:3
    % --- segmentazione SENZA (identica a test_baseline) ---
    EA = nan(T_norm, 8, numel(e.start));
    for r = 1:numel(e.start)
        switch fasi{f}
            case 'Intero';  t0=e.start(r); t1=e.stop(r);
            case 'Salita';  t0=e.start(r); t1=e.mid(r);
            case 'Discesa'; t0=e.mid(r);   t1=e.stop(r);
        end
        EA(:,:,r) = taglia(normA, tempo, t0, t1, T_norm);
    end

    % --- M = [8 x (T*nrep)] come nella tua sinergie ---
    blocchi = {}; validi = [];
    for r = 1:size(EA,3)
        X = squeeze(EA(:,:,r))';
        if all(~isfinite(X(:))) || max(X(:))<eps; continue; end
        X(~isfinite(X)) = 0; blocchi{end+1} = max(X,0); validi(end+1)=r; %#ok<AGROW>
    end
    if isempty(blocchi)
        RIS = riempi_nan(RIS, fasi{f}); INFO.(fasi{f}) = struct('R2',NaN,'frac_neg',NaN);
        continue;
    end
    M = [blocchi{:}];

    % --- estrazione simultanea: tonico low-pass emergente ---
    [tonic, R2] = estrai_tonico(M, T_norm, opts);
    phasic = M - tonic;                        % residuo fasico (con segno)
    frac_neg = mean(phasic(:) < 0);
    phasic_c = max(phasic, 0);                 % clip per indici non-negativi

    % --- ricostruisco EB [T x 8 x nrep] dai blocchi fasici ---
    EB = nan(T_norm, 8, numel(e.start));
    for b = 1:numel(validi)
        blk = phasic_c(:, (b-1)*T_norm + (1:T_norm));   % [8 x T]
        EB(:,:,validi(b)) = blk';                       % [T x 8]
    end

    % --- indici (le TUE tmci e sinergie) su SENZA e CON ---
    tmA = nan(size(EA,3),1); tmB = nan(size(EB,3),1);
    for r = 1:size(EA,3), tmA(r) = tmci(squeeze(EA(:,:,r)), T_norm); end
    for r = 1:size(EB,3)
        tmp = EB(:,:,r);
        if all(isnan(tmp(:))); continue; end
        tmB(r) = tmci(tmp, T_norm);
    end
    [kAa,kVa,v1a] = sinergie(EA);
    [kAb,kVb,v1b] = sinergie(EB);

    RIS.(fasi{f}).senza = struct('TMCi',mean(tmA,'omitnan'),'k_AIC',kAa,'k_VAF',kVa,'VAF_k1',v1a);
    RIS.(fasi{f}).con   = struct('TMCi',mean(tmB,'omitnan'),'k_AIC',kAb,'k_VAF',kVb,'VAF_k1',v1b);
    INFO.(fasi{f}) = struct('R2',R2,'frac_neg',frac_neg);
end

%% ---------- 6. Confronto ----------
fprintf('\n%s\n  CONFRONTO SIMULTANEA (lato %s, Np=%d, Wn=%.3f)\n%s\n', ...
        repmat('=',1,58), lato, opts.Np, opts.Wn, repmat('=',1,58));
fprintf('%-10s %-9s %10s %8s %8s %10s   %s\n', ...
        'fase','versione','TMCi','k_AIC','k_VAF','VAF(k=1)','[R2 fit | frac.neg]');
for f = 1:3
    if ~isfield(RIS, fasi{f}) || ~isfield(RIS.(fasi{f}),'senza'); continue; end
    S = RIS.(fasi{f}).senza; C = RIS.(fasi{f}).con; I = INFO.(fasi{f});
    fprintf('%-10s %-9s %10.2f %8d %8d %10.3f\n', fasi{f},'SENZA',S.TMCi,S.k_AIC,S.k_VAF,S.VAF_k1);
    fprintf('%-10s %-9s %10.2f %8d %8d %10.3f   [%.3f | %.2f]\n', ...
            '','CON',C.TMCi,C.k_AIC,C.k_VAF,C.VAF_k1, I.R2, I.frac_neg);
    fprintf('%-10s %-9s %+9.1f%% %+8d %+8d %+10.3f\n\n','','delta', ...
        100*(C.TMCi-S.TMCi)/S.TMCi, C.k_AIC-S.k_AIC, C.k_VAF-S.k_VAF, C.VAF_k1-S.VAF_k1);
end

OUT.RIS = RIS; OUT.INFO = INFO; OUT.nomi = nomi; OUT.normA = normA; OUT.tempo = tempo;
end

%% ========================================================= NUOVE
function [tonic, R2] = estrai_tonico(M, T, opts)
% Estrazione simultanea ridotta: alterna NMF fasica (parte sopra-tonico) e
% stima tonica come componente lenta (low-pass per blocco). Multi-restart.
[nCh, Ttot] = size(M);
n_rep = Ttot / T;
Mc = M - mean(M,2); SST = sum(Mc(:).^2);
best = struct('R2',-inf,'tonic',zeros(nCh,Ttot));
for rs = 1:opts.n_restart
    Wp = rand(nCh, opts.Np)+eps; Hp = rand(opts.Np, Ttot)+eps;
    % init tonico = low-pass(M): rimuove il lento dal bersaglio fasico fin da
    % subito, cosi' il lento resta nel tonico e la NMF fasica non se lo prende.
    tonic = lowpass_blocchi(M, T, n_rep, opts.Wn); R2p = -inf; stall = 0;
    for it = 1:opts.max_iter
        Dp = max(M - tonic, 0);                    % parte fasica (>=0)
        [Wp, Hp] = nmf_step(Dp, Wp, Hp, 5);
        Mp = Wp*Hp;
        Rt = M - Mp;                               % cio' che il fasico non spiega
        tonic = lowpass_blocchi(Rt, T, n_rep, opts.Wn);
        tonic = max(tonic, 0);
        neg = min(M - (Mp + tonic), 0);            % nota lambda: soft non-neg
        tonic = max(tonic + opts.lambda*neg, 0);
        Er = M - (Mp + tonic); R2 = 1 - sum(Er(:).^2)/SST;
        if abs(R2 - R2p) < opts.tol, stall = stall+1; else, stall = 0; end
        R2p = R2; if stall >= 10, break; end
    end
    if R2 > best.R2, best = struct('R2',R2,'tonic',tonic); end
end
tonic = best.tonic; R2 = best.R2;
end

function [W, H] = nmf_step(X, W, H, iters)
X = max(X,0);
for i = 1:iters
    WH = W*H + eps; H = H .* (W'*X) ./ (W'*WH + eps);
    WH = W*H + eps; W = W .* (X*H') ./ (WH*H' + eps);
    nrm = sqrt(sum(W.^2,1)) + eps; W = W ./ nrm; H = H .* nrm';
end
end

function Y = lowpass_blocchi(X, T, n_rep, Wn)
[nCh,~] = size(X); Y = zeros(size(X));
usa_butter = exist('butter','file') && exist('filtfilt','file');
if usa_butter, [b,a] = butter(2, Wn); end
for c = 1:nCh
    for r = 1:n_rep
        idx = (r-1)*T + (1:T); seg = X(c, idx);
        if usa_butter, Y(c,idx) = filtfilt(b,a,seg);
        else,          Y(c,idx) = mediamobile_zerofase(seg, max(3,round(1/Wn))); end
    end
end
end

function y = mediamobile_zerofase(x, w)
w = 2*floor(w/2)+1; k = ones(1,w)/w;
pad = @(v)[repmat(v(1),1,w), v, repmat(v(end),1,w)];
f = @(v) conv(pad(v),k,'same');
y1 = f(x); y1 = y1(w+1:end-w);
y2 = fliplr(f(fliplr(y1))); y2 = y2(w+1:end-w);
if numel(y2)~=numel(x), y2 = interp1(linspace(0,1,numel(y2)),y2,linspace(0,1,numel(x))); end
y = y2;
end

function R = riempi_nan(R, fase)
z = struct('TMCi',NaN,'k_AIC',NaN,'k_VAF',NaN,'VAF_k1',NaN);
R.(fase).senza = z; R.(fase).con = z;
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
    R = W*H; VAF(k) = 1 - sum((M(:)-R(:)).^2)/sum(M(:).^2);
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
