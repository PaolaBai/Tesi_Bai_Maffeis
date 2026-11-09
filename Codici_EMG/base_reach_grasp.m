function R = base_reach_grasp(DATA, opts)
%BASE_REACH_GRASP  Calcola ampiezza massima (uV) e media (uV) dei valori base EMG
%  del RandG separati per REACH e GRASP, a partire dagli inviluppi EMG_cat.
%
%  Reach = fasi RAndata_Intero + RRitorno_Intero (unite).
%  Grasp = fasi GAndata_Intero + GRitorno_Intero (unite).
%  EMG_cat e' normalizzato 0-100: l'ampMax e la media sono de-normalizzate in uV
%  moltiplicando per picchi_uV (come calcola_base_emg nel MASTER).
%
%  USO
%    R = base_reach_grasp(DATA);
%    R = base_reach_grasp(DATA, struct('gruppi',{{'Sani','Patologici'}}));
%
%  OUTPUT R: struttura con, per ogni soggetto/timepoint,
%    R.<gruppo>.<sog>.<tempo>.reach.amp_max_uV  [1x8]
%                                 .media_uV      [1x8]
%                            .grasp.amp_max_uV   [1x8]
%                                 .media_uV      [1x8]
%  Piu' una tabella piatta R.TAB (soggetto, gruppo, tempo, segmento, muscolo, ampMax, media).

if nargin < 2, opts = struct; end
if ~isfield(opts,'gruppi'), opts.gruppi = {'Sani','Patologici'}; end
if ~isfield(opts,'mov'),    opts.mov = 'RandG'; end

FASI.reach = {'RAndata_Intero','RRitorno_Intero'};
FASI.grasp = {'GAndata_Intero','GRitorno_Intero'};
MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};

R = struct(); righe = {};
for g = 1:numel(opts.gruppi)
    gruppo = opts.gruppi{g};
    if ~isfield(DATA, gruppo); continue; end
    sogg = fieldnames(DATA.(gruppo));
    for s = 1:numel(sogg)
        Snm = sogg{s};
        tempi = fieldnames(DATA.(gruppo).(Snm));
        for it = 1:numel(tempi)
            TP = tempi{it};
            st = DATA.(gruppo).(Snm).(TP);
            if ~isstruct(st) || ~isfield(st, opts.mov); continue; end
            M = st.(opts.mov);
            if ~isfield(M,'sinergie') || ~isfield(M.sinergie,'EMG_cat'); continue; end
            if ~isfield(M,'picchi_uV'); continue; end
            syn = M.sinergie; lab = cellstr(syn.phase_labels); picchi = M.picchi_uV(:)';

            for seg = {'reach','grasp'}
                segn = seg{1};
                % concatena gli inviluppi delle fasi del segmento (andata+ritorno)
                E = [];
                for f = 1:numel(FASI.(segn))
                    j = find(strcmp(lab, FASI.(segn){f}), 1);
                    if isempty(j) || j > numel(syn.EMG_cat); continue; end
                    Ej = syn.EMG_cat{j};              % [8 x T], scala 0-100
                    if isempty(Ej); continue; end
                    E = [E, Ej];                      %#ok<AGROW> concatena nel tempo
                end
                if isempty(E); continue; end
                % de-normalizzazione in uV: valore0-100 /100 * picco_uV del canale
                nM = size(E,1);
                amp = nan(1,nM); med = nan(1,nM);
                for c = 1:nM
                    x100 = E(c,:); x100 = x100(isfinite(x100));
                    if c > numel(picchi) || ~isfinite(picchi(c)); continue; end
                    xuv = x100/100 * picchi(c);       % de-normalizza in uV
                    if ~isempty(xuv)
                        amp(c) = max(xuv);
                        med(c) = mean(xuv);
                    end
                end
                R.(gruppo).(Snm).(TP).(segn).amp_max_uV = amp;
                R.(gruppo).(Snm).(TP).(segn).media_uV   = med;
                % righe tabella
                for c = 1:nM
                    righe(end+1,:) = { Snm, gruppo, TP, segn, MUS{min(c,numel(MUS))}, amp(c), med(c) }; %#ok<AGROW>
                end
            end
        end
    end
end

intest = {'soggetto','gruppo','timepoint','segmento','muscolo','ampMax_uV','media_uV'};
if exist('cell2table','file') && ~isempty(righe)
    R.TAB = cell2table(righe,'VariableNames',intest);
else
    R.TAB = [intest; righe];
end

fprintf('[base_reach_grasp] calcolati valori base reach/grasp per %d righe\n', size(righe,1));
end
