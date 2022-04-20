library(CohortMethod)
library(dplyr)

cmData1 <- loadCohortMethodData("JnJ_ThreadFix/CmData_l1_t137_c143.zip")
cmData2 <- loadCohortMethodData("NN_ThreadFix/CmData_l1_t137_c143.zip")


all.equal(
  cmData1$cohorts %>%
    arrange(rowId) %>%
    collect(),
  cmData2$cohorts %>%
    arrange(rowId) %>%
    collect()
)
# TRUE

all.equal(
  cmData1$covariates %>%
    arrange(rowId, covariateId) %>%
    collect(),
  cmData2$covariates %>%
    arrange(rowId, covariateId) %>%
    collect()
)
# TRUE

all.equal(
  cmData1$outcomes %>%
    arrange(rowId, outcomeId) %>%
    collect(),
  cmData2$outcomes %>%
    arrange(rowId, outcomeId) %>%
    collect()
)
# TRUE

ps1 <- readRDS("JnJ_ThreadFix/Ps_l1_s2_p1_t137_c143.rds")
ps2 <- readRDS("NN_ThreadFix/Ps_l1_s2_p1_t137_c143.rds")

merged <- inner_join(
  ps1 %>%
    select(rowId, ps1 = propensityScore),
  ps2 %>%
    select(rowId, ps2 = propensityScore),
  by = "rowId"
)


different <- merged %>%
  filter(ps1 != ps2)

different %>%
  mutate(delta = ps1 - ps2) %>%
  summarise(max(delta))
# # A tibble: 1 x 1
# `max(delta)`
# <dbl>
#   1     9.99e-16

psModelCoef1 <- attr(ps1, "metaData")$psModelCoef
psModelCoef2 <- attr(ps1, "metaData")$psModelCoef

mergedCoef <- inner_join(
  tibble(covariateId = names(psModelCoef1),
         coef1 = psModelCoef1),
  tibble(covariateId = names(psModelCoef2),
         coef2 = psModelCoef2),
  by = "covariateId"
)

different <- mergedCoef %>%
  filter(coef1 != coef2)

different %>%
  mutate(delta = ps1 - ps2) %>%
  summarise(max(delta))

attr(ps1, "metaData")$psModelPriorVariance - attr(ps2, "metaData")$psModelPriorVariance

matched1 <- matchOnPs(ps1)
matched2 <- matchOnPs(ps2)

mergedMatched <- inner_join(
  matched1 %>%
    select(rowId, stratumId1 = stratumId),
  matched2 %>%
    select(rowId, stratumId2 = stratumId),
  by = "rowId"
)
sum(mergedMatched$stratumId1 != mergedMatched$stratumId2)
# 21

.Machine
# $double.eps
# [1] 2.220446e-16
# 
# $double.neg.eps
# [1] 1.110223e-16
# 
# $double.xmin
# [1] 2.225074e-308
# 
# $double.xmax
# [1] 1.797693e+308
# 
# $double.base
# [1] 2
# 
# $double.digits
# [1] 53
# 
# $double.rounding
# [1] 5
# 
# $double.guard
# [1] 0
# 
# $double.ulp.digits
# [1] -52
# 
# $double.neg.ulp.digits
# [1] -53
# 
# $double.exponent
# [1] 11
# 
# $double.min.exp
# [1] -1022
# 
# $double.max.exp
# [1] 1024
# 
# $integer.max
# [1] 2147483647
# 
# $sizeof.long
# [1] 4
# 
# $sizeof.longlong
# [1] 8
# 
# $sizeof.longdouble
# [1] 16
# 
# $sizeof.pointer
# [1] 8
# 
# $longdouble.eps
# [1] 1.084202e-19
# 
# $longdouble.neg.eps
# [1] 5.421011e-20
# 
# $longdouble.digits
# [1] 64
# 
# $longdouble.rounding
# [1] 5
# 
# $longdouble.guard
# [1] 0
# 
# $longdouble.ulp.digits
# [1] -63
# 
# $longdouble.neg.ulp.digits
# [1] -64
# 
# $longdouble.exponent
# [1] 15
# 
# $longdouble.min.exp
# [1] -16382
# 
# $longdouble.max.exp
# [1] 16384




# Reproduce exact regression input:

studyPop <- CohortMethod::createStudyPopulation(cmData1, 
                                                restrictToCommonPeriod = FALSE,
                                                removeDuplicateSubjects = "keep all",
                                                minDaysAtRisk = 1,
                                                addExposureDaysToStart = FALSE,
                                                riskWindowStart = 1,
                                                washoutPeriod = 0,
                                                censorAtNewRiskWindow = TRUE,
                                                addExposureDaysToEnd = FALSE,
                                                priorOutcomeLookback = 30,
                                                removeSubjectsWithPriorOutcome = TRUE,
                                                riskWindowEnd = 30,
                                                firstExposureOnly = FALSE)
ps3 <- createPs(cohortMethodData = cmData1,
                population = studyPop,
                control = createControl(startingVariance = 0.01,
                                        seed = 1,
                                        tolerance = 2e-7,
                                        cvRepetitions = 10,
                                        resetCoefficients = TRUE,
                                        threads = 4))
merged <- inner_join(
  ps1 %>%
    select(rowId, ps1 = propensityScore),
  ps3 %>%
    select(rowId, ps3 = propensityScore),
  by = "rowId"
)


different <- merged %>%
  filter(ps3 != ps3)

different

library(Cyclops)
outcomes <- readRDS("c:/temp/outcomes.rds")
covariates <- readRDS("c:/temp/covariates.rds")
cyclopsData <- convertToCyclopsData(outcomes, covariates, modelType = "lr")
fit <- fitCyclopsModel(cyclopsData = cyclopsData, 
                       prior = createPrior(priorType = "laplace",
                                           useCrossValidation = TRUE),
                       control = createControl(startingVariance = 0.01,
                                               seed = 1,
                                               tolerance = 2e-7,
                                               cvRepetitions = 10,
                                               resetCoefficients = TRUE,
                                               threads = 4))
coeffs <- coef(fit)
ps4 <- predict(fit)
ps4
head(ps4)
head(ps3$propensityScore)
saveRDS(coeffs, "c:/temp/coeffs.rds")
saveRDS(ps4, "c:/temp/prediction.rds")

