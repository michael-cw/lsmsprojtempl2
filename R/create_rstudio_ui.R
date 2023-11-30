#' @title Create Project from RStudio UI Inputs
#'
#' @description Creates a new RStudio project with a basic structure for a shiny application.
#'
#' @param path Path to the new project
#' @param ... Additional arguments passed to \code{usethis::create_package}
#'
#' @return NULL


create_proj_report_gui <- function(path, ...) {
  ########################################
  # GENERAL STRUCTURE
  # A.1 Ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)# collect inputs
  package_name <- basename(path)

  # A.2. Check that usethis, devtools and roxygen2 are installed, if not install them (only in interactive mode)
  if(interactive()) {
    if(!rlang::is_installed("usethis")) {
      utils::install.packages("usethis")
    }
    if(!rlang::is_installed("devtools")) {
      utils::install.packages("devtools")
    }
    if(!rlang::is_installed("roxygen2")) {
      utils::install.packages("roxygen2")
    }
  }

  ########################################
  ## 1. Create package structure
  dots <- list(...)


  # Create other L1 directories (dev, inst and man)
  dir.create(file.path(path, "dev"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(path, "inst"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(path, "man"), recursive = TRUE, showWarnings = FALSE)

  # create L2 directories (inst/www, man/figures)
  dir.create(file.path(path, "inst", "www"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(path, "man", "figures"), recursive = TRUE, showWarnings = FALSE)

  # copy style files to templates directory
  file.copy(
    from = system.file("styles", "styles.scss", package = "lsmsrprojtempl2"),
    to = file.path(path, "inst", "www", "styles.scss")
  )
  file.copy(
    from = system.file("styles", "logoWBDG.png", package = "lsmsrprojtempl2"),
    to = file.path(path, "inst", "www", "logoWBDG.png")
  )

  # create readme from template with replace_and_save_rmd
  # get logo
  if(dots$logo == "SuSo Quality") {
    file.copy(
      from = system.file("readme", "susotools.png", package = "lsmsrprojtempl2"),
      to = file.path(path, "man", "figures", "susotools.png")
    )
    LOGOhtml<-'<a href=\'https://docs.mysurvey.solutions/\'>
    <img src="man/figures/susotools.png" align="right" height="139"
    style="float:right; height:139px;"/></a>'

  } else if(dots$logo == "SuSo Spatial") {
    file.copy(
      from = system.file("readme", "susospatial.png", package = "lsmsrprojtempl2"),
      to = file.path(path, "man", "figures", "susospatial.png")
    )
    LOGOhtml<-'<a href=\'https://docs.mysurvey.solutions/\'>
    <img src="man/figures/susospatial.png" align="right" height="139"
    style="float:right; height:139px;"/></a>'

  } else if (dots$logo == "None") {
    LOGOhtml<-"" # no logo in readme
  }

  ########################################
  # PACKAGE META INFORMATION CREATED WITH USETHIS
  # General structure (creates description, NAMESPACE, R folder)
  afirst<-strsplit(dots$author, " ")[[1]][1]
  alast<-strsplit(dots$author, " ")[[1]][2]
  usethis::create_package(path,
                          rstudio = F,
                          roxygen = T,
                          check_name = F,
                          open = F,
                          fields = list(
                            "Authors@R" = utils::person(afirst,
                                                        alast,
                                                        role = c("aut", "cre"),
                                                        email = paste0(alast, "@worldbank.org")
                                                        ),
                            "Language" = "en",
                            "License" = "MIT + file LICENSE"
                          ))
  # set project
  usethis::proj_set( path = normalizePath(path))
  # add package level documentation
  usethis::use_package_doc(open = F)
  # add license
  usethis::use_mit_license(dots$author)
  # # add package author
  # usethis::use_author(dots$author)

  # git and build ignore
  usethis::use_git_ignore(c(".Rproj", ".Rproj.user", ".Rhistory", "dev",
  ".RData", ".Ruserdata", ".Rbuildignore"))
  usethis::use_build_ignore(c("dev", "README.Rmd", ".github", "LICENSE.md"))
  # add packages
  usethis::use_package("shiny")
  usethis::use_package("DT")
  usethis::use_package("sass")
  usethis::use_package("waiter")

  #
  # # add functions
  usethis::use_namespace()
  # # shiny
  usethis::use_import_from("shiny", c("runApp", "downloadButton",  "downloadHandler",
                                      "fileInput", "fluidPage", "mainPanel", "moduleServer", "NS", "observe", "observeEvent", "reactiveVal", "reactiveValues", "req",
                                      "selectInput", "sidebarLayout", "sidebarPanel", "tagList", "titlePanel", "updateSelectInput", "addResourcePath"), load = F)
  # DT
  usethis::use_import_from("DT", c("datatable", "DTOutput", "renderDT"), load = F)
  # waiter
  usethis::use_import_from("waiter", c("use_waiter", "waiter_hide", "waiter_show", "spin_fading_circles"), load = F)

  replacements <- list(
    "SUSOLOGO" = LOGOhtml,
    "APP_NAME" = dots$full_title,
    "APP_DESCRIPTION" = "This is a description of my app.",
    "PACK_NAME" = basename(normalizePath(path)),
    "GITREPO" = dots$gitdir,
    "RUNAPPNAME" = dots$runappname,
    "RUNAPPSERVER" = paste0(dots$runappname, "Server")
  )
  replace_and_save_rmd(system.file("readme", "README.Rmd", package = "lsmsrprojtempl2"), path, replacements)

  ########################################
  # A. runapp.R file
  replace_and_save_rmd(system.file("templates", "runapp.R", package = "lsmsrprojtempl2"), file.path(path, "R"), replacements)
  formatR::tidy_file(file.path(path, "R", "runapp.R"))

  ########################################
  # B. ui.R file
  # B.1. header
  replace_and_save_rmd(system.file("templates", "ui.R", package = "lsmsrprojtempl2"), file.path(path, "R"), replacements)
  #formatR::tidy_file(file.path(path, "R", "ui.R"))

  ########################################
  # C. server.R file
  # C.1. header
  replace_and_save_rmd(system.file("templates", "server.R", package = "lsmsrprojtempl2"), file.path(path, "R"), replacements)
  formatR::tidy_file(file.path(path, "R", "server.R"))

  ########################################
  # D. module file
  replace_and_save_rmd(system.file("templates", "module1.R", package = "lsmsrprojtempl2"), file.path(path, "R"), replacements)
  #formatR::tidy_file(file.path(path, "R", "module1.R"))

  # write .Rprofile file
  write_rprofile <- function(path) {
    # Define the path to the .Rprofile file in the current working directory
    rprofile_path <- file.path(path, ".Rprofile")

    # Define the line to write to the .Rprofile file
    line_to_write <- 'library("devtools")'

    # Write the line to the .Rprofile file
    write(line_to_write, rprofile_path)
  }
  write_rprofile(path)

}
