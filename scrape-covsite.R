# Set library ----
library(rvest)
library(RPostgreSQL)

# List of covid sites
# https://news.google.com/covid19/map
# https://www.worldometers.info/coronavirus/country/indonesia/
# https://corona.jakarta.go.id/id/data-pemantauan
# https://kawalcovid19.id/
# https://covid19.go.id/peta-sebaran

url <- "https://www.worldometers.info/coronavirus/country/indonesia/"
html <- read_html(url)
count <- html_text(html_nodes(html, ".maincounter-number"), trim=T)

con <- dbConnect(
  dbDriver("PostgreSQL"),
  dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"),
  host = Sys.getenv("ELEPHANT_SQL_HOST"),
  port = 5432,
  user = Sys.getenv("ELEPHANT_SQL_USER"),
  password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

if(!dbExistsTable(con, "covid")) {
  covid <- data.frame(no=integer(), cases=character(), deaths=character(), recovered=character())
  dbCreateTable(con, "covid", covid)
} 

covid <- dbReadTable(con, "covid")
rows <- nrow(covid)

newcovid <- data.frame(no = rows + 1, cases = count[1], deaths = count[2], recovered = count[3])
dbWriteTable(con = con, name = "covid", value = newcovid, append = TRUE, row.names = FALSE, overwrite=FALSE)

on.exit(dbDisconnect(con)) 


