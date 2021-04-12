# Environment ------------------------------------------------------------------
library(tidyverse)
library(here)

source(here("src", "R", "analysis.R"))

# Data IO ----------------------------------------------------------------------
filepath <- here("data", "processed")
filesR <- list.files(filepath, pattern = "resampled50Hz", full.names = TRUE,
                     recursive = TRUE)

# DFA Analysis -----------------------------------------------------------------
dfa_df <- tibble(
    subject_id   = character(0),
    timepoint    = character(0),
    date         = ymd(),
    task         = character(0),
    dfa_alpha_ml = numeric(0),
    dfa_alpha_ap = numeric(0)
)

for (ith_file in 1:length(filesR)) {
    COP_timeseries <- read_csv(filesR[ith_file], col_types = cols())
    str_list <- basename(filesR[ith_file]) %>% str_split("_") %>% unlist()
    
    dfa_result <- calculate_dfa(COP_timeseries)
    
    # store results to a data frame
    dfa_df[ith_file, 1] <- str_list[2]
    dfa_df[ith_file, 2] <- str_list[3]
    dfa_df[ith_file, 3] <- ymd(str_replace(str_list[6], ".csv", ""))
    dfa_df[ith_file, 4] <- str_list[4]
    dfa_df[ith_file, 5] <- dfa_result[1]
    dfa_df[ith_file, 6] <- dfa_result[2]
}

# save file to outputs
write_csv(dfa_df, here("outputs", "results", "individual_dfa.csv"))

