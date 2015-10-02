library(tm)
library(wordcloud)
library(memoise)
library(RColorBrewer)
library(RSQLite)
library(KoNLP)
useSejongDic()

#refs <<- list("Sep-W1 (1) : Romans 12:1-2" = "Rm_12_1-2", 
#              "Sep-W1 (2) : Mark 8:35" = "Mk_8_35")

v <- read.csv("iibc_verses.csv", header=TRUE)
refs <- as.list(v$ref)
names(refs) = as.list(paste(v$week, ":", v$verses))

# Connect SQLite db
db <- dbConnect(SQLite(), "bible.sqlite")

getWords <- memoise(function(ref, lang) {  
  # english = 1, korean = 2
  verse.df <- get.verses(ref, lang)
  extract.ref.and.words(verse.df, lang)
})

# using "memoise" to automatically cache the resules
getTermMatrix <- memoise(function(ref) { 
  verse.df <- get.verses(ref, 1)   # 1 = English
  text <- extract.words.only(verse.df)
      
  myCorpus <- Corpus(VectorSource(text))
  myCorpus <- tm_map(myCorpus, content_transformer(tolower))
  myCorpus <- tm_map(myCorpus, removePunctuation)
  myCorpus <- tm_map(myCorpus, removeNumbers)
  myCorpus <- tm_map(myCorpus, removeWords, stopwords("en"))
  
  myDTM = TermDocumentMatrix(myCorpus, control = list(minWordLength = 1))
  m = as.matrix(myDTM)
  sort(rowSums(m), decreasing = TRUE)  
})

getNounCountTable <- memoise(function(ref) 
{
  verse.df <- get.verses(ref, 2)  # 2 = Korean
  text <- extract.words.only(verse.df)
  gsub("\\[|\\]", "", text)  # delete [, ]  
  nouns <- sapply(text, extractNoun, USE.NAMES = F)
  nouns <- unlist(nouns)
  write(nouns, "nouns.txt")
  data <- read.table("nouns.txt")
  wordcount <- table(data)  
})

get.verses <- function (key, lang) 
{  # returns data.frame
  # ex) key = Rm_12_1, or Rm_12_1-2
  if (lang == 2) 
    table.name <- 'hkjv'
  else 
    table.name <- 'kjv'
  
  ref <- unlist(strsplit(key, " "))
  book.code <- ref[1]
  chap.num <- ref[2]
  verse.from <- ref[3]
  if (length(ref) == 4) 
    verse.to <- ref[4]
  else
    verse.to <- ref[3]
  
  dbGetQuery(db, sprintf("SELECT e_bookname, k_bookname, chapter, 
            verse, words FROM %s natural join book 
            WHERE e_abbv1='%s' and chapter=%s and verse >= %s 
            and verse <= %s", table.name, book.code, chap.num,
                         verse.from, verse.to))
}

get.ref.text <- function (key, lang) {
  df <- get.verses(key, lang)
  if (lang == 1) {
    if (nrow(df) == 1)
      paste(df[1,1], df[1,3], ":", df[1,4])
    else
      paste(df[1,1], df[1,3], ":", df[1,4], "-", df[nrow(df),4])
  }     
  else if (lang == 2) {
    if (nrow(df) == 1)
      paste(df[1,2], df[1,3], ":", df[1,4])
    else
      paste(df[1,2], df[1,3], ":", df[1,4], "-", df[nrow(df),4])    
  }
}

extract.words.only <- function (df)
{
  text = ''
  for (i in seq(1, nrow(df)))
    text <- paste(text, df[i,5])
  text <- gsub("\\[|\\]", "", text)
}

extract.ref.and.words <- function (df, lang)
{
  text = "<div>"
  for (i in seq(1, nrow(df))) {
    text <- paste(text, paste(df[i,4], df[i,5]))
    text <- paste(text, "<br>")
  }
  if (lang == 1) {
    text <- gsub("\\[|\\]", "", text)
    text <- gsub("God", "<strong>God</strong>", text)
    text <- gsub("Lord", "<strong>Lord</strong>", text)
    text <- gsub("Holy Ghost", "<strong>Holy Ghost</strong>", text)
  } else if (lang == 2) {
    text <- paste(text, "</div>")
    text <- gsub("\\[", "<strong>", text)
    text <- gsub("\\]", "</strong>", text)  
  }
}
