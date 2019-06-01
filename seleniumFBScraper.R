library(RSelenium)
library(tidyverse)
library(magrittr)
source("src/utils/not_in.R")

# Start Session ####
rD <- rsDriver(port = 4567L, 
                browser = "chrome", 
                chromever = "74.0.3729.6", 
                verbose = FALSE)
remDr <- rD$client

# Login ####
loginFB <- function(remDr, login_url, my_email, my_pass) {
  remDr$navigate(login_url)
  
  emailInput <- remDr$findElement(using = "id", value = "email")
  emailInput$sendKeysToElement(my_email)
  
  passInput <- remDr$findElement(using = "id", value = "pass")
  passInput$sendKeysToElement(my_pass)
  
  logInBtn <- remDr$findElement(using = "id", value = "loginbutton")
  logInBtn$clickElement()
}

login_url <- "http://www.facebook.com"
my_email <- read_rds("data/my_email.rds")
my_pass <- read_rds("data/my_pass.rds")

loginFB(remDr, login_url, my_email, my_pass)

# Go to group ####
openGroup <- function(group_id, sorting = "CHRONOLOGICAL"){
  group_url <- paste0( "https://www.facebook.com/groups/", 
                       group_id, 
                       "/?sorting_setting=", 
                       sorting)
  remDr$navigate(group_url)
}

group_id <- read_rds("data/group_id.rds")
openGroup(group_id)

find_element <- function(remDr, using, value){
  suppressMessages({
    tryCatch(remDr$findElement(using = using, 
                               value = value), 
             error = function(e){
               return(NA)
             })
  })
}

find_element(remDr, "css", "ahdljk")

make_get_post <- function(type = "text") {
  if (type %!in% c("text", "url")) {
    stop('Unknown Type')
  }
  get_function <- function(post) {
    out <- tryCatch(
      {
        if (type == "text") {
          element <- post$getElementText()
        } else if (type == "url") {
          element <- post$getElementAttribute("href")
        }
        element
      },
      error = function(cond) {
        return(NULL)
      },
      warning = function(cond) {
        message("Warning")
        message(cond)
        return(NA)
      },
      finally = {
      }
    )    
    return(out)    
  }
}
make_get_remDr <- function(using = "css", value, type = "text", method = "one") {
  if (type %!in% c("text", "url")) {
    stop('Unknown Type')
  }
  if (method %!in% c("one", "all")) {
    stop('Method must be either "one" or "all"')
  }
  
  get_function <- function(remDr) {
    out <- tryCatch(
      {
        get_elem <- make_get_post(type)
        if (method == "one") {
          # element <- remDr$findElement(using = using, value = value)
          element <- find_element(remDr, using, value)
          if (!is.na(element)) {
            element <- get_elem(element) 
          }
        } else if (method =="all") {
          elements <- remDr$findElements(using = using, value = value)
          element <- sapply(elements, get_elem)
        }
        
        # if (length(element) == 1) {} # achei errado
          element <- unlist(element)
        
        element
      },
      error = function(cond) {
        return(NA)
      },
      warning = function(cond) {
        message("Warning")
        message(cond)
        return(NA)
      }
    )    
    return(out)    
  }
}


# Get all permalinks and summary texts on page ####
get_permalinks <- make_get_remDr(using = "css", 
                                 value = "._5pcq", 
                                 type = "url", 
                                 method = "all")
get_sumr_texts <- make_get_remDr(using = "css", 
                                 value = "[data-testid='post_message']", 
                                 method = "all")

posts_tbl <- tibble(sumrText = get_sumr_texts(remDr),
                    permalink = get_permalinks(remDr))

process_post <- function(remDr, link) {
  out <- tryCatch(
    {
      get_author_name <- make_get_remDr(using = "css", 
                                        value = '.fwb  [ajaxify*="member_bio"]',
                                        type = "text")
      get_author_link <- make_get_remDr(using = "css", 
                                        value = '.fwb  [ajaxify*="member_bio"]',
                                        type = "url")
      get_interactions <- make_get_remDr(using = "css", 
                                         value = "._81hb",
                                         type = "text")
      get_comments_counter <- make_get_remDr(using = "css", 
                                             value = '[data-testid*="CommentsCount"',
                                             type = "text")
      get_post_message <- make_get_remDr(using = "css", 
                                         value = '[data-testid*="post_message"',
                                         type = "text")
      
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
      
      tbl <- tibble(authorName = authorName,
                    authorLink = authorLink,
                    interactionsCounter = interactionsCounter,
                    commentsCounter = commentsCounter,
                    postMessage = postMessage)
      
      remDr$closeWindow()
      remDr$switchToWindow(mainWindow)
      tbl
    },
    error=function(cond) {
      message("Error")
      message(cond)
      return(NULL)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      return(NA)
    }
  )    
  return(out)
}


link <- posts_tbl[1,'permalink']
process_post(remDr, link)






tmp_main <- tibble(sumrTexts = sapply(postsTexts, get_texts),
                   permalink = sapply(postsLinks, get_permalink))









post <- postsLinks[[3]]
process_post(post)

tbl <- bind_rows(lapply(postsLinks, process_post))

tmp_main %>%
  bind_cols(tbl)

#scroll down
#get new links and sumr texts, discarding old ones
#repeat

posts_tbl %<>%
  bind_rows(tmp_main)


remDr$close()
rD$server$stop()
rD$server$process

