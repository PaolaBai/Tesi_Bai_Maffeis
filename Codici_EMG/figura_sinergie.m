function OUT = figura_sinergie(DATA, mov, fase, k_ref, gruppo_ref, sog_paz, tempo_paz, fase_paz, fonte, PROTO)
%FIGURA_SINERGIE  Riferimento sani (media +/- SD) vs UN paziente.
%
%  W_ref (moduli di riferimento) da due FONTI, a scelta:
%    fonte='nnmf'    -> NNMF concatenata di tutti i sani, moda dei k_AIC (default)
%    fonte='cluster' -> prototipi dal clustering (PROTO.<mov>.<fase>.Wref, >=50%)
%
%  Riga superiore: W di riferimento. Riga inferiore: media +/- SD degli H dei
%  sani (banda) e H del paziente scelto; in titolo il VAF del paziente.
%
%  USO
%    figura_sinergie(DATA, 'Addu', 'R_Intero', [], 'Sani', 'S041', 'T0')
%    % paziente lato L: passa la sua fase omologa come 8o argomento
%    figura_sinergie(DATA, 'Addu', 'R_Intero', [], 'Sani', 'S041', 'T0', 'L_Intero')
%
%  k_ref     n. moduli del riferimento (default: moda dei k_AIC dei sani)
%  fase_paz  fase del paziente (default = fase). Per un paziente con lato
%            affetto L, la fase omologa e' la L (es. 'L_Intero').

if nargin < 4; k_ref = []; end
if nargin < 5 || isempty(gruppo_ref); gruppo_ref = 'Sani'; end
if nargin < 6 || isempty(sog_paz); error('figura_sinergie:paz','Specifica il paziente (sog_paz).'); end
if nargin < 7; tempo_paz = ''; end
if nargin < 8 || isempty(fase_paz); fase_paz = fase; end
if nargin < 9 || isempty(fonte); fonte = 'nnmf'; end     % 'nnmf' | 'cluster'
if nargin < 10; PROTO = []; end

nomi_mus = {'Erettore','Bicipite','Flessore','Delt.Ant', ...
            'Addome','Tricipite','Estensore','Delt.Post'};

%% ---------- 1. W di riferimento dai sani ----------
if ~isfield(DATA, gruppo_ref); error('figura_sinergie:gruppo','Gruppo "%s" non trovato.', gruppo_ref); end
sani = fieldnames(DATA.(gruppo_ref));

if strcmpi(fonte,'cluster')
    % --- W_ref dai PROTOTIPI del clustering (PROTO), filtrati a prevalenza >=50% ---
    if isempty(PROTO) || ~isfield(PROTO,mov) || ~isfield(PROTO.(mov),fase)
        error('figura_sinergie:proto', ...
            'fonte "cluster": serve PROTO con %s/%s (da tutti_prototipi).', mov, fase);
    end
    Pc = PROTO.(mov).(fase);
    W_ref = Pc.Wref;
    if isfield(Pc,'prevalenza') && isfield(Pc,'n_sani')
        keep  = (Pc.prevalenza(:)/Pc.n_sani) >= 0.50;
        W_ref = W_ref(:,keep);
    end
    if isempty(W_ref) || size(W_ref,2)==0
        error('figura_sinergie:proto_vuoto','Nessun prototipo >=50%% per %s/%s.', mov, fase);
    end
    for i = 1:size(W_ref,2)                     % rinormalizza a norma 1 per sicurezza
        nn = norm(W_ref(:,i)); if nn>eps; W_ref(:,i)=W_ref(:,i)/nn; end
    end
    k_ref = size(W_ref,2);                      % gia' ordinati per prevalenza
    fprintf('W_ref da CLUSTER: %d prototipi (prevalenza >= 50%%)\n', k_ref);
