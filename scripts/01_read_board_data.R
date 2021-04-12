# Environment ------------------------------------------------------------------
library(tidyverse)
library(here)
library(lubridate)

source(here("src", "R", "data.R"))

# Data IO ----------------------------------------------------------------------
datadir <- here("data", "raw", "Lincoln_OriginalData_With_ConvertedData")
outdir <- here("data", "processed")
dirs <- list.dirs(datadir, full.names = FALSE, recursive = TRUE)
# get only directories with baseline (BL) or followup (FU)
dirs <- grep("BL|FU", dirs, value = TRUE)

# Sway Measures ----------------------------------------------------------------
# Initialize empty data.frame for sway measures data
SwayMeasures <- tibble(
    subject_id = character(0),
    timepoint  = character(0),
    date       = ymd(),
    task       = character(0),
    rdMeanDist = double(0),
    mlMeanDist = double(0), 
    pMeanDist  = double(0),
    rdRMS      = double(0),
    mlRMS      = double(0),
    apRMS      = double(0),
    rdTotExc   = double(0),
    mlTotExc   = double(0),
    apTotExc   = double(0),
    rdVelocity = double(0),
    mlVelocity = double(0),
    apVelocity = double(0)
)
count <- 1

for (ith_dir in 1:length(dirs)) {
    
    filesA <- list.files(here(datadir, dirs[ith_dir]), pattern = "Active",
                         full.names = TRUE, recursive = TRUE)
    filesC <- list.files(here(datadir, dirs[ith_dir]), pattern = "Calib",
                         full.names = TRUE, recursive = TRUE)
    
    for (ith_file in 1:length(filesA)) {
        
        # check 
        str_list <- basename(filesA[ith_file]) %>% str_split("_")
        if (length(str_list %>% unlist()) < 4) {
            next 
        } else {
            task <- str_list[[1]][4]
            task_list <- c("EyesClosed", "Fixation", "Reading")
            if (!task %in% task_list) {
                next
            }
        }
        
        COP_timeseries <- calculate_cop(filesA[ith_file], filesC[ith_file])
        tmp_date <- COP_timeseries$TimeStamp[1] %>% date() %>% as.character()
        write_csv(COP_timeseries,
                  here(outdir, sprintf("%s_%s_COPTimeSeries_%s.csv",
                                      str_replace_all(dirs[ith_dir], "/", "_"),
                                      COP_timeseries$task[1],
                                      str_replace_all(tmp_date, "-", ""))))
        
        subjid_timept = dirs[ith_dir] %>% str_split("/") %>% unlist()
        
        SwayMeasures[count, 1]    <- subjid_timept[1]
        SwayMeasures[count, 2]    <- subjid_timept[2]
        SwayMeasures[count, 3]    <- ymd(tmp_date)
        SwayMeasures[count, 4]    <- task
        SwayMeasures[count, 5:16] <- calculate_sway_measures(COP_timeseries)
    
        count <- count + 1
    }
}

# summary of each subject at each time point
write_csv(SwayMeasures, here("outputs", "results", "indiviudal_sway_measures.csv"))
