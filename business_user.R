setwd("C:/Users/varun76/Desktop/577")
getwd()

install.packages("RJSONIO")
install.packages("jsonlite")
install.packages("tibble")
install.packages("stringr")
install.packages("tidyr")
install.packages("dplyr")
install.packages("sqldf")
install.packages("magrittr")
install.packages("igraph")


library(RJSONIO)
library(jsonlite)
library(tibble)
library(stringr)
library(tidyr)
library(dplyr)
library(sqldf)
library(magrittr)
library(igraph)

memory.size(max = 1E10)

#Importing the yelp business user dataset
business_user <- stream_in(file("yelp_academic_dataset_user.json"))

#unlist
business_user_flat<-flatten(business_user)
rm(business_user)
#structure
str(business_user_flat)
#Column headers
colnames(business_user_flat)

#Users and their asscociated friends
User_Friends_Table <- business_user_flat %>% select(user_id, review_count,fans,friends) 
rm(business_user_flat)
User_Friends_Table_1 <- User_Friends_Table %>% unnest(friends)

