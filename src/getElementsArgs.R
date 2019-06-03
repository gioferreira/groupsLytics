# Elements Args for makeGetFuncion.
# They basically define the findElement params for each get function
getElementsArgs <- function(){
  author_name_args <- list(using = "css",
                           value = '.fwb  [ajaxify*="member_bio"]',
                           method = "one",
                           what  = "text",
                           attrName = "authorName")
  
  author_link_args <- list(using = "css", 
                           value = '.fwb  [ajaxify*="member_bio"]',
                           method = "one",
                           what = "url",
                           attrName = "authorLink")
  
  interactions_args <- list(using = "css", 
                            value = "._81hb",
                            method = "one",
                            what = "text",
                            attrName = "interactions")
  comments_counter_args <- list(using = "css", 
                                value = '[data-testid*="CommentsCount"',
                                method = "one",
                                what = "text",
                                attrName = "commentsCounter")
  post_message_args <- list(using = "css", 
                            value = '[data-testid*="post_message"',
                            method = "one",
                            what = "text",
                            attrName = "postMessage")
  
  elementsArgs <- list(author_name_args = author_name_args,
                       author_link_args = author_link_args,
                       interactions_args = interactions_args,
                       comments_counter_args = comments_counter_args,
                       post_message_args = post_message_args)
  list2env(elementsArgs)
}