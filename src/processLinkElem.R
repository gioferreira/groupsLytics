# Get link elem/attribu
processLinkElem <- function(element, 
                            what, # What to extract from links? (text or url)
                            ...) { 
  source("src/utils/not_in.R")
  if (what %!in% c("text", "url")) {
    stop('Unknown attr')
  }
  
  tryCatch({
    if (what == "text") {
      out <- map(element,function(element){
        if (class(element)[[1]] != "webElement") stop("link is not a webElement")
        element$getElementText()
      })
    } else if (what == "url") {
      out <- map(element,function(element){
        if (class(element)[[1]] != "webElement") stop("link is not a webElement")
        element$getElementAttribute("href")
      })
    }
    out},
    error = function(e){
      return(NA) # Also returns NA when element not found
    })
}