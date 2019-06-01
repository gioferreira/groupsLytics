# Load Libraries and tools ####
library(RSelenium)
library(tidyverse)
library(magrittr)
source("src/utils/not_in.R")

# Define core functions ####
loginFB <- function(remDr, login_url, my_email, my_pass) {
  remDr$navigate(login_url)
  
  emailInput <- remDr$findElement(using = "id", value = "email")
  emailInput$sendKeysToElement(my_email)
  
  passInput <- remDr$findElement(using = "id", value = "pass")
  passInput$sendKeysToElement(my_pass)
  
  logInBtn <- remDr$findElement(using = "id", value = "loginbutton")
  logInBtn$clickElement()
}
openGroup <- function(group_id, sorting = "CHRONOLOGICAL"){
  group_url <- paste0( "https://www.facebook.com/groups/", 
                       group_id, 
                       "/?sorting_setting=", 
                       sorting)
  remDr$navigate(group_url)
}

find_element <- function(remDr, using, value){
  suppressMessages({
    tryCatch(remDr$findElement(using = using, 
                               value = value), 
             error = function(e){
               return(NA)
             })
  })
}
get_link_elem <- function(elem = "text") {
  if (elem %!in% c("text", "url")) {
    stop('Unknown elem')
  }
  get_function <- function(post) {
    tryCatch({
      if (elem == "text") {
        element <- post$getElementText()
      } else if (elem == "url") {
        element <- post$getElementAttribute("href")
      }
      element}, 
      error = function(e){
        return(NA)
      })
  }
}
make_get_remDr <- function(using = "css", value, elem = "text", method = "one") {
  if (elem %!in% c("text", "url")) {
    stop('Unknown elem')
  }
  if (method %!in% c("one", "all")) {
    stop('Method must be either "one" or "all"')
  }
  get_function <- function(remDr) {
    get_elem <- get_link_elem(elem)
    if (method == "one") {
      # element <- remDr$findElement(using = using, value = value)
      element <- find_element(remDr, using, value)
      if (class(element)[[1]] == "webElement") {
        element <- get_elem(element) 
      }
    } else if (method == "all") {
      elements <- remDr$findElements(using = using, value = value)
      element <- sapply(elements, get_elem)
    }
    
    
    element <- unlist(element)
    
    element
  }
}
# Start Session ####
rD <- rsDriver(port = 4567L, 
                browser = "chrome", 
                chromever = "74.0.3729.6", 
                verbose = FALSE)
remDr <- rD$client

# Login ####
my_email <- read_rds("data/my_email.rds")
my_pass <- read_rds("data/my_pass.rds")
loginFB(remDr, my_email, my_pass, login_url = "http://www.facebook.com")

# Go to group ####
group_id <- read_rds("data/group_id.rds")
openGroup(group_id)

# Get all permalinks and summary texts on page ####
get_permalinks <- make_get_remDr(using = "css", 
                                 value = "._5pcq", 
                                 elem = "url", 
                                 method = "all")
get_sumr_texts <- make_get_remDr(using = "css", 
                                 value = "[data-testid='post_message']", 
                                 method = "all")
sumrText <- get_sumr_texts(remDr)
permalink <- get_permalinks(remDr)

posts_tbl <- tibble(sumrText = sumrText,
                    permalink = permalink)

# Now ####
process_post <- function(remDr, link) {
      get_author_name <- make_get_remDr(using = "css", 
                                        value = '.fwb  [ajaxify*="member_bio"]',
                                        elem = "text")
      get_author_link <- make_get_remDr(using = "css", 
                                        value = '.fwb  [ajaxify*="member_bio"]',
                                        elem = "url")
      get_interactions <- make_get_remDr(using = "css", 
                                         value = "._81hb",
                                         elem = "text")
      get_comments_counter <- make_get_remDr(using = "css", 
                                             value = '[data-testid*="CommentsCount"',
                                             elem = "text")
      get_post_message <- make_get_remDr(using = "css", 
                                         value = '[data-testid*="post_message"',
                                         elem = "text")
      
      mainWindow <- unlist(remDr$getCurrentWindowHandle())
      script <- paste0('window.open("', link, '", "windowName", "height=768,width=1024");')
      remDr$executeScript(script)
      newWindow <- remDr$getWindowHandles()[[2]]
      remDr$switchToWindow(newWindow)
      
      authorName <- get_author_name(remDr)
      authorLink <- get_author_link(remDr)
      interactionsCounter <- get_interactions(remDr)
      commentsCounter <- get_comments_counter(remDr)
      postMessage <- get_post_message(remDr)
  
      remDr$closeWindow()
      remDr$switchToWindow(mainWindow)
      
      out <- list(authorName = authorName,
                    authorLink = authorLink,
                    interactionsCounter = interactionsCounter,
                    commentsCounter = commentsCounter,
                    postMessage = postMessage)
      out
}

enrich_post_tbl <- function(posts_tbl, remDr){
  #select wich posts to enrich
  # process the link
  # add the columns
  posts_tbl
}


link <- posts_tbl[2,'permalink']
process_post(remDr, link)



#scroll down
#get new links and sumr texts
#enrich those
#repeat


remDr$close()
rD$server$stop()
rD$server$process

