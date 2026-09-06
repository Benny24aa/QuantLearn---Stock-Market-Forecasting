library(arrow)
library(dplyr)
library(lubridate)

folder <- "Stock Data Parquets"

dataset <- open_dataset(
  folder,
  format = "csv"
)

sample_listings <- dataset  %>% 
  select(listing_key) %>% 
  distinct() %>% 
  collect() %>% 
  slice_sample(n = 1000)

df <- dataset %>% 
  semi_join(
    sample_listings,
    by = "listing_key"
  ) %>% 
  collect()