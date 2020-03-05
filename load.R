library(tidyverse)
library(jsonlite)

lac_results_raw <- read_json("data/source/TBS - Incumbent System data files.json", flatten = TRUE)

lac_results <- lac_results_raw$SearchResults$Records %>%
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
  pivot_wider(id_cols = record_id, names_from = N, values_from = V)
