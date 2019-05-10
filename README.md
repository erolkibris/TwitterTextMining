# Twitter Duygu Analizi / Twitter Sentiment Analysis

[English document](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/READMEENG.md)


## Projenin Amacı

Gelişen teknolojiyle birlikte ortaya çıkan sosyal medya araçları farklı disiplerden araştırmacılara, çalışmaları için anlık ve büyük boyutta veri imkanı sunmaktadır. Biz bu çalışmamız da, Türkiye’de yaklaşık olarak 7 milyon kişiyi hem fiziksel hem de ruhsal olarak etkileyen migren rahatsızlığının Twitter’da Türkçe mesajlardan elde edilen veriler doğrultusunda duygu analizini yapmayı planlamaktayız. Çalışmamızda özellikle, Twitter mesajlarında, migren rahatsızlığının üç temel karekteristiği olan, frekansını, süresini ve şiddetini belirtmek için Türkçe Twitter kullanıcıların hangi kelimeleri kullandığı, bu mesajları haftanın hangi gününde ve günün hangi saatinde daha çok kullandığı üzerine çıkarımlar yapmayı ummaktayız. Bu çıkarımları yapabilmek için de istatistiksel veri görselleştirme araçlarını kullanmayı planlanmaktayız. Son olarak, migren hastalarının yaşam kalitesinin artmasına katkıda bulunmak için elde ettiğimiz bulguları için baş ağrısı uzmanları ile paylaşmayı planlamaktayız.

## Kullanım
R programı, Twitter developer hesabına gerek kalmadan, Twitter’dan veri çekmemize imkan veriyor. Bu işlemi yapabilmemiz için öncelikli olarak bir Twitter hesabımızın olması gereklidir.

## Gerekli R Paketleri
İşlemlerimizi yapabilmemiz için öncelikli olarak kullanacağımız R paketlerini indirmemiz ve kurmamız gerekiyor. İlk etapta R rtweet paketine, Twitter’dan veri çekebilmemiz için ihtiyacımız var. Aşağıda listelenen diğer paketler ise ileriki aşamada sırasıyla ihtiyacımız olan ve kullandığımız paketler.
```R
## R rtweet Twitter'dan veri çekmek için 
## R dplyr veri düzenlemesi için
## R roperators metinde bir kelimenin belirli uzantılarını aramak için
## R ggplot2 grafik çizimi için gerekli
## R lubridate tarih ve saat değişkenleri üzerinde değişiklik yapabilmek için
## R plyr veri düzenlemesi için
## R shiny paketi uygulama için gerekli
## R reshape2 veriyi görselleştirmek için düzenlemede gerekli
## R tidytext paketi metin madenciliği için gerekli
## R tidyr paketi kelime analizinde düzenleme için gerekli
## R stringr paketi istenilen kelimeleri bulmak için gerekli
## R wordcloud paketi kelime bulutu yapmak için gerekli

## Paketlerin kurulumu

install.packages("rtweet")
install.packages("dplyr")
install.packages("roperators")
install.packages("ggplot2")
install.packages("lubridate")
install.packages("plyr")
install.packages("shiny")
install.packages("reshape2")
install.packages("tidytext")
install.packages("tidyr")
install.packages("stringr")
install.packages("wordcloud)

## Paketlerin aktivasyonu

library(rtweet)
library(dplyr)
library(roperators)
library(ggplot2)
library(lubridate)
library(plyr)
library(shiny)
library(reshape2)
library(tidyr)
library(tidytext)
library(stringr)
library(wordcloud)

```

## Migren Kelimesi Geçen Tweetleri Çekmek

R rtweet paketindeki search_tweets fonksiyonu, Twitter’dan 10 gün öncesine kadar veri çekebilmemizi sağlar. Biz 18 Şubat  2019-19 Mart 2019 tarihleri arasında, her 10 günde bir, içinde migren kelimesi geçen Türkçe tweetleri toplayarak bir veri tabanı oluşturduk.

