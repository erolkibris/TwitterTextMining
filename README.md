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
##search_tweets() fonksiyonuyla migren kelimesi geçen tweetleri migo değişkenine atadım. 
migo <- search_tweets(
  q="migren", n=18000 ,retryonratelimit = TRUE, include_rts = FALSE
)
```

