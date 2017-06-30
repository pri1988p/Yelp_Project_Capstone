#Required Packages
set.seed(10)
installLibraries = function(){
  install.packages("RJSONIO")
  install.packages("jsonlite")
  install.packages("tibble")
  install.packages("stringr")
  install.packages("tidyr")
  install.packages("dplyr")
  install.packages("sqldf")
  install.packages("RSQLite")
  install.packages("tidytext")
  install.packages("readr")
  print("The libraries are installed")}
loadlibraries=function(){
  library(RJSONIO)
  library(jsonlite)
  library(tibble)
  library(stringr)
  library(tidyr)
  library(dplyr)
  library(plyr)
  library(sqldf)
  library(RSQLite)
  library(tidytext)
  library(readr)
  print("The libraries are loaded")}

installLibraries()
loadlibraries()
#Parse the Review .JSON file
yelp_review <- "C:/Users/winx87/Desktop/yelp/yelp_academic_dataset_review.json"
review <- read_lines(yelp_review, n_max = 200000, progress = FALSE)
#read_lines
reviews_combined <- str_c("[", str_c(review, collapse = ", "), "]")
yelp_review_table <- fromJSON(reviews_combined) %>%   flatten() %>% tbl_df()

#------------------------Review file data cleaning------------------------------------------#
review_words <- yelp_review_table %>%
  select(review_id, business_id, stars, text) %>%
  unnest_tokens(word, text) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "^[a-z']+$"))
yelp_review_table$word <- gsub('-', '' , yelp_review_table$word)
yelp_review_table$word <- gsub('"', '' , yelp_review_table$word)
yelp_review_table$word <- gsub(pattern = "\\'", replacement = "" , yelp_review_table$word)
yelp_review_table$word <- gsub(pattern = "\\{", replacement = "" , yelp_review_table$word)
yelp_review_table$word <- gsub(pattern = "\\}", replacement = "" , yelp_review_table$word)







business_value$value <- gsub(pattern = "\\c()", replacement = "" , business_value$value)
business_value$value <- gsub(pattern = "\\(", replacement = "" , business_value$value)
business_value$value <- gsub(pattern = "\\)", replacement = "" , business_value$value)
business_value$value <- gsub(pattern = "\\\n", replacement = "" , business_value$value)








head(yelp_review_table, 5)  
str(yelp_review_table)


#yelp_review_table <- as_data_frame(yelp_review)
#head(yelp_review_table)

attach(yelp_review_table)

sqldf("select count(*) from yelp_review_table")

business_yelp<- read.csv("business_category.csv", header = TRUE, na.strings = "#NAME?")
#sqldf("select count(*)  from business_yelp")

head(business_yelp)


restaurant_review_text <- sqldf("select * from yelp_review_table
                                where business_id in (select distinct business_id from business_yelp)")
head(restaurant_review_text)
sqldf("select count(*) from restaurant_review_text")

#review_text_sample<- sample(restaurant_review_text, size = 1000)





head(review_words)


sqldf("select count(*) from review_words")
#8774699

write.table(review_words, "review_words.txt", sep = "|")
