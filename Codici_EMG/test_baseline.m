function OUT = test_baseline(f_emg, f_ev, lato, T_norm)
%TEST_BASELINE  Confronta la pipeline CON e SENZA sottrazione della linea
%  di base, su un singolo movimento. Non tocca il MASTER: serve a decidere
%  se la modifica vale prima di rifare tutto.
%
%  USO (funzione: chiamare dal Command Window)
%    OUT = test_baseline_segmentata (['C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG\Patologici\S041\T0\S041_Flex_EMG.emt'], ['C:\Users\simom\OneDrive\Desktop\Simone\Uni\Tesi\Analyzer\DATI EMG\Patologici\S041\T0\S041_Flex.emt'], 'R')
%  COSA FA
%   1. elabora l'EMG come il MASTER (notch, banda, rettifica, RMS)
%   2. stima la LINEA DI BASE per muscolo dalle finestre di quiete
%      (prima del primo Start, tra i blocchi R e L, dopo l'ultimo Stop)
%   3. produce DUE versioni normalizzate: con e senza sottrazione
%   4. segmenta entrambe e calcola TMCi (Globale) e sinergie
%   5. stampa il confronto affiancato
%
%  PERCHE' UNA COSTANTE E NON UNA RAMPA
%  Il modello tonico di d'Avella e' una rampa lineare tra il livello
%  posturale iniziale e quello finale. Qui postura iniziale e finale
%  COINCIDONO (braccio lungo il fianco), quindi il tonico e' costante e
%  basta stimarne un livello solo. Lo max(0,...) dopo la sottrazione e'
%  lo 0-padding che Scano et al. (2022) definiscono approssimazione
%  ragionevole per i movimenti contro gravita'.
%
%  ATTENZIONE all'ORDINE: la sottrazione va fatta PRIMA della
%  normalizzazione al picco, altrimenti anche il picco cambia e
%  l'operazione non e' piu' una rimozione di offset.

if nargin < 3 || isempty(lato);   lato   = 'R';  end
if nargin < 4 || isempty(T_norm); T_norm = 100;  end

%% ---------- 1. Caricamento ed elaborazione ----------
[tempo, emg_raw, nomi, unita] = leggi_emg_semplice(f_emg);
fs = round(1/median(diff(tempo)));
fprintf('EMG: %d canali, %.1f s, fs=%d Hz, %s\n', size(emg_raw,2), tempo(end), fs, unita);

idx     = mappa_mus(nomi);
emg_raw = emg_raw(:, idx);
nomi    = nomi(idx);

emg_rms = inviluppo(emg_raw, fs, 100);

%% ---------- 2. Eventi e finestre di quiete ----------
EV = leggi_eventi_semplice(f_ev);
if ~isfield(EV, lato)
    error('test_baseline:lato', 'Lato "%s" non trovato. Presenti: %s', ...
          lato, strjoin(fieldnames(EV), ', '));
end

% Tutti gli intervalli di movimento (di ogni lato), per escluderli
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
if sum(quiete)/fs < 1
    warning('test_baseline:poca_quiete', ...
        'Meno di 1 s di quiete: la stima della linea di base e'' fragile.');
end

%% ---------- 3. Linea di base per muscolo ----------
base = median(emg_rms(quiete,:), 1, 'omitnan');
picchi = max(emg_rms, [], 1, 'omitnan');

fprintf('\n%-11s %10s %10s %9s %9s\n', 'muscolo','base','picco','base/pk','rapporto');
mask_mov = false(size(tempo));
e = EV.(lato);
for r = 1:numel(e.start)
    mask_mov = mask_mov | (tempo >= e.start(r) & tempo <= e.stop(r));
end
for k = 1:8
    liv_mov = mean(emg_rms(mask_mov,k), 'omitnan');
    fprintf('%-11s %10.2f %10.2f %8.0f%% %9.2f\n', nomi{k}, base(k), picchi(k), ...
            100*base(k)/picchi(k), liv_mov/max(base(k),eps));
end
fprintf('  (rapporto = livello medio in movimento / linea di base;\n');
fprintf('   ~1 significa muscolo NON modulato dal gesto)\n');

%% ---------- 4. Due versioni normalizzate ----------
% A: come il MASTER attuale
normA = nan(size(emg_rms));
for k = 1:8
    if picchi(k) > 0; normA(:,k) = emg_rms(:,k)/picchi(k)*100; end
end

% B: sottrazione della linea di base PRIMA della normalizzazione
emg_sub = max(0, emg_rms - base);          % 0-padding
picchiB = max(emg_sub, [], 1, 'omitnan');
normB = nan(size(emg_sub));
for k = 1:8
    if picchiB(k) > 0; normB(:,k) = emg_sub(:,k)/picchiB(k)*100; end
end

%% ---------- 5. Segmentazione e indici ----------
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
        % TMCi Globale
        tm = nan(size(E,3),1);
        for r = 1:size(E,3)
            tm(r) = tmci(squeeze(E(:,:,r)), T_norm);
        end
        % sinergie sulla concatenazione
        [kA, kV, vaf1] = sinergie(E);
        RIS(v).tag = tag;
        RIS(v).(fasi{f}) = struct('TMCi',mean(tm,'omitnan'), ...
                                  'k_AIC',kA,'k_VAF',kV,'VAF_k1',vaf1);
        RIS(v).emg.(fasi{f}) = E;
    end
end

%% ---------- 6. Confronto ----------
fprintf('\n%s\n  CONFRONTO  (lato %s)\n%s\n', repmat('=',1,58), lato, repmat('=',1,58));
fprintf('%-10s %-9s %10s %8s %8s %10s\n', 'fase','versione','TMCi','k_AIC','k_VAF','VAF(k=1)');
for f = 1:3
    for v = 1:2
        S = RIS(v).(fasi{f});
        fprintf('%-10s %-9s %10.2f %8d %8d %10.3f\n', ...
            fasi{f}, RIS(v).tag, S.TMCi, S.k_AIC, S.k_VAF, S.VAF_k1);
    end
    a = RIS(1).(fasi{f}); b = RIS(2).(fasi{f});
    fprintf('%-10s %-9s %+9.1f%% %+8d %+8d %+10.3f\n\n', '', 'delta', ...
        100*(b.TMCi-a.TMCi)/a.TMCi, b.k_AIC-a.k_AIC, b.k_VAF-a.k_VAF, b.VAF_k1-a.VAF_k1);
end

OUT.base    = base;
OUT.picchi  = picchi;
OUT.nomi    = nomi;
OUT.senza   = RIS(1);
OUT.con     = RIS(2);
OUT.normA   = normA;
OUT.normB   = normB;
OUT.tempo   = tempo;
end


%% =========================================================
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
% AIC semplificato (stessa forma del MASTER, senza wavelet: qui serve
% solo il confronto relativo tra le due versioni)
AIC = zeros(7,1);
for k = 1:7
    [W,H] = nnmf(M,k,'replicates',10,'algorithm','mult');
    R = W*H; res = M-R;
    s2 = var(M(:)) + (0.15*movmean(M,round(size(M,2)*0.02),2)).^2;
    AIC(k) = -(-0.5*sum(sum(res.^2./(s2+eps)))) + 8*k + k*round(size(M,2)/10);
end
[~,kA] = min(AIC);
end
