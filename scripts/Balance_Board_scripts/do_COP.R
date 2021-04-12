do_COP <- function(fileA, fileC) {
  active <- suppressMessages(read_csv(fileA)) #suppressMessages prevents read_csv from printing column specifications for every file opened
  calib <- suppressMessages(read_csv(fileC))

  # Calculate mean (over all time points) of calibration measurement of each location
  calib_means <- summarise_all(calib[,c(10:13)], funs(mean))

  # Subtract calibration means from Active measurement at each time point
  active.calib <- active[,c("ActiveTimeStamp","ActiveTopLeftZ","ActiveTopRightZ","ActiveBottomLeftZ","ActiveBottomRightZ")]
  active.calib[,"ActiveTopLeftZ"] <- map2_df(active.calib[,"ActiveTopLeftZ"], calib_means[1,"CalibrationTopLeftZ"], `-`)
  active.calib[,"ActiveTopRightZ"] <- map2_df(active.calib[,"ActiveTopRightZ"], calib_means[1,"CalibrationTopRightZ"], `-`)
  active.calib[,"ActiveBottomLeftZ"] <- map2_df(active.calib[,"ActiveBottomLeftZ"], calib_means[1,"CalibrationBottomLeftZ"], `-`)
  active.calib[,"ActiveBottomRightZ"] <- map2_df(active.calib[,"ActiveBottomRightZ"], calib_means[1,"CalibrationBottomRightZ"], `-`)
  
  # Calculate Center of Pressure (COP)
  L <- 433 # Length of Wii Board in mm (see Leach et al., 2014; Bartlett et al., 2014)
  W <- 238 # Width of Wii Board in mm 
  TR <- active.calib$ActiveTopRightZ[251:(length(active.calib$ActiveTopRightZ)-250)] # remove first and last 250 data points
  BR <- active.calib$ActiveBottomRightZ[251:(length(active.calib$ActiveBottomRightZ)-250)] # remove first and last 250 data points
  TL <- active.calib$ActiveTopLeftZ[251:(length(active.calib$ActiveTopLeftZ)-250)] # remove first and last 250 data points
  BL <- active.calib$ActiveBottomLeftZ[251:(length(active.calib$ActiveBottomLeftZ)-250)] # remove first and last 250 data points
  COPml <- (L/2)*(((TR + BR) - (TL + BL)) / (TR + BR + TL + BL)) # Formula for COP displacement (in mm) for the medial-lateral (ML) direction
  COPap <- (W/2)*(((TR + TL) - (BR + BL)) / (TR + BR + TL + BL)) # Formula for COP displacement (in mm) for the anterior-posterior (AP) direction
  
  # create data frame with timepoints and COPml and COPap
  timepoints <- dim(active[c(251:(length(active$ActiveTimeStamp)-250)),1])[1]
  COPall <- tibble(subject_id = integer(timepoints), task = character(timepoints), TimeStamp = factor(timepoints), time = double(timepoints), COPml = double(timepoints), COPap = double(timepoints))
  timeline <- tibble(TimeStamp = factor(timepoints), timediff = double(timepoints), time = double(timepoints))
  timeline[,1] <- active[c(251:(length(active$ActiveTimeStamp)-250)),"ActiveTimeStamp"]
  for (t in 2:timepoints) {
    timeline[t,2] <- (as.POSIXlt(timeline$TimeStamp[t]) - as.POSIXlt(timeline$TimeStamp[t-1])) # difference between each timepoint, in seconds
  }
  timeline[,3] <- cumsum(timeline[,2]) # timeline in sec (cumulative sum of timepoint differences)
  
  COPall[,1] <- active[1,"subject_id"]
  COPall[,2] <- active[1,"task"]
  COPall[,3] <- timeline[,1] # timestamps
  COPall[,4] <- timeline[,3] # timeline
  COPall[,5] <- COPml
  COPall[,6] <- COPap
  
  result <- COPall
  #return(result)
}
  

  
