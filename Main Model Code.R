library(arrow)
library(tidyverse)
library(TTR)

Stock_lookup <- read.csv("stock_lookup.csv")%>% 
  filter(exchange == "LSE") %>% 
  select(listing_key, asset_type, stock_sector, aliases )

LSE_Data <- open_dataset("market_data_stage_one.parquet") %>% 
  filter(
    date >= as.Date("2024-01-01"),
    exchange == "LSE"
  ) %>% 
  select(
    listing_key,ticker,exchange,name,country,date,open,high,low,close,volume,adjusted
  ) %>% 
  collect() %>% 
  left_join(Stock_lookup, by = "listing_key")

#### Smoothing Moving Average Function
SMA <- function(x, n) {
  result <- rep(NA_real_, length(x))
  valid <- !is.na(x)
  
  if (sum(valid) >= n) {
    result[valid] <- TTR::SMA(x[valid], n = n)
  }
  
  result
}

LSE_Data <- LSE_Data %>%
  arrange(listing_key, date) %>%
  group_by(listing_key) %>%
  mutate(
    SMA_7 = SMA(close, 7),
    SMA_14 = SMA(close, 14),
    SMA_20 = SMA(close, 20),
    SMA_50 = SMA(close, 50),
    SMA_100 = SMA(close, 100),
    SMA_100 = SMA(close, 200)
  ) %>%
  ungroup()
