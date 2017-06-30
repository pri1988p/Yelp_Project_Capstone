install.packages("RJSONIO")
install.packages("jsonlite")
install.packages("tibble")
install.packages("stringr")
install.packages("tidyr")
install.packages("dplyr")
install.packages("sqldf")
install.packages("magrittr")
install.packages("igraph")



library(RJSONIO)
library(jsonlite)
library(tibble)
library(stringr)
library(tidyr)
library(dplyr)
library(sqldf)
library(magrittr)
library(igraph)
library(networkD3)

memory.size(max = 1E10)

userfriends <- read.csv(file = "userfriends.csv",header = TRUE)

#Convert dataframe to graph
graphPX <- graph.data.frame(userfriends)

#To delete redudant edges
gPX <- simplify(graphPX)

#Network Stats

PXdegree <- degree(gPX)
PXbetweenness <- betweenness(gPX)
PXcloseness <- closeness(gPX)
PXevcent <- evcent(gPX)
PXevcent1 <- PXevcent$vector


statsPX <- data.frame(V(graphPX)$name,PXdegree,PXbetweenness,PXcloseness,PXevcent1)

correlationPX <- cor(statsPX[,2:5])


largestcommunityPX <- largest_cliques(graphPX %>% as.undirected)

gPX <- simplify(graphPX) %>% as.undirected

clusterPX <- cluster_louvain(gPX)
modularityPX <- modularity(clusterPX)
membership <- membership(clusterPX)
sizes (clusterPX)





