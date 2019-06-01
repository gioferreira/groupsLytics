library(RSelenium)
library(tidyverse)
library(magrittr)


# Start Session ####
rD <- rsDriver(port = 4567L, 
                browser = "chrome", 
                chromever = "74.0.3729.6", 
                verbose = FALSE)
remDr <- rD$client

# Define Login Vars ####
login_url <- "http://www.facebook.com"
my_email <- list("giovaniferreira")
my_pass <- list("CaraAmassada1")

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

loginFB(remDr, login_url, my_email, my_pass)

# Define Group Vars ####
group_url <- "https://www.facebook.com/groups/910141242384839/?sorting_setting=CHRONOLOGICAL"

# Go to group ####
remDr$navigate(group_url)

get_texts <- function(post) {
  out <- tryCatch(
    {
      unlist(post$getElementText())
    },
    error=function(cond) {
      message("Error")
      message(cond)
      return(NA)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      return(NULL)
    },
    finally={
    }
  )    
  return(out)
}
get_permalink <- function(post) {
  out <- tryCatch(
    {
      unlist(post$getElementAttribute("href"))
    },
    error=function(cond) {
      message("Error")
      message(cond)
      return(NA)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      return(NULL)
    },
    finally={
    }
  )    
  return(out)
}

postsLinks <- remDr$findElements(using = "css", value = "._5pcq")
postsTexts <- remDr$findElements(using = "css", value = "[data-testid='post_message']")

posts_tbl <- tibble(sumrTexts = character(),
                     permalink = character())

tmp_main <- tibble(sumrTexts = sapply(postsTexts, get_texts),
                   permalink = sapply(postsLinks, get_permalink))



get_poster <- function(post){
  out <- tryCatch(
    {
      unlist(post$getElementText())
    },
    error=function(cond) {
      message("Error")
      message(cond)
      return(NA)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      return(NULL)
    },
    finally={
    }
  )    
  return(out)  
}



open_link_nw <- function(post) {
  out <- tryCatch(
    {
      link <- unlist(post$getElementAttribute("href"))
      mainWindow <- remDr$getCurrentWindowHandle()
      script <- paste0('window.open("', link, '", "windowName", "height=768,width=1024");')
      remDr$executeScript(script)
      newWindow <- remDr$getWindowHandles()[[2]]
      remDr$switchToWindow(newWindow)
      postPoster <- remDr$findElement(using = "css", value = "._q7o .profileLink")
      authorProfile <- postPoster$getElementText()
      authorName <- postPoster$getElementText()
      remDr$closeWindow()
      remDr$switchToWindow(mainWindow[[1]])
      tbl <- tibble(authorName = authorName[[1]],
                    authorProfile = authorProfile[[1]])
      tbl
    },
    error=function(cond) {
      message("Error")
      message(cond)
      return(NA)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      return(NULL)
    },
    finally={
    }
  )    
  return(out)
}



post <- postsLinks[[1]]
open_link_nw(post)

sapply(postsLinks, open_link_nw)

#open each link in new window
#scrape information from each tab
#close each tab
#return to main tab
#scroll down
#get new links and sumr texts, discarding old ones
#repeat

posts_tbl %<>%
  bind_rows(temp_tbl)

remDr$win



remDr$close()
rD$server$stop()
rD$server$process

