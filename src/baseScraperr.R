# Load Common Libraries
library(magrittr)
library(purrr)


# Define base functions ####
startSession <- function(headless = FALSE, # @todo test with headless = TRUE
                         gpu = TRUE,
                         windowSize = "1280,800",
                         port = 4567L,
                         ...) {
  args <- c()
  if (headless == TRUE) { args <- append(args, '--headless') }
  if (gpu == FALSE) { args <- append(args, '--disable-gpu') }
  args <- append(args, paste0('--window-size=', windowSize))
  eCaps <- list(chromeOptions = list(
    args = args))
  # @todo implement version using docker instead of rsDriver()
  rD <-rsDriver(port = port, 
                browser = "chrome", 
                chromever = "74.0.3729.6", 
                verbose = FALSE#,
                # @todo implement extraCapabilities specially to be able to use headless
                # extraCapabilities = eCaps
                # @todo is there a chromeOptions to default to "no notifications" ? 
  )
  remDr <- rD$client
  out <- list(rD = rD, remDr = remDr)
  list2env(out, envir = .GlobalEnv)
}

stopSession <- function(rD, 
                        rm = TRUE # Remove vars before Quit
){
  rD$client$closeall()
  rD$server$stop()
  out <- rD$server$process
  if (rm == TRUE) {
    rm(list = c("rD", "remDr"), pos = ".GlobalEnv")
  }
  out
}

loginFB <- function(remDr, 
                    my_email, 
                    my_pass, 
                    login_url = "http://www.facebook.com") {
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

getPostsList <- function(remDr) { 
  source("src/makeGetFunction.R")
  getPermalinks <- makeGetFunction(attrName = "permalink")
  getSumrTexts <- makeGetFunction(attrName = "sumrText")
  
  permalinks <- getPermalinks(remDr,
                              using = "css", 
                              value = "._5pcq", 
                              what = "url", 
                              method = "all",
                              attrName = "permalinks")
  
  
  
  # @TODO permalinks are selecting permalinks for locations (vargem grande) when available.
  # maybe clean up permalinks before return or change the css selector
  
  sumrText <- getSumrTexts(remDr,
                           using = "css", 
                           value = "[data-testid='post_message']",
                           what = "text",
                           method = "all",
                           attrName = "sumrText")
  
  # posts_list <- map2(permalinks, sumrText, append)
  posts_list <- permalinks
  posts_list
} # Get all permalinks and summary texts on current page

enrichPostList <- function(posts_list, remDr, ...){
  source("src/processPost.R")
  f <- function(x) {
    r <- processPost(remDr, x[['permalink']], ...)
    r
  }
  enriched_posts_list <- map(posts_list, f)
  posts_list <- map2(posts_list, enriched_posts_list, append)
  posts_list
} # Enter on each permalink and extract post features defined in processPost()

goToEnd <- function(remDr, 
                    cycles = 2, # Number of "end" key to be sent to remDr
                    interval = 4 # Seconds between each key
) { 
  body <- remDr$findElement("css", "body")
  for (i in 1:cycles){
    body$sendKeysToElement(list(key = "end"))
    Sys.sleep(interval)  
  }
  remDr$screenshot(display = FALSE)
  return(NA)
} 

appendNew <- function(posts_list, nw_posts_list) {
  source("src/getPermalinks.R")
  previous_permalinks <- getPermalinks(posts_list)
  
  f <- function(nw_post) {
    if (nw_post[['permalink']] %!in% previous_permalinks) { nw_post }
  }
  
  posts_list %>% 
    append(compact(map(nw_posts_list, f))) %>%
    return()
} # Given x and y lists, appends only the new/different elements from the y to x