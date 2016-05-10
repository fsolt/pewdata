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
#' @export
pew_download <- function(area = "politics",
                         file_id, 
                         name = getOption("pew_name"),
                         org = getOption("pew_org"),
                         phone = getOption("pew_phone"),
                         email = getOption("pew_email"),
                         download_dir = "pew_data",
                         msg = TRUE,
                         unzip = TRUE,
                         delete_zip = TRUE) {

  # Set Firefox properties to not open a download dialog
  fprof <- RSelenium::makeFirefoxProfile(list(
    browser.download.dir = paste0(getwd(), "/", download_dir),
    browser.download.folderList = 2L,
    browser.download.manager.showWhenStarting = FALSE,
    browser.helperApps.neverAsk.saveToDisk = "application/zip"))
  
  # Set up server as open initial window
  RSelenium::checkForServer()
  RSelenium::startServer()
  remDr <- RSelenium::remoteDriver(extraCapabilities = fprof)
  remDr$open(silent = TRUE)

  # Get list of current download directory contents
  if (!dir.exists(download_dir)) dir.create(download_dir)
  dd_old <- list.files(download_dir)
  
  # Loop through files
  for (item in file_id) {  
    if(msg) message("Downloading Pew file: ", item, sprintf(" (%s)", Sys.time()))
    
    # build url
    if (area == "politics") {
      url <- paste0("http://www.people-press.org/category/datasets/?download=", item)
    } else if (area == "journalism") {
      url <- paste0("http://www.journalism.org/datasets/", item)
    } else if (area == "internet") {
      url <- paste0("http://www.pewinternet.org/datasets/", item)
    } else if (area == "religion") {
      url <- paste0("http://www.pewforum.org/datasets/", item)
    } else {
      url <- paste0("http://www.pew", area, ".org/category/datasets/?download=", item)
    } 

    # navigate to download page and fill in required contact information
    remDr$navigate(url)
    
    remDr$findElement(using = "name", "Name")$sendKeysToElement(list(name))
    remDr$findElement(using = "name", "Organization")$sendKeysToElement(list(org))
    remDr$findElement(using = "name", "Phone")$sendKeysToElement(list(phone))
    remDr$findElement(using = "name", "Email")$sendKeysToElement(list(email))
    
    remDr$findElement(using = "id", "Agreement")$clickElement()
    remDr$findElement(using = "id", "submit")$clickElement()
    
    # Switch back to first window
    remDr$switchToWindow(remDr$getWindowHandles()[[1]])
  }
  
  # Confirm that downloads are completed, then close driver
  dd_new <- list.files(download_dir)[!list.files(download_dir) %in% dd_old]
  while (any(grepl("\\.zip\\.part", dd_new))) {
    Sys.sleep(1)
    dd_new <- list.files(download_dir)[!list.files(download_dir) %in% dd_old]
  }
  remDr$close()
  
  if (unzip == TRUE) {
    lapply(dd_new, function(x) unzip(paste0(download_dir, "/", x), exdir = paste0(download_dir, "/", gsub(".zip", "", x))))
  }
  if (delete_zip == TRUE) {
    invisible(file.remove(paste0(download_dir, "/", dd_new)))
  }
}
