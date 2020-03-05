library(tidyverse)
library(jsonlite)

read_results_json <- function(json_path) {
  results_raw <- read_json(json_path, flatten = TRUE)
  
  results <- results_raw$SearchResults$Records %>%
    as_tibble() %>%
    mutate(id = row_number()) %>%
    select(id, value = Record) %>%
    unnest(c(value)) %>%
    unnest(c(value)) %>%
    group_by(id) %>%
    mutate(property_id = row_number(), name = map(value, names)) %>%
    unnest(c(name, value)) %>%
    unnest(c(value)) %>%
    select(record_id = id, property_id, key = name, value) %>%
    group_by(record_id, property_id) %>%
    pivot_wider(names_from = key, values_from = value) %>%
    ungroup() %>%
    group_by(record_id, N, L) %>% summarise_all(paste, collapse = '\n\n---\n\n') %>% ## when we have multiple values for a property, combine into one string (otherwise pivot_longer snaps)
    ungroup() %>%
    pivot_wider(id_cols = record_id, names_from = N, values_from = V)
  
  results
}

tbs_incumbent_data <- read_results_json("data/source/TBS - Incumbent System data files.json")

na_electronic_fonds <- read_results_json("data/source/na - electronic fonds.json")

search_electronic_files <- fs::dir_ls("data/source/", regexp = "search_electronic") %>%
  enframe(name = NULL, value = "source_file_path") %>%
  mutate(
    source_file_path = as.character(source_file_path),
    source_file_id = row_number()
  )

search_electronic_results <- search_electronic_files %>%
  pull(source_file_path) %>%
  map_dfr(~ read_results_json(.x), .id = "source_file_id") %>%
  mutate(source_file_id = as.integer(source_file_id)) %>%
  left_join(search_electronic_files)



search_electronic_results %>%
  filter(
    AccessConditionDesc %in%
      c(
        "Open",
        "Open, no copying",
        "Restrictions vary"
      )
    ) %>%
  filter(LanguageOfCataloging == "eng")


## compare the CSV to the JSON
el <- read_csv("data/source/search_electronic__sub_series.csv", skip = 4)
el %>%
  remove_extra_columns() %>%
  glimpse

search_electronic_results %>%
  filter(source_file_path == "data/source/search_electronic__sub_series.json") %>%
  remove_extra_columns() %>%
  glimpse

