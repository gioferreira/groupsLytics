# Load Libraries and tools ####
library(RSelenium)
library(readr)
library(magrittr)
source("src/groupScraperr.R")

# Scrape Specific Group ####

# Define credentials & group_id
my_email <- read_rds("data/my_email.rds")
my_pass <- read_rds("data/my_pass.rds")
group_id <- read_rds("data/group_id.rds")

startSession()
loginFB(remDr, my_email, my_pass)

openGroup(group_id)

posts_list <- getPostsList(remDr)
posts_list %<>% 
  enrichPostList(remDr, interval = 1)

# Save and/or open enriched_posts_list
outfile <- paste0("data/posts_list-", Sys.Date(), ".rds")
write_rds(posts_list, outfile)

posts_list <- read_rds(outfile)

# Sroll down to the end of current page and get permalinks and sumrTexts
goToEnd(remDr, cycles = 2)
nw_posts_list <- getPostsList(remDr)

# append new nw_posts_List to posts_list
posts_list %<>%
  appendNew(nw_posts_list)

posts_list[lengths(posts_list) == 1] %<>%
  enrichPostList(remDr, interval = 1)

#repeat
# Stop Session ####
stopSession(rD)
# Utils ####
remDr$screenshot(display = TRUE)
