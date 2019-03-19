
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github("mkearney/rtweet")


library(rtweet)
library(dplyr)
library(lubridate)
library(plyr)
library(ggplot2)
library(tidyr)
library(roperators)


migren_tweets <- search_tweets(
  q="migren", n=18000 ,retryonratelimit = TRUE, include_rts = FALSE
)

migren_df <- as.data.frame(migo)

migren_triki <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")%>%
  arrange(migren_triki$created_at)
  
migren_df2 <- as.data.frame(migren_tweets)
  
migren_truc <- migren_df2%>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df2$lang == "tr")%>%
  arrange(migren_truc$created_at)

migren_truc$created_at <- round_date(migren_truc$created_at, "hour", week_start = getOption("lubridate.week.start",7))

migren_truc$date <- as.Date(migren_truc$created_at)
migren_truc$time <- format(migren_truc$created_at, "%H")
migren_truc$day <- wday(migren_truc$date,label = TRUE)

migren <- rbind(migren, migren_truc)


migren_time = data.frame(migren$day, migren$time)

migren_time %>%
  group_by(migren.day, migren.time)
 
sum_table <- as.data.frame(table(migren_time$migren.day,migren_time$migren.time))
  
sum_table <- sum_table %>% 
  arrange(Var1)


ist <- sum(migren$location %s/% 'stanbul') 
ank <- sum(migren$location %s/% 'Ankara')
izm <- sum(migren$location %s/% 'zmir')
bur <- sum(migren$location %s/% 'Bursa')



cities <- data.frame("Cities" = c("Ýstanbul","Ankara", "Ýzmir", "Bursa", "Diðer"), 
                     "Frequency" = c(ist, ank, izm, bur, dim(migren)[1] - (ist+ank+izm+bur)))

cities$Perc <- cities$Frequency / sum(cities$Frequency)*100


ggplot(data = cities)+
  aes(x=Cities, y = Perc)+
  geom_bar(stat="identity",fill="light blue")+
  theme_classic()+
  labs(title = "Þehirlere göre atýlan tweetler")+
  xlab("Þehirler")+
  ylab("Yüzdeler")


x <- data.frame(matrix(,nrow = 24, ncol = 9))
coln <- c("saat", "Pzt", "Sal", "Car", "Per", "Cum", "Cmt", "Paz", "Ort")
colnames(x) <- coln
x$saat <- c(0:23)
x[,(c("Paz", "Sal", "Car", "Per", "Cum", "Cmt", "Pzt", "Ort"))]=t(ldply(split(sum.table$Freq, sum.table$day))[,-1])

x$hici <- with(x[,2:6], rowMeans(x[,2:6]))
x$hsonu <- with(x[,7:8], rowMeans(x[,7:8]))




  
  
 
  


  
                     