else
    % --- W_ref per NNMF concatenata di tutti i sani (moda dei k_AIC) ---
    blocchi = {};
    for s = 1:numel(sani)
        tempo_sano = ''; if isfield(DATA.(gruppo_ref).(sani{s}), 'T'); tempo_sano = 'T'; end
        E = prendi_emg(DATA, gruppo_ref, sani{s}, tempo_sano, mov, fase);
        if ~isempty(E); blocchi{end+1} = E; end %#ok<AGROW>
    end
    if isempty(blocchi); error('figura_sinergie:dati','Nessun EMG concatenato dei sani per questa fase.'); end
    M_ref = [blocchi{:}];
    fprintf('W_ref da %d sani (NNMF): [%d x %d]\n', numel(blocchi), size(M_ref,1), size(M_ref,2));
    if isempty(k_ref)
        kk = [];
        for s = 1:numel(sani)
            tempo_sano = ''; if isfield(DATA.(gruppo_ref).(sani{s}), 'T'); tempo_sano = 'T'; end
            k = prendi_k(DATA, gruppo_ref, sani{s}, tempo_sano, mov, fase);
            if ~isnan(k); kk(end+1) = k; end %#ok<AGROW>
        end
        k_ref = mode(kk);
        fprintf('k_ref = %d (moda dei k_AIC dei sani)\n', k_ref);
    end
    [W_ref, H_ref] = nnmf(M_ref, k_ref, 'replicates', 20, 'algorithm', 'mult');
    [W_ref, H_ref] = normalizza(W_ref, H_ref);
    T = size(H_ref,2); coa = zeros(1,k_ref);    % riordino per centro di attivita'
    for i = 1:k_ref
        h = H_ref(i,:); coa(i) = sum((1:T).*h)/max(sum(h),eps);
    end
    [~, ordine] = sort(coa);
    W_ref = W_ref(:,ordine);
end

%% ---------- 2. NNR: H di OGNI sano (per media+SD) e del paziente ----------
Tn = 100;
Hs = {};                                   % H medi dei sani [k x Tn]
for s = 1:numel(sani)
    tempo_sano = ''; if isfield(DATA.(gruppo_ref).(sani{s}), 'T'); tempo_sano = 'T'; end
    E = prendi_emg(DATA, gruppo_ref, sani{s}, tempo_sano, mov, fase);
    if isempty(E); continue; end
    [H, ~] = ricostruzione_nnr(E, W_ref);
    Hs{end+1} = media_cicli(H, Tn); %#ok<AGROW>
end
[H_sani_mean, H_sani_sd] = aggrega_H(Hs, k_ref, Tn);

% paziente
E_paz = prendi_emg(DATA, gruppo_paz_group(DATA, sog_paz), sog_paz, tempo_paz, mov, fase_paz);
if isempty(E_paz)
    error('figura_sinergie:paz_dati','Paziente %s: fase "%s" non trovata.', sog_paz, fase_paz);
end
[H_p, vaf_paz] = ricostruzione_nnr(E_paz, W_ref);
H_paz = media_cicli(H_p, Tn);

%% ---------- 3. Figura ----------
figure('Color','w','Position',[80 80 260*k_ref 560]);
x = linspace(0,100,Tn);

% riga superiore: W_ref
for i = 1:k_ref
    subplot(2, k_ref, i);
    barh(1:8, W_ref(:,i), 'FaceColor',[0.25 0.25 0.25], 'EdgeColor','none');
    set(gca,'YDir','reverse','YTick',1:8,'YTickLabel',nomi_mus,'FontSize',8);
    xlim([0 1]); xlabel('peso'); title(sprintf('W%d_{%s}', i, upper(gruppo_ref)));
    box off; if i > 1; set(gca,'YTickLabel',[]); end
end

% riga inferiore: media sani +/- SD  +  paziente
for i = 1:k_ref
    subplot(2, k_ref, k_ref+i); hold on;
    mu = H_sani_mean(i,:); sd = H_sani_sd(i,:);
    xf = [x, fliplr(x)]; yf = [mu+sd, fliplr(mu-sd)]; yf(~isfinite(yf))=0;
    fill(xf, yf, [0.2 0.5 0.9], 'FaceAlpha',0.18, 'EdgeColor','none');
    hs = plot(x, mu, 'Color',[0.2 0.5 0.9], 'LineWidth',1.8);
    hp = plot(x, H_paz(i,:), 'Color',[0.85 0.2 0.2], 'LineWidth',2.0);
    xlim([0 100]); xlabel('% del ciclo'); title(sprintf('H%d', i));
    box off; grid on;
    if i == 1
        ylabel('attivazione');
        legend([hs hp], {sprintf('%s (media\\pmSD)',gruppo_ref), ...
               sprintf('%s (VAF=%.2f)', sog_paz, vaf_paz)}, 'Location','best','FontSize',8);
    end
