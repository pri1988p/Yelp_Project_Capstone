install.packages("data.table")
library(data.table)

file <- read.csv(file = "business_with_all_Restaurant_without_category_column.csv", header = TRUE, sep = ",")
colnames(file)

file <- subset(file, file$is_open=="1")
gc()

business <- file %>% select(business_id,name,city,stars)
rm(file)
business <- subset(business,business$city=="Phoenix")

gc()
memory.size()
