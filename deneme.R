
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
library(stopwords)
library(wordcloud)
library(tidytext)
library(stringr)


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
colnames(sum_table) <- c("day", "time", "Freq")  
sum_table <- sum_table %>% 
  arrange(day)

sum_table <- as.data.frame(table(migren$day,migren$time))
colnames(sum_table) <- c("day", "time", "Freq")

sum_table <- sum_table %>%
  arrange(day)

sum_table2 <- sum_table %>%
  group_by(time)%>%
  summarise(Freq=round(mean(Freq),4)) 

sum_table2$day <- "Ort"

ist <- sum(migren$location %s/% 'stanbul') 
ank <- sum(migren$location %s/% 'Ankara')
izm <- sum(migren$location %s/% 'zmir')
bur <- sum(migren$location %s/% 'Bursa')



cities <- data.frame("Cities" = c("Ýstanbul","Ankara", "Ýzmir", "Bursa", "Diðer"), 
                     "Frequency" = c(ist, ank, izm, bur, dim(migren)[1] - (ist+ank+izm+bur)))

cities$Perc <- round(cities$Frequency / sum(cities$Frequency)*100, 4)


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

###########################################################

data(stop_words)
tidy_migren <- migren%>%
  select(text)%>%
  unnest_tokens(word, text)

kelime <- tidy_migren%>%
  count(word, sort = T)
  
with(wordcloud(word, n, max.words = 100))
  
stoptr <- stopwords::stopwords("tr",source = "stopwords-iso")  

bigrams <- migren%>%
  select(text)%>%
  mutate(text = str_replace_all(text, " ", " ")) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

bigrams_count <- bigrams %>%
  group_by(bigram) %>%
  count(, sort = T)

sum(tidy_migren %s/% 'hava')

tidy_migren[grep("hava", tidy_migren)]

bigrams_seperated <- bigrams%>%
  separate(bigram, c("word1", "word2"), sep = " ")

bi_hava <- bigrams_seperated %>%
  filter(str_detect(word1, "hava") | str_detect(word2,"hava"))%>%
  count(word1, word2, sort = TRUE)

bi_sure <- bigrams_seperated%>%
  filter(str_detect(word1, "saat") | str_detect(word2, "saat") |
           str_detect(word1, "dakik") | str_detect(word2, "dakik") | 
           str_detect(word1, "dk") | str_detect(word2, "dk") |
           str_detect(word1, "gün") | str_detect(word2, "gün")|
           str_detect(word1, "hafta") | str_detect(word2, "hafta"))%>%
  count(word1, word2, sort = TRUE)

bi_disease <- bigrams_seperated%>%
  filter(str_detect(word1, "stres") | str_detect(word2, "stres")|
           str_detect(word1, "diþ") | str_detect(word2, "diþ") | 
           str_detect(word1, "kalp") | str_detect(word2, "kalp")|
           str_detect(word1, "depresyon") | str_detect(word2, "depresyon")|
           str_detect(word1, "uyk") | str_detect(word2, "uyk"))%>%
  count(word1, word2, sort = TRUE)

bi_freq <- bigrams_seperated%>%
  filter(str_detect(word1, "çok") | str_detect(word2, "çok") |
           str_detect(word1, "kere") | str_detect(word2, "kere") | 
           str_detect(word1, "kez") | str_detect(word2, "kez") |
           str_detect(word1, "sefer") | str_detect(word2, "sefer"))%>%
  count(word1, word2, sort = TRUE)

bi_volume <- bigrams_seperated%>%
  filter(str_detect(word1, "kötü") | str_detect(word2, "kötü") |
           str_detect(word1, "ölüm") | str_detect(word2, "ölüm") | 
           str_detect(word1, "intihar") | str_detect(word2, "intihar")|
           str_detect(word1, "þiddet") | str_detect(word2, "þiddet")|
           str_detect(word1, "çýldýrmak")| str_detect(word2, "çýldýrmak"))%>%
  count(word1, word2, sort = TRUE)

bi_effect <- bigrams_seperated%>%
  filter(  str_detect(word1, "okul") | str_detect(word2, "okul") | 
           str_detect(word1, "çalýþ") | str_detect(word2, "çalýþ") |
           str_detect(word1, "sýnav") | str_detect(word2, "sýnav")|
           str_detect(word1, "arkadaþ") | str_detect(word2, "arkadaþ")|
           str_detect(word1, "dost") | str_detect(word2, "dost")|
           str_detect(word1, "aile") | str_detect(word2, "aile")|
           str_detect(word1, "anne") | str_detect(word2, "anne")|
           str_detect(word1, "baba") | str_detect(word2, "baba")|
           str_detect(word1, "çocuk") | str_detect(word2, "çocuk")|
           str_detect(word1, "kardeþ") | str_detect(word2, "kardeþ")|
           str_detect(word1, "sevgili") | str_detect(word2, "sevgili"))%>%
  count(word1, word2, sort = TRUE)

  