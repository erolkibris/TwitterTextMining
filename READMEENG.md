# Twitter Text Mining

## Usage

rtweet package provides users to extract Twitter data without Twitter developer account. All you need is a Twitter account.

## Required Packages

```R
## rtweet for collecting Twitter data
## dplyr for data manipulation
## ggplot2 for graphs
## lubridate for working with date and time
## plyr for data manipulation
## shiny for ShinyApp
## reshape2 
## tidytext for text mining
## tidyr for creating tidy data
## stringr for working with strings
## wordcloud for generate wordcloud

## Installation of packages

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

## Activation of packages

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

## Searching Tweets

I collected data between 18 February 2019-19 March 2019. My project was in Turkish so i gathered tweets about migraine in Turkish.

```R
## search for 18000 tweets using the "migren" (migren means migraine in Turkish)

migo <- search_tweets(
  q="migren", n=18000, retryonratelimit = TRUE, include_rts = FALSE
)

## save as data frame

migren_df <- as.data.frame(migo)
```

## Turkish tweets

"Migren" word means migraine in several languages. Therefore, i filtered language only "tr".

```R

migren <- migren_df %>%
  select(status_id, created_at, text, location)%>%
  filter(migren_df$lang =="tr")%>%
  arrange(migren$created_at) 
```

## Cities vs tweets

```R
##how many tweets in 4 biggest cities of Turkey.
ist <- sum(migren$location %s/% 'stanbul') 
ank <- sum(migren$location %s/% 'Ankara')
izm <- sum(migren$location %s/% 'zmir')
bur <- sum(migren$location %s/% 'Bursa')
```
```R
cities <- data.frame("Cities" = c("İstanbul","Ankara", "İzmir", "Bursa", "Diğer"), 
                     "Frequency" = c(ist, ank, izm, bur, dim(migren)[1] - (ist+ank+izm+bur)))

cities$Perc <- round(cities$Frequency / sum(cities$Frequency)*100,4)

```

```R
head(cities)

   Cities  Frequency   Perc
1 İstanbul       397 13.6426
2   Ankara       122  4.1924
3    İzmir       137  4.7079
4    Bursa        51  1.7526
5    Diğer      2203 75.7045  ##Diğer means other.
```
```R
#plot cities vs tweet
ggplot(data = cities)+
  aes(x=Cities, y = Perc)+
  geom_bar(stat="identity",fill="light blue")+
  theme(panel.background = element_rect(fill = "white"))+
  labs(title = "Şehirlere göre atılan tweetler")+
  xlab("Şehirler")+ ##Cities
  ylab("Yüzdeler") ##Percentages
```
![Şehirler](https://github.com/erolkibris/TwitterDuyguAnalizi/blob/master/Graphs/sehir-tweet.jpeg)

## Hour-Day-Tweets Graphs

```R
migren$created_at[1:10]

 [1] "2019-02-18 08:27:04 UTC" "2019-02-18 11:54:36 UTC" "2019-02-18 13:09:33 UTC"
 [4] "2019-02-18 13:21:51 UTC" "2019-02-18 13:39:16 UTC" "2019-02-18 13:55:46 UTC"
 [7] "2019-02-18 14:14:24 UTC" "2019-02-18 14:14:33 UTC" "2019-02-18 14:46:28 UTC"
[10] "2019-02-18 15:57:14 UTC"
```
round_date() takes a date-time object and rounds it to the nearest value of the specified time unit.

```R
migren$created_at <- round_date(migren$created_at, "hour", week_start = getOption("lubridate.week.start",7))

migren$date <- as.Date(migren$created_at)
migren$time <- format(migren$created_at, "%H")
migren$day <- wday(migren$date,label = TRUE)
```

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

```R
##figure out mean of tweets day by day
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

## Day-Tweet Shiny Application

### Arrange the data for ShinyApp

```R
x <- data.frame(matrix(,nrow = 24, ncol = 9))
coln <- c("saat", "Pzt", "Sal", "Car", "Per", "Cum", "Cmt", "Paz", "Ort")
colnames(x) <- coln
x$saat <- c(0:23)
x[,(c("Paz", "Sal", "Car", "Per", "Cum", "Cmt", "Pzt", "Ort"))]=t(ldply(split(sum.table$Freq, sum.table$day))[,-1])
x$hici <- with(x[,2:6], rowMeans(x[,2:6])) ## weekdays
x$hsonu <- with(x[,7:8], rowMeans(x[,7:8])) ## weekend
```
```R
head(x)
#hour #Mon #Tue #Wed #Thu #Fri #Sat #Sun #Avg #Wday #Weekend
saat Pzt   Sal   Car Per  Cum  Cmt  Paz  Ort  hici hsonu
1    0      17  12  15   6  10   9   8 11.0000 12.0   8.5
2    1      5   6   7   5   5   8   7  6.1429  5.6   7.5
3    2      4   6   6   5   5   1   2  4.1429  5.2   1.5
4    3      3   0   2   5   1   2   3  2.2857  2.2   2.5
5    4      2   3   6   1   2   5   1  2.8571  2.8   3.0
6    5      6   5   7  10   4   8   2  6.0000  6.4   5.0
```

### Shiny App

```R

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

