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

stock_lookup <- listings %>% 
  filter(
    str_to_lower(asset_type) == "stock",
    !is.na(ticker),
    ticker != "",
    exchange == "LSE"
  ) %>% 
  distinct(
    ticker,
    exchange,
    .keep_all = TRUE
  ) %>% 
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
  ) %>% 
  arrange(
    country,
    exchange,
    ticker
  )

write_csv(
  stock_lookup,
  "stock_lookup.csv"
)

stocks <- stock_lookup

failed <- tibble(
  listing_key = character(),
  ticker = character(),
  exchange = character(),
  error = character()
)

for (i in seq_len(nrow(stocks))) {
  
  ticker <- stocks$ticker[i]
  yahoo_ticker <- paste0(ticker, ".L")
  listing_key <- stocks$listing_key[i]
  
  message(
    i,
    " / ",
    nrow(stocks),
    " | ",
    ticker,
    " | ",
    yahoo_ticker
  )
  
  data <- tryCatch(
    getSymbols(
      yahoo_ticker,
      src = "yahoo",
      from = "1900-01-01",
      to = Sys.Date(),
      auto.assign = FALSE,
      warnings = FALSE
    ),
    error = function(e) {
      message(
        "FAILED | ",
        ticker,
        " | ",
        conditionMessage(e)
      )
      NULL
    }
  )
  
  if (is.null(data)) {
    
    failed <- bind_rows(
      failed,
      tibble(
        listing_key = listing_key,
        ticker = ticker,
        exchange = stocks$exchange[i],
        error = "Yahoo data unavailable"
      )
    )
    
    next
  }
  
  output <- data.frame(
    listing_key = listing_key,
    ticker = ticker,
    exchange = stocks$exchange[i],
    name = stocks$name[i],
    country = stocks$country[i],
    date = as.Date(index(data)),
    open = as.numeric(Op(data)),
    high = as.numeric(Hi(data)),
    low = as.numeric(Lo(data)),
    close = as.numeric(Cl(data)),
    volume = as.numeric(Vo(data)),
    adjusted = as.numeric(Ad(data))
  )
  
  safe_name <- gsub(
    "[^A-Za-z0-9_.-]",
    "_",
    listing_key
  )
  
  write_csv(
    output,
    paste0(
      "LSE Data/",
      safe_name,
      ".csv"
    )
  )
}

write_csv(
  failed,
  "LSE Data/failed.csv"
)