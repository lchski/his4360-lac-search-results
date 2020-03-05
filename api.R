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
  cat("yoyo1\n")
  multipart <- mime::parse_multipart(req)
  cat("yoyo2\n")
  ## TODO sanitize this
  results_json_path <- multipart$upload$datapath
  cat("yoyo3\n")
  cat(results_json_path)
  cat("yoyo4\n")
  read_results_json(results_json_path) %>%
    format_csv()
}
