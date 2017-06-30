
#........................This Code is to process the Checkin JSON File..............................

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

install.packages("xlsx")
library(xlsx)

#Parse the Checkin.JSAON file
business_checkins_raw <- stream_in(file("yelp_academic_dataset_checkin.json"))  #File Load
head(business_checkins_raw, 5) # First 5 records view.


str(business_yelp) # Data Structure view

business_checkin_flat<- flatten(business_checkins_raw) #unlist/flatten vectors
bus_Checkin_table <- as_data_frame(business_checkin_flat) #Coerce the unlisted data into a Data frame
head(bus_Checkin_table, 5)

bus_Checkin_table %>% mutate(time = as.character(time)) %>% select(business_id, time) # Mutate adds a new variable 


#Remove Special characters and store Day and hours value in separate columns

business_checkin_intermediate <- bus_Checkin_table %>% mutate(time = strsplit(as.character(time), ",")) %>%  unnest(time) %>% 
  select(business_id, time)   #unnest creates atomic values from a list


business_checkin_time <- business_checkin_intermediate %>% separate(time, c("day", "hours"),sep = "-", remove=TRUE)%>%
unnest(hours) %>% select(business_id, hours, day) 

#business_checkin_intermediate %>% separate(time, c("day", "hours"),sep = " ", remove=TRUE)%>%
 #unnest(hours) %>% select(business_id, hours, day)




#Create table to store the top 5 categories

category_count_top_5<-sqldf("select categories, cat_count from 
      (select distinct categories, count(categories) cat_count
      from business_category_loc
      group by categories)
        order by cat_count desc limit 5")


sqldf("select * from business_category_loc limit 5")

#Create table to store checkins for business in Top 5 categories

Final_yelp_checkins<- sqldf("Select distinct A.business_id business_id, name, day, hours, city
                            from business_checkin_time A
                        inner join business_category_loc B 
                        on A.business_id = B.business_id
                            where B.categories in (select categories from category_count_top_5)")

#business_category_loc table in above query comes from dataload_Code.R

#........Export results..........

write.table(Final_yelp_checkins, "Business_Checkins_top_5_hours.txt", sep=" ", row.names = F) 

write.table(category_count, "category_count.txt", sep=" ", row.names = F) 






