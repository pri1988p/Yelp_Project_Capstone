setwd("C:/Users/winx87/Desktop/ISDS_577/PHASE 2")
getwd()

set.seed(10)

#Required Packages

require(tm)
library(tm)
#rm(installLibraries)

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

### -----------Read the Review - Bag of words -----------####
review_words <- read.table("review_words.txt", header=TRUE, sep="|")
dim(review_words)
names(review_words)
head(review_words,20)


### --------Read the Sentiment Dictionary ----------###
Sentiment_dictionary = read.csv("Sentiment Dictionary.csv", header = TRUE)
dim(Sentiment_dictionary)
head(Sentiment_dictionary)


### -------------Clean and standardize the Dictionary---------------###
Sentiment_dictionary_unnest = Sentiment_dictionary %>% mutate(term = strsplit(as.character(term), " ")) %>%
                                 unnest(term) %>%  select(term, score)


Sentiment_dictionary_sum = sqldf("select term, sum(score)/count(score) as std_score
                                 from Sentiment_dictionary_unnest
                                 group by term")

attach(Sentiment_dictionary_sum)

####------------Categorize sentiments in to 'Positive', 'Negative' and 'Neutral'------------####

Sentiment_type = ifelse(std_score>0 , "Positive" , 
                        if_else(std_score <0, "Negative", "Neutral"))

Sentiment_dict = data.frame (Sentiment_dictionary_sum, Sentiment_type)
names(Sentiment_dict)
tail(head(Sentiment_dict, 2600),20)
  


####-----------Remove punctuations and special characters from Review words-----------####

review_words$review_id <- gsub('-','',review_words$review_id)

review_words$word <- gsub('-','',review_words$word)
review_words$word <- gsub("\"", '', review_words$word)
review_words$word <- gsub("'", '', review_words$word)


####-------------Calculate the Term Frequency of each word in a review--------------####

term_frequency = sqldf("select review_id, business_id, stars, word, 
                  count(word) freq from review_words
                       group by review_id, business_id, stars, word")



reviewword_frequency = sqldf(" Select review_id, business_id,stars, word, freq, 
                                Sentiment_type, std_score * freq as std_score
                                from
                              (select review_id, business_id, stars, word, count(word) freq, 
                                Sentiment_type, std_score
                                from review_words Rw
                                inner join Sentiment_dict Sd
                                on Rw.word = Sd.term
                              group by review_id, business_id, stars, word,Sentiment_type)x")

head(reviewword_frequency, 20)

###-------------Segregate the Positive, Negative and Neutral words-----------###

Word_lengths <- sqldf(" Select Pos.review_id, Pos.business_id, Pos.review_stars, Pos.Pos_words, 
        CASE Neg.Neg_words
          WHEN 'NA' THEN 0
          ELSE Neg.Neg_words
          END as Neg_words, 
        Total.Total_words
        from
      (select review_id, business_id, stars as review_stars, count(Sentiment_type) Pos_words
      from reviewword_frequency
      where Sentiment_type = 'Positive'
      group by review_id, business_id, stars) Pos
      left join 
      (select review_id, business_id, stars, count(Sentiment_type) Neg_words
      from reviewword_frequency
      where Sentiment_type = 'Negative'
      group by review_id, business_id, stars) Neg
      on Pos.review_id = Neg.review_id
      and Pos.business_id = Neg.business_id
      left join 
      (select review_id, business_id, stars, count(word) Total_words
      from review_words
      group by review_id, business_id, stars) Total
      on Pos.review_id = Total.review_id
      and Pos.business_id = Total.business_id")


Word_lengths = Word_lengths %>% mutate(Neg_words = replace(Neg_words, is.na(Neg_words),0))

####-----------Remove punctuations and special characters from Review ID-----------####
reviewword_frequency$review_id <- gsub(pattern = "\\---", replacement = "" , reviewword_frequency$review_id)
reviewword_frequency$review_id <- gsub(pattern = "\\--", replacement = "" , reviewword_frequency$review_id)
reviewword_frequency$review_id <- gsub(pattern = "\\-", replacement = "" , reviewword_frequency$review_id)
reviewword_frequency$review_id <- gsub('-', '' , reviewword_frequency$review_id)

Word_lengths$review_id <- gsub(pattern = "\\---", replacement = "" , Word_lengths$review_id)
Word_lengths$review_id <- gsub(pattern = "\\--", replacement = "" , Word_lengths$review_id)
Word_lengths$review_id <- gsub(pattern = "\\-", replacement = "" , Word_lengths$review_id)
Word_lengths$review_id <- gsub('-', '' , Word_lengths$review_id)


###----------------------MLR--------------------------####

attach(Word_lengths)  
summary(Word_lengths)

lm_fit = lm (stars ~ Pos_words+Neg_words+Total_words)
summary(lm_fit)
                    

head(Word_lengths)
head(reviewword_frequency)


###----------------------Calculate standardized Sentiment Score-------------------------###

Sentiment_score <- sqldf("Select inv.review_id as review_id, inv.business_id as business_id, 
                          inv.stars as review_stars,
                         sum(inv.std_score)/Total.Total_words as senti_score
                         from
                         (select review_id, business_id, stars, word, std_score 
                         from reviewword_frequency) inv
                         left join 
                         (select review_id, business_id, review_stars, Total_words
                         from Word_lengths) Total
                         on inv.review_id = Total.review_id
                         and inv.business_id = Total.business_id
                         group by inv.review_id, inv.business_id, inv.stars")
summary(Sentiment_score)

write.table(Sentiment_score, "Sentiment_score_std.txt", sep="|", row.names = FALSE, col.names = TRUE)


#------------------------Find sentiment score of each word in a review giv

business_sentiments = sqldf("select R.*, S.review_id, S.review_stars, S.senti_score
      from yelp_restaurants_data R
      inner join Sentiment_score S
      on R.business_id = S.business_id")

business_sentiments_all = sqldf("select business_id, name, city , stars as Business_Stars,
                                 latitude, longitude, 
                                (sum(senti_score)/count(review_id))*100 as total_sentis
                                from business_sentiments
                                group by business_id, name, city , stars,latitude, longitude")


summary(business_sentiments_all)



--------------------------------------------------------------------------------------------------------
##--------------------------------------WordClouds---------------------------------------------------##
--------------------------------------------------------------------------------------------------------  

  
  Review_star5=sqldf("select review_id, business_id, stars, word
  from review_words
                     where stars = 5") 
#head(review_words)

head(Review_star5,10)
attach(Review_star5)

review_words = review_words %>% mutate(word = replace(word, is.na(word),0))

Review_star5=Review_star5%>% mutate(word = replace(word, is.na(word),0))
#review_words<-as.character()
install.packages("wordcloud")
library(wordcloud)


Review_star5_freq=sqldf("select word, count(word) as freq
                        from Review_star5
                        group by word
                        order by freq desc")

#install.packages("tm")

attach(Review_star5_freq)
head(Review_star5_freq)


#review_words = tm_map(review_words, removePunctuation)
??wordcloud

set.seed(123)
wordcloud(word,freq,min.freq = 1000, colors=brewer.pal(6, "Dark2"))







Review_star1=sqldf("select review_id, business_id, stars, word
                   from review_words where stars in (1,2)") 


head(Review_star1,10)
attach(Review_star1)

Review_star1=Review_star1%>% mutate(word = replace(word, is.na(word),0))

Review_star1_freq=sqldf("select word, count(word) as freq
                        from Review_star1
                        group by word
                        order by freq desc")

attach(Review_star1_freq)
head(Review_star1_freq)

wordcloud(word,freq,min.freq = 1200, colors=brewer.pal(6, "Dark2"))

  
  
  
head(business_yelp)

business_4cloud=sqldf("select Y.*, W.word from business_yelp Y
      left join review_words W
      on Y.business_id = W.business_id
      where Y.stars >=4.0")

Business_star5_freq=sqldf("select word, count(word) as freq
                        from business_4cloud
                        group by word
                        order by freq desc")

attach(Business_star5_freq)
head(Business_star5_freq)

business_2cloud=sqldf("select Y.*, W.word from business_yelp Y
      left join review_words W
      on Y.business_id = W.business_id
      where Y.stars < 3.0")

Business_star2_freq=sqldf("select word, count(word) as freq
                        from business_2cloud
                        group by word
                        order by freq desc")

attach(Business_star2_freq)
head(Business_star2_freq)

wordcloud(word,freq,min.freq = 250, colors=brewer.pal(8, "Dark2"))


###------------------------LOCATION WORD CLOUDS------------------------------------###

head(business_yelp)

sqldf("select distinct state, count(business_id) fr
      from business_yelp
      group by state
      order by fr desc")

business_locAzNvCloud=sqldf("select Y.*, W.word from business_yelp Y
      left join review_words W
      on Y.business_id = W.business_id
      where Y.state in ('AZ','NV')")

business_locAzNv_freq=sqldf("select word, count(word) as freq
                        from business_locAzNvCloud
                        group by word
                        order by freq desc")

attach(business_locAzNv_freq)
head(business_locAzNv_freq)

wordcloud(word,freq,min.freq = 1000, colors=brewer.pal(8, "Dark2"))



business_loc_ON_Cloud=sqldf("select Y.*, W.word from business_yelp Y
      left join review_words W
      on Y.business_id = W.business_id
      where Y.state= 'ON'")

business_loc_ON_freq=sqldf("select word, count(word) as freq
                        from business_loc_ON_Cloud
                        group by word
                        order by freq desc")

attach(business_loc_ON_freq)
head(business_loc_ON_freq)

wordcloud(word,freq,min.freq = 600, colors=brewer.pal(8, "Dark2"))



business_loc_UK_Cloud=sqldf("select Y.*, W.word from business_yelp Y
      left join review_words W
      on Y.business_id = W.business_id
      where Y.state in  ('EDH','MLN', 'HLD', 'FIF', ' ELN', 'WLN', 'ESX', 'KHL')")

business_loc_UK_freq=sqldf("select word, count(word) as freq
                        from business_loc_UK_Cloud
                        group by word
                        order by freq desc")

attach(business_loc_UK_freq)
head(business_loc_UK_freq)

wordcloud(word,freq,min.freq = 250, colors=brewer.pal(8, "Dark2"))



business_loc_Canada_Cloud=sqldf("select Y.*, W.word from business_yelp Y
                              left join review_words W
                            on Y.business_id = W.business_id
                            where Y.state in  ('ON', 'QC')")

business_loc_Canada_freq=sqldf("select word, count(word) as freq
                           from business_loc_Canada_Cloud
                           group by word
                           order by freq desc")

attach(business_loc_Canada_freq)
head(business_loc_Canada_freq)

wordcloud(word,freq,min.freq = 250, colors=brewer.pal(8, "Dark2"))


