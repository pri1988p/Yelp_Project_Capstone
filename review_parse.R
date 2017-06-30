library(mongolite)
c=mongo(collection = "review", db="yelp", url = "mongodb://localhost")

c$distinct("type")
c$count()

c$info()
c$find()
