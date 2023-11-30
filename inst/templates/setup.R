# This is a basic setup template to create and deploy a shiny app as a package.
#
# The template includes the basic function for this process from either the usettis, attachment or devtools package.
# Selection of these function is purely subjective and can be changed or left out as required.
# Please see the documentation for these packages for more information.
#
# Also note, that a basic structure for the package was already created during project set-up.
# Nevetheless the functions bellow will be used to update the package structure and files.
#
# The file itself is stored in your dev folder, and added to the .gitignore & .Rbuildignore files.

# Get relevant packages if not available
if(interactive()) {
  if(!rlang::is_installed("available")) {
    utils::install.packages("available")
  }
  if(!rlang::is_installed("devtools")) {
    utils::install.packages("devtools")
  }
  if(!rlang::is_installed("attachment")) {
    utils::install.packages("attachment")
  }
  if(!rlang::is_installed("pkgdown")) {
    utils::install.packages("pkgdown")
  }
}

# 1. Name check
available::available("PACK_NAME")

# 2. Update Description
# 2. Description file
# --> ATTENTION: This will COMPLETELY overwrite the description file. small changes
# --> can be made with the specific functions in the next step.
# --> or even manually.
# --> HOWEVER: if you do overwrite the description file, make sure to add the relevenat packages again (see steps 4 to 7)
usethis::use_description(fields = list(
  Title = "APP_NAME",
  Version = "0.1.0",
  Description = "The APP_NAME package does the following wounderfull things...",
  "Authors@R" = utils::person("AFIRST",
                              "ALAST",
                              role = c("aut", "cre"),
                              email = paste0("ALAST", "@worldbank.org")
  ),
  Language = "en",
  License = "MIT + file LICENSE" # change this to the license chosen bellow.
))

# 2.1. Adding packages to the description file manually (under point 7 you can do this in batch)
usethis::use_package("shiny")
usethis::use_package("DT")
usethis::use_package("sass")
usethis::use_package("waiter")


# 3. License, code of conduct, badges and news
usethis::use_mit_license("AUTHOR") # You can set another license here
usethis::use_readme_rmd(open = T)

usethis::use_code_of_conduct(contact = "AUTHOR")
usethis::use_lifecycle_badge("Experimental")
usethis::use_news_md(open = FALSE)

# 4. Create importFrom entries
lsmsrprojtempl2::roxy_importFrom_fromAppDir() # Make sure, all the packages are loaded before running this function

# 5. Check for source or library entries in your files
lsmsrprojtempl2::identify_source_lib_requ(fileDir = "R", appFiles = NULL)

# 6. Special operators (optional)
usethis::use_pipe() # %>% operator
usethis::use_data_table() # when using the data.table package

# 7. Add all dependencies to the DESCRIPTION file
# this adds all the packages which are either used in importFrom or source or library
# (see documentation for details))
attachment::att_amend_desc()

# 8. Create a vignette (optional)
usethis::use_vignette("appuse", "Using the APP_NAME Application")

# 9. Create a pkgdown website (optional)
usethis::use_pkgdown()
pkgdown::build_site()

# 9.1. Deployment to github
# -->make sure non cran packages are under Remote in the DESCRIPTION file
usethis::use_pkgdown_github_pages()



