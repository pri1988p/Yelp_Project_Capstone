

#------------------------------------Read_review_samples - remove stopwords and punctuations----------------------------------#

set.seed(10)

install.packages("readr")
library(readr)

yelp_review <- "C:/Users/winx87/Desktop/ISDS_577/yelp_dataset/yelp_academic_dataset_review.json"
review <- read_lines(yelp_review, n_max = 200000, progress = FALSE)

reviews_combined <- str_c("[", str_c(review, collapse = ", "), "]")


yelp_review_table <- fromJSON(reviews_combined) %>%   flatten() %>% tbl_df()

head(yelp_review_table, 5)  
#str(yelp_review_table)


attach(yelp_review_table)

sqldf("select count(*) from yelp_review_table")

business_yelp<- read.csv("business_category.csv", header = TRUE, na.strings = "#NAME?")

head(business_yelp)


restaurant_review_text <- sqldf("select * from yelp_review_table
                                where business_id in (select distinct business_id from business_yelp)")

review_text <- yelp_review_table %>%
  select(review_id, business_id, stars, text) 
head(review_text)







