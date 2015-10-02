library(shiny)

shinyUI(fluidPage(
    titlePanel("IIBC Weekly Memory Verses"),

    sidebarLayout(
        sidebarPanel(
            selectInput("selection", "Choose Week & Reference:",
                        choices = refs),
            hr(),
            fluidRow(
              
              column(5,
                     radioButtons("language", label = "Language:",
                                  choices = list("English" = 1, "Korean" = 2),
                                  selected = 1)),
              column(5,
                     radioButtons("hideshow", label = "Verses:",
                                  choices = list("Hide" = 1, "Show" = 2),
                                  selected = 1))
            ),           
            hr(),
            sliderInput("freq",
                        "Minimum Frequency:",
                        min = 1, max = 5,  value = 1),
            sliderInput("max",
                        "Maximum Words:",
                        min = 1, max = 20, value = 10),
            sliderInput("scale",
                        "Scale Range of Word Cloud:",
                        min = 1, max = 10, value = c(2, 6))
        ),

        mainPanel(
            plotOutput("plot"),
            hr(),
            htmlOutput("ref"),
            br(),
            htmlOutput("text_en"),
            hr(),
            htmlOutput("text_ko")
        )
    )
))
