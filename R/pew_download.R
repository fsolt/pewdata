http://www.people-press.org/category/datasets/?download=20059299

#' Download dataset from GESIS
#'
#' Download dataset from GESIS identified by its Document Object Identifier (DOI) and filetype
#'
#' @param remDr Selenium remote driver created with \code{setup_gesis}.
#' @param doi The unique identifier for the dataset to be downloaded (see details).
#' @param filetype The filetype to be downloaded (usually only "dta" or "spss" available).
#' @param purpose The purpose for which you are downloading the data set (see details).
#' @param msg If TRUE, outputs a message showing which data set is being downloaded.
#'
#' @details Datasets reposited with GESIS are uniquely identified with a
#'   numberic identifier called a "DOI". This identifier appears both in the URL
#'   for a dataset's website, and on the website itself.
#'
#'   In addition to accepting the terms of use, you need to input a purpose for
#'   downloading a data set. The options are as follows:
#'
#' 1. for scientific research (incl. PhD)
#' 2. for reserach with commercial mandate
#' 3. for teaching as lecturer
#' 4. for my academic studies
#' 5. for my final exam (e.g. bachelor or master)
#' 6. for professional training and qualification
#'
#' @return Downloads a file.
#'
#' @examples
#' \dontrun{
#' gesis_remDr <- setup_gesis(download_dir = "downloads")
#' login_gesis(gesis_remDr, user = "myusername", pass = "mypassword")
#' download_dataset(gesis_remDr, doi = 5928)
#' }
#'
#' @export
pew_download <- function(remDr, 
                         area = "politics",
                         file_no, 
                         name = getOption("pew_name"),
                         org = getOption("pew_org"),
                         phone = getOption("pew_phone"),
                         email = getOption("pew_email"),
                         msg = TRUE) {
  
  for (item in file_no) {  
    if(msg) message("Downloading Pew file: ", item, sprintf(" (%s)", Sys.time()))
    
    # build url
    if (area == "politics") {
      url <- paste0("http://www.people-press.org/category/datasets/?download=", item)
    }
    # need to add other Pew areas
    
    remDr$navigate(url)
    
    remDr$findElement(using = "name", "Name")$sendKeysToElement(list(name))
    remDr$findElement(using = "name", "Organization")$sendKeysToElement(list(org))
    remDr$findElement(using = "name", "Phone")$sendKeysToElement(list(phone))
    remDr$findElement(using = "name", "Email")$sendKeysToElement(list(email))
    
    remDr$findElement(using = "id", "Agreement")$clickElement()
    remDr$findElement(using = "id", "submit")$clickElement()
    
    # Switch back to first window
    #  remDr$closeWindow()
    remDr$switchToWindow(remDr$getWindowHandles()[[1]])
  }
}
