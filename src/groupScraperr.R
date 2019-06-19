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
  saveList <- function(){
    if (save_list == TRUE) {
      file_name <- paste0("posts_list-", Sys.Date())
      save_path <- paste0("data/", file_name, ".rds")
      write_rds(posts_list, save_path)
    }
  }
  
  startSession(...)
  loginFB(remDr, my_email, my_pass)
  openGroup(group_id)
  
  if (is.null(saved_list)) {
    posts_list <- getPostsList(remDr)
  } else {
    posts_list <- read_rds(saved_list)
  }
  posts_list_init_len <- length(posts_list)
  counter <- 0
  print(paste0("posts_list initial length: ", posts_list_init_len))
  while (counter < count) {
  # Get Posts on Screen
    nw_posts_list <- getPostsList(remDr)
    
    # append new nw_posts_List to posts_list
    posts_list %<>%
      appendNew(nw_posts_list)
    
    counter <- (length(posts_list) - posts_list_init_len)
    
    saveList()
    print(paste0("posts added so far: ", counter))
    
    posts_to_enrich <- length(posts_list[lengths(posts_list) == 1])
    print(paste0("posts to enrich: ", posts_to_enrich))
    # Enrich posts with only 1 attr (hopefully permalink)
    posts_list[lengths(posts_list) == 1] %<>%
      enrichPostList(remDr, ...)
    saveList()
    print("posts enriched, scrolling down")
    # Sroll down to the end of current page
    goToEnd(...)
    
  }
  
  posts_list_final_len <- length(posts_list)
  print(paste0("posts_list final length: ", posts_list_final_len))
  print(paste0("Total posts added: ", posts_list_final_len - posts_list_init_len))
  saveList()
  
  stopSession(rD)
  
  if (return_tbl == TRUE) {
    posts_tbl <- map(posts_list, function(post) {as_tibble(post)} )
    posts_tbl <- do.call(bind_rows, posts_tbl)
    return(posts_tbl)
  } else {
    return(posts_list)
  }
}

