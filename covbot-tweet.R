library(RPostgreSQL)
library(rtweet)

con <- dbConnect(
  dbDriver("PostgreSQL"),
  dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"),
  host = Sys.getenv("ELEPHANT_SQL_HOST"),
  port = 5432,
  user = Sys.getenv("ELEPHANT_SQL_USER"),
  password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

covid <- dbReadTable(con, "covid")
tweetcovid <- covid[nrow(covid),]

## 1st Hash Tag
hashtag <- c("MDS","rvest","rtweet", "ElephantSQL","bot","covid","RPostgreSQL")
samp_word <- sample(hashtag, 3)

## Status Message
status_details <- paste0(
  "Update terakhir kasus corona di Indonesia\n",
  "📈 Kasus Aktif:", tweetcovid[2],"\n",
  "☠️ Meninggal:", tweetcovid[3],"\n",
  "🩹 Sembuh:", tweetcovid[4],"\n\n",
  "Source: https://worldometers.info/coronavirus/",
  "\n\n",
  paste0("#", samp_word, collapse = " "))

## Create Twitter token
token <- create_token(
  app = "covidMD",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

## Post the image to Twitter
post_tweet(
  status = status_details,
  token = token
)

on.exit(dbDisconnect(con))