end
sgtitle(sprintf('%s — %s   |   %s vs %s', mov, strrep(fase,'_','\_'), sog_paz, gruppo_ref), 'FontSize',11);

%% ---------- 4. Output ----------
OUT.W_ref = W_ref; OUT.k_ref = k_ref;
OUT.H_sani_mean = H_sani_mean; OUT.H_sani_sd = H_sani_sd;
OUT.H_paz = H_paz; OUT.VAF_paz = vaf_paz;
OUT.sog_paz = sog_paz; OUT.mov = mov; OUT.fase = fase; OUT.fase_paz = fase_paz;
end

%% =========================================================
function [Hm, Hsd] = aggrega_H(Hs, k, T)
% media e SD, modulo per modulo, delle curve H dei sani
n = numel(Hs);
cubo = nan(k, T, n);
for s = 1:n
    Hcur = Hs{s};
    if size(Hcur,1) >= k; cubo(:,:,s) = Hcur(1:k,1:T); end
end
Hm  = nan(k,T); Hsd = nan(k,T);
for i = 1:k
    for t = 1:T
        v = squeeze(cubo(i,t,:)); v = v(isfinite(v));
        if ~isempty(v); Hm(i,t) = mean(v); end
        if numel(v) > 1; Hsd(i,t) = std(v); end
    end
end
end

%% =========================================================
function [H, vaf] = ricostruzione_nnr(M, W)
T = size(M,2); k = size(W,2); H = zeros(k,T);
for t = 1:T; H(:,t) = lsqnonneg(W, M(:,t)); end
R = W*H; vaf = 1 - sum((M(:)-R(:)).^2) / sum(M(:).^2);
end

function Hm = media_cicli(H, T)
k = size(H,1); n = floor(size(H,2)/T);
if n < 1; Hm = H; return; end
Hm = zeros(k,T);
for i = 1:n; Hm = Hm + H(:, (i-1)*T + (1:T)); end
Hm = Hm / n;
end

function [W,H] = normalizza(W,H)
for i = 1:size(W,2)
    nn = norm(W(:,i)); if nn > eps; W(:,i)=W(:,i)/nn; H(i,:)=H(i,:)*nn; end
end
end

function g = gruppo_paz_group(DATA, sog)
% trova il gruppo che contiene il paziente
g = ''; gr = fieldnames(DATA);
for i = 1:numel(gr); if isfield(DATA.(gr{i}), sog); g = gr{i}; return; end; end
if isempty(g); error('figura_sinergie:paz','Soggetto %s non trovato in DATA.', sog); end
end

function E = prendi_emg(DATA, g, s, tempo, mov, fase)
E = [];
if ~isfield(DATA.(g), s); return; end
ss = DATA.(g).(s);
if ~isempty(tempo) && isfield(ss, tempo); tgt = ss.(tempo); else; tgt = ss; end
if ~isfield(tgt, mov); return; end
M = tgt.(mov);
if ~isfield(M,'sinergie'); return; end
syn = M.sinergie; if ~isfield(syn,'EMG_cat'); return; end
lab = cellstr(syn.phase_labels); j = find(strcmp(lab, fase),1);
if isempty(j) || j > numel(syn.EMG_cat); return; end
E = syn.EMG_cat{j};
end

function k = prendi_k(DATA, g, s, tempo, mov, fase)
k = NaN;
if ~isfield(DATA.(g), s); return; end
ss = DATA.(g).(s);
if ~isempty(tempo) && isfield(ss, tempo); tgt = ss.(tempo); else; tgt = ss; end
if ~isfield(tgt, mov); return; end
syn = tgt.(mov).sinergie; lab = cellstr(syn.phase_labels); j = find(strcmp(lab, fase),1);
if isempty(j); return; end
if size(syn.k_AIC,1) == 1; k = syn.k_AIC(1,j); else; k = round(mean(syn.k_AIC(:,j),'omitnan')); end
end
