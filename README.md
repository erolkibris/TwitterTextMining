# Twitter Duygu Analizi

## Projenin Amacı

Gelişen teknolojiyle birlikte ortaya çıkan sosyal medya araçları farklı disiplerden araştırmacılara, çalışmaları için anlık ve büyük 
boyutta veri imkanı sunmaktadır. Biz bu çalışmamız da, Türkiye’de yaklaşık olarak 7 milyon kişiyi hem fiziksel hem de
ruhsal olarak etkiliyen migren rahatsızlığının Twitter’da Türkçe mesajlardan elde edilen veriler doğrultusunda duygu analizini yapmayı 
planlamaktayız. Çalışmamızda özellikle, Twitter mesajlarında, migren rahatsızlığının üç temel karekteristiği 
olan, frekansını, süresini ve şiddetini belirtmek için Türkçe Twitter kullanıcıların hangi kelimelerin kullandığı, 
bu mesajları günün hangi saatinde, haftanın hangi gününde,
ve yılın hangi ayında daha çok kullanıldığı üzerine çıkarımlar yapmayı ummaktayız.
Bu çıkarımları yapabilmek için de istatistiksel veri görselleştirme araçlarını kullanmayı planlanmaktayız. 
Son olarak, elde ettiğimiz bulguları migren hastalarının yaşam kalitesinin artması 
için baş ağrısı uzmanları ile paylaşmayı planlamaktayız.

## Kurulum
Kullanacağımız paketleri kurmamız gerekiyor: 
```R
## rtweet Twitter'dan veri çekmek için 
## dplyr veri düzenlemesi için
## lubridate tarih ve saat değişkenleri için
## ggplot2 grafik çizimi için

## paketlerin kurulumu
install.packages("rtweet")
install.packages("dplyr")
install.packages("lubridate")
install.packages("ggplot2")
install.packages("plyr")

## paketlerin aktivasyonu
library(rtweet)
library(dplyr)
library(lubridate)
library(ggplot2)
library(plyr)

```

## Kullanım
R rtweet paketi Twitter developer hesabına gerek kalmadan veri çekmemize yardımcı oluyor. Tek gereken Twitter hesabı (kullanıcı adı ve şifre). 

## Migren Kelimesi Geçen Tweetleri Çekmek
search_tweets fonksiyonu programı çalıştırdıktan 10 gün öncesine kadar veri toplar.
```R
## search_tweets() fonksiyonuyla migren kelimesi geçen tweetleri migo değişkenine atadım. 
migo <- search_tweets(
  q="migren", n=18000 ,retryonratelimit = TRUE, include_rts = FALSE
)
## q değişkeni istediğimiz kelimenin geçtiği tweetleri, 
## n değişkeni tweet sayısını belirtir.
```
```R
## listeyi data frame olarak kaydettim.
migren_df <- as.data.frame(migo)
```

## Veriyi Görmek İçin
```R
## Veriyi indirmeden aşağıdaki kodlarla veriyi görebilirsiniz.
githubURL <- "https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/migren_tr.RData"
load(url(githubURL))
head(df)
```
## Türkçe Tweetleri Çekme

Türkçe tweetleri toplamak ve data frame'in gereken sütunlarını görmek için:

```R
## migren_df'den sadece status_id, created_at, text ve location sütunlarını ve Türkçe tweetleri alacağım
migren_tr <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")%>%
  arrange(migren_tr$created_at) 
  ## arrange fonksiyonu created_at sütununu artan şekilde sıralıyor
```
## Verileri Birleştirmek
Daha fazla veriyle çalışmak için farklı zamanlarda veriler çekmek gerekti. Bu yüzden çekilen verileri birleştirmek için 

```R
migren <- rbind(migren_tr, migren_triki[124:1040,])
```

## date, time ve day Sütunlarını Oluşturma
```R
## created_at sütununda veri tarih ve saat şeklinde birleşik. 
## Saati yuvarlayıp created_at sütununa kaydettik.

migren_tr$created_at <- round_date(migren_tr$created_at, "hour", week_start = getOption("lubridate.week.start",7))

## Tarih, saat ve haftanın hangi günü olduğunu dair yeni sütunları oluşturduk.

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

cities$Perc <- cities$Frequency / sum(cities$Frequency)*100
cities$Perc
```
Twitter'da konum belirtme isteğe bağlıdır. Twitter kullanıcıların çoğu büyük şehirlerde yaşayanlardır. Migrenle ilgili atılan tweetlerin konuma göre yüzdesi aşağıdaki gibidir. Diğer kısmında yeri belirtmemiş ve anlamlı yer belirtmemiş kişilerdir.

```R
   Cities Frequency      Perc
1 İstanbul       134 11.996419
2   Ankara        41  3.670546
3    İzmir        47  4.207699
4    Bursa        22  1.969561
5    Diğer       873 78.155774
```
## Hangi şehirde ne kadar tweet atılmış?
```R
ggplot(data = cities)+
  aes(x=Cities, y = Perc)+
  geom_bar(stat="identity",fill="light blue")+
  theme(panel.background = element_rect(fill = "white"))+
  labs(title = "Şehirlere göre atılan tweetler")+
  xlab("Şehirler")+
  ylab("Yüzdeler")
```
![Şehirler](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/sehir-tweet.jpeg)


## Gün-Tweet Grafiği
Bu grafiği ShinyApp olarak yapacağız. Öncelikle gerekli olan verileri data frame haline getiriyoruz. Data frame saatleri, haftanın günlerini, genel ortalamayı, hafta içi ve hafta sonu atılan tweetlerin sayısını içeriyor.

```R
#boş bir data frame oluşturduk
x <- data.frame(matrix(,nrow = 24, ncol = 9))
#sütun adlarını verdik
coln <- c("saat", "Pzt", "Sal", "Car", "Per", "Cum", "Cmt", "Paz", "Ort")
colnames(x) <- coln
#saat sütununa saatleri ekledik
x$saat <- c(0:23)
#Ort sütununa time_day tablosundan Mean sütununu ekledik
x$Ort <- time_day$Mean
#sum_table tablosundan gerekli olan verileri çekiyoruz
x[,(c("Paz", "Sal", "Car", "Per", "Cum", "Cmt", "Pzt"))]=t(ldply(split(sum_table$Freq, sum_table$Var1))[,-1])
#hici ve hsonu sütunlarını da tabloya ekliyoruz.
x$hici <- with(x[,2:6], rowSums(x[,2:6]))
x$hsonu <- with(x[,7:8], rowSums(x[,7:8]))
```
```R
head(x)
  saat Pzt Sal Car Per Cum Cmt Paz      Ort hici hsonu
1    0  17   5  12   3   7   7   5 8.000000   44    12
2    1   3   5   4   5   3   3   5 4.000000   20     8
3    2   3   6   4   5   3   0   1 3.142857   21     1
4    3   2   0   2   5   0   2   1 1.714286    9     3
5    4   2   2   5   1   2   5   0 2.428571   12     5
6    5   4   4   3   9   2   7   0 4.142857   22     7
```
