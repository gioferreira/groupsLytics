# Get elem/attribu
processElem <- function(element, 
                            what, # What to extract from elem? (text, url, title)
                            ...) { 
  source("src/utils/not_in.R")
  if (what %!in% c("text", "url", "title")) {
    stop('Unknown attr')
  }
  
  tryCatch({
    if (what == "text") {
      out <- map(element, function(element){
        if (class(element)[[1]] != "webElement") stop("Element is not a webElement")
        element$getElementText()
      })
    } else if (what == "url") {
      out <- map(element, function(element){
        if (class(element)[[1]] != "webElement") stop("Element is not a webElement")
        element$getElementAttribute("href")
      })
    } else if (what == "title") {
      out <- map(element, function(element){
        if (class(element)[[1]] != "webElement") stop("Element is not a webElement")
        element$getElementAttribute("title")
      })
    }
    out },
    error = function(e){
      return(NA) # Also returns NA when element not found
    })
}