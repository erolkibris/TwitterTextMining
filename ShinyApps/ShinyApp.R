library(shiny)
library(ggplot2)


ui <- fluidPage(
  title = "Migren-Hastalık",
  titlePanel("Migren-Hastalık İlişkisi"),
  sidebarLayout(
    sidebarPanel(
      #Onay kutucukları kullanıcıya seçim sağlıyor
      radioButtons("choice", 
                   h1("Secim yapiniz"), 
                   choices = list("Uyku" = "Uyku", "Dis" = "Diş",
                                  "Kalp" = "Kalp"))
    ),
    #grafiğin gösterileceği kısım
    mainPanel(
      plotOutput("plot"))
  )
  
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    data_hastalik <- data_hastalik[data_hastalik$hastalik %in% input$choice, ]
    ggplot(data=data_hastalik, aes(x=reorder(text, +count), y=count))+
      geom_bar(stat = 'identity', fill = 'light blue')+
      theme_classic()+
      coord_flip()+
      labs(y="Frekans", x=input$choice)
  
})
}

shinyApp(ui = ui, server = server)