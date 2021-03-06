library(tidyverse)
library(jsonlite)

library(helpers)

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