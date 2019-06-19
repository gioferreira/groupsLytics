library(readr)
library(purrr)
library(tibble)
library(dplyr)
library(lubridate)
library(stringr)
library(skimr)
library(tidyr)

# It reads a previous saved list as tbl
readPostsList <- function(saved_list) {
  posts_list <- read_rds(saved_list)
  posts_tbl <- map(posts_list, function(post) {as_tibble(post)} )
  posts_tbl <- do.call(bind_rows, posts_tbl)
  
  posts_tbl %>% 
    mutate(postDate = dmy_hm(postDate)) %>%
    # Convert CommentsCounter to integer (it comes in the format of "10 comentários")
    mutate(commentsCounter = as.integer(str_replace(commentsCounter, " .*", ""))) %>% 
    replace_na(list(commentsCounter = 0)) %>%
    # select(interactionsCounter) %>% print(n=Inf)
    # skim()
    return()
    
    
  # Interactions Counter:
    # Tem coisas como 1,6 mil
  # detectar se tem char
  # separar 1,6 de mil
  # classificar mil (não acho que existam milhões) disparar erro caso outra coisa apareça
  # fazer a multiplicação

  

}

