source("lib/load-helpers.R")

## Disable CORS protecton
##
#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#' Convert an LAC results JSON file to CSV.
## @param results_json The JSON results file to convert to CSV.
#' @serializer contentType list(type="text/csv")
#' @post /convert
function(req, res) {
  multipart <- mime::parse_multipart(req)
  
  ## TODO sanitize this
  results_json_path <- multipart$upload
  
  read_results_json(results_json_path) %>%
    format_csv()
}
