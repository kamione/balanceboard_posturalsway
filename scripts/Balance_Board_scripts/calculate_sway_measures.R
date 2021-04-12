calculate_sway_measures <- function(COP_timeseries) {

  require(seewave) # includes function (rms) to calculate root mean square
  
  # See Prieto, T, Myklebust, J, Hoffmann, R, Lovett, E, and Myklebust, B. (1996). Measures of Postural Steadiness: Differences
  #   Between Healthy Young and Elderly Adults. IEEE TRANSACTIONS ON BIOMEDICAL ENGINEERING, 43(9),
  #   for postural measure equations
  
  # Calculate distance from mean COP at each time point
  mlAvgDist <- vector("numeric")
  apAvgDist <- vector("numeric")
  for (s in 1:length(COP_timeseries$COPml)) {
    mlAvgDist[s] <- COP_timeseries$COPml[s] - mean(COP_timeseries$COPml)
    apAvgDist[s] <- COP_timeseries$COPap[s] - mean(COP_timeseries$COPap)
  }
  
  # Calculate Resultant Distance at each time point
  ResDist <- vector("numeric")
  for (s in 1:length(COP_timeseries$COPml)) {
    ResDist[s] <- sqrt(apAvgDist[s]^2 + mlAvgDist[s]^2)
  }
  
  # Calculate mean distance (the mean of the Distance time series; represents the average distance from the mean COP)
  rdMeanDist <- mean(ResDist) # overall distance from mean COP
  mlMeanDist <- mean(abs(mlAvgDist)) # distance from mean COP in ML direction
  apMeanDist <- mean(abs(apAvgDist)) # distance from mean COP in AP direction
  
  # Calculate Root Mean Square distance from the mean COP
  rdRMS <- rms(ResDist) # Resultant Distance; overall RMS
  mlRMS <- rms(mlAvgDist) # RMS in ML direction
  apRMS <- rms(apAvgDist) # RMS in AP direction
      
  # Calculate distance traveled between consecutive time points
  # used in calculation of Total Excursion and Path Velocity
  diffsCOPml <- vector("numeric")
  diffsCOPap <- vector("numeric")
  for (s in 1:length(COP_timeseries$COPml)-1) {
    diffsCOPml[s] <- abs(COP_timeseries$COPml[s+1] - COP_timeseries$COPml[s])
    diffsCOPap[s] <- abs(COP_timeseries$COPap[s+1] - COP_timeseries$COPap[s])
  }
  
  # Calculate Total Excursion
  rdTotExc <- vector("numeric")
  mlTotExc <- vector("numeric")
  apTotExc <- vector("numeric")
  for (s in 1:length(diffsCOPml)) {
    rdTotExc[s] <- sqrt((diffsCOPml[s]^2 + diffsCOPap[s]^2))
  }
  rdTotExc <- sum(rdTotExc) # overall (ResDist) Total Excursion
  
  mlTotExc <- sum(diffsCOPml) # ML Total Excursion
  apTotExc <- sum(diffsCOPap) # AP Total Excursion
  
  # Calculate Path Velocity
  rdVelocity <- rdTotExc/COP_timeseries$time[length(COP_timeseries$time)] # overall (RD) path velocity
  mlVelocity <- mlTotExc/COP_timeseries$time[length(COP_timeseries$time)] # ML path velocity
  apVelocity <- apTotExc/COP_timeseries$time[length(COP_timeseries$time)] # AP path velocity
  
  distList <- list(rdMeanDist, mlMeanDist, apMeanDist, rdRMS, mlRMS, apRMS, rdTotExc, mlTotExc, apTotExc, rdVelocity, mlVelocity, apVelocity)
  
  result <- distList
  
}

