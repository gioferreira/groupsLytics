library(tidyverse)
library(rvest)

login <- "https://www.facebook.com/"
pgsession <- html_session(login, 
                        httr::add_headers(.headers = c("Connection" = "keep-alive",
                                                 "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                                                 "User-Agent" =  "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
                                                 "Accept-Encoding" = "gzip,deflate,sdch",
                                                 "Accept-Language" = "en-GB,en;q=0.8,en-US;q=0.6,es;q=0.4,fr;q=0.2,ja;q=0.2")))
pgform <- html_form(pgsession)[[1]]  #in this case the submit is the 2nd form
filled_form <- set_values(pgform, 
                          email = "giovaniferreira", 
                          pass = "CaraAmassada1")
submit_form(pgsession, filled_form)

results <- tibble()

url <- "https://www.facebook.com/groups/910141242384839/?sorting_setting=CHRONOLOGICAL"

page <- jump_to(pgsession, url)

#Loading both the required libraries
library(V8)
#URL with js-rendered content to be scraped
link <- url
#Read the html page content and extract all javascript codes that are inside a list
emailjs <- read_html(link) %>% 
  html_nodes('script') %>% html_text()
# Create a new v8 context
ct <- v8()
#parse the html content from the js output and print it as text
read_html(ct$eval(gsub('document.write','',emailjs))) %>% 
  html_text()

html <- read_html(page)

html %>% 
  html_nodes("div") %>% html_text() %>% view()
  html_nodes("._4-u8") %>%
  html_nodes("p")
  html_text()
