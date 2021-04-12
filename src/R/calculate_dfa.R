calculate_dfa <- function(COP_timeseries) {
    
    # Calculate DFA
    DFAout_ml <- dfa(COP_timeseries$COPml)
    dfa_alpah_ml <- estimate(DFAout_ml, do.plot = FALSE)
    DFAout_ap <- dfa(COP_timeseries$COPap)
    dfa_alpah_ap <- estimate(DFAout_ap, do.plot = FALSE)
    
    results <- c(dfa_alpah_ml[1], dfa_alpah_ap[1])
    
    return(results)
}