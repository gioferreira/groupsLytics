# Load Libraries and tools ####
library(RSelenium)
library(readr)
library(magrittr)
source("src/seleniumFBScraper.R")

# Scrape Specific Group ####

# Define credentials & group_id
my_email <- read_rds("data/my_email.rds")
my_pass <- read_rds("data/my_pass.rds")
group_id <- read_rds("data/group_id.rds")

startSession()
loginFB(remDr, my_email, my_pass)

openGroup(group_id)
posts_list <- getPostsList(remDr)
posts_list[1:3] %<>% 
  enrichPostList(remDr, interval = 1)
# save enriched_posts_list

# Sroll down to the end of current page and get permalinks and sumrTexts
goToEnd(remDr, cycles = 2)
nw_posts_list <- getPostsList(remDr)

# append new nwPosts_List to erinched_posts_list
previous_permalinks <- getPermalinks(posts_list)

#enrich those
#repeat
# Stop Session ####
stopSession(rD)
# Utils ####
remDr$screenshot(display = TRUE)
