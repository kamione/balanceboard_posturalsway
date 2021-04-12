do_DFA <- function(COP_timeseries) {
  # make sure to run library(nonlinearTseries) before running 
  # called from 'read_resampled_data_do_DFA' script
  
  # Calculate DFA
  DFAout.ml <- dfa(COP_timeseries$COPml)
  DFA.ml <- estimate(DFAout.ml,do.plot=FALSE)
  DFAout.ap <- dfa(COP_timeseries$COPap)
  DFA.ap <- estimate(DFAout.ap,do.plot=FALSE)
  
  dfaList <- list(DFA.ml, DFA.ap)
  
  result <- dfaList
  
}

