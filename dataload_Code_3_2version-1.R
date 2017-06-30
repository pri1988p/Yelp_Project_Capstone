
#.....................Seggregate the Attribute column from Business JSON File..................


setwd("C:/Project 577")  # Change the Working directory here.
getwd()



#Required Packages
install.packages("RJSONIO")
install.packages("jsonlite")
install.packages("tibble")
install.packages("stringr")
install.packages("tidyr")
install.packages("dplyr")
install.packages("sqldf")
install.packages("RSQLite")

library(RJSONIO)
library(jsonlite)
library(tibble)
library(stringr)
library(tidyr)
library(dplyr)
library(plyr)
library(sqldf)
library(RSQLite)


#Parse the Business .JSON file
business_yelp <- stream_in(file("yelp_academic_dataset_business.json")) #File Load
head(business_yelp, 5)  # First 5 records view.
str(business_yelp) # Data Structure view

business_yelp_flat<- flatten(business_yelp) #unlist/flatten vectors
str(business_yelp_flat) # Data Structure view
bus_yelp_table <- as_data_frame(business_yelp_flat) #Coerce the unlisted data into a Data frame
bus_yelp_table

bus_yelp_table$attributes
 
  
#Transform data in to 1NF

  business_attributes <- bus_yelp_table %>% mutate(attributes= strsplit(as.character(attributes), ","))%>%
    unnest(attributes) %>%
    select(business_id, name, attributes)
  
    business_attributes
  
    business_attributes <- bus_yelp_table %>% mutate(attributes= strsplit(as.character(attributes), ","))%>%
    unnest(attributes) %>% 
    select(business_id, name, attributes)
    
    business_value <- business_attributes%>% separate(attributes, c("attributes", "value"), sep = "\\:", remove=TRUE)%>%
      unnest(value) %>%
      select(business_id, attributes, value)
    
    business_value
    