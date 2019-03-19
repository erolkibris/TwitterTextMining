# Twitter Duygu Analizi

[For English document](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/READMEENG.md)

## Projenin Amacı

Gelişen teknolojiyle birlikte ortaya çıkan sosyal medya araçları farklı disiplerden araştırmacılara, çalışmaları için anlık ve büyük boyutta veri imkanı sunmaktadır. Biz bu çalışmamız da, Türkiye’de yaklaşık olarak 7 milyon kişiyi hem fiziksel hem de ruhsal olarak etkileyen migren rahatsızlığının Twitter’da Türkçe mesajlardan elde edilen veriler doğrultusunda duygu analizini yapmayı planlamaktayız. Çalışmamızda özellikle, Twitter mesajlarında, migren rahatsızlığının üç temel karekteristiği olan, frekansını, süresini ve şiddetini belirtmek için Türkçe Twitter kullanıcıların hangi kelimeleri kullandığı, bu mesajları haftanın hangi gününde ve günün hangi saatinde daha çok kullandığı üzerine çıkarımlar yapmayı ummaktayız. Bu çıkarımları yapabilmek için de istatistiksel veri görselleştirme araçlarını kullanmayı planlanmaktayız. Son olarak, migren hastalarının yaşam kalitesinin artmasına katkıda bulunmak için elde ettiğimiz bulguları için baş ağrısı uzmanları ile paylaşmayı planlamaktayız.

## Kullanım
R programı, Twitter developer hesabına gerek kalmadan, Twitter’dan veri çekmemize imkan veriyor. Bu işlemi yapabilmemiz için öncelikli olarak bir Twitter hesabımızın olması gereklidir.

## Gerekli R Paketleri
Öncelikli olarak kullanacağımız R paketlerini indirmemiz ve kurmamız gerekiyor. İlk etapta R rtweet paketine, Twitter’dan veri çekebilmemiz için ihtiyacımız var. Aşağıda listelenen diğer paketler ise ileriki aşamada sırasıyla ihtiyacımız olan paketler.
```R
## R rtweet Twitter'dan veri çekmek için 
## R dplyr veri düzenlemesi için
## R roperators metinde bir kelimenin belirli uzantılarını aramak için
## R ggplot2 grafik çizimi için gerekli
## R lubridate tarih ve saat değişkenleri üzerinde değişiklik yapabilmek için
## R plyr veri düzenlemesi için
## R shiny paketi uygulama için gerekli
## R reshape2 veriyi görselleştirmek için düzenlemede gerekli


## Paketlerin kurulumu

install.packages("rtweet")
install.packages("dplyr")
install.packages("roperators")
install.packages("ggplot2")
install.packages("lubridate")
install.packages("plyr")
install.packages("shiny")
install.packages("reshape2")

## Paketlerin aktivasyonu

library(rtweet)
library(dplyr)
library(roperators)
library(ggplot2)
library(lubridate)
library(plyr)
```

## Migren Kelimesi Geçen Tweetleri Çekmek

R rtweet paketindeki search_tweets fonksiyonu, Twitter’dan 10 gün öncesine kadar veri çekebilmemizi sağlar.

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

Elde ettiğimiz ham veride, farklı dillerde de migren kelimesi yer aldığını farkettik. Bu sebeple, sadece dili Türkçe olan tweetleri çekmek ve diğer gerekli bir takım sütunları (mesajın kimlik numarasını, mesajın ne zaman atıldığını, mesajın nereden atıldığını ve mesajın kendisini) çekmek için aşağıdaki kodu kullandık ve Github’da migren_tr ismiyle sakladık.
```R
## Ham veri olan migren_df'den sadece status_id, created_at, text ve location ## sütunlarını ve Türkçe tweetleri alalım

migren_tr <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")%>%
  arrange(migren_tr$created_at) 


## filter fonksiyonu, Twitter mesajlarini Turkce olanlarini seciyor
## arrange fonksiyonu, veriyi created_at sütununa göre, yani kronolojik 
## olarak artan şekilde sıralıyor.
```
## Hangi şehirde ne kadar tweet atılmış?
Twitter'da yaşanılan yere ait şehir isim bilgisi yani konum belirtme isteğe bağlıdır. Bu sebeple, tüm kullanılara ait konum bilgisi elde etmemiz mükün olmazken, genel olarak bilinen yargı ise Twitter kullanıcıların çoğunun büyük şehirlerde yaşayan genç insanlar olduğudur. Yine bu nedenle, biz de, Türkiye’de 4 büyük şehirden migren ile ilgili ne kadar Tweet atılmış görelim istedik:

