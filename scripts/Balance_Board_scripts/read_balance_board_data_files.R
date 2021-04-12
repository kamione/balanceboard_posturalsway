require(tidyverse)

filepath <- "~/projects/Balance_Board/data" 
dirs <- list.dirs(filepath, full.names = FALSE, recursive = TRUE)

for (i in 2:length(dirs)) {
  filesA <- list.files(paste0(filepath, "/", dirs[i]), pattern = "Active", full.names=TRUE, recursive=TRUE)
  filesC <- list.files(paste0(filepath, "/", dirs[i]), pattern = "Calib", full.names=TRUE, recursive=TRUE)
  
  # Initialize empty data.frame for sway measures data
  SwayMeasures <- tibble(subject_id = integer(0), date = as.Date(character(0)), task = character(0), 
                         rdMeanDist = double(0), mlMeanDist = double(0), apMeanDist = double(0), 
                         rdRMS = double(0), mlRMS = double(0), apRMS = double(0),
                         rdTotExc = double(0), mlTotExc = double(0), apTotExc = double(0), 
                         rdVelocity = double(0), mlVelocity = double(0), apVelocity = double(0))
  
  for (f in 1:length(filesA)) {
    print(paste0("Performing COP on file ", f, " of ", length(filesA), " for subject ", i-1, " of ", length(dirs)-1))
    
    COP_timeseries <- do_COP(filesA[f], filesC[f])
    COP.date <- as.Date(substr(as.character(COP_timeseries$TimeStamp[1]),1,10))
    write_csv(COP_timeseries, paste0(filepath, "/", dirs[i], "/", dirs[i], "_", COP_timeseries[1,"task"], "_", "COPTimeSeries_", COP.date, ".csv"))

    print(paste0("Calculating sway measures on file ", f, " of ", length(filesA)))
    sway.data <- calculate_sway_measures(COP_timeseries)
    SwayMeasures[f,1] <- dirs[i]
    SwayMeasures[f,2] <- COP.date
    SwayMeasures[f,3] <- COP_timeseries[1,"task"]
    SwayMeasures[f,4] <- sway.data[1]
    SwayMeasures[f,5] <- sway.data[2]
    SwayMeasures[f,6] <- sway.data[3]
    SwayMeasures[f,7] <- sway.data[4]
    SwayMeasures[f,8] <- sway.data[5]
    SwayMeasures[f,9] <- sway.data[6]
    SwayMeasures[f,10] <- sway.data[7]
    SwayMeasures[f,11] <- sway.data[8]
    SwayMeasures[f,12] <- sway.data[9]
    SwayMeasures[f,13] <- sway.data[10]
    SwayMeasures[f,14] <- sway.data[11]
    SwayMeasures[f,15] <- sway.data[12]
    
  }
  write_csv(SwayMeasures, paste0(filepath, "/", dirs[i], "/", dirs[i], "_", COP_timeseries[1,"task"], "_", "sway_measures_", as.character(COP.date), ".csv"))
  rm(SwayMeasures)
}

  
