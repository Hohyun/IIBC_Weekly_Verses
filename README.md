# IIBC_Weekly_Verses
This is a shiny app that help people to memorize God's words.

## How to execute this app
1. Install R program in your compute.
2. Install related R packages.
  - install.packages("shiny")
  - install.packages(c("tm", "wordcloud", "memoise", "RColorBrewer", "RSQLIte","KoNLP"))
3. Execute app from R
  - Open up R program
  - Enter next command to R command prompt
    + runGitHub("IIBC_Weekly_Verses", "Hohyun")

## How to use this app
- Select "Week & Reference" --> Then word-cloud will appear on the screen
- language  : English(default), Korean --> this controls how word-cloud shoud be rendered.
- Hide/Show : Hide(default) --> this controls whether bible text is displayed or not in the bottom right of the screen

