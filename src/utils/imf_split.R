library(tidyverse)

file_list <- c(
  "adv_annual.csv",
  "developing_annual.csv",
  "other_annual.csv"
)

code_list <- list()

for (file in file_list) {
  country_group <- strsplit(file, "_")[[1]][1]
  df <- read_csv(
    paste0("../../examples/imf/", file),
    col_select = "Country Code", lazy=T, 
    show_col_types = F, name_repair = "minimal"
  )
  country_codes <- df %>%
    distinct(`Country Code`) %>%
    pull()
  # add to named list
  code_list[[country_group]] <- country_codes
}

split_imf_data <- function(df) {
  split_dfs <- list()
  for (group in names(code_list)) {
    codes <- code_list[[group]]
    split_df <- df %>%
      filter(`Country Code` %in% codes)
    split_dfs[[group]] <- split_df
  }
  return(split_dfs)
}


