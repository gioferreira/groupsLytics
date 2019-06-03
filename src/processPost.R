processPost <- function(remDr, permalink, interval = 2) {
  source("src/getElementsArgs.R")
  elementsArgs <- getElementsArgs()
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
  
  authorName <- getAuthorName(remDr)
  authorLink <- getAuthorLink(remDr)
  interactionsCounter <- getInteractions(remDr)
  commentsCounter <- getCommentsCounter(remDr)
  postMessage <- getPostMessage(remDr)
  
  Sys.sleep(interval)
  
  remDr$closeWindow()
  remDr$switchToWindow(mainWindow)
  
  out <- list(authorName = authorName,
              authorLink = authorLink,
              interactionsCounter = interactionsCounter,
              commentsCounter = commentsCounter,
              postMessage = postMessage)
  out
}