# Comparing the three sites after ETL, using data from the DQD

library(dplyr)

getRowCounts <- function(dqd) {
    dqd$CheckResults %>%
        group_by(CDM_TABLE_NAME) %>%
        summarize(rowCount = max(NUM_DENOMINATOR_ROWS)) %>%
        mutate(rowCount = ifelse(is.na(rowCount), 0, rowCount)) %>%
        rename(table = CDM_TABLE_NAME) %>%
        arrange(table) %>%
        return()
}

getMissingConceptCounts <- function(dqd) {
    dqd$CheckResults %>%
        filter(CHECK_NAME == "standardConceptRecordCompleteness") %>%
        select(table = CDM_TABLE_NAME, field = CDM_FIELD_NAME, rows = NUM_VIOLATED_ROWS) %>%
        arrange(table, field) %>%
        return()
}

dqdJnJ <- jsonlite::fromJSON("JnJ.json")
dqdNn <- jsonlite::fromJSON("NN.json")
dqdDac <- jsonlite::fromJSON("dqd20.json")

rowCountsJnJ <- getRowCounts(dqdJnJ)
rowCountsNn <- getRowCounts(dqdNn)
rowCountsDac <- getRowCounts(dqdDac)

joined <- inner_join(
    inner_join(rowCountsJnJ %>%
                   rename(rowCount1 = rowCount),
               rowCountsNn%>%
                   rename(rowCount2 = rowCount),
               by = "table"),
    rowCountsDac%>%
        rename(rowCount3 = rowCount),
    by = "table")
View(joined)

dqdJnJ$Metadata$VOCABULARY_VERSION
dqdNn$Metadata$VOCABULARY_VERSION
dqdDac$Metadata$VOCABULARY_VERSION

missingCountsJnJ <- getMissingConceptCounts(dqdJnJ)
missingCountsNn <- getMissingConceptCounts(dqdNn)
missingCountsDac <- getMissingConceptCounts(dqdDac)

joined <- inner_join(
    inner_join(missingCountsJnJ %>%
                   rename(rowCount1 = rows),
               missingCountsNn%>%
                   rename(rowCount2 = rows),
               by = c("table", "field")),
    missingCountsDac%>%
        rename(rowCount3 = rows),
    by =  c("table", "field"))
View(joined)