```R
## R search_tweets fonksiyonuyla migren kelimesi geçen tweetleri migo R objesine atadım. 

migo <- search_tweets(
  q="migren", n=18000, retryonratelimit = TRUE, include_rts = FALSE
)

## Burada, q argumanı tweetlerde arayacağımız kelimeyi, 
## n argumanı ise istenilen tweet sayısını belirtir.

## listeyi data frame olarak kaydelim:

migren_df <- as.data.frame(migo)
```

## Türkçe Tweetleri Çekme

Elde ettiğimiz ham veride, farklı dillerde de “migren” kelimesinin yer aldığını farkettik. Bu sebeple, sadece dili Türkçe olan tweetleri çekmek ve diğer gerekli bir takım sütunları (mesajın kimlik numarasını, mesajın ne zaman atıldığını, mesajın nereden atıldığını ve mesajın kendisini) çekmek için aşağıdaki kodu kullandık ve Github’da migren ismiyle sakladık.
```R
## Ham veri olan migren_df'den sadece status_id, created_at, text ve location 
## sütunlarını ve Türkçe tweetleri alalım

migren <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")%>%
  arrange(migren$created_at) 

## filter fonksiyonu, Twitter mesajlarini Turkce olanlarini seciyor
## arrange fonksiyonu, veriyi created_at sütununa göre, yani kronolojik 
## olarak artan şekilde sıralıyor.
```
## Hangi şehirde ne kadar tweet atılmış?
Twitter'da yaşanılan yere ait şehir bilgisi verme, yani konum belirtme, isteğe bağlıdır. Bu sebeple, tüm kullanıcılara ait konum bilgisi elde etmemiz mükün olamazken, genel olarak bilinen yargı ise Twitter kullanıcıların çoğunun büyük şehirlerde yaşayan genç ve eğitimli insanlar olduğudur. Bu nedenle, biz de, Türkiye’de 4 büyük şehirden migren ile ilgili ne kadar Tweet atılmış görelim istedik:

```R
## Hangi şehirlerden ne kadar tweet atılmış
ist <- sum(migren$location %s/% 'stanbul') 
ank <- sum(migren$location %s/% 'Ankara')
izm <- sum(migren$location %s/% 'zmir')
bur <- sum(migren$location %s/% 'Bursa')
```
```R
##cities data frame oluşturup sıklıklarını ve yüzdelerini yazıyoruz.
cities <- data.frame("Cities" = c("İstanbul","Ankara", "İzmir", "Bursa", "Diğer"), 
                     "Frequency" = c(ist, ank, izm, bur, dim(migren)[1] - (ist+ank+izm+bur)))

cities$Perc <- round(cities$Frequency / sum(cities$Frequency)*100,4)

```

Migrenle ilgili atılan Tweetlerin konumlara göre yüzdesi aşağıdaki gibidir. “Diğer” kısmında ise Twitter hesabında yeri belirtilmemiş veya anlamlı yer belirtilmemiş kullanıcılar yer almaktadır.

```R
head(cities)

   Cities  Frequency   Perc
1 İstanbul       397 13.6426
2   Ankara       122  4.1924
3    İzmir       137  4.7079
4    Bursa        51  1.7526
5    Diğer      2203 75.7045
```
```R
#Veriyi görselleştirmek için
ggplot(data = cities)+
  aes(x=Cities, y = Perc)+
  geom_bar(stat="identity",fill="light blue")+
  theme(panel.background = element_rect(fill = "white"))+
  labs(title = "Şehirlere göre atılan tweetler")+
  xlab("Şehirler")+
  ylab("Yüzdeler")
```
![Şehirler](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/sehir-tweet.jpeg)

## Saat-Gün-Tweet Sayısı Verisi ve Grafiği

Twitter, kullanıcılarının yaşadıkları olaylara anlık olarak tepki verdikleri bir ortam olarak bilindiği için, biz de, migren hastalarının, başları ağrıdığında, anlık olarak tepkilerini Twitter’da yansıttıklarını varsayıyoruz. Bu sebeple, migren rahatsızlığı yaşayan Twitter kullanıcılarının davranışlarını incelemek için, içinde migren geçen Türkçe Tweetlerin haftanın hangi günü, günün hangi saatinde atıldığına dair bir çizgi grafik çıkararak incelemek istedik. Fakat, elimizdeki ham veride, Tweetlerin atıldığı zamana dair sadece “created_at” değişkeni var. Aşağıdaki örnekte de görüleceği gibi burada, tarih ve saat birleşik olarak verilmiş.

