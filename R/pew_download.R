#' Download datasets from the Pew Research Center
#'
#' \code{pew_download} provides a programmatic and reproducible means to download survey datasets from the Pew Research Center 
#'
#' @param area One of the seven research areas of the Pew Research Center 
#'  (see details).
#' @param file_id The unique identifier (or optionally a vector of these identifiers)
#'  for the dataset(s) to be downloaded (see details).
#' @param name,org,phone,email Contact information to submit to Pew Research Center
#'  (see details).
#' @param reset If TRUE, the register information will be reset. The default is FALSE.
#' @param download_dir The directory (relative to your working directory) to
#'   which files from the Pew Research Center will be downloaded.
#' @param msg If TRUE, outputs a message showing which data set is being downloaded.
#' @param unzip If TRUE, the downloaded zip files will be unzipped.
#' @param delete_zip If TRUE, the downloaded zip files will be deleted.
#'
#' @details The Pew Research Center has seven areas of research focus.  Pass one of the 
#'  following strings to the \code{area} argument to specify which area generated
#'  the datasets you want to download:
#'  
#'  \code{politics} U.S. Politics & Policy (the default)
#'  
#'  \code{journalism} Journalism & Media
#'  
#'  \code{internet} Internet, Science & Tech
#'  
#'  \code{religion} Religion & Public Life
#'  
#'  \code{hispanic} Hispanic Trends
#'  
#'  \code{global} Global Attitudes & Trends
#'  
#'  \code{socialtrends} Social & Demographic Trends
#'
#'  To avoid requiring others to edit your scripts to insert their own contact 
#'  information, the default is set to fetch this information from the user's 
#'  .Rprofile.  Before running \code{pew_download}, then, you should be sure to
#'  add these options to your .Rprofile substituting your info for the example below:
#'
#'  \code{
#'   options("pew_name" = "Juanita Herrera",
#'          "pew_org" = "Upper Midwest University",
#'          "pew_phone" = "888-000-0000",
#'          "pew_email" = "jherrera@uppermidwest.edu")
#'  }
#'
#' @return The function returns downloaded files.
#'
#' @examples
#' \dontrun{
#'  pew_download(file_id = c(20059299, 20058139))
#' }
#'
#' @importFrom rvest html_session html_form set_values submit_form
#' @importFrom magrittr "%>%"
#' @importFrom purrr walk
#' 
#' @export

pew_download <- function(area = "politics",
                         file_id, 
                         name = getOption("pew_name"),
                         org = getOption("pew_org"),
                         phone = getOption("pew_phone"),
                         email = getOption("pew_email"),
                         reset = FALSE,
                         download_dir = "pew_data",
                         msg = TRUE,
                         unzip = TRUE,
                         delete_zip = TRUE) {
  
  # Detect the login info
  if (reset){
    name <- org <- phone <- email <- NULL
  }
  
  if (is.null(name)){
    pew_name <- readline(prompt = "Please enter the name to register the download: \n")
    options("pew_name" = pew_name)
    name <- getOption("pew_name")
  }
  
  if (is.null(org)){
    pew_org <- readline(prompt = "Please enter the organization to register the download: \n")
    options("pew_org" = pew_org)
    org <- getOption("pew_org")
  }
  
  if (is.null(phone)){
    pew_phone = readline(prompt = "Please enter the phone to register the download: \n")
    options("pew_phone" = pew_phone)
    phone <-  getOption("pew_phone")
  }
  
  if (is.null(email)){
    pew_email <- readline(prompt = "Please enter the email to register the download: \n")
    options("pew_email" = pew_email)
    email <- getOption("pew_email")
  }

  # Get list of current download directory contents
  if (!dir.exists(download_dir)) dir.create(download_dir, recursive = TRUE)
  dd_old <- list.files(download_dir)
  
  # Loop through files
  file_id %>% walk(function(item) {
    # show process
    if(msg) message("Downloading Pew file: ", item, sprintf(" (%s)", Sys.time()))
    
    # build url
    url <- switch(area,
                  politics = paste0("http://www.people-press.org/category/datasets/?download=", item),
                  journalism = paste0("http://www.journalism.org/datasets/", item),
                  internet = paste0("http://www.pewinternet.org/datasets/", item),
                  religion = paste0("http://www.pewforum.org/datasets/", item),
                  # default
                  paste0("http://www.pew", area, ".org/category/datasets/?download=", item)
                  )
    
    s <- html_session(url)
    form <- html_form(s)[[1]] %>% 
      set_values(Name = name,
                 Organization= org,
                 Phone = phone,
                 Email = email) 

    suppressMessages(output <- submit_form(s, form))
    file_name <- strsplit(output$response$url, "[/]") %>% 
      unlist() %>% .[length(.)]  # extract the zip file name 
    file_dir <- paste0(file.path(download_dir, file_name))
    writeBin(httr::content(output$response, "raw"), file_dir)
    
    if (unzip == TRUE) unzip(file_dir, exdir = paste0(download_dir, "/", gsub(".zip", "", file_name)))

    if (delete_zip == TRUE) invisible(file.remove(file_dir))
  
  })
}
  
  
  