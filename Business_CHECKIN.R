#........................This Code is to process the Checkin JSON File..............................

setwd("C:/Users/winx87/Desktop/ISDS_577/yelp_dataset") # Change the Working directory here.
getwd()


set.seed(10)

#Required Packages

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
  install.packages("tm")
  print("The libraries are installed")
}

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
  library(tm)
  print("The libraries are loaded")
}

installLibraries()
loadlibraries()

#Parse the Checkin.JSAON file
business_checkins_raw <- stream_in(file("yelp_academic_dataset_checkin.json"))  #File Load
head(business_checkins_raw, 5) # First 5 records view.



business_checkin_flat<- flatten(business_checkins_raw) #unlist/flatten vectors
bus_Checkin_table <- as_data_frame(business_checkin_flat) #Coerce the unlisted data into a Data frame
head(bus_Checkin_table, 5)

bus_Checkin_table %>% mutate(time = as.character(time)) %>% select(business_id, time) # Mutate adds a new variable 


#Remove Special characters and store Day and hours value in separate columns

business_checkin_intermediate <- bus_Checkin_table %>% mutate(time = strsplit(as.character(time), ",")) %>%  unnest(time) %>% 
  select(business_id, time)   #unnest creates atomic values from a list

head(business_checkin_intermediate)

business_checkin_day <- business_checkin_intermediate %>% separate(time, c("day", "hours_checkincount"),sep = "-", remove=TRUE)%>%
  unnest(hours_checkincount) %>% select(business_id, day, hours_checkincount) 



head(business_checkin_day)


business_checkin_count <- business_checkin_day %>% separate(hours_checkincount, c("hours", "checkin_count"),sep = ":", remove=TRUE)%>%
  unnest(checkin_count) %>% select(business_id, day, hours, checkin_count) 

head(business_checkin_count)

Total_checkins<- sqldf("select business_id, sum(checkin_count) Total_checkins
      from business_checkin_count
      group by business_id")

Total_checkins$business_id = gsub('-', '', Total_checkins$business_id)

Total_checkins


??write.table

write.table(Total_checkins,"Total_checkins.txt", sep = " ", row.names = FALSE,
            col.names = TRUE)








