
business_sentiments_CLU_AZ = sqldf("select business_id,  total_sentis, Business_Stars,latitude,longitude, review_count, name, city, is_open, state
                                  from business_sentiments_CLUSTER
                                   where state in ('AZ')")
head(business_sentiments_CLU_AZ)


####-------------------PCA--------------------#############
pr.out =prcomp (business_sentiments_CLU_AZ[,2:5] , scale =TRUE)
names(pr.out )
pr.out$center
pr.out$scale
pr.out$rotation
dim(pr.out$x )
biplot (pr.out , scale =0)
pr.out$rotation=-pr.out$rotation
pr.out$x=-pr.out$x
biplot (pr.out , scale =0)
pr.out$sdev
pr.var =pr.out$sdev ^2
pr.var
pve=pr.var/sum(pr.var )
pve
plot(cumsum (pve ), xlab=" Principal Component ", ylab ="
     Cumulative Proportion of Variance Explained ", ylim=c(0,1) , type='b')



business_senti_CLU_AZ = scale(business_sentiments_CLU_AZ[,2:5])

install.packages("cluster")
library(cluster)


?clusplot

?kmeans

KM.OUT = kmeans(business_senti_CLU_AZ, 4, nstart = 200 )
KM.OUT$cluster
KM.OUT$centers
KM.OUT$size
KM.OUT$centers
KM.OUT$withinss
KM.OUT$betweenss

plot(x, col =(KM.OUT$cluster) , main="K-Means Clustering
     Results with K=4", xlab ="", ylab="", pch =1, cex =2)

clusplot(business_senti_CLU_AZ, KM.OUT$cluster, main='2D representation of the Cluster solution',
         color=TRUE, shade=TRUE,
         labels=2, lines=0)
