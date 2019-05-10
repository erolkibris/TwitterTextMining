
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
library(tm)


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
  summarize(Freq=round(mean(Freq),4)) 

sum_table2$day <- "Ort"

sum.table <- rbind(sum_table, sum_table2)

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


tidy_migren <- migren%>%
  select(text)%>%
  unnest_tokens(word, text)

#Wordcloud kodu

kelime <- tidy_migren%>%
  count(word, sort = T)%>%
  with(wordcloud(word, n, max.words = 200,random.order = FALSE,colors=brewer.pal(8, "Dark2")))
  
stoptr <- stopwords::stopwords("tr",source = "stopwords-iso")  

bigrams <- migren%>%
  select(text)%>%
  mutate(text = str_replace_all(text, " ", " ")) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)

bigrams_count <- bigrams %>%
  group_by(bigram) %>%
  count(, sort = T)

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

bi_sure_dakika <- bi_sure%>%
  filter(str_detect(word1, "dakika") | str_detect(word2, "dakika"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_sure_saat <- bi_sure%>%
  filter(str_detect(word1, "saat") | str_detect(word2, "saat"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_sure_gun <- bi_sure%>%
  filter(str_detect(word1, "gün") | str_detect(word2, "gün"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_sure_hafta <- bi_sure%>%
  filter(str_detect(word1, "hafta") | str_detect(word2, "hafta"))%>%
  arrange(word1)%>%
  top_n(10,n)  

data_dakika = tibble('text' = c('3', '5','15','20','45'),
                     'count' = c(2,4,2,1,1))  

ggplot(data_dakika, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Dakika")

data_saat = tibble('text' = c('1','2','3','5','7','24'),
                   'count' = c(4,8,6,3,3,7))  

ggplot(data_saat, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Saat")

data_gun = tibble('text' = c('1','2','3','4','Her Gün','Bugün'),
                  'count' = c(24,14,10,5,6,15))
ggplot(data_gun, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Gün")


data_hafta = tibble('text' = c('1 Hafta', '2 Hafta'),
                    'count' = c(10,3))

ggplot(data_hafta, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Hafta")

data_sure = tibble('zaman' = c(rep('Dakika',5), rep('Saat',6), rep('Gün',5),rep('Hafta',2)),
                   'text'= c('3','5','15','20','45','1','2','3','5','7','24','1','2','3','4','Bugün',
                             'Bir hafta','Ýki hafta'), 
                   'count'=c(2,4,2,1,1,4,8,6,3,3,7,24,14,10,5,15,10,3))


bi_disease_dis <- bi_disease%>%
  filter(str_detect(word1, "diþ") | str_detect(word2, "diþ"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_disease_stres <- bi_disease%>%
  filter(str_detect(word1, "stres") | str_detect(word2, "stres"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_disease_kalp <- bi_disease%>%
  filter(str_detect(word1, "kalp") | str_detect(word2, "kalp"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_disease_uyku <- bi_disease%>%
  filter(str_detect(word1, "uyk") | str_detect(word2, "uyk"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_disease_depr <- bi_disease%>%
  filter(str_detect(word1, "depresyon") | str_detect(word2, "depresyon"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_freq_cok <- bi_freq%>%
  filter(str_detect(word1, "çok") | str_detect(word2, "çok"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_freq_kere <- bi_freq%>%
  filter(str_detect(word1, "kere") | str_detect(word2, "kere"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_freq_kez <- bi_freq%>%
  filter(str_detect(word1, "kez") | str_detect(word2, "kez"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_freq_sefer <- bi_freq%>%
  filter(str_detect(word1, "sefer") | str_detect(word2, "sefer"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_kotu <- bi_volume%>%
  filter(str_detect(word1, "kötü") | str_detect(word2, "kötü"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_olum <- bi_volume%>%
  filter(str_detect(word1, "ölüm") | str_detect(word2, "ölüm"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_intihar <- bi_volume%>%
  filter(str_detect(word1, "intihar") | str_detect(word2, "intihar"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_siddet <- bi_volume%>%
  filter(str_detect(word1, "þiddet") | str_detect(word2, "þiddet"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_effect_sinav <- bi_effect%>%
  filter(str_detect(word1, "sýnav") | str_detect(word2, "sýnav"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_calis <- bi_effect%>%
  filter(str_detect(word1, "çalýþ") | str_detect(word2, "çalýþ"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_dost <- bi_effect%>%
  filter(str_detect(word1, "dost") | str_detect(word2, "dost"))%>%
  arrange(word1)%>%
  top_n(10,n)

bi_volume_baba <- bi_effect%>%
  filter(str_detect(word1, "baba") | str_detect(word2, "baba"))%>%
  arrange(word1)%>%
  top_n(10,n)

data_dis = tibble('text' = c('aðrý', 'sýkma'),
                  'count' = c(15,9))
ggplot(data_dis, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren-Hastalýk Ýliþkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Diþ")

data_uyku = tibble('text' = c('aðrý', 'düzen'), 
                   'count' = c(3,4))

ggplot(data_uyku, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren-Hastalýk Ýliþkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Uyku")

data_kalp = tibble('text' = c('aðrý', 'hasta'), 
                   'count' = c(4,3))

ggplot(data_kalp, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren-Hastalýk Ýliþkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Kalp")

data_cok = tibble('text' = c('zor', 'kötü','güzel','az','daha'), 
                   'count' = c(13,10,8,5,14))

ggplot(data_cok, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren-Sýklýk Ýliþkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Çok")

data_kez = tibble('text' = c('ilk', 'iki'), 
                   'count' = c(4,2))

ggplot(data_kez, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren-Sýklýk Ýliþkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Kez")

data_kotu = tibble('text' = c('cok', 'biri','bir','daha'), 
                   'count' = c(12,9,8,4))

ggplot(data_kotu, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren-Þiddet Ýliþkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Kötü")

data_hastalik = tibble('hastalik' = c(rep('Diþ',2), rep('Kalp',2), rep('Uyku',2)),
                   'text'= c('Aðrý', 'Sýkma','Aðrý', 'Hasta','Aðrý','Düzen'), 
                   'count'=c(15,9,4,3,3,4))

migren_text <- migren%>%
  select(text)

emotions <- get_nrc_sentiment(migren_text$text, language="turkish")
emo_bar = colSums(emotions)
emo_sum = data.frame(count = emo_bar, emotion = names(emo_bar))
emo_sum$emotion = factor(emo_sum$emotion, levels = emo_sum$emotion[order(emo_sum$count, decreasing = TRUE)])

ggplot(emo_sum, aes(x=emotion, y= count))+
  geom_bar(stat = "identity")

wordcloud_tweet = c(
  paste(migren_text$text[emotions$anger > 0], collapse=" "),
  paste(migren_text$text[emotions$anticipation > 0], collapse=" "),
  paste(migren_text$text[emotions$disgust > 0], collapse=" "),
  paste(migren_text$text[emotions$fear > 0], collapse=" "),
  paste(migren_text$text[emotions$joy > 0], collapse=" "),
  paste(migren_text$text[emotions$sadness > 0], collapse=" "),
  paste(migren_text$text[emotions$surprise > 0], collapse=" "),
  paste(migren_text$text[emotions$trust > 0], collapse=" ")
)

# create corpus
corpus = VCorpus(VectorSource(wordcloud_tweet))

# remove punctuation, convert every word in lower case and remove stop words

corpus = tm_map(corpus, PlainTextDocument)
corpus = tm_map(corpus, removePunctuation)
corpus = tm_map(corpus, removeWords, c(stopwords("tr", source = "stopwords-iso")))
corpus = tm_map(corpus, stemDocument)

# create document term matrix

tdm = TermDocumentMatrix(corpus)

# convert as matrix
tdm = as.matrix(tdm)
tdmnew <- tdm[nchar(rownames(tdm)) < 11,]

# column name binding
colnames(tdm) = c('anger', 'anticipation', 'disgust', 'fear', 'joy', 'sadness', 'surprise', 'trust')
colnames(tdmnew) <- colnames(tdm)
comparison.cloud(tdmnew, random.order=FALSE,
                 colors = c("#00B2FF", "red", "#FF0099", "#6600CC", "green", "orange", "blue", "brown"),
                 title.size=1, max.words=250, scale=c(2.5,0.4),rot.per=0.4)

