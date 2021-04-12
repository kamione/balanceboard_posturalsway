library(nonlinearTseries)

filepath <- "~/projects/Balance_Board/data"
dirs <- list.dirs(filepath, full.names = FALSE, recursive = TRUE)

for (i in 2:length(dirs)) {
  filesR <- list.files(paste0(filepath, "/", dirs[i]), pattern = "resampled50Hz", full.names=TRUE, recursive=TRUE)
  
  # Initialize empty data.frame for mean distance traveled data
  DFAout <- data.frame(subject_id = numeric(0), date = as.Date(character(0)), task = character(0), DFAout.ml.estimate = numeric(0), DFAout.ap.estimate = numeric(0), stringsAsFactors=FALSE)
  
  for (f in 1:length(filesR)) {
    print(paste0("Calculating DFA on file ", f, " of ", length(filesR), " for subject ", i-1, " of ", length(dirs)-1))
    COP_timeseries <- read.csv(filesR[f], header=TRUE)
    COP.date <- substr(filesR[f],nchar(filesR[f])-13,nchar(filesR[f])-4) #gets date from end of file name
    task.type <- substr(filesR[f], unlist(gregexpr(dirs[i], filesR[f]))[2]+6, unlist(gregexpr("COP", filesR[f]))-2)
    dfa.result <- do_DFA(COP_timeseries)
    DFAout[f,1] <- dirs[i]
    DFAout[f,2] <- COP.date
    DFAout[f,3] <- task.type
    DFAout[f,4] <- dfa.result[1]
    DFAout[f,5] <- dfa.result[2]
  }
  write.csv(DFAout, paste0(filepath, "/", dirs[i], "/", dirs[i], "_", "DFA_resampled_data_all_visits_all_conditions.csv"), row.names=FALSE)
  rm(DFAout)
  
}

# append all files into one large data file
print("Combining DFA files for all subjects")
for (d in 2:length(dirs)) {
  dfa_file <- read.csv(paste0(filepath, "/", dirs[d], "/", dirs[d], "_", "DFA_resampled_data_all_visits_all_conditions.csv"), header = TRUE)
  
  if (d == 2) {  # first time through loop, put data into dist_file_all_subs
    dfa_file_all_subs <- dfa_file
    rm(dfa_file)
  }  else  			# after first loop, append data to end of dist_file_all_subs
    dfa_file_all_subs <- rbind(dfa_file_all_subs, dfa_file)
  rm(dfa_file)
}

write.csv(dfa_file_all_subs, paste0(filepath, "/", "DFA_resampled_data_all_visits_all_conditions_all_subs.csv"), row.names=FALSE)
  
