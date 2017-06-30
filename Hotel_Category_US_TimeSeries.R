
###---------------Data Preparation for Time Series Analysis------------------#####


#-----Read the raw csv file extracted from Pentaho-----###

#Hotel_Category <- read.csv("Hotel_Category.csv", header=TRUE)
#dim(Hotel_Category)
#names(Hotel_Category)
#head(Hotel_Category)

Hotel_Category_reviewdates_US <- read.csv("review_dates_US.csv", header=TRUE)
dim(Hotel_Category_reviewdates_US)
head(Hotel_Category_reviewdates_US)


Hotel_Category_review_monthYear=sqldf("select review_date, sum(review_count) as review_count
      from Hotel_Category_reviewdates
      group by review_date
      order by review_date asc")

###-------Output------###

write.table(Hotel_Category_review_monthYear, file="Hotel_Category_review_monthYear.txt", sep = "|", col.names = TRUE, row.names = FALSE)

#-------Query to extract US states only------##

Hotel_Category_review_date_us = sqldf("select review_date, count(review_id)
      from Hotel_Category
      where state in ('NV', 'OH', 'AZ', 'PA', 'NC', 'SC', 'IL', 'WI', 'VT')
      group by review_date
      order by review_date asc")
head(Hotel_Category_review_date_us)


###-------Output------###

write.table(Hotel_Category_review_date_us, file="Hotel_Category_review_date_us.txt", sep = "|", col.names = TRUE, row.names = FALSE)



#-------- Review Counts grouped by month and year---------###


Hotel_Category_review_month_Year_US <- Hotel_Category_reviewdates_US%>% separate(review_date, c("review_date","review_Month", "review_year"), sep = "-", remove=TRUE)%>%
    select(review_date, review_Month, review_year, Review_count)

dim(Hotel_Category_review_month_Year_US)
head(Hotel_Category_review_month_Year_US)


Hotel_Cat_review_month_Year_US= sqldf("select review_Month, review_year, sum(review_count) as review_count
      from Hotel_Category_review_month_Year_US
      group by review_Month, review_year
      order by review_year, review_Month asc")

###---------Output--------###
write.table(Hotel_Cat_review_month_Year_US, file="Hotel_Cat_review_month_Year_US.txt", sep = "|", col.names = TRUE, row.names = FALSE)
