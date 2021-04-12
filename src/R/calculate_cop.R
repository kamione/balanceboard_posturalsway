calculate_cop <- function(fileA, fileC) {
    active <- read_csv(fileA, col_types = cols())
    calib <- read_csv(fileC, col_types = cols())
    
    # Calculate mean (over all time points) of calibration measurement of each
    # location
    calib_means <- calib %>%
        select(ends_with("Z")) %>% 
        summarise_all(funs(mean))
    
    # Subtract calibration means from Active measurement at each time point
    active_calib <- active %>% 
        select(ActiveTimeStamp, ends_with("Z")) %>% 
        mutate(ActiveTopLeftZ = ActiveTopLeftZ - calib_means$CalibrationTopLeftZ) %>% 
        mutate(ActiveTopRightZ = ActiveTopRightZ - calib_means$CalibrationTopRightZ) %>% 
        mutate(ActiveBottomLeftZ = ActiveBottomLeftZ - calib_means$CalibrationBottomLeftZ) %>% 
        mutate(ActiveBottomRightZ = ActiveBottomRightZ - calib_means$CalibrationBottomRightZ)
    
    # Calculate Center of Pressure (COP)
    # references: see Leach et al., 2014; Bartlett et al., 2014
    L <- 433 # Length of Wii Board in mm
    W <- 238 # Width of Wii Board in mm 
    # remove first and last 250 data points
    
    active_calib_sliced <- active_calib %>% 
        slice(251:(length(active_calib$ActiveTopRightZ) - 250))
    
    TR <- active_calib_sliced$ActiveTopRightZ
    BR <- active_calib_sliced$ActiveBottomRightZ
    TL <- active_calib_sliced$ActiveTopLeftZ
    BL <- active_calib_sliced$ActiveBottomLeftZ
    # COP displacement (in mm) for the medial-lateral (ML) direction
    COPml <- (L / 2) * (((TR + BR) - (TL + BL)) / (TR + BR + TL + BL))
    # COP displacement (in mm) for the anterior-posterior (AP) direction
    COPap <- (W / 2) * (((TR + TL) - (BR + BL)) / (TR + BR + TL + BL)) 
    
    # create data frame with timepoints and COPml and COPap
    timepoints <- dim(active_calib_sliced)[1]
    
    COPall <- tibble(
        subject_id = basename(fileA) %>% str_split("_") %>% sapply("[", 2),
        task       = basename(fileA) %>% str_split("_") %>% sapply("[", 4),
        TimeStamp  = active_calib_sliced$ActiveTimeStamp,
        time       = double(timepoints),
        COPml      = COPml,
        COPap      = COPap
    ) %>%
        mutate(TimeStamp_lag = c(TimeStamp[1], TimeStamp[-timepoints])) %>% 
        mutate(timediff = interval(TimeStamp_lag, TimeStamp)) %>% 
        mutate(timediff = as.numeric(timediff, units = "seconds")) %>% 
        mutate(time = cumsum(timediff)) %>% # accumulate sum
        select(-c(TimeStamp_lag, timediff))
    
    return(COPall)
}
