# Twitter Duygu Analizi

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

## Paketlerin kurulumu

install.packages("rtweet")
install.packages("dplyr")
install.packages("roperators")
install.packages("ggplot2")
install.packages("lubridate")
install.packages("plyr")

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
                     "Frequency" = c(ist, ank, izm, bur, 1117 - (ist+ank+izm+bur)))

cities$Perc <- round(cities$Frequency / sum(cities$Frequency)*100,4)
cities$Perc
```

Migrenle ilgili atılan Tweetlerin konumlara göre yüzdesi aşağıdaki gibidir. “Diğer” kısmında ise Twitter hesabında yeri belirtilmemiş veya anlamlı yer belirtilmemiş kullanıcılar yer almaktadır.

```R
head(cities)

   Cities  Frequency    Perc
1 İstanbul       284 25.4252
2   Ankara        78  6.9830
3    İzmir        91  8.1468
4    Bursa        33  2.9543
5    Diğer       631 56.4906
```
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

Twitter'da konum belirtme isteğe bağlıdır. Twitter kullanıcıların çoğu büyük şehirlerde yaşayanlardır. Migrenle ilgili atılan tweetlerin konuma göre yüzdesi aşağıdaki gibidir. Diğer kısmında yeri belirtmemiş ve anlamlı yer belirtmemiş kişilerdir.


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

## ShinyApp 
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
Bu uygulamayı bilgisyarınızda görmek için aşağıdaki komutu RStudio'da çalıştırın. 

```R
runGitHub("TwitterDuyguAnalizi", "erolkibris")
```
