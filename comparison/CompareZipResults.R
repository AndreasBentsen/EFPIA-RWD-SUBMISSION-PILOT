library(tidyr)
library(openxlsx)
options(scipen=999)

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