```R
migren$created_at[1:10]

 [1] "2019-02-18 08:27:04 UTC" "2019-02-18 11:54:36 UTC" "2019-02-18 13:09:33 UTC"
 [4] "2019-02-18 13:21:51 UTC" "2019-02-18 13:39:16 UTC" "2019-02-18 13:55:46 UTC"
 [7] "2019-02-18 14:14:24 UTC" "2019-02-18 14:14:33 UTC" "2019-02-18 14:46:28 UTC"
[10] "2019-02-18 15:57:14 UTC"
```

Burada, R lubridate paketi bize, “created_at” değişkeninden öncelikle saatleri çekip ve yuvarlayıp, sonrasında da, tarih kısmından saati ve günü çıkarmamıza yardımcı oluyor.

```R
migren$created_at <- round_date(migren$created_at, "hour", week_start = getOption("lubridate.week.start",7))

## created_at sütununda veri tarih ve saat şeklinde birleşik. 
## Saati yuvarlayıp created_at sütununa kaydettik.

migren$date <- as.Date(migren$created_at)
migren$time <- format(migren$created_at, "%H")
migren$day <- wday(migren$date,label = TRUE)
```


Aşağıdaki örnekte de görüleceği üzere, artık verimizde, hem tarih, hem gün hem de saat ayrı ayrı mevcut.
```R
head(migren[,c("date","time", "day")],10)

       date   time day
1  2019-02-18   08 Pzt
2  2019-02-18   12 Pzt
3  2019-02-18   13 Pzt
4  2019-02-18   13 Pzt
5  2019-02-18   14 Pzt
6  2019-02-18   14 Pzt
7  2019-02-18   14 Pzt
8  2019-02-18   14 Pzt
9  2019-02-18   15 Pzt
10 2019-02-18   16 Pzt
```

Yukarıda bahsettiğimiz gibi, haftanın hangi gününde, saat kaçta, kaç tane tweet atıldığına dair bir çizgi grafiği elde etmek istiyoruz. Sonrasında, bu grafiği R Shiny uygulamasını kullanarak dinamik hale geritereceğiz. Bu sebeple, öncelikle, gerekli olan veriyi yani haftanın hangi gününde, hangi saatte kaç tane Tweet atıldığını çıkaralım. Bunun için de R dplyr paketinden faydalandık.

```R
sum_table <- as.data.frame(table(migren$day,migren$time))
colnames(sum_table) <- c("day", "time", "Freq")

sum_table <- sum_table %>%
   arrange(day)
```
```R
head(sum_table, 25)
   day  time Freq
1   Paz   00    8
2   Paz   01    7
3   Paz   02    2
4   Paz   03    3
5   Paz   04    1
6   Paz   05    2
7   Paz   06    6
8   Paz   07   11
9   Paz   08    9
10  Paz   09   11
11  Paz   10    7
12  Paz   11   14
13  Paz   12   11
14  Paz   13   10
15  Paz   14   11
16  Paz   15   14
17  Paz   16   14
18  Paz   17   17
19  Paz   18   25
20  Paz   19   25
21  Paz   20   31
22  Paz   21   37
23  Paz   22   33
24  Paz   23   16
25  Pzt   00   12
```
Saat bazında atılan Tweetlerin 7 gün üzerinden ortalamasını hesaplayıp, yeni bir veri seti oluşturduk.

```R
sum_table2 <- sum_table %>%
    group_by(time) %>%
    summarize(Freq=round(mean(Freq),4)) 
sum_table2$day <- "Ort"
 
sum.table <- rbind(sum_table,sum_table2)

  tail(sum.table,25)
```
```R
    day time    Freq
168 Cmt   23 16.0000
169 Ort   00 11.0000
170 Ort   01  6.1429
171 Ort   02  4.1429
172 Ort   03  2.2857
173 Ort   04  2.8571
174 Ort   05  6.0000
175 Ort   06  6.5714
176 Ort   07 13.0000
177 Ort   08 13.4286
178 Ort   09 17.4286
179 Ort   10 15.0000
180 Ort   11 15.0000
181 Ort   12 14.5714
182 Ort   13 16.2857
183 Ort   14 17.4286
184 Ort   15 18.2857
185 Ort   16 21.2857
186 Ort   17 21.7143
187 Ort   18 31.0000
188 Ort   19 29.8571
189 Ort   20 39.8571
190 Ort   21 43.5714
191 Ort   22 31.1429
192 Ort   23 17.8571
```
## Gün-Tweet Shiny Uygulaması

