# Twitter Duygu Analizi

## Projenin Amacı

Gelişen teknolojiyle birlikte ortaya çıkan sosyal medya araçları farklı disiplerden araştırmacılara, çalışmaları için anlık ve büyük 
boyutta veri imkanı sunmaktadır. Biz bu çalışmamız da, Türkiye’de yaklaşık olarak 7 milyon kişiyi hem fiziksel hem de
ruhsal olarak etkiliyen migren rahatsızlığının Twitter’da Türkçe mesajlardan elde edilen veriler doğrultusunda duygu analizini yapmayı 
planlamaktayız.Çalışmamızda özellikle, Twitter mesajlarında, migren rahatsızlığının üç temel karekteristiği 
olan, frekans, süre ve şiddetini belirtmek için Türkçe Twitter kullanıcıların hangi kelimelerin kullandığı, 
bu mesajları günün hangi saatinde, haftanın hangi gününde,
ve yılın hangi ayında daha çok kullanıldığı üzerine çıkarımlar yapmayı ummaktayız.
Bu çıkarımları yapabilmek için de istatistiksel veri görselleştirme araçlarını kullanmayı planlanmaktayız. 
Son olarak, elde ettiğimiz bulguları migren hastalarının yaşam kalitesinin artması 
için başağrısı uzmanları ile paylaşmayı planlamaktayız.

## Kurulum
Kullanacağımız paketleri kurmamız gerekiyor: 
```R
## rtweet, dplyr ve lubridate paketlerinin kurulumu
install.packages("rtweet")
install.packages("dplyr")
install.packages("lubridate")

## paketlerin yüklenmesi
library(rtweet)
library(dplyr)
library(lubridate)
```

## Kullanım
rtweet paketi Twitter developer hesabına gerek kalmadan veri çekmemize yardımcı oluyor. Tek gereken Twitter hesabı(kullanıcı adı ve şifre). 

## Migren Kelimesi Geçen Tweetleri Çekmek
```R
## search_tweets() fonksiyonuyla migren kelimesi geçen tweetleri migo değişkenine atadım. 
migo <- search_tweets(
  q="migren", n=18000 ,retryonratelimit = TRUE, include_rts = FALSE
)
```
```R
## listeyi data frame olarak kaydettim.
migren_df <- as.data.frame(migo)
```
## Türkçe Tweetleri Çekme

Türkçe tweetleri toplamak ve data frame'in gereken sütunlarını görmek için:

```R
## migren_df'den sadece status_id, created_at, text ve location sütunlarını ve Türkçe tweetleri alacağım
migren_tr <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")%>%
  arrange(migren_tr$created_at)
```
## date, time ve day Sütunlarını Oluşturma
```R
## created_at sütununda veri tarih ve saat şeklinde. Saati yuvarlayıp created_at sütununa kaydettik
migren_tr$created_at <- round_date(migren_tr$created_at, "hour", week_start = getOption("lubridate.week.start",7))

## date, time ve day sütunlarını oluşturduk
migren_tr$date <- as.Date(migren_tr$created_at)
migren_tr$time <- format(migren_tr$created_at, "%H")
migren_tr$day <- wday(migren_tr$date,label = TRUE)
```
## Gün, saat ve tarihlerin sıklıkları
```R
day_freq <- count(migren_tr,'day')
time_freq <- count(migren_tr, 'time')
date_freq <- count(migren_tr, 'date')
```
```R
## Hangi şehirlerden ne kadar tweet atılmış
ist <- sum(migren_tr$location %s/% 'İstanbul') 
ank <- sum(migren_tr$location %s/% 'Ankara')
izm <- sum(migren_tr$location %s/% 'İzmir')
bur <- sum(migren_tr$location %s/% 'Bursa')
```

```R
##cities data frame oluşturup sıklıklarını ve yüzdelerini yazıyoruz.
cities <- data.frame("Cities" = c("İstanbul","Ankara", "İzmir", "Bursa", "Diğer"), 
                     "Frequency" = c(ist, ank, izm, bur, 1117 - (ist+ank+izm+bur)))

cities$perc <- cities$Frequency / sum(cities$Frequency)*100
```
## Hangi şehirde ne kadar tweet atılmış
```R
ggplot(data = cities)+
  aes(x=Cities, y = perc)+
  geom_bar(stat="identity")+
  theme(panel.background = element_rect(fill = "white"))+
  labs(title = "Şehirlere göre atılan tweetler")+
  xlab("Şehirler")+
  ylab("Yüzdeler")
```
