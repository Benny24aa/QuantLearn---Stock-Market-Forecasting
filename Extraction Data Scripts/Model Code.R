library(data.table)

files <- list.files(
  "stock_data",
  pattern = "\\.csv$",
  full.names = TRUE
)

files <- files[
  basename(files) != "failed.csv"
]

df <- rbindlist(
  lapply(
    files,
    function(x) {
      fread(
        x,
        colClasses = list(
          character = c(
            "listing_key",
            "ticker",
            "exchange",
            "name",
            "country",
            "country_code",
            "currency",
            "isin",
            "figi"
          )
        )
      )
    }
  ),
  fill = TRUE
)

library(arrow)

write_parquet(
  df,
  "market_data_stage_one.parquet"
)