### Shiny için Veri Düzenlemesi

Yukarıda oluşturduğumuz veriyi R plyr paketinin de yardımıyla, R shiny uygulamasında kullanabilmek için tekrar düzenledik ve hafta içi hafta sonu atılan twetterin ortalmasını da yeni verimize ekledik (not: R dplyr ve plyr paketi aynı anda aktif olursa problem yaratabiliyor).

```R
x <- data.frame(matrix(,nrow = 24, ncol = 9))
coln <- c("saat", "Pzt", "Sal", "Car", "Per", "Cum", "Cmt", "Paz", "Ort")
colnames(x) <- coln
x$saat <- c(0:23)
x[,(c("Paz", "Sal", "Car", "Per", "Cum", "Cmt", "Pzt", "Ort"))]=t(ldply(split(sum.table$Freq, sum.table$day))[,-1])
x$hici <- with(x[,2:6], rowMeans(x[,2:6]))
x$hsonu <- with(x[,7:8], rowMeans(x[,7:8]))
```
```R
head(x)
saat Pzt Sal Car Per Cum Cmt Paz     Ort hici hsonu
1    0  17  12  15   6  10   9   8 11.0000 12.0   8.5
2    1   5   6   7   5   5   8   7  6.1429  5.6   7.5
3    2   4   6   6   5   5   1   2  4.1429  5.2   1.5
4    3   3   0   2   5   1   2   3  2.2857  2.2   2.5
5    4   2   3   6   1   2   5   1  2.8571  2.8   3.0
6    5   6   5   7  10   4   8   2  6.0000  6.4   5.0
```

### Shiny Uygulaması 
Migren hastalarının davranışlarını zaman üzerinden incelemek için, R shiny paketini kullanarak, dinamik grafikler elde ettik. R Shiny uygulamasının kodu 2 kısımdan oluşuyor: kullanıcı arayüzü, diğer bir ifadeyle ui kısmı ve server kısmı. ui kısmı kullanıcı seçimlerinin ve grafiğin göründüğü kısım, server ise arka planda çalışan grafiği çizdirmek için gerekli olan kısımdır.

```R
## R shiny paketi uygulama için gerekli
## R ggplot2 grafik için
## R reshape2 veriyi görselleştirmek için düzenlemede gerekli

library(shiny)
library(ggplot2)
library(reshape2)

ui <- fluidPage(
  title = "Gün-Tweet Sayısı,",
  titlePanel("Gün ve Saate Göre Atılan Tweet Sayısı"),
  sidebarLayout(
    sidebarPanel(
    #Onay kutucukları kullanıcıya gün seçimini sağlıyor
      checkboxGroupInput("gun", 
                         h1("Gunu seciniz."), 
                         choices = list("Pazartesi" = "Pzt", "Sali" = "Sal",
                                        "Carsamba" = "Car", "Persembe" = "Per",
                                        "Cuma" = "Cum", "Cumartesi" = "Cmt", 
                                        "Pazar" ="Paz", "Ortalama" = "Ort",
                                        "Hafta ici" = "hici", "Hafta sonu" = "hsonu"))
    ),
    #grafiğin gösterileceği kısım
    mainPanel(
      plotOutput("plot"))
  )
)


server <- function(input, output, session) {
  output$plot <- renderPlot({
    plot.data <- melt(x, id.vars = 'saat')
    plot.data <- plot.data[plot.data$variable %in% input$gun, ]
    ggplot(data=plot.data)+
      geom_line(mapping = aes(x=saat, y= value, colour = variable))+
      theme_classic()+
      scale_x_continuous(breaks = c(0:23))+
      ylab("Tweetler")+
      xlab("Saat")
    
      
  })
}

shinyApp(ui = ui, server = server)
```
Bu uygulamayı bilgisayarınızda görmek için aşağıdaki komutu RStudio'da çalıştırın. Shiny kütüphanesinin aktif olmasına dikkat edin.

