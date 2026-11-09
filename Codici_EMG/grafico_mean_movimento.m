function OUT = grafico_mean_movimento(MEAN, mov, fase)
%GRAFICO_MEAN_MOVIMENTO  Un'unica figura per un movimento con le k mean synergies
%  affiancate (pannelli), ognuna con i pesi muscolari (sigle). Titolo = nome
%  esteso del movimento (Circonduzione divisa avanti/indietro).
%
%  USO
%    grafico_mean_movimento(MEAN, 'Addu')                    % fase di default (R_Intero)
%    grafico_mean_movimento(MEAN, 'Circ', 'RAvanti_Intero')  % Circ: specifica la direzione
%    grafico_mean_movimento(MEAN, 'Circ', 'RIndietro_Intero')
%    grafico_mean_movimento(MEAN, 'RandG', 'Completo_Intero')

MUS = {'ES','BB','FRC','DA','RA','TB','ERC','DP'};
COL = [0 0 0];

if ~isfield(MEAN, mov); error('grafico_mean_movimento:mov','MEAN non ha %s.', mov); end
fasi = fieldnames(MEAN.(mov));
if nargin < 3 || isempty(fase); fase = fasi{1}; end
if ~isfield(MEAN.(mov), fase); error('grafico_mean_movimento:fase','MEAN.%s non ha %s.', mov, fase); end

W = MEAN.(mov).(fase).Wref; k = size(W,2);
titolo = nome_movimento(mov, fase);

figure('Color','w','Position',[60 60 max(300*k,360) 470]);
for i = 1:k
    subplot(1, k, i);
    barh(1:8, W(:,i), 'FaceColor', COL, 'EdgeColor','none');
    set(gca,'YDir','reverse','YTick',1:8,'YTickLabel',MUS,'FontSize',10);
    xlim([0 max(0.01,max(W(:)))*1.1]); xlabel('peso');
    title(sprintf('Sinergia %d', i), 'FontWeight','normal','FontSize',11);
    box off;
    if i > 1; set(gca,'YTickLabel',[]); end
end
try; sgtitle(titolo, 'FontSize',14, 'FontWeight','bold'); catch; end

OUT.Wref = W; OUT.k = k; OUT.mov = mov; OUT.fase = fase; OUT.titolo = titolo;
end

%% ---------------------------------------------------------
function nm = nome_movimento(mov, fase)
switch mov
    case 'Flex';       nm = 'Flessione';
    case 'Addu';       nm = 'Adduzione';
    case 'Addu_orizz'; nm = 'Adduzione orizzontale';
    case 'RandG';      nm = 'Reach and Grasp';
    case 'Circ'
        if ~isempty(regexp(fase,'^RAvanti|^LAvanti','once')); nm = 'Circonduzione avanti';
        elseif ~isempty(regexp(fase,'^RIndietro|^LIndietro','once')); nm = 'Circonduzione indietro';
        else; nm = 'Circonduzione'; end
    otherwise; nm = mov;
end
end
