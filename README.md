## R Scripts to Process Wii Balance Board Data:

Please start with **_PosturalSway.Rproj_**. This will set up the working
directory.

**01_read_board_data.R**

1. Raw data processing script. This script assumes that, within the top-level
directory (e.g., "data/raw/_project_name_/_subject_id_"). Each subject has
their time point, within which all of that time point’s balance board data
files are stored.

2. Separate “Active” and “Calibration” files for each condition at each time
point.

```bash
# example tree directory
data/raw/project_A/P001
├── BL
│   ├── Active_P001_Female_EyesClosed_20160805.csv
│   ├── Active_P001_Female_Fixation_20160805.csv
│   ├── Active_P001_Female_Reading_20160805.csv
│   ├── Calibration_P001_Female_EyesClosed_20160805.csv
│   ├── Calibration_P001_Female_Fixation_20160805.csv
│   ├── Calibration_P001_Female_Reading_20160805.csv
└── FU
    ├── Active_P001_Female_EyesClosed_20161220.csv
    ├── Active_P001_Female_Fixation_20161220.csv
    ├── Active_P001_Female_Reading_20161220.csv
    ├── Calibration_P001_Female_EyesClosed_20161220.csv
    ├── Calibration_P001_Female_Fixation_20161220.csv
    ├── Calibration_P001_Female_Reading_20161220.csv
```

3. This script calls two functions from "src/R/data.R"

    * calculate_cop.R: Calculates the Center of Pressure (COP)

    * calculate_sway_measures.R: Takes the COP time series output from
    calculate_cop.R and calculates a number of postural sway measures. To know
    what these measures are, there is a paper cited at the top of this function
    that describes them and their calculation.

4. Output files:

    * A .csv file of the COP time series for each participant at each time
    point, save to "data/processed"

    * A .csv file of the sway measures for all participants, save to
    "outputs/results/individual_sway_measures.csv"

**02_resample_cop_timeseries.m**

1. The Wii balance board data is not sampled at a uniform sampling rate, i.e.
there is not the same number of milliseconds between each data sample. To do
DFA, the data needs to be uniformly sampled, so we must resample the COP time
series data to a constant rate…in our case, to a 50 Hz sampling rate.

2. This script reads in the COP time series data files output by the R scripts,
resamples it to a uniform 50 Hz, and saves the new resampled data in a .csv
file.

**03_run_dfa_on_resampled_data.R**

1. This script calls the function calculate_dfa.R from "src/R/analysis.R"

2. Output file:

    * A .csv file with DFA estimates for all conditions for all visits for each
    subject

**Credits**: These scripts are adapted and modified from the Lab of Professor
Kelvin Lim at Department of Psychiatry, University of Minnesota