```R
runGitHub("TwitterDuyguAnalizi", "erolkibris")
```

## Twwetlerde Migrenin Karakteristiklerinin İncelenmesi
Migren, hastaların hem fiziksel hem de duygusal olarak etkileyen nörolojik bir rahatsızlıktır. En temel fizyolojik özellikleri uzun sürmesi, çok şiddetli olması, tekrar etmesi ve dolayısıyla, kişinin okul veya iş hayatını etkilemesidir.  Bu bağlamda, konu ile atılan bazı Tweetler şöyledir:

```R
migren$text[128]
[128] "Migren ders çalışmama izin vermiyor" 

migren$text[332]
[332] "Allahım okul bende migren ağrısı yapıyor dayanamıyorum yemin ederim yaa" 

migren$text[337]
[377] "Migren yüzünden doğru düzgün yaşayamıyorum" 

migren$text[440]
[440] "Öldürmeyen Allah migren ağrısı ile sınıyor.."  

migren$text[457]
[457] "Gerginlik, stres, uykusuzluk, migren, mide bulantısı, reflü. Eklenirse yazarım." 

migren$text[499]
[499] "Sen migren ağrısı nedir bilir misin"   
   
migren$text[501]
[501] "migren yüzünden hayatımı karanlık ve sessiz ortamlarda geçiriyorum yarasa gibi oldum resmen" 

migren$text[556]
[556] "Migren süründürür."  

migren$text[780]
[780] "20 dakika ders çalıştım migren ağrım başladı bünye kaldırmıyor" 


migren$text[1928]
[1928] "3 saattir migren ağrısından uyuyamadım bu nasıl bir şey koparın kafamı" 
```

Bu sebeple, bu bölümde ise, migren rahatsızlığıyla ilgili atılan Tweetlerden, hastaların deneyimledikleri migren ağrısının süresi, sıklığı, şiddeti hakkında ne tür bilgiler verdiklerini ve migrenin varsa diğer rahatsızlıklar ile ilişkisini tespit etmek için, metin analizi yaptık.


### Verinin düzenlenmesi
Bu sebeple, migren verişinden sadece Tweet mentinlerinin olduğu sütunu çekerek kelimelerine ayırıyoruz. Bunun için R tidytext paketinden faydalanıyoruz.

```R
#tidytext paketi gerekli

tidy_migren <- migren%>%
  select(text)%>%
  unnest_tokens(word, text)
```
```R
head(tidy_migren,10)
           
           word
1         benim
1.1      migren
1.2 ataklarımın
1.3         ana
1.4  kaynağıdır
1.5       https
1.6        t.co
1.7  xrsitmiuu0
2        migren
2.1         ben
```
Metinlerde en çok geçen kelimeleri bulabilmek için kelimelerin frekanslarını hesapladık.
```R
kelime <- tidy_migren%>%
  count(word, sort = T)
```

```R
head(kelime,10)
   word       n
   <chr>  <int>
 1 migren  2958
 2 bir      563
 3 ve       401
 4 bu       395
 5 https    351
 6 t.co     350
 7 ağrısı   346
 8 beni     257
 9 de       241
10 bi       239
```
Kelimeleri ikili olarak ayırdık.
```R
bigrams <- migren%>%
  select(text)%>%
  mutate(text = str_replace_all(text, " ", " ")) %>%
  unnest_tokens(bigram, text, token = "ngrams", n = 2)
```
```R
head(bigrams,10)
                bigram
1         benim migren
1.1 migren ataklarımın
1.2    ataklarımın ana
1.3     ana kaynağıdır
1.4   kaynağıdır https
1.5         https t.co
1.6    t.co xrsitmiuu0
1.7  xrsitmiuu0 migren
1.8         migren ben
1.9           ben daha
```

