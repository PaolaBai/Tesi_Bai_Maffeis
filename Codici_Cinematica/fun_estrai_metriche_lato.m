function vals = fun_estrai_metriche_lato(tab_grezza, soggetto, lato)

num_metriche = 18;

filtro = startsWith(strip(string(tab_grezza.Lato)), lato, 'IgnoreCase', true) & (string(tab_grezza.Soggetto) == soggetto);

if any(filtro)
    sub_lato = tab_grezza(filtro, :);

    filtro_andata = string(sub_lato.Tratto) == "Andata";
    filtro_ritorno = string(sub_lato.Tratto) == "Ritorno";
    filtro_totale = string(sub_lato.Tratto) == "Totale";

    jerkM_A = estrai_singolo_valore(sub_lato.jerkMean, filtro_andata);
    jerkM_R = estrai_singolo_valore(sub_lato.jerkMean, filtro_ritorno);
    jerkP_A = estrai_singolo_valore(sub_lato.jerkPeak, filtro_andata);
    jerkP_R = estrai_singolo_valore(sub_lato.jerkPeak, filtro_ritorno);
    LDLJ_A = estrai_singolo_valore(sub_lato.LDLJ, filtro_andata);
    LDLJ_R = estrai_singolo_valore(sub_lato.LDLJ, filtro_ritorno);
    SPARC_A = estrai_singolo_valore(sub_lato.SPARC, filtro_andata);
    SPARC_R = estrai_singolo_valore(sub_lato.SPARC, filtro_ritorno);
    skewness_A = estrai_singolo_valore(sub_lato.skewness, filtro_andata);
    skewness_R = estrai_singolo_valore(sub_lato.skewness, filtro_ritorno);

    angolo_spalla = estrai_singolo_valore(sub_lato.AngoloSpallaMedio, filtro_totale);
    ROM_spalla = estrai_singolo_valore(sub_lato.ROMSpalla, filtro_totale);
    angolo_sag = estrai_singolo_valore(sub_lato.AngoloSagittaleTroncoMedio, filtro_totale);
    ROM_sag = estrai_singolo_valore(sub_lato.ROMTroncoSagittale, filtro_totale);
    angolo_front = estrai_singolo_valore(sub_lato.AngoloFrontaleTroncoMedio, filtro_totale);
    ROM_front = estrai_singolo_valore(sub_lato.ROMTroncoFrontale, filtro_totale);
    angolo_tors = estrai_singolo_valore(sub_lato.AngoloTorsioneTroncoMedio, filtro_totale);
    ROM_tors = estrai_singolo_valore(sub_lato.ROMTroncoTorsione, filtro_totale);

    vals = [jerkM_A, jerkM_R, jerkP_A, jerkP_R, LDLJ_A, LDLJ_R, SPARC_A, SPARC_R, skewness_A, skewness_R,...
        angolo_spalla, ROM_spalla, angolo_sag, ROM_sag, angolo_front, ROM_front, angolo_tors, ROM_tors];
else
    vals = NaN(1, num_metriche);
end
end

function val = estrai_singolo_valore(colonna, filtro)
tmp = colonna(filtro);
if ~isempty(tmp)
    val = tmp(1);
else
    val = NaN;
end
end