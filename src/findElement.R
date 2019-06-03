# Retake on remDr$findElement(s) so it returns NA when an element is not found 
# For it it's a better indication of a not found
findElement <- function(remDr, 
                        using = "css",
                        value,
                        method,
                        ...){
  source("src/utils/not_in.R")
  if (method %!in% c("one", "all")) {
    stop('Method must be either "one" or "all"')
  }
  suppressMessages({
    tryCatch(
      if (method == "one") {
        remDr$findElement(using = using, 
                          value = value)
      } else if (method == "all") {
        remDr$findElements(using = using, 
                           value = value)
      }, 
      error = function(e){
        return(NA)
      })
  })
}