İkili kelimeleri ikiye bölerek tabloya kaydettik.
```R
bigrams_seperated <- bigrams%>%
  separate(bigram, c("word1", "word2"), sep = " ")
```
```
head(bigrams_seperated,10)

          word1       word2
1         benim      migren
1.1      migren ataklarımın
1.2 ataklarımın         ana
1.3         ana  kaynağıdır
1.4  kaynağıdır       https
1.5       https        t.co
1.6        t.co  xrsitmiuu0
1.7  xrsitmiuu0      migren
1.8      migren         ben
1.9         ben        daha
```
Migren ile ilişkili kelime çiftlerini bulmak için, analizini yapmak istediğimiz konuları ayrı ayrı 5 farklı grupta inceledik.

```R
## Süreyle ilgili tablo
bi_sure <- bigrams_seperated%>%
  filter(str_detect(word1, "saat") | str_detect(word2, "saat") |
           str_detect(word1, "dakik") | str_detect(word2, "dakik") | 
           str_detect(word1, "dk") | str_detect(word2, "dk") |
           str_detect(word1, "gün") | str_detect(word2, "gün")|
           str_detect(word1, "hafta") | str_detect(word2, "hafta"))%>%
  count(word1, word2, sort = TRUE)


## Sıklıkla ilgili tablo
bi_freq <- bigrams_seperated%>%
  filter(  str_detect(word1, "kere") | str_detect(word2, "kere") | 
           str_detect(word1, "kez") | str_detect(word2, "kez") |
           str_detect(word1, "sefer") | str_detect(word2, "sefer"))%>%
  count(word1, word2, sort = TRUE)


## Siddetle ilgili tablo
oldur <- sum(migren$text %s/% 'öldür')
inti <- sum(migren$text %s/% 'intihar')
Sid <- sum(migren$text %s/% 'şiddet')



## Hastalıkla ilgili tablo
stres <- sum(migren$text %s/% 'stres')
diş <- sum(migren$text %s/% 'diş')
kalp <- sum(migren$text %s/% 'kalp')
depresyon <- sum(migren$text %s/% 'depresyon')
uyku <- sum(migren$text %s/% 'uyku')
uyu <- sum(migren$text %s/% 'uyu')
uyuy <- sum(migren$text %s/% 'uyuy')
sinuzit <- sum(migren$text %s/% 'sinüzit')



## Sosyal hayata etkisiyle ilgili tablo
okul <- sum(migren$text %s/% 'okul')
ders <- sum(migren$text %s/% 'ders')

```
Dakika, saat, gün ve hafta bazındaki ikilileri ayırdık.
```R
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
```

```R
head(bi_sure_dakika)
  word1 word2         n
  <chr> <chr>     <int>
1 15    dakikada      1
2 15    dakikalık     1
3 20    dakika        1
4 3     dakikada      1
5 45    dakika        1
6 5     dakika        2
```
### Grafiklerin Çizimi
#### Migren Süresi
```R
#dakikaları ve frekansları bir tabloda birleştirdik
data_dakika = tibble('text' = c('3', '5','15','20','45'),
                     'count' = c(2,4,2,1,1))  

#grafik
ggplot(data_dakika, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Dakika")
```
![dakika-frekans](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/dakika-frekans.jpeg)

```R
#saatleri ve frekansları bir tabloda birleştirdik
data_saat = tibble('text' = c('1','2','3','5','7','24'),
                   'count' = c(4,8,6,3,3,7))  

ggplot(data_saat, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Saat")
```
![saat-frekans](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/saat-frekans.jpeg)
```R
#günleri ve frekansları bir tabloda birleştirdik
data_gun = tibble('text' = c('1','2','3','4','Her Gün','Bugün'),
                  'count' = c(24,14,10,5,6,15))
ggplot(data_gun, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Gün")
```
![gun-frekans](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/gun-frekans.jpeg)
```R
#haftaları ve frekansları bir tabloda birleştirdik
data_hafta = tibble('text' = c('1 Hafta', '2 Hafta'),
                    'count' = c(10,3))

ggplot(data_hafta, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Süresi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Hafta")
```
![hafta-frekans](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/hafta-frekans.jpeg)
#### Migren Süresi Shiny Uygulaması
```R
data_sure = tibble('zaman' = c(rep('Dakika',5), rep('Saat',6), rep('Gün',5),rep('Hafta',2)),
                   'text'= c('3','5','15','20','45','1','2','3','5','7','24','1','2','3','4','Bugün',
                             'Bir hafta','İki hafta'), 
                   'count'=c(2,4,2,1,1,4,8,6,3,3,7,24,14,10,5,15,10,3))

```

