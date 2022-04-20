library(dplyr)

resultSets <- tibble(site = c(1, 2, 3, 1, 2, 3, 1, 3),
                     ftp = c(FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE),
                     threadFix = c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE),
                     zipFile = c("siteJnJ/UsingJnJetlAndRenv.zip",
                                 "ResultsDKMA/ResultsDKMA.zip",
                                 "siteNN/ResultsNN.zip",
                                 "siteJnJ/UsingJnJetlAndRenv.zip",
                                 "ResultsDKMA/ResultsDKMA_FTP.zip",
                                 "siteNN/ResultsNN_FTP.zip",
                                 "siteJnJ/UsingJnJetlAndRenvThreadFix.zip",
                                 "siteNN/ResultsNNThread.zip"))

unzipFile <- function(zipFile) {
    folder <- tempfile("rwd")
    dir.create(folder)
    unzip(zipfile = zipFile, junkpaths = TRUE, exdir = folder)
    return(folder)
}

resultSets$unzippedFolder <- sapply(resultSets$zipFile, unzipFile)


# Compare exposure cohort sizes ----------------------------------------

getExposureCohortSizes <- function(i) {
    attrition <- read.csv(file.path(resultSets$unzippedFolder[i], "attrition.csv"))
    attrition %>%
        filter(analysis_id == 1 & sequence_number == 1 & outcome_id == 6) %>%
        select(exposure_id, subjects) %>%
        mutate(site = resultSets$site[i]) %>%
        return()
}

lapply(which(resultSets$ftp == FALSE & resultSets$threadFix == FALSE), getExposureCohortSizes)
# [[1]]
# exposure_id subjects site
# 1           2     4371    1
# 2          28    39758    1
# 3         137       23    1
# 4         143      191    1
#
# [[2]]
# exposure_id subjects site
# 1           2     4371    2
# 2          28    39758    2
# 3         137       23    2
# 4         143      191    2
#
# [[3]]
# exposure_id subjects site
# 1           2     4371    3
# 2          28    39758    3
# 3         137       23    3
# 4         143      191    3


getExposureCohortSizes <- function(i) {
    cmResults <- read.csv(file.path(resultSets$unzippedFolder[i], "cohort_method_result.csv"))
    cmResults %>%
        select(target_id, comparator_id, outcome_id, analysis_id, target_subjects, comparator_subjects, target_days, comparator_days) %>%
        mutate(site = sprintf("Site %d", resultSets$site[i]),
               sharedEtl = ifelse(resultSets$ftp[i], "Shared ETL", "Local ETL"),
               key = paste(target_id, comparator_id, outcome_id, analysis_id)) %>%
        return()
}
exposureSizes <- lapply(which(resultSets$threadFix == FALSE), getExposureCohortSizes)
exposureSizes <- bind_rows(exposureSizes)
different <- exposureSizes %>%
    group_by(target_id, comparator_id, outcome_id, analysis_id) %>%
    summarize(targetSubjectsSpread = max(target_subjects) - min(target_subjects),
              comparatorSubjectsSpread = max(comparator_subjects) - min(comparator_subjects),
              targetDaysSpread = max(target_days) - min(target_days),
              comparatorDaysSpread = max(comparator_days) - min(comparator_days)) %>%
    filter(targetSubjectsSpread > 0 | comparatorSubjectsSpread > 0 | targetDaysSpread > 0 | comparatorDaysSpread > 0)

exposureSizes %>%
    inner_join(different)


# Compare outcome cohort sizes -----------------------------------------
# We don't have explicit outcome cohort sizes, but since PS stratification
# was used we didn't lose anyone. Therefore using the CM results table
# to determine outcome cohort sizes (within exposed only).

getOutcomeCohortSizes <- function(i) {
    cmResults <- read.csv(file.path(resultSets$unzippedFolder[i], "cohort_method_result.csv"))
    cmResults %>%
        filter(analysis_id == 1) %>%
        select(target_id, comparator_id, outcome_id, analysis_id, target_outcomes, comparator_outcomes) %>%
        mutate(site = resultSets$site[i]) %>%
        return()
}

outcomeCohortSizes <- lapply(which(resultSets$ftp == FALSE & resultSets$threadFix == FALSE), getOutcomeCohortSizes)
outcomeCohortSizes <- bind_rows(outcomeCohortSizes)
different <- outcomeCohortSizes %>%
    group_by(target_id, comparator_id, outcome_id) %>%
    summarize(targetSpread = max(target_outcomes) - min(target_outcomes),
              comparatorSpread = max(comparator_outcomes) - min(comparator_outcomes)) %>%
    filter(targetSpread > 0 | comparatorSpread > 0)

outcomeCohortSizes %>%
    inner_join(different, by = c("target_id", "comparator_id", "outcome_id"))
# target_id comparator_id outcome_id analysis_id target_outcomes comparator_outcomes site targetSpread comparatorSpread
# 1         2            28         18           1               9                  85    1            1                1
# 2         2            28         18           1               8                  84    2            1                1
# 3         2            28         18           1               9                  85    3            1                1





# Compare effect size estimates ------------------
getEffectSizes <- function(i) {
    hois <- read.csv(file.path(resultSets$unzippedFolder[i], "outcome_of_interest.csv"))
    cmResults <- read.csv(file.path(resultSets$unzippedFolder[i], "cohort_method_result.csv"))
    cmResults %>%
        filter(outcome_id %in% !!hois$outcome_id & !is.na(calibrated_rr)) %>%
        select(target_id, comparator_id, outcome_id, analysis_id, calibrated_rr, calibrated_ci_95_lb, calibrated_ci_95_ub) %>%
        mutate(site = sprintf("Site %d", resultSets$site[i]),
               sharedEtl = ifelse(resultSets$ftp[i], "Shared ETL", "Local ETL"),
               key = paste(target_id, comparator_id, outcome_id, analysis_id)) %>%
        return()
}
effectSizes <- lapply(which(resultSets$threadFix == FALSE), getEffectSizes)
effectSizes <- bind_rows(effectSizes)

meanRrs <- effectSizes %>%
    group_by(key) %>%
    summarize(meanRr = mean(calibrated_rr, na.rm = TRUE)) %>%
    arrange(meanRr) %>%
    mutate(y = row_number())

effectSizes <- effectSizes %>%
    inner_join(meanRrs, by = "key") %>%
    mutate(y = ifelse(sharedEtl == "Shared ETL", y - 0.2, y + 0.2))

library(ggplot2)
breaks <- c(0.1, 0.25, 0.5, 1, 2, 4, 6, 8, 10)
ggplot(effectSizes, aes(x = calibrated_rr, y = y, group = site, shape = site, color = sharedEtl)) +
    geom_vline(xintercept = 1) +
    geom_point(size = 2, alpha = 0.6) +
    geom_errorbarh(aes(xmin = calibrated_ci_95_lb, xmax = calibrated_ci_95_ub), size = 0.5, alpha = 0.6) +
    scale_x_log10("Calibrated Hazard Ratio",  breaks = breaks, labels = breaks) +
    coord_cartesian(xlim = c(0.1, 10)) +
    theme(axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major.y = element_blank(),
          axis.ticks.y = element_blank(),
          legend.title = element_blank())
ggsave("EffectSizes.png", width = 5.5, height = 6, dpi = 400)

# Biggest difference

effectSizes %>%
    group_by(key) %>%
    summarize(sd = sd(calibrated_rr, na.rm = TRUE)) %>%
    arrange(desc(sd))


effectSizes %>%
    filter(target_id == 2 & comparator_id == 28 & outcome_id == 18 & analysis_id == 1 & sharedEtl == "Shared ETL") %>%
    select(calibrated_rr, calibrated_ci_95_lb, calibrated_ci_95_ub) %>%
    round(3)
# calibrated_rr calibrated_ci_95_lb calibrated_ci_95_ub
# 1         0.996               0.492               2.014
# 2         0.990               0.489               2.003
# 3         0.992               0.491               2.007




#
# # Compare single target-comparator-outcome effect size estimate across sites ---------------------
# getEffectSizes <- function(i) {
#     cmResults <- read.csv(file.path(resultSets$unzippedFolder[i], "cohort_method_result.csv"))
#     cmResults %>%
#         mutate(site = sprintf("Site %d", resultSets$site[i]),
#                key = paste(target_id, comparator_id, outcome_id, analysis_id)) %>%
#         return()
# }
# # effectSizes <- lapply(which(resultSets$ftp), getEffectSizes)
# effectSizes <- lapply(1:nrow(resultSets), getEffectSizes)
# effectSizes <- bind_rows(effectSizes)
# effectSizes %>%
#     # filter(se_log_rr < 1) %>%
#     group_by(key) %>%
#     summarize(sd = sd(log_rr, na.rm = TRUE)) %>%
#     arrange(desc(sd))
#
# effectSizes %>%
#     filter(target_id == 2 & comparator_id == 28 & outcome_id == 22 & analysis_id == 2)
#
# effectSizes %>%
#     filter(target_id == 137 & comparator_id == 143 & outcome_id == 4209423  & analysis_id == 2)
#
#
# effectSizes %>%
#     filter(target_id == 2 & comparator_id == 28 & outcome_id == 18  & analysis_id == 1)
