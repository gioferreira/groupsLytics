printScreen <- function(remDr) {
  filename <- paste0(gsub(":", "-", as.character(Sys.time())), ".png")
  filepath <- paste0("_tmp/imgs/", filename)
  remDr$screenshot(file = filepath) 
}