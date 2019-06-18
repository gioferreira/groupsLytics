# Load Common Libraries
library(magrittr)
library(purrr)
library(tibble)
library(dplyr)


# # Utils ####
# remDr$screenshot(display = TRUE)

groupScraperr <- function(my_email, 
                          my_pass, 
                          group_id,
                          count = 20,
                          save_list = TRUE,
                          saved_list = NULL,
                          return_tbl = FALSE,
                          ...) {
  source("src/baseScraperr.R")
  
  startSession(...)
  loginFB(remDr, my_email, my_pass)
  openGroup(group_id)
  
  if (is.null(saved_list)) {
    posts_list <- getPostsList(remDr)
  } else {
    posts_list <- read_rds(saved_list)
  }
  
  counter <- 0
  while (counter < count) {
    posts_list_init_len <- length(posts_list)
    
    # Get Posts on Screen
    nw_posts_list <- getPostsList(remDr)
    
    # append new nw_posts_List to posts_list
    posts_list %<>%
      appendNew(nw_posts_list)
    
    posts_list_final_len <- length(posts_list)
    counter <- posts_list_final_len - posts_list_init_len
    
    # Enrich posts with only 1 attr (hopefully permalink)
    posts_list[lengths(posts_list) == 1] %<>%
      enrichPostList(remDr, ...)
    print(paste0(counter, "post(s) added so far"))
    
    # Sroll down to the end of current page
    goToEnd(remDr, ...)
  }
  
  stopSession(rD)
  
  if (save_list == TRUE) {
    file_name <- paste0("posts_list-", Sys.Date())
    save_path <- paste0("data/", file_name, ".rds")
    write_rds(posts_list, save_path)
  }
  
  if (return_tbl == TRUE) {
    posts_tbl <- map(posts_list, function(post) {as_tibble(post)} )
    posts_tbl <- do.call(bind_rows, posts_tbl)
    return(posts_tbl)
  } else {
    return(posts_list)
  }
}

