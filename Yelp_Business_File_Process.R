
#........................This Code is to process the Business JSON File..............................



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


#Parse the Business .JSAON file
business_yelp <- stream_in(file("yelp_academic_dataset_business.json"))  #File Load
head(business_yelp, 5)  # First 5 records view.
str(business_yelp) # Data Structure view

business_yelp_flat<- flatten(business_yelp) #unlist/flatten vectors
str(business_yelp_flat) # Data Structure view
bus_yelp_table <- as_data_frame(business_yelp_flat) #Coerce the unlisted data into a Data frame
bus_yelp_table

attach(bus_yelp_table)

#Transform data in to 3NF 

#Separate the Category column and store in a separate table  

  bus_yelp_table %>% mutate(categories = as.character(categories)) %>% select(categories) # Mutate adds a new variable 
  names(bus_yelp_table) #Gives Column names

  business_category_loc <- bus_yelp_table %>% select(-starts_with("hours"), -starts_with("attribute")) %>% filter(str_detect(categories, "Restaurant")) %>% 
		unnest(categories) %>% select(business_id, name, categories, city)   #Create table to store Location wise Categories
		#unnest creates atomic values from a list

  
 
  attach(business_category)
  
# DIstinct Category List
  category_count<-sqldf("select distinct categories, count(categories) count_cat
        from business_category group by categories")  
  
#Result output
  write.table(category_count, "Business_Checkinstext.txt", sep=" ", row.names = F) 
  
#List the businesses category wise
  category_count<- sqldf("select count(distinct(categories)), categories, name from
        (select business_id, name, categories
        from business_category)
        group by business_id")
  
  
  
#Result output
  write.table(category_count, "category_count.txt", sep="\t") 
  
  sqldf("select count(distinct(business_id)) from business_category")
  
  
  sqldf("select count(distinct(categories)) from business_category")
  
  
#Distinct Business list
  bus_yelp_table_business_id <- bus_yelp_table %>% select(business_id, name)
  
  bus_yelp_table_business_id
  
  sqldf("select count(distinct(business_id)) from bus_yelp_table_business_id")
  
  sqldf("select A.business_id, A.name, B.categories from bus_yelp_table_business_id A
  inner join business_category B
  on  A.business_id=B.business_id")
  
  attach(bus_yelp_table_business_id)


#Find the missing/null categories for businesses and replace them with "UNKNOWN" value
  
  sqldf("select Count(B) as b_id_no_category 
          from
        (select distinct(bus_yelp_table_business_id.business_id) A, 
            coalesce(business_category.business_id, 'UNKNOWN') as B
        from bus_yelp_table_business_id 
        left join business_category
        on bus_yelp_table_business_id.business_id = business_category.business_id
        where B = 'UNKNOWN')")
  
  
  
  sqldf("select count(distinct(business_category.business_id)) b_id_with_category
       from bus_yelp_table_business_id
        inner join business_category
        on bus_yelp_table_business_id.business_id = business_category.business_id")
  
  
#Print Business Categories
  business_category %>% count("business_id")
  
  
#Separate the hours column and store in a separate table    
  
  bus_yelp_table %>% mutate(hours = as.character(hours)) %>% select(hours)
  
  business_hours <- bus_yelp_table %>% select(-starts_with("attributes"), -starts_with("categories")) %>%
  unnest(hours) %>%
  select( business_id,hours)
  
#Print Business Hours  
  business_hours
  
  business_hours %>% count("business_id")
  
  business_hours
  
  aggregate(business, data = business_hours)
  
  attach(business_hours)
  
  
  sqldf("select count(hours) from business_hours 
        group by business_id")
  
  
  
  