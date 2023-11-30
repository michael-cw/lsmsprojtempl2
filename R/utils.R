#' Update readme.Rmd file with new values
#'
#' @param file_path Path to the readme.Rmd file
#' @param new_dir Path to the new directory
#' @param replacements List of replacements to make
#'
#' @return NULL
#'
#' @keywords internal
#' @export

replace_and_save_rmd <- function(file_path, new_dir, replacements) {
  # Read the contents of the Rmd file
  content <- readLines(file_path, warn = FALSE)

  # Replace placeholders with new values
  for (key in names(replacements)) {
    replacement_value <- replacements[[key]]
    content <- gsub(key, replacement_value, content)
  }

  # Create new directory if it does not exist
  if (!dir.exists(new_dir)) {
    dir.create(new_dir, recursive = TRUE)
  }

  # Construct new file path
  new_file_path <- file.path(new_dir, basename(file_path))

  # Write the new content to the new Rmd file
  writeLines(content, new_file_path)
}

# # Example usage
# replacements <- list(
#   "SUSOLOGO" = '<a href=\'https://docs.mysurvey.solutions/\'>
#   <img src="man/figures/susotools.png" align="right" height="139"
#   style="float:right; height:139px;"/></a>',
#   "APP_NAME" = "My Shiny App",
#   "APP_DESCRIPTION" = "This is a description of my app.",
#   "PACK_NAME" = "myshinyapp",
#   "GITREPO" = "michael-cw"
# )
# replace_and_save_rmd("./inst/readme/README.Rmd", "./dev/", replacements)