```R
#Shiny uygulaması Migren Süresi
library(shiny)
library(ggplot2)
library(reshape2)
library(stats)

ui <- fluidPage(
  title = "Migren-Süre",
  titlePanel("Migren Süresi"),
  sidebarLayout(
    sidebarPanel(
      #Onay kutucukları kullanıcıya seçim sağlıyor
      radioButtons("choice", 
                         h1("Secim yapiniz"), 
                         choices = list("Dakika" = "Dakika", "Saat" = "Saat",
                                        "Gun" = "Gün", "Hafta" = "Hafta"))
    ),
    #grafiğin gösterileceği kısım
    mainPanel(
      plotOutput("plot"))
  )
)


server <- function(input, output, session) {
  output$plot <- renderPlot({
    data_sure <- data_sure[data_sure$zaman %in% input$choice, ]
    ggplot(data=data_sure, aes(x=reorder(text, +count), y=count))+
      geom_bar(stat = 'identity', fill = 'light blue')+
      theme_classic()+
      coord_flip()+
      labs(y="Frekans", x=input$choice)
     
})
}

shinyApp(ui = ui, server = server)
```
#### Migren Sıklık
```R
## Sıklık ve frekansları bir tabloda birleştirdik

data_sıklık = tibble('text' = c('Her gün' ,'iki kez','7 kez'), 
                   'count' = c (6,2,1))

ggplot(data_sıklık, aes(x=reorder(text, +count), y=count))+
  ggtitle("Migren Sıklık İlişkisi")+
  geom_bar(stat = 'identity', fill ="light blue")+
  coord_flip()+
  ylab("Frekans")+
  xlab("Sıklık")

```
![migren-sıklık](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/frekans.jpeg)

#### Migren Şiddeti

```R
## Şiddeti ve frekansları bir tabloda birleştirdik

data_siddet = tibble('text' = c(' öldür','intihar','şiddet'),
                    'count' = c (97,10,18))

ggplot(data_siddet, aes(x=reorder(text, +count), y=count))+
   ggtitle("Migren Şiddet İlişkisi")+
   geom_bar(stat = 'identity', fill ="light blue")+
   coord_flip()+
   ylab("Frekans")+
   xlab("Şiddet")
```
![siddet](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/siddet.jpeg)

#### Migren Hastalık İlişkisi
```R
## Hastalıkları ve frekansları bir tabloda birleştirdik

data_hastalik = tibble('text' = c('stres','diş', 'kalp',  
'depresyon','uyku', 'sinuzit'),'count' = c (41,25,14,11,92,63))

ggplot(data_hastalik, aes(x=reorder(text, +count), y=count))+
   ggtitle("Migren Hastalık İlişkisi")+
   geom_bar(stat = 'identity', fill ="light blue")+
   coord_flip()+
   ylab("Frekans")+
   xlab("Hastalık")
```
![hasta](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/hasta.jpeg)

#### Migren Sosyal Hayat İlişkisi
```R
## Okul vs ile ilgili kavramları ve frekansları bir tabloda birleştirdik

data_hayat = tibble('text' = c('okul','ders'),'count' = c (11,32))

ggplot(data_hayat, aes(x=reorder(text, +count), y=count))+
   ggtitle("Migren Sosyal Hayat İlişkisi")+
   geom_bar(stat = 'identity', fill ="light blue")+
   coord_flip()+
   ylab("Frekans")+
   xlab("Sosyal Hayat")

```
![kalp-frekans](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/shayat.jpeg)

#### Kelime Bulutu


```R
kelime <- tidy_migren%>%
  count(word, sort = T)%>%
  with(wordcloud(word, n, max.words = 200,random.order = FALSE,colors=brewer.pal(8, "Dark2")))
```

![kelime-bulutu](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/wordcloud.jpeg)

