calculate_sway_measures <- function(COP_timeseries) {
    # See Prieto, T, Myklebust, J, Hoffmann, R, Lovett, E, and Myklebust, B.
    #    (1996). Measures of Postural Steadiness: Differences Between Healthy
    #    Young and Elderly Adults. IEEE TRANSACTIONS ON BIOMEDICAL ENGINEERING,
    #    43(9), for postural measure equations
    
    # Calculate distance from mean COP at each time point and Resultant
    # Distance at each time point
    acc_time <- COP_timeseries$time[length(COP_timeseries$time)]
    sway_measures <- COP_timeseries %>%
        mutate(mlAvgDist = COPml - mean(COPml)) %>% 
        mutate(apAvgDist = COPap - mean(COPap)) %>% 
        mutate(ResDist = sqrt(apAvgDist^2 + mlAvgDist^2)) %>% 
        mutate(diffsCOPml = c(abs(diff(COPml)), NA)) %>% 
        mutate(diffsCOPap = c(abs(diff(COPap)), NA)) %>% 
        mutate(rdTotExc = sqrt((diffsCOPml^2 + diffsCOPap^2))) %>% 
        summarize(
            rdMeanDist = mean(ResDist),
            mlMeanDist = mean(abs(mlAvgDist)),
            apMeanDist = mean(abs(apAvgDist)),
            rdRMS      = rms(ResDist),
            mlRMS      = rms(mlAvgDist),
            apRMS      = rms(apAvgDist),
            rdTotExc   = sum(rdTotExc, na.rm = TRUE),
            mlTotExc   = sum(diffsCOPml, na.rm = TRUE),
            apTotExc   = sum(diffsCOPap, na.rm = TRUE),
        ) %>% 
        mutate(rdVelocity = rdTotExc / acc_time) %>% 
        mutate(mlVelocity = mlTotExc / acc_time) %>% 
        mutate(apVelocity = apTotExc / acc_time)
    
    return(sway_measures)
}