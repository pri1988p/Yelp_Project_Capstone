Table_Join_1 <- merge(business,business_review_Table1,by = "business_id")
rm(business)
rm(business_review_Table1)
gc()
memory.size()
Table_Join_2 <- merge(Table_Join_1,User_Friends_Table,by = "user_id")
rm(Table_Join_1)
gc()


Table_Join_2 <- as.data.frame(Table_Join_2)

head(Table_Join_2)

Table_Join_2_del = Table_Join_2

Table_Join_2_del = Table_Join_2_del %>% select(-starts_with("friends"))


head(Table_Join_2_del)

df_Table_Join_2 = as_data_frame(Table_Join_2)

allusers <- sqldf("select user_id, business_id, name, review_count, fans
                from Table_Join_2_del
               order by review_count, fans desc")
                 

Top9users <- sqldf("select user_id, business_id, name, review_count, fans
                from Table_Join_2_del
                where review_count>3632
               order by review_count, fans desc")


rm(Table_Join_2)


rm(review)
rm(Table_Join_2_del)
gc()
memory.size()

write.csv(Top9users,file = "Top9users.csv")

Friends_of_Top9Users <- merge(Top9users,User_Friends_Table,by = "user_id")

Friends_of_Top9Users <- Friends_of_Top9Users %>% unnest(friends)

write.csv(Friends_of_Top9Users, file = "Friends_of_Top9Users.csv")

