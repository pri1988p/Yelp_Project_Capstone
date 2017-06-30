
setwd("C:/Users/winx87/Desktop/ISDS_577/PHASE 2")
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
#library(plyr)
library(sqldf)
library(RSQLite)


dreview = read.csv("review_cleaned.csv", header = T)
head(dreview,15)
attach(dreview)
names(dreview)
dim(dreview)
str(dreview)


install.packages("tm")
install.packages("qdap")
install.packages("qdapDictionaries")
install.packages("RColorBrewer")
install.packages("scales")
library(tm) # Framework for text mining.
library(qdap) # Quantitative discourse analysis of transcripts.
library(qdapDictionaries)
#library(dplyr) # Data wrangling, pipe operator %>%().
library(RColorBrewer) # Generate palette of colours for plots.
library(ggplot2) # Plot word frequencies.
library(scales) # Include commas in numbers.
library(Rgraphviz) # Correlation plots.


getTransformations()
attach(dreview)

head(dreview$cool, 5)

review_text <- dreview %>% select(text)

names(review_text)

