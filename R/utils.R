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

#' Create importFrom entries as a text file
#'
#' @description Creates a text file with the importFrom entries for the app
#'
#' @details
#' This function uses the NCmisc::list.functions.in.file function to get all functions in the app directory. To make this work
#' correctly, the app directory needs to contain a R directory with all the R files of the app, and all the packages need to be
#' installed and loaded. The function then loops over all the functions and checks if they are exported from a package. If they
#' are, the function creates an importFrom entry for the package. The function then writes the importFrom entries to a text file,
#' which can be copied to the package level documentation file, or any other location. Please be aware, that not all functions
#' may be identified correctly, and that the importFrom entries may need to be adjusted manually.
#'
#'
#' @param appDir Path to the app directory, which need to contain a R directory
#' @param filename Path to the file to be created
#'
#' @return NULL
#'
#' @export


roxy_importFrom_fromAppDir<-function(appDir = ".", filename = "./roxy_importFromFull.txt") {

  # Get the list of file paths
  fpHelp<-file.path(appDir, "R")
  filelist<-list.files(fpHelp, pattern = ".R$", full.names = T)

  list.functions.in.file_clean<-function(x) {
    lists <- list()
    # get all functions
    flist<-NCmisc::list.functions.in.file(x)
    # set global/character to privateFunction
    names(flist)[names(flist)%in%c("character(0)", ".GlobalEnv")]<-"privateFunction"
    # combine same
    flist<-tapply(unlist(flist, use.names = F, recursive=FALSE), rep(names(flist), lengths(flist)), FUN = c)
    # clear names
    names(flist) <- gsub("package:", "", names(flist))
    # loop over names and create entry when multiple targets
    for (name in names(flist)) {
      neval<-tryCatch(
        {eval(parse(text = name))},
        error = function(e) {return((name))}
      )
      # if more than one package create repeated entry for each
      if(length(neval)>1) {
        for(ne in neval) {
          if(ne%in%names(flist)) {
            flist[[ne]]<-unique(c(flist[[name]], flist[[ne]]))
          } else {
            flist[[ne]]<-flist[[name]]
          }
        }
        flist[[name]]<-NULL
      } else {
        #flist[[name]]<-flist[[name]]
      }
    }
    return(flist)
  }
  LISTS<-sapply(filelist, list.functions.in.file_clean, USE.NAMES = F)
  #names(LISTS)<-basename(tools::file_path_sans_ext(filelist))
  # combine elements with same name and keep only unique
  LISTS<-unlist(LISTS, recursive = F, use.names = T)
  LISTS<-tapply(unlist(LISTS, use.names = FALSE), rep(names(LISTS), lengths(LISTS)), FUN = function(x) sort(unique(c(x))))

  # create the string
  create_string <- function(lists) {
    strings <- c()
    for (name in names(lists)) {
      print(name)
      # exclude base and private function
      if(name%in%c("base", "privateFunction")) next()
      elements <- lists[[name]]
      string<-sprintf("#' @importFrom %s %s", name, paste(elements, collapse = " "))
      strings <- c(strings, string)
    }

    return(strings)
  }
  LISTSstring<-create_string(LISTS)

  # write to file
  write_to_file <- function(strings, filename) {
    writeLines(as.character(strings), con = filename, sep = "\n")
  }
  write_to_file(LISTSstring, filename)

  return(LISTS)
}


#' Identify any source, library or require entries in your script
#'
#' @description This function identifies any source, library or require entries in your script and returns them as a list. However
#' the pattern can be changed to identify any other entries, which are not supposed to be included in a package.
#'
#' @param appDir Path to the app directory
#' @param fileDir Path to the directory containing the files to be checked
#' @param appFiles Files to be checked in the app directory, usually server.R and ui.R, when transforming a classic shiny app structure. Set this
#' to NULL if you only want to check the files in the fileDir
#' @param pattern Pattern to be used to identify the entries, default is "(^source)|(^library)|(^require)"
#'
#' @return A list with the file names as names and the identified entries as elements
#'
#' @export


identify_source_lib_requ<-function(appDir = ".",
                                   fileDir = "helpers",
                                   appFiles = c("ui.R", "server.R"),
                                   pattern = "(^source)|(^library)|(^require)") {

  # Get the list of file pathes, add server and ui, currently only with helper
  fpHelp<-file.path(appDir, fileDir)
  filelist<-list.files(fpHelp, pattern = ".R$", full.names = T)
  if(!is.null(appFiles)) filelist<-c(file.path(appDir, appFiles), filelist)
  fullList<-list()
  for (fl in filelist) {
    fllines<-readLines(con = fl, skipNul = T, encoding = "UTF-8")
    fllines<-fllines[grepl(pattern = pattern, fllines)]
    # skip if no lines
    if(length(fllines)==0) next()
    # return if file has entries
    lname<-basename(tools::file_path_sans_ext(fl))
    fullList[[lname]]<-fllines

  }
  return(fullList)

}
