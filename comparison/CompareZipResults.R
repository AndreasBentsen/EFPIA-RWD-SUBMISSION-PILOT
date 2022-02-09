library(tidyr)
library(openxlsx)
options(scipen=999)

# results_dir = "./exportedResults/"
results_dir = "/EFPIA/EFPIA-RWD-SUBMISSION-PILOT/exportedResults/"
results_paths = list.files(path = results_dir,recursive = TRUE,full.names = TRUE)

results = do.call("rbind", lapply(results_paths,function(path) {
  tmp_dir = tempdir(check = TRUE)
  unzip(zipfile = path,exdir = tmp_dir)
  tmp_df = read.csv( list.files(path = tmp_dir, pattern = "cohort_method_result.csv",recursive = TRUE,full.names = TRUE) )
  tmp_df$path = path
  tmp_df = tmp_df %>% gather(stat,value,rr:calibrated_se_log_rr)
  # tmp_df$analysis_id = NULL
  tmp_df$database_id = NULL
  unlink(tmp_dir, recursive = T)
  return(tmp_df)
})) %>% spread(path,value)

openxlsx::write.xlsx(x = results,file = paste0(results_dir,"comparison_results.xlsx"))

# Find biggest differences between 'FTP runs' -----------------------------------------
library(dplyr)

# Find any differences
results <- results %>%
  rename(valueDkma = `./exportedResults//ResultsDKMA/ResultsDKMA_FTP.zip`,
         valueJnJ = `./exportedResults//siteJnJ/UsingJnJetlAndRenv.zip`,
         valueNn = `./exportedResults//siteNN/ResultsNN_FTP.zip`) %>%
  rowwise() %>%
  mutate(sd = sd(c(valueDkma, valueJnJ, valueNn))) %>%
  filter(sd > 0)

# Find differences where standard error is 'small'
smallSeKey <- results %>%
  filter(stat == "se_log_rr" & 
           pmin(valueDkma, valueJnJ, valueNn) < 1) %>%
  select(target_id, comparator_id, outcome_id, analysis_id)

differencesOfInterest <- results %>%
  inner_join(smallSeKey, by = c("target_id", "comparator_id", "outcome_id", "analysis_id"))

differencesOfInterest %>%
  filter(outcome_id <= 22)


subset <- results %>%
  filter(target_id == 2 & comparator_id == 28 & outcome_id == 6 & analysis_id == 1)