```R
## Hangi şehirlerden ne kadar tweet atılmış
ist <- sum(migren_tr$location %s/% 'stanbul') 
ank <- sum(migren_tr$location %s/% 'Ankara')
izm <- sum(migren_tr$location %s/% 'zmir')
bur <- sum(migren_tr$location %s/% 'Bursa')
```
```R
##cities data frame oluşturup sıklıklarını ve yüzdelerini yazıyoruz.
cities <- data.frame("Cities" = c("İstanbul","Ankara", "İzmir", "Bursa", "Diğer"), 
                     "Frequency" = c(ist, ank, izm, bur, dim(migren_tr)[1] - (ist+ank+izm+bur)))

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

Tweetlerin haftanın hangi günü, günün hangi saatinde atıldığına dair bir çizgi grafik çıkarmak istiyoruz. Fakat, elimizdeki veride, zamana dair sadece “created_at” değişkeni var. Burada, tarih ve saat birleşik olarak verilmiş.

```R
migren_tr$created_at[1:10]

 [1] "2019-02-18 08:27:04 UTC" "2019-02-18 11:54:36 UTC" "2019-02-18 13:09:33 UTC"
 [4] "2019-02-18 13:21:51 UTC" "2019-02-18 13:39:16 UTC" "2019-02-18 13:55:46 UTC"
 [7] "2019-02-18 14:14:24 UTC" "2019-02-18 14:14:33 UTC" "2019-02-18 14:46:28 UTC"
[10] "2019-02-18 15:57:14 UTC"
```

R lubridate paketi bize, “created_at” değişkeninden öncelikle saatleri çekip ve yuvarlayıp, sonrasında da, tarih kısmından saati ve günü çıkarmamıza yardımcı oluyor.

```R
migren_tr$created_at <- round_date(migren_tr$created_at, "hour", week_start = getOption("lubridate.week.start",7))

## created_at sütununda veri tarih ve saat şeklinde birleşik. 
## Saati yuvarlayıp created_at sütununa kaydettik.

migren_tr$date <- as.Date(migren_tr$created_at)
migren_tr$time <- format(migren_tr$created_at, "%H")
migren_tr$day <- wday(migren_tr$date,label = TRUE)
```

Artık verimizde, hem tarih, hem gün hem de saat ayrı ayrı mevcut.

```R
head(migren_tr[,c("date","time", "day")],10)

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
Haftanın hangi gününde, saat kaçta, kaç tane tweet atıldığına dair biz çizgi grafiği elde etmek istiyoruz. Sonrasında, bu grafiği R Shiny uygulamasını kullanarak dinamik hale geritereceğiz. Bu sebeple, öncelikle, gerekli olan veriyi yani haftanın hangi gününde, hangi saatte kaç tane Tweet atıldığını çıkaralım.

```R
sum_table <- as.data.frame(table(migren_tr$day,migren_tr$time))
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
    day  time  Freq
168 Cmt   23 11.0000
169 Ort   00  8.0000
170 Ort   01  4.0000
171 Ort   02  3.1429
172 Ort   03  1.7143
173 Ort   04  2.4286
174 Ort   05  4.1429
175 Ort   06  3.8571
176 Ort   07  8.7143
177 Ort   08  8.7143
178 Ort   09 11.4286
179 Ort   10 11.4286
180 Ort   11 10.5714
181 Ort   12 11.0000
182 Ort   13 11.1429
183 Ort   14 11.5714
184 Ort   15 12.0000
185 Ort   16 16.0000
186 Ort   17 14.2857
187 Ort   18 18.0000
188 Ort   19 21.1429
189 Ort   20 29.4286
190 Ort   21 31.5714
191 Ort   22 23.0000
192 Ort   23 13.2857
```
## Gün-Tweet Shiny Uygulaması

### Shiny için Veri Düzenlemesi
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
saat Pzt Sal Car Per Cum Cmt Paz    Ort hici hsonu
1    0  17   5  12   3   7   7   5 8.0000  8.8   6.0
2    1   3   5   4   5   3   3   5 4.0000  4.0   4.0
3    2   3   6   4   5   3   0   1 3.1429  4.2   0.5
4    3   2   0   2   5   0   2   1 1.7143  1.8   1.5
5    4   2   2   5   1   2   5   0 2.4286  2.4   2.5
6    5   4   4   3   9   2   7   0 4.1429  4.4   3.5
```

### Shiny Uygulaması 
Shiny kütüphanesini kullanarak dinamik grafikler elde ettik. Kullanıcıya günlere göre atılan tweetleri çizgi grafik aracılığıyla görselleştirdik. Shiny uygulaması 2 kısımdan oluşuyor. Kullanıcı arayüzü ve server kısmı. ui kısmı kullanıcının seçimleri ve grafiği gördüğü kısım, server arka planda çalışarak grafiği çizdirmek için gerekli

```R
#shiny uygulama için gerekli
#ggplot2 grafik için
#reshape2 veriyi görselleştirmek için düzenlemede gerekli
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
Bu uygulamayı bilgisayarınızda görmek için aşağıdaki komutu RStudio'da çalıştırın. Shiny kütüphanesinin aktif olmasına 
dikkat edin.

```R
runGitHub("TwitterDuyguAnalizi", "erolkibris")
```
