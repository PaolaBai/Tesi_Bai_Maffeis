function vals = fun_estrai_metriche_lato_RandG(tab_grezza, soggetto)

num_metriche = 36;

filtro = (string(tab_grezza.Soggetto) == soggetto);

if any(filtro)
    sub_lato = tab_grezza(filtro, :);

    col_tratto = (string(sub_lato.Tratto));
    col_accelerazione = (string(sub_lato.Accelerazione));

    filtro_andata = col_tratto == "Andata";
    filtro_ritorno = col_tratto == "Ritorno";
    filtro_totale = col_tratto == "Totale";

    filtro_acc = col_accelerazione == "Accelerazione";
    filtro_dec = col_accelerazione == "Decelerazione";
    filtro_tot = col_accelerazione == "Totale";

    jerkM_Acc_A = estrai_singolo_valore(sub_lato.jerkMean, filtro_andata & filtro_acc);
    jerkM_Dec_A = estrai_singolo_valore(sub_lato.jerkMean, filtro_andata & filtro_dec);
    jerkM_A = estrai_singolo_valore(sub_lato.jerkMean, filtro_andata & filtro_tot);
    jerkM_Acc_R = estrai_singolo_valore(sub_lato.jerkMean, filtro_ritorno & filtro_acc);
    jerkM_Dec_R = estrai_singolo_valore(sub_lato.jerkMean, filtro_ritorno & filtro_dec);
    jerkM_R = estrai_singolo_valore(sub_lato.jerkMean, filtro_ritorno & filtro_tot);
    jerkP_Acc_A = estrai_singolo_valore(sub_lato.jerkPeak, filtro_andata & filtro_acc);
    jerkP_Dec_A = estrai_singolo_valore(sub_lato.jerkPeak, filtro_andata & filtro_dec);
    jerkP_A = estrai_singolo_valore(sub_lato.jerkPeak, filtro_andata & filtro_tot);
    jerkP_Acc_R = estrai_singolo_valore(sub_lato.jerkPeak, filtro_ritorno & filtro_acc);
    jerkP_Dec_R = estrai_singolo_valore(sub_lato.jerkPeak, filtro_ritorno & filtro_dec);
    jerkP_R = estrai_singolo_valore(sub_lato.jerkPeak, filtro_ritorno & filtro_tot);
    LDLJ_Acc_A = estrai_singolo_valore(sub_lato.LDLJ, filtro_andata & filtro_acc);
    LDLJ_Dec_A = estrai_singolo_valore(sub_lato.LDLJ, filtro_andata & filtro_dec);
    LDLJ_A = estrai_singolo_valore(sub_lato.LDLJ, filtro_andata & filtro_tot);
    LDLJ_Acc_R = estrai_singolo_valore(sub_lato.LDLJ, filtro_ritorno & filtro_acc);
    LDLJ_Dec_R = estrai_singolo_valore(sub_lato.LDLJ, filtro_ritorno & filtro_dec);
    LDLJ_R = estrai_singolo_valore(sub_lato.LDLJ, filtro_ritorno & filtro_tot);
    SPARC_Acc_A = estrai_singolo_valore(sub_lato.SPARC, filtro_andata & filtro_acc);
    SPARC_Dec_A = estrai_singolo_valore(sub_lato.SPARC, filtro_andata & filtro_dec);
    SPARC_A = estrai_singolo_valore(sub_lato.SPARC, filtro_andata & filtro_tot);
    SPARC_Acc_R = estrai_singolo_valore(sub_lato.SPARC, filtro_ritorno & filtro_acc);    
    SPARC_Dec_R = estrai_singolo_valore(sub_lato.SPARC, filtro_ritorno & filtro_dec);
    SPARC_R = estrai_singolo_valore(sub_lato.SPARC, filtro_ritorno & filtro_tot);

    skewness_A = estrai_singolo_valore(sub_lato.skewness, filtro_andata & filtro_tot);
    skewness_R = estrai_singolo_valore(sub_lato.skewness, filtro_ritorno & filtro_tot);

    angolo_spalla = estrai_singolo_valore(sub_lato.AngoloSpallaMedio, filtro_totale & filtro_tot);
    ROM_spalla = estrai_singolo_valore(sub_lato.ROMSpalla, filtro_totale & filtro_tot);
    angolo_gomito = estrai_singolo_valore(sub_lato.AngoloMedioGomito, filtro_totale & filtro_tot);
    ROM_gomito = estrai_singolo_valore(sub_lato.ROMGomito, filtro_totale & filtro_tot);
    angolo_sag = estrai_singolo_valore(sub_lato.AngoloSagittaleTroncoMedio, filtro_totale & filtro_tot);
    ROM_sag = estrai_singolo_valore(sub_lato.ROMTroncoSagittale, filtro_totale & filtro_tot);
    angolo_front = estrai_singolo_valore(sub_lato.AngoloFrontaleTroncoMedio, filtro_totale & filtro_tot);
    ROM_front = estrai_singolo_valore(sub_lato.ROMTroncoFrontale, filtro_totale & filtro_tot);
    angolo_tors = estrai_singolo_valore(sub_lato.AngoloTorsioneTroncoMedio, filtro_totale & filtro_tot);
    ROM_tors = estrai_singolo_valore(sub_lato.ROMTroncoTorsione, filtro_totale & filtro_tot);

    vals = [jerkM_Acc_A, jerkM_Dec_A, jerkM_A, jerkM_Acc_R, jerkM_Dec_R, jerkM_R, jerkP_Acc_A, jerkP_Dec_A, jerkP_A, jerkP_Acc_R, jerkP_Dec_R, jerkP_R, ...
        LDLJ_Acc_A, LDLJ_Dec_A, LDLJ_A, LDLJ_Acc_R, LDLJ_Dec_R, LDLJ_R, SPARC_Acc_A, SPARC_Dec_A, SPARC_A, SPARC_Acc_R,SPARC_Dec_R, SPARC_R,...
        skewness_A, skewness_R, angolo_spalla, ROM_spalla, angolo_gomito, ROM_gomito, angolo_sag, ROM_sag, angolo_front, ROM_front, angolo_tors, ROM_tors];
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