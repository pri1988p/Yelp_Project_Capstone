
#........................This Code is to process the Users JSON File..............................

setwd("C:/Users/winx87/Desktop/ISDS 577/yelp_dataset_challenge_round9") # Change the Working directory here.
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



#Parse the Users.JSAON file
business_users_raw <- stream_in(file("yelp_academic_dataset_user.json"))  #File Load
head(business_users_raw, 5) # First 5 records view.




business_users_flat<- flatten(business_users_raw) #unlist/flatten vectors
str(business_users_flat) # Data Structure view
bus_Users_table <- as_data_frame(business_users_flat) #Coerce the unlisted data into a Data frame
bus_Users_table




####Elite_years - Seggregation ######

bus_Users_table %>% mutate(elite = as.character(elite)) %>% select(elite) # Mutate adds a new variable 

business_users_elite <- bus_Users_table %>% unnest(elite) %>% select(user_id, name, elite) #unnest creates atomic values from a list

Yelp_users_elite <- sqldf("select user_id, name, elite as elite_years from business_users_elite") # Create table to store the Elite year information

#Export the above table records

write.table(Yelp_users_elite, "Yelp_users_elite.txt", sep="\t", row.names = F) 



####All other Columns except Elite and Friends###

Yelp_User <- bus_Users_table %>% select(-starts_with("friends"), -starts_with("elite"))  # Create table to store the Elite year information

sqldf("select * from Yelp_User limit 10") #View first 10 columns

write.table(Yelp_User, "Yelp_User.txt", sep=" ", row.names = F)  #Export the above table records


