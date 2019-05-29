library(RSelenium)
library(tidyverse)
library(magrittr)

#Start Session
rD <- rsDriver(port = 4567L, browser = "chrome", verbose = FALSE)
remDr <- rD$client

#Define Login Vars
login_url <- "http://www.facebook.com"
my_email <- list("giovaniferreira")
my_pass <- list("CaraAmassada1")

#Login
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

#Define Group Vars
group_url <- "https://www.facebook.com/groups/910141242384839/?sorting_setting=CHRONOLOGICAL"

#Go to group
remDr$navigate(group_url)

postsLinks <- remDr$findElements(using = "css", value = "._5pcq")

posts_tbl <- tibble(permalink = character())

get_texts <- function(post) {
  out <- tryCatch(
    {
      unlist(post$getElementText())
    },
    error=function(cond) {
      message("Error")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      # Choose a return value in case of warning
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
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message("Warning")
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={
    }
  )    
  return(out)
}

posts_tbl %<>%
  add_row(permalink = sapply(postsLinks, get_permalink))



remDr$close()
rD$server$stop()
rD$server$process

