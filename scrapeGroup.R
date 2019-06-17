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

# Load Previous posts_list
saved_list <- "data/posts_list-2019-06-17.rds"
posts_list <- read_rds(saved_list)

# Get Posts on Screen
nw_posts_list <- getPostsList(remDr)

# append new nw_posts_List to posts_list
posts_list %<>%
  appendNew(nw_posts_list)

# Enrich posts with only 1 attr (hopefully permalink)
posts_list[lengths(posts_list) == 1] %<>%
  enrichPostList(remDr, interval = 1)

# Sroll down to the end of current page and get permalinks and sumrTexts
goToEnd(remDr, cycles = 2)
nw_posts_list <- getPostsList(remDr)

#repeat


# Stop Session ####
stopSession(rD)
# Utils ####
remDr$screenshot(display = TRUE)
