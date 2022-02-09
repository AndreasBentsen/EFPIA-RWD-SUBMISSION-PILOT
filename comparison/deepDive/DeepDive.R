# Explore minor differences by comparing the patient-level data files

library(ggplot2)
library(dplyr)

folder1 <- "./comparison/DeepDive/Dkma"
folder2 <- "./comparison/DeepDive/JnJ"

psFile1 <- readRDS(file.path(folder1, "Ps_l1_s1_p1_t2_c28_o6.rds"))
psFile2 <- readRDS(file.path(folder2, "Ps_l1_s1_p1_t2_c28_o6.rds"))

# head(psFile1)
# head(psFile2)

metaData1 <- attr(psFile1, "metaData")
metaData2 <- attr(psFile2, "metaData")
metaData1$psModelPriorVariance
metaData2$psModelPriorVariance

coef1 <- metaData1$psModelCoef
coef2 <- metaData2$psModelCoef

coef1 <- tibble(covariateId = names(coef1),
                beta1 = coef1)
coef2 <- tibble(covariateId = names(coef2),
                beta2 = coef2)

coef <- coef1 %>%
  inner_join(coef2, by = "covariateId") %>%
  filter(beta1 != 0 & beta2 != 0)

ggplot(coef, aes(x = beta1, y = beta2)) +
  geom_abline(slope = 1) +
  geom_point(alpha = 0.1, color = "blue")

ggsave("./comparison/DeepDive/PsModelBetas.png", width = 5, height = 5, dpi = 200)

# CohortMethod::plotPs(psFile1)
# CohortMethod::plotPs(psFile2)
# strataFile1 <- CohortMethod::stratifyByPs(psFile1, numberOfStrata = 5)
# strataFile2 <- CohortMethod::stratifyByPs(psFile2, numberOfStrata = 5)

plotData <- psFile1 %>%
  select(rowId, ps1 = propensityScore) %>%
  inner_join(psFile2 %>%
               select(rowId, ps2 = propensityScore),
             by = "rowId")

ggplot(plotData, aes(x = ps1, y = ps2)) +
  geom_abline(slope = 1) +
  geom_point(alpha = 0.1, color = "blue")
ggsave("./comparison/DeepDive/Ps.png", width = 5, height = 5, dpi = 200)

strataFile1 <- readRDS(file.path(folder1, "StratPop_l1_s1_p1_t2_c28_s1_o6.rds"))
strataFile2 <- readRDS(file.path(folder2, "StratPop_l1_s1_p1_t2_c28_s1_o6.rds"))

# head(strataFile1)
# head(strataFile2)

joinedData <- strataFile1 %>%
  select(rowId, stratumId1 = stratumId) %>%
  inner_join(strataFile2 %>%
               select(rowId, stratumId2 = stratumId),
             by = "rowId")
mean(joinedData$stratumId1 == joinedData$stratumId2)
# [1] 0.9947391