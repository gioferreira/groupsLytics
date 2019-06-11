# Make Get functions which find an elem using findElement 
makeGetFunction <- function(appendName = TRUE, # @todo test with false
                            attrName, # Name to be appended when appendName = TRUE
                            ...) {
  # ... args
  # 'using' and 'value' and 'method' which are passed to findElement
  # 'what' which is passed to processLinkElem
  # Args Handling ####
  if (appendName == TRUE & is.null(attrName)){
    stop("attrName can't be NULL when appendName == TRUE")
  }
  if (is.null(attrName)) {
    attrName <- elem
  }
  
  # Define getFunction ####
  getFunction <- function(remDr, 
                          simplify = TRUE # Unlist when length == 1
  ){ 
    source("src/findElement.R")
    source("src/processElem.R")
    element <- findElement(remDr, ...)
    element <- processElem(element, ...)
    if (appendName == TRUE){
      element <- map(element, set_names, nm = attrName)
    }
    
    if (simplify == TRUE && length(element) == 1) {
      element <- unlist(element)
    }
    
    element
  }
  
  return(getFunction)
}
