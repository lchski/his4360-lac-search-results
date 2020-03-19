source("lib/load-helpers.R")

tbs_incumbent_data <- read_results_json("data/source/TBS - Incumbent System data files.json")

na_electronic_fonds <- read_results_json("data/source/na - electronic fonds.json")

search_electronic_files <- fs::dir_ls("data/source/", regexp = "search_electronic") %>%
  enframe(name = NULL, value = "source_file_path") %>%
  mutate(
    source_file_path = as.character(source_file_path),
    source_file_id = row_number()
  ) %>%
  filter(str_detect(source_file_path, ".json"))

search_electronic_results <- search_electronic_files %>%
  pull(source_file_path) %>%
  map_dfr(~ read_results_json(.x), .id = "source_file_id") %>%
  mutate(source_file_id = as.integer(source_file_id)) %>%
  left_join(search_electronic_files)



# curl -v -F "upload=data/source/search_electronic__sous_fonds.json" "http://localhost:8000/convert" -H "accept: application/json"
read_results_json("data/source/search_electronic__sous_fonds.json")


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

search_electronic_results %>%
  filter(
    AccessConditionDesc %in%
      c(
        "Open",
        "Open, no copying",
        "Restrictions vary"
      )
  ) %>%
  filter(LanguageOfCataloging == "eng") %>%
  filter(Source == "Private") %>% ## or "Government"
  filter(str_detect(Title, "electronic")) %>%
  remove_extra_columns() %>%
  View()

search_electronic_results %>%
  filter(
    AccessConditionDesc %in%
      c(
        "Open",
        "Open, no copying",
        "Restrictions vary"
      )
  ) %>%
  filter(LanguageOfCataloging == "eng") %>%
  filter(Source == "Private") %>% ## "Private" or "Government"
  filter(str_detect(Title, "electronic")) %>%
  filter(str_detect(TypeOfMaterial, regex("Textual", ignore_case = TRUE))) %>%
  remove_extra_columns() %>%
  select(Title, DateIssued, AccessConditionDesc, TypeOfMaterial, DateYear, HierarchyLevel, DisplayUrl) %>%
  View()


## compare the CSV to the JSON
el <- read_csv("data/source/search_electronic__sub_series.csv", skip = 4)
el %>%
  remove_extra_columns() %>%
  glimpse

search_electronic_results %>%
  filter(source_file_path == "data/source/search_electronic__sub_series.json") %>%
  remove_extra_columns() %>%
  glimpse


## run the API
plumb("api.R")$run(port=8000)




government_fonds <- read_results_json("data/source/browse__fonds_collections__government.json")

