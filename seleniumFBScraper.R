# Load Libraries and tools ####
library(RSelenium)
library(readr)
library(purrr)
source("src/utils/not_in.R")

# Define core functions ####

stopSession <- function(rD, 
                        rm = TRUE #Remove vars before Quit
){
  rD$client$closeall()
  rD$server$stop()
  out <- rD$server$process
  if (rm == TRUE) {
    rm(list = c("rD", "remDr"), pos = ".GlobalEnv")
  }
  out
}
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
findElement <- function(remDr, using, value){
  suppressMessages({
    tryCatch(remDr$findElement(using = using, 
                               value = value), 
             error = function(e){
               return(NA)
             })
  })
}
getLinkElem <- function(elem = "text") {
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
makeGetRemDr <- function(using = "css",  # Argument passed to findElement and them RSelenium
                         value, # Argument passed to findElement and them RSelenium
                         elem = "text", # What to extract from links? text or url?
                         method = "one", # First element or all of them
                         attrName = NULL) {
  if (elem %!in% c("text", "url")) {
    stop('Unknown elem')
  }
  if (method %!in% c("one", "all")) {
    stop('Method must be either "one" or "all"')
  }
  if (is.null(attrName)) {
    attrName <- elem
  }
  get_function <- function(remDr, simplify = TRUE){ # Unlist when length == 1) {
    get_elem <- getLinkElem(elem)
    if (method == "one") {
      # element <- remDr$findElement(using = using, value = value)
      element <- findElement(remDr, using, value)
      if (class(element)[[1]] == "webElement") {
        element <- get_elem(element) 
      }
    } else if (method == "all") {
      elements <- remDr$findElements(using = using, value = value)
      element <- map(elements, get_elem)
    }
    renamef <- function(x, attrName){x
      names(x) <- attrName
      return(x)
    }
    element <- map(element, set_names, nm = attrName)
    if (simplify == TRUE & length(element) == 1) {
      element <- unlist(element)
    }
    element
  }
}
processPost <- function(remDr, link, interval = 2) {
  get_author_name <- makeGetRemDr(using = "css", 
                                  value = '.fwb  [ajaxify*="member_bio"]',
                                  elem = "text")
  get_author_link <- makeGetRemDr(using = "css", 
                                  value = '.fwb  [ajaxify*="member_bio"]',
                                  elem = "url")
  get_interactions <- makeGetRemDr(using = "css", 
                                   value = "._81hb",
                                   elem = "text")
  get_comments_counter <- makeGetRemDr(using = "css", 
                                       value = '[data-testid*="CommentsCount"',
                                       elem = "text")
  get_post_message <- makeGetRemDr(using = "css", 
                                   value = '[data-testid*="post_message"',
                                   elem = "text")
  
  mainWindow <- unlist(remDr$getCurrentWindowHandle())
  script <- paste0('window.open("', link, '", "windowName", "height=800,width=1280");')
  remDr$executeScript(script)
  newWindow <- remDr$getWindowHandles()[[2]]
  remDr$switchToWindow(newWindow)
  
  authorName <- get_author_name(remDr)
  authorLink <- get_author_link(remDr)
  interactionsCounter <- get_interactions(remDr)
  commentsCounter <- get_comments_counter(remDr)
  postMessage <- get_post_message(remDr)
  
  Sys.sleep(interval)
  
  remDr$closeWindow()
  remDr$switchToWindow(mainWindow)
  
  out <- list(authorName = authorName,
              authorLink = authorLink,
              interactionsCounter = interactionsCounter,
              commentsCounter = commentsCounter,
              postMessage = postMessage)
  out
}
getPostsList <- function(remDr) {
  getPermalinks <- makeGetRemDr(using = "css", 
                                value = "._5pcq", 
                                elem = "url", 
                                method = "all",
                                attrName = "permalink")
  getSumrTexts <- makeGetRemDr(using = "css", 
                               value = "[data-testid='post_message']", 
                               method = "all",
                               attrName = "sumrText")
  
  permalink <- getPermalinks(remDr)
  sumrText <- getSumrTexts(remDr)
  
  posts_list <- map2(permalink, sumrText, append)
  posts_list
}
enrichPostList <- function(posts_list, remDr){
  f <- function(x) {
    r <- processPost(remDr, x[['permalink']])
    r
  }
  enriched_posts_list <- map(posts_list, f)
  posts_list <- map2(posts_list, enriched_posts_list, append)
}
goToEnd <- function(remDr, cycles = 2, interval = 4) {
  webElem <- remDr$findElement("css", "body")
  for (i in 1:cycles){
    webElem$sendKeysToElement(list(key = "end"))
    Sys.sleep(interval)  
  }
}
# Start Session ####
# eCaps <- list(chromeOptions = list(
#   args = c('--headless', '--window-size=1280,800')
# ))
rD <-rsDriver(port = 4567L, 
              browser = "chrome", 
              chromever = "74.0.3729.6", 
              verbose = FALSE)#,
# extraCapabilities = eCaps)
remDr <- rD$client


# Login ####
my_email <- read_rds("data/my_email.rds")
my_pass <- read_rds("data/my_pass.rds")
loginFB(remDr, my_email, my_pass, login_url = "http://www.facebook.com")

# Go to group ####
group_id <- read_rds("data/group_id.rds")
openGroup(group_id)

# Get all permalinks and summary texts on page ####
posts_list <- getPostsList(remDr)
# Enter on each permalink and extract post features  ####
postsLists <- enrichPostList(posts_list, remDr)
# Sroll down to the end of current page and get permalinks and sumrTexts####
goToEnd(remDr)
#get new links and sumr texts
nw_posts_list <- getPostsList(remDr)
# append new nwPosts_List to erinched_posts_list
getPermalinks <- function(posts_list) {
  permalinks <- map(posts_list, function(post){})
  permalinks
}
previousP
#enrich those
#repeat
# Stop Session ####
stopSession(rD)
# Utils ####
remDr$screenshot(display = TRUE)
