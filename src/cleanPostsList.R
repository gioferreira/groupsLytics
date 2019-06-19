library(purrr)

# This function gets a posts_list and remove data from posts where the postDate wasn't found
# It just keeps the permalink, so it's enriched again when it goes through the groupScraperr
# @todo implement diferent scenarios where the data might need to be removed.
# This postdate thing was due to a change on the css locator for the postDate

cleanPostsList <- function(posts_list) {
  cleanPost <- function(post) {
    cleaned_post <- post
    if (nchar(post['postDate']) == 0 | is.null(post['postDate']) | is.na(post['postDate'])){
      cleaned_post <- post['permalink']
    }
    return(cleaned_post)
  }
  cleaned_list <- map(posts_list, cleanPost)
  compact(cleaned_list)
}