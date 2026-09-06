# library(httr2)
# library(jsonlite)
# library(dplyr)
# library(purrr)
# library(readr)
# library(tidyr)
# library(stringr)
# library(quantmod)
# 
# stocks <- c(
#   "AAPL",
#   "MSFT",
#   "NVDA",
#   "AMZN",
#   "GOOGL"
# )
# 
# 
# get_stock <- function(ticker,
#                       from = "2010-01-01") {
#   
#   message("Downloading: ", ticker)
#   
#   tryCatch({
#     
#     x <- getSymbols(
#       ticker,
#       src = "yahoo",
#       from = from,
#       auto.assign = FALSE,
#       warnings = FALSE
#     )
#     
#     data.frame(
#       ticker = ticker,
#       date = index(x),
#       coredata(x)
#     )
#     
#   }, error = function(e) {
#     
#     message(
#       "Failed: ",
#       ticker,
#       " | ",
#       conditionMessage(e)
#     )
#     
#     NULL
#   })
# }
# 
# prices <- map_dfr(
#   stocks,
#   get_stock
# )
# 
# write.csv(
#   prices,
#   "stock_prices.csv",
#   row.names = FALSE
# )



