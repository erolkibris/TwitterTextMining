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
  