
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github("mkearney/rtweet")


library(rtweet)
library(dplyr)
library(lubridate)
library(chron)
library(plyr)
library(stringr)
library(roperators)
library(ggplot2)
library(tidyr)
library(scales)

migo <- search_tweets(
  q="migren", n=18000 ,retryonratelimit = TRUE, include_rts = FALSE
)

migren_df <- as.data.frame(migo)

migren_triki <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")
  
  

migren_triki$created_at <- round_date(migren_triki$created_at, "hour", week_start = getOption("lubridate.week.start",7))

migren_triki$date <- as.Date(migren_triki$created_at)
migren_triki$time <- format(migren_triki$created_at, "%H")
migren_triki$day <- wday(migren_triki$date,label = TRUE)



day_freq <- count(migren_tr,'day')
time_freq <- count(migren_tr, 'time')
date_freq <- count(migren_tr, 'date')

ist <- sum(migren_tr$location %s/% 'Ýstanbul') 
ank <- sum(migren_tr$location %s/% 'Ankara')
izm <- sum(migren_tr$location %s/% 'Ýzmir')
bur <- sum(migren_tr$location %s/% 'Bursa')

cities <- data.frame("Cities" = c("Ýstanbul","Ankara", "Ýzmir", "Bursa", "Diðer"), 
                     "Frequency" = c(ist, ank, izm, bur, 1117 - (ist+ank+izm+bur)))

cities$Perc <- cities$Frequency / sum(cities$Frequency)*100


ggplot(data = cities)+
  aes(x=Cities, y = Perc)+
  geom_bar(stat="identity",fill="light blue")+
  theme(panel.background = element_rect(fill = "white"))+
  labs(title = "Þehirlere göre atýlan tweetler")+
  xlab("Þehirler")+
  ylab("Yüzdeler")
  


  
                     