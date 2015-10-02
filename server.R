library(shiny)

shinyServer(function(input, output) {
    
    output$plot <- renderPlot({
      if (input$language == 1){
        v <- getTermMatrix(input$selection)        
      } 
      else if (input$language == 2) {
        v <- getNounCountTable(input$selection)
        #par(family = "AppleGothic")
        par(family = "NanumGothic")
      }
      wordcloud(names(v), v, scale=c(input$scale[2],input$scale[1]),
                min.freq = 1, max.words = input$max,
                random.order = TRUE, random.color = TRUE, 
                colors = brewer.pal(8, "Dark2"))
    })
    
    output$ref <- renderUI({
      code(get.ref.text(input$selection, input$language))
    })
    
    output$text_en <- renderUI({
      if (input$hideshow == 1) 
        ""
      else {
        HTML(getWords(input$selection, "1"))
      }
    })
    
    output$text_ko <- renderUI({
      if (input$hideshow == 1) 
        ""
      else {
        HTML(getWords(input$selection, "2"))
      }
    })
})
