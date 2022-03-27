library(stringr)
library(data.table)
library(readr)

### set working folders
# Folders must only contain csv data files & baseline files
# Data files must have format of YYYYMMDD.csv
# Baseline files must have format of YYYYMMDD_Baseline.csv
setwd("~/nBox/Others/working folder/PTRMS Batch")

# set working folder for output VOC concentration file
path_out = "C:/Users/janet/Documents/nBox/Others/working folder/PTRMS Batch output/"

### Sensitivity file
# To be manually changed for each periods (e.g., data before Jun. 2020, data after Jun. 2020)
sensitivity <- read_delim("~/nBox/Others/working folder/0. Sensitivities (Before Jun-2020).csv", 
                          ";", escape_double = FALSE, trim_ws = TRUE)

# Sensitivity file processing
colnames = colnames(sensitivity)
sensitivity = sensitivity[0:1,2:ncol(sensitivity)]

# Import Baseline file
baseline_files = list.files(pattern= c('_Baseline'))

# Import Data file
data_files = grep(list.files(), 
                 pattern = c('_Baseline.csv'), 
                 invert = TRUE, value = TRUE)

### Check if no. of baseline files = no. of data files
# If there is no baseline line for a certain day, make a copy of the baseline file for previous day and rename to that certain day
# e.g. 27 Mar. 2022 does not have baseline file -> make a copy of 26 Mar. 2022 baseline file -> rename to 20220327_Baseline.csv
if (length(baseline_files) == length(data_files)) {
  print ("No. of baseline files = no. of data files")
} else {print("Check again :)")}

# Read all baseline & data files
baseline_all = lapply(baseline_files, read.csv, sep=";")
data_all = lapply(data_files, read.csv, sep=";")

### Batch process all files
# VOC concentration file will be name: YYYYMMDD_VOClist.csv
for (i in 1:length(data_files)) {
  baseline_file = as.data.frame(baseline_all[i])
  data_file = as.data.frame(data_all[i])
  
  # Columns name = Species name
  names(baseline_file) <- colnames
  names(data_file) <- colnames
  
  # Baseline calculation
  baseline_ave = (lapply(baseline_file,mean))
  baseline = as.data.frame(baseline_ave[2:length(baseline_ave)])
  baseline_expand = baseline[rep(1:nrow(baseline),each=nrow(data_file)),]
  
  # Subtracting baseline from Raw data set (ions/s)
  return = data_file[,2:ncol(data_file)]-baseline_expand
  return = return[,1:ncol(return)-1]
  
  # Calculate concentration (ppb) by dividing by sensitivity
  sensitivity_expand = sensitivity[rep(1:nrow(sensitivity),each=nrow(return)),]
  concentration = return/sensitivity_expand
  
  # Date&Time
  concentration$DateTime = data_file$Species
  
  # Move Date&Time column to first column
  concentration = concentration[,c(ncol(concentration),1:ncol(concentration)-1)]
  
  # Account for LoD of 1ppt--> replace all values <0.001ppb as BD
  concentration[concentration<0.001]="BD"
  
  # Export data
  file_name = paste(path_out, strsplit(data_files[i],split=".csv"),"_VOClist.csv", sep="")
  write.csv(concentration,file = file_name)
  print (i)
  print (data_files[i])
  print (baseline_files[i])
}
