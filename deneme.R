
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github("mkearney/rtweet")


library(rtweet)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)

migo <- search_tweets(
  q="migren", n=18000 ,retryonratelimit = TRUE, include_rts = FALSE
)



