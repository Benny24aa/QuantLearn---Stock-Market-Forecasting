library(readr)
library(dplyr)
library(stringr)

url <- paste0(
  "https://raw.githubusercontent.com/",
  "adanos-software/free-ticker-database/",
  "main/data/listings.csv"
)

listings <- read_csv(
  url,
  show_col_types = FALSE
)

stock_lookup <- listings |>
  filter(
    str_to_lower(asset_type) == "stock",
    !is.na(ticker),
    ticker != ""
  ) |>
  distinct(
    ticker,
    exchange,
    .keep_all = TRUE
  ) |>
  select(
    any_of(c(
      "listing_key",
      "ticker",
      "name",
      "exchange",
      "exchange_name",
      "country",
      "country_code",
      "currency",
      "isin",
      "asset_type",
      "stock_sector",
      "stock_industry",
      "figi",
      "cik",
      "aliases"
    ))
  ) |>
  arrange(
    country,
    exchange,
    ticker
  )

write_csv(
  stock_lookup,
  "stock_lookup.csv"
)