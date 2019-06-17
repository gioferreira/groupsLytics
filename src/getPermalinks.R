# Given  a posts_list returns only permalinks
getPermalinks <- function(posts_list) { 
  permalinks <- map(posts_list, function(post){ post[['permalink']] })
  permalinks
}