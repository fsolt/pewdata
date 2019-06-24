#' Download datasets from the Pew Research Center
#'
#' \code{pew_download} provides a programmatic and reproducible means to download survey datasets from the Pew Research Center 
#'
#' @param area One of the seven research areas of the Pew Research Center 
#'  (see details).
#' @param file_id The unique identifier (or optionally a vector of these identifiers)
#'  for the dataset(s) to be downloaded (see details).
#' @param email,password Account information to submit to Pew Research Center (see details).
#' @param reset If TRUE, the register information will be reset. The default is FALSE.
#' @param download_dir The directory (relative to your working directory) to
#'   which files from the Pew Research Center will be downloaded.
#' @param msg If TRUE, outputs a message showing which data set is being downloaded.
#' @param convert If TRUE, converts downloaded file(s) to .RData format.
#' @param delay If the speed of your connection to the Pew Data Center is particularly slow, 
#'   \code{pew_download} may encounter problems.  Increasing the \code{delay} parameter
#'   may help.
#'
#' @details The Pew Research Center has seven areas of research focus.  Pass one of the 
#'  following strings to the \code{area} argument to specify which area generated
#'  the datasets you want to download:
#'  
#'  \code{politics} U.S. Politics & Policy (the default)
#'  
#'  \code{journalism} Journalism & Media
#'  
#'  \code{socialtrends} Social & Demographic Trends
#'  
#'  \code{religion} Religion & Public Life
#'  
#'  \code{internet} Internet & Technology
#'  
#'  \code{science} Science & Society
#'     
#'  \code{hispanic} Hispanic Trends
#'  
#'  \code{global} Global Attitudes & Trends
#'  
#'
#'  To avoid requiring others to edit your scripts to insert their own contact 
#'  information, the default is set to fetch this information from the user's 
#'  .Rprofile.  Before running \code{pew_download}, then, you should be sure to
#'  add these options to your .Rprofile substituting your info for the example below:
#'
#'  \code{
#'   options("pew_email" = "jherrera@uppermidwest.edu"
#'          "pew_password" = "password123!")
#'  }
#'
#' @return The function downloads files.
#'
#' @examples
#' \dontrun{
#'  pew_download(file_id = c("september-2018-political-survey", "june-2018-political-survey"))
#' }
#'
#' @import RSelenium
#' @importFrom stringr str_detect str_subset
#' @importFrom magrittr "%>%"
#' @importFrom purrr walk
#' @importFrom rio convert export
#' @importFrom foreign read.spss
#' @importFrom tools file_path_sans_ext
#' @importFrom utils unzip
#' 
#' @export

