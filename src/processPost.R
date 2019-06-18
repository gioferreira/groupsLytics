processPost <- function(remDr, permalink, interval, ...) {
  source("src/getElementsArgs.R")
  elementsArgs <- getElementsArgs()
  getPostDate <- do.call(makeGetFunction, elementsArgs$post_date_args)
  getAuthorName <- do.call(makeGetFunction, elementsArgs$author_name_args)
  getAuthorLink <- do.call(makeGetFunction, elementsArgs$author_link_args)
  getInteractions <- do.call(makeGetFunction, elementsArgs$interactions_args)
  getCommentsCounter <- do.call(makeGetFunction, elementsArgs$comments_counter_args)
  getPostMessage <- do.call(makeGetFunction, elementsArgs$post_message_args)
  
  
  mainWindow <- unlist(remDr$getCurrentWindowHandle())
  script <- paste0('window.open("', permalink, '", "windowName", "height=800,width=1280");')
  remDr$executeScript(script)
  newWindow <- remDr$getWindowHandles()[[2]]
  remDr$switchToWindow(newWindow)
  
  scrapeTime <- Sys.time()
  # getPostDate(remDr, using = "css", value = 'abbr[class*=\"timestamp\"]', method = "one", what = "title", attrName = "postDate")
  
  postDate <- do.call(getPostDate, 
                      c(remDr = remDr, 
                        elementsArgs$post_date_args))
  authorName <- do.call(getAuthorName, 
                        c(remDr = remDr,
                          elementsArgs$author_name_args))
  authorLink <- do.call(getAuthorLink, 
                        c(remDr = remDr,
                          elementsArgs$author_link_args))
  interactionsCounter <- do.call(getInteractions, 
                                 c(remDr = remDr,
                                   elementsArgs$interactions_args))
  commentsCounter <- do.call(getCommentsCounter, 
                             c(remDr = remDr,
                               elementsArgs$comments_counter_args))
  postMessage <- do.call(getPostMessage, 
                         c(remDr = remDr,
                           elementsArgs$post_message_args))
  
  
  
  Sys.sleep(interval)
  
  remDr$closeWindow()
  remDr$switchToWindow(mainWindow)
  
  out <- list(scrapeTime = scrapeTime,
              postDate = postDate,
              authorName = authorName,
              authorLink = authorLink,
              interactionsCounter = interactionsCounter,
              commentsCounter = commentsCounter,
              postMessage = postMessage)
  out
}