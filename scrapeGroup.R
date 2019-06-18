# Load Libraries and tools ####
library(RSelenium)
library(readr)
library(tibble)
library(dplyr)

source("src/groupScraperr.R")

# Scrape Specific Group ####

# Define credentials & group_id
my_email <- read_rds("data/my_email.rds")
my_pass <- read_rds("data/my_pass.rds")
group_id <- read_rds("data/group_id.rds")


# If there's a previous list
saved_list <- "data/posts_list-2019-06-18.rds"


groupScraperr(my_email = my_email, 
              my_pass = my_pass, 
              group_id = group_id,
              count = 6,
              save_list = TRUE,
              saved_list = saved_list, # Can be ommitted 
              interval = 2,
              return_tbl = TRUE)