pew_download <- function(area = "politics",
                         file_id, 
                         email = getOption("pew_email"),
                         password = getOption("pew_password"),
                         reset = FALSE,
                         download_dir = "pew_data",
                         msg = TRUE,
                         convert = TRUE,
                         delay = 2) {
  
  # detect login info
  if (reset) {
    email <- password <- NULL
  }
  
  if (is.null(email)) {
    pew_email <- readline(prompt = "The Pew Data Center requires your user account information.  Please enter your email address: \n")
    options("pew_email" = pew_email)
    email <- getOption("pew_email")
  }
  
  if (is.null(password)) {
    pew_password <- readline(prompt = "Please enter your Pew password: \n")
    options("pew_password" = pew_password)
    password <- getOption("pew_password")
  }
  
  # build path to chrome's default download directory
  if (Sys.info()[["sysname"]]=="Linux") {
    default_dir <- file.path("home", Sys.info()[["user"]], "Downloads")
  } else {
    default_dir <- file.path("", "Users", Sys.info()[["user"]], "Downloads")
  }
  
  # initialize driver
  if(msg) message("Initializing RSelenium driver")
  rD <- RSelenium::rsDriver(browser = "chrome")
  remDr <- rD[["client"]]
  
  # get signin url
  signin <- switch(area,
                   politics = "https://www.people-press.org/datasets/",
                   journalism = "https://www.journalism.org/datasets/",
                   religion = "https://www.pewforum.org/datasets/",
                   science = "https://www.pewresearch.org/science/datasets/",
                   # default
                   paste0("http://www.pew", area, ".org/datasets/")
  )
  
  # sign in
  remDr$navigate(signin)
  Sys.sleep(delay)
  remDr$findElement(using = "name", "username")$sendKeysToElement(list(email))
  remDr$findElement(using = "name", "password")$sendKeysToElement(list(password))
  if (area == "global") {
    remDr$findElement(using = "css selector", "#js-prc-user-accounts .button")$clickElement()
  } else {
    remDr$findElement(using = "css selector", ".button")$clickElement()
  }
  Sys.sleep(delay)
  
  # loop through files
  walk(file_id, function(item) {
    # show process
    if(msg) message("Downloading Pew file: ", item, sprintf(" (%s)", Sys.time()))
    
    # create specified download directory if necessary
    if (!dir.exists(file.path(download_dir, item))) dir.create(file.path(download_dir, item), recursive = TRUE)
  
    # get list of current default download directory contents
    dd_old <- list.files(default_dir)
    
    # navigate to download page  
    url <- switch(area,
                  politics = paste0("https://www.people-press.org/dataset/", item),
                  journalism = paste0("https://www.journalism.org/dataset/", item),
                  religion = paste0("https://www.pewforum.org/dataset/", item),
                  science = paste0("https://www.pewresearch.org/science/dataset/", item),
                  # default
                  paste0("http://www.pew", area, ".org/dataset/", item)
    )
    remDr$navigate(url)
    Sys.sleep(delay)
    if (area == "global") {
      remDr$findElement(using = "css selector", "#prc-dataset-widget-3 .button")$clickElement()
    } else {
      remDr$findElement(using = "css selector", ".button")$clickElement()
    }
    
    # agree to terms
    try({remDr$findElement(using = "class name", "checkbox")$clickElement()
      remDr$findElement(using = "class name", "green")$clickElement()})
    
    # check that download has completed
    dd_new <- list.files(default_dir)[!list.files(default_dir) %in% dd_old]
    wait <- TRUE
    tryCatch(
      while(all.equal(stringr::str_detect(dd_new, "\\.part$"), logical(0))) {
        Sys.sleep(1)
        dd_new <- list.files(default_dir)[!list.files(default_dir) %in% dd_old]
      }, error = function(e) 1 )
    while(any(stringr::str_detect(dd_new, "\\.crdownload$"))) {
      Sys.sleep(1)
      dd_new <- list.files(default_dir)[!list.files(default_dir) %in% dd_old]
    }
    
    # unzip into specified directory and convert to .RData
    unzip(file.path(default_dir, dd_new), exdir = file.path(download_dir, item))
    unlink(file.path(default_dir, dd_new))

    data_files <- list.files(path = file.path(download_dir, item), recursive = TRUE) %>%
      stringr::str_subset("\\.sav")
    if (convert == TRUE) {
      for (i in seq_along(data_files)) {
        data_file <- data_files[i]
        tryCatch(rio::convert(file.path(download_dir, item, data_file),
                              paste0(tools::file_path_sans_ext(file.path(download_dir,
                                                                         item,
                                                                         basename(data_file))), ".RData")),
                 error = function(c) suppressWarnings(
                   foreign::read.spss(file.path(download_dir, item, data_file),
                                      to.data.frame = TRUE,
                                      use.value.labels = FALSE) %>%
                     rio::export(paste0(tools::file_path_sans_ext(file.path(download_dir,
                                                                            item,
                                                                            basename(data_file))), ".RData"))
                 )
        )
        if (file.size(file.path(download_dir, item, data_file)) == max(file.size(file.path(download_dir, item, data_files)))) {
          file.rename(paste0(tools::file_path_sans_ext(file.path(download_dir,
                                                                 item,
                                                                 basename(data_file))), ".RData"),
                      paste0(file.path(download_dir, item, item), ".RData"))
        }
      }
    }
  })
  
  # Close driver
  remDr$close()
  rD[["server"]]$stop()
} 
