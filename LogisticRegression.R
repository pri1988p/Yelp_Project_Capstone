setwd("C:/Users/CampusUser/Desktop/BusinessandCheckins")
getwd()

#Data cleaning
#Removing NA and -
businessreviewstd<-read.csv("AllBusinessCategoryStandardisedReviewsCountCSV.csv")
businessreviewstd$business_id=gsub("-","",businessreviewstd$business_id)
businessreviewstd
summary(businessreviewstd)
write.csv(businessreviewstd,"BusinessReviewSTDnew.csv")
#Removing unidentified business ids
businessreviewsclean<-read.csv("BusinessReviewSTDnew.csv",na.strings = "#NAME?")
businessreviewsclean<-is.na(businessreviewsclean)
businessreviewsclean<-na.omit(businessreviewsclean)
write.csv(businessreviewsclean,"BusinessReviewsClean.csv")
businesscheckins<-read.csv("BusinessCheckins.csv")
#Merging check in file and review file
CheckinBusReview<-merge(businesscheckins,businessreviewsclean,by="business_id")
write.csv(CheckinBusReview,"BusinessReviewCheckin.csv")
BusSentiment<-read.table("Sentiment_score_std.txt",header = TRUE,sep = "|")
BusSentiment<-rename(BusSentiment,replace = c("inv.business_id"="business_id"))
BusSentiment$business_id=gsub("-","",BusSentiment$business_id)
BusCheckinReview<-read.csv("BusinessReviewCheckin.csv")
BusReviewSentiment<-merge(BusSentiment,BusCheckinReview,by="business_id")
write.csv(BusReviewSentiment,"BusReviewSentiCheckin.csv")
head(BusReviewSentiment_cln)
names(BusCheckinReview)

BusReviewSentiment_cln = read.csv("BusReviewSentiCheckin.csv", header = TRUE)
BusinessReviewCheckin = read.csv("BusinessReviewCheckin.csv", header = TRUE)

attach(BusReviewSentiment)

rename(BusReviewSentiment, inv.review_id = review_id)

install.packages("sqldf")
install.packages("RSQLite")
library(sqldf)
library(RSQLite)

BusReviewSentiment$inv.review_id = review_id

total_sentiments= sqldf("select business_id, sum(senti_score)/count(review_id) Total_sentis
                        from BusReviewSentiment_cln
                        group by business_id")
#Joining Business table with Sentiments table

final_business_rate= sqldf("select * from BusCheckinReview R
                           inner join total_sentiments T
                           on T.business_id = R.business_id")

#Logistic Regression
Final_Business<-read.csv("LogisticReg.csv")
head(Final_Business)
Open.RestData$starsCat<-ifelse(Open.RestData$stars>=3, 1, 0)
#Splitting the data
training = sample(1:nrow(Open.RestData), nrow(Open.RestData)*0.80)
testing = -training
training_data = Open.RestData[training,]
testing_data = Open.RestData[testing,]
star_testing = starsCat[testing]
head(Open.RestData)
logitModel<-glm(formula = starsCat~Standardised.Review.Count+Standardised.Checkin.Count+Total_sentis,data=training_data,family = binomial)
summary(logitModel)
logitpredict<-predict(logitModel,testing_data,type = "response")
summary(logitpredict)

attach(Open.RestData)
#Replicating values from testing data
model_pred_stars= rep(0, 627)
#Setting the default cutoff
model_pred_stars[logitpredict>0.5] = 1
#Confusion matrix
table(model_pred_stars, star_testing )
mean(model_pred_stars != star_testing )
