#' query_data UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import shinybusy
#'

load("inst/extdata/statecodes_df.Rdata")
load("inst/extdata/query_choices.Rdata")

# new (2024-05-23) list for new Country/Ocean(s) Query the Water Quality Portal option. Not included in saved query_choices file
library(jsonlite)
library(dplyr)
url <- 'https://www.waterqualitydata.us/Codes/countrycode?mimeType=json'
countryocean_source <- fromJSON(txt=url)
countryocean_source <- countryocean_source$codes %>% select(-one_of('providers'))
countryocean_source <- countryocean_source[order(countryocean_source$desc),]
countryocean_choices <- countryocean_source$value
names(countryocean_choices) <- countryocean_source$desc

# Last run by EDH on 08/25/23
# county = readr::read_tsv(url("https://www2.census.gov/geo/docs/reference/codes/files/national_county.txt"), col_names = FALSE)
# county = county%>%tidyr::separate(X1,into = c("STUSAB","STATE","COUNTY","COUNTY_NAME","COUNTY_ID"), sep=",")
# orgs = unique(utils::read.csv(url("https://cdx.epa.gov/wqx/download/DomainValues/Organization.CSV"))$ID)
# chars = unique(utils::read.csv(url("https://cdx.epa.gov/wqx/download/DomainValues/Characteristic.CSV"))$Name)
# chargroup = unique(utils::read.csv(url("https://cdx.epa.gov/wqx/download/DomainValues/CharacteristicGroup.CSV"))$Name)
# media = c(unique(utils::read.csv(url("https://cdx.epa.gov/wqx/download/DomainValues/ActivityMedia.CSV"))$Name),"water","Biological Tissue","No media")
# # sitetype = unique(utils::read.csv(url("https://cdx.epa.gov/wqx/download/DomainValues/MonitoringLocationType.CSV"))$Name)
# sitetype = c("Aggregate groundwater use","Aggregate surface-water-use","Aggregate water-use establishment","Atmosphere","Estuary","Facility","Glacier","Lake, Reservoir, Impoundment","Land","Not Assigned","Ocean","Spring","Stream","Subsurface","Well","Wetland")
# projects = unique(data.table::fread("https://www.waterqualitydata.us/data/Project/search?mimeType=csv&zip=no&providers=NWIS&providers=STEWARDS&providers=STORET")$ProjectIdentifier)
# mlids = unique(data.table::fread("https://www.waterqualitydata.us/data/Station/search?mimeType=csv&zip=no&providers=NWIS&providers=STEWARDS&providers=STORET")$MonitoringLocationIdentifier)
# save(orgs, chars, chargroup, media, county, sitetype, projects, mlids, file = "inst/extdata/query_choices.Rdata")

mod_query_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::fluidRow(
      htmltools::h3("Option A: Use example data"),
      column(3, shiny::selectInput(
        ns("example_data"),
        "Use example data",
        choices = c(
          "",
          "Nutrients Utah (15k results)",
          "Shepherdstown (34k results)",
          "Tribal (132k results)"
        )
      ))
    ),
    shiny::fluidRow(column(
      3,
      shiny::actionButton(
        ns("example_data_go"),
        "Load",
        shiny::icon("truck-ramp-box"),
        style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
      )
    )),
    htmltools::hr(),
    shiny::fluidRow(
      htmltools::h3("Option B: Query the Water Quality Portal (WQP)"),
      "Use the fields below to download a dataset directly from WQP. Fields with '(s)' in the label allow multiple selections. Hydrologic Units may be at any scale, from subwatershed to region. However, be mindful that large queries may time out."
    ),
    htmltools::br(),
    # styling several fluid rows with columns to hold the input drop down widgets
    htmltools::h4("Date Range"),
    shiny::fluidRow(
      column(
        4,
        shiny::dateInput(
          ns("startDate"),
          "Start Date",
          format = "yyyy-mm-dd",
          startview = "year"
        )
      ),
      column(
        4,
        shiny::dateInput(
          ns("endDate"),
          "End Date",
          format = "yyyy-mm-dd",
          startview = "year"
        )
      )
    ),
    htmltools::h4("Location Information"),
    shiny::fluidRow(
      column(4, shiny::selectizeInput(ns("state"), "State", choices = NULL)),
      column(
        4,
        shiny::selectizeInput(ns("county"), "County (pick state first)", choices = NULL)
      ),
      column(
        4,
        shiny::textInput(ns("huc"), "Hydrologic Unit", placeholder = "e.g. 020700100103")
      )
    ),
    shiny::fluidRow(
      column(4, 
             shiny::selectizeInput(ns("siteid"),
             "Monitoring Location ID(s)",
             choices = NULL,
             multiple = TRUE)),
      column(4, 
             shiny::selectizeInput(ns("countryocean"),
             "Country/Ocean(s)", 
             choices = NULL, 
             multiple = TRUE))
    ),
    htmltools::h4("Metadata Filters"),   
    shiny::fluidRow(
      column(
        4,
        shiny::selectizeInput(
          ns("org"),
          "Organization(s)",
          choices = NULL,
          multiple = TRUE
        )
      ),
      column(
        4,
        shiny::selectizeInput(
          ns("project"),
          "Project(s)",
          choices = NULL,
          multiple = TRUE
        )
      ),
      column(
        4,
        shiny::selectizeInput(
          ns("type"),
          "Site Type(s)",
          choices = c(sitetype),
          multiple = TRUE
        )
      )
    ),
    shiny::fluidRow(
      column(
        4,
        shiny::selectizeInput(
          ns("media"),
          tags$span(
            "Sample Media",
            tags$i(
              class = "glyphicon glyphicon-info-sign",
              style = "color:#0072B2;",
              title = "TADA is designed to work with water data"
            )
          ),
          choices = c("", media),
          selected = c("Water", "water"),
          multiple = TRUE
        )
      ),
      column(
        4,
        shiny::selectizeInput(
          ns("chargroup"), 
          "Characteristic Group", 
          choices = NULL,
          multiple = TRUE
          )
      ),
      column(
        4,
        shiny::selectizeInput(
          ns("characteristic"),
          "Characteristic(s)",
          choices = NULL,
          multiple = TRUE
        )
      )
    ),
    shiny::fluidRow(
      column(
             4,
             shiny::checkboxGroupInput(ns("providers"), 
             "Data Source", 
             c("NWIS (USGS)" = "NWIS", "WQX (EPA)" = "STORET"))
      )
    ),
    shiny::fluidRow(column(
      4,
      shiny::actionButton(ns("querynow"), "Run Query", shiny::icon("cloud"),
        style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
      )
    )),
    htmltools::hr(),
    shiny::fluidRow(
      htmltools::h3("Option C: Upload dataset"),
      htmltools::HTML((
        "Upload a dataset from your computer. This upload feature only accepts data in .xls and .xlsx formats.
                                    The file can be a <B>fresh</B> TADA dataset or a <B>working</B> TADA dataset that you are returning to the
                                    app to iterate on. Data must also be formatted in the EPA Water Quality eXchange (WQX) schema to leverage
                                    this tool. You may reach out to the WQX helpdesk at WQX@epa.gov for assistance preparing and submitting your data
                                    to the WQP through EPA's WQX."
      )),
      # widget to upload WQP profile or WQX formatted spreadsheet
      column(
        9,
        shiny::fileInput(
          ns("file"),
          "",
          multiple = TRUE,
          accept = c(".xlsx", ".xls"),
          width = "100%"
        )
      )
    ),
    htmltools::hr(),
    shiny::fluidRow(
      htmltools::h3("Optional: Upload Progress File"),
      htmltools::HTML((
        "Upload a progress file from your computer. This upload feature only accepts data in the .RData format.
        The TADA Shiny application keeps track of all user selections, and makes a .RData file
        available for download at any time. If you saved a progress file you generated during a
        previous use of the TADA Shiny application, then it can be uploaded here and used
        to automatically parameterize the TADA Shiny app with the same selections. This file can
        be used to regenerate a dataset with the same decisions as before, or can be used
        to apply the same user selctions to a new dataset"
      )),
      # widget to upload WQP profile or WQX formatted spreadsheet
      column(
        9,
        shiny::fileInput(
          ns("progress_file"),
          "",
          multiple = TRUE,
          accept = c(".RData"),
          width = "100%"
        )
      )
    ),
  )
}

#' query_data Server Functions
#'
#' @noRd
mod_query_data_server <- function(id, tadat) {
  shiny::moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # read in the excel spreadsheet dataset if this input reactive object is populated via fileInput and define as tadat$raw
    shiny::observeEvent(input$file, {
      # a modal that pops up showing it's working on querying the portal
      shinybusy::show_modal_spinner(
        spin = "double-bounce",
        color = "#0071bc",
        text = "Uploading dataset...",
        session = shiny::getDefaultReactiveDomain()
      )

      # user uploaded data
      raw <-
        suppressWarnings(readxl::read_excel(input$file$datapath, sheet = 1))
      raw$TADA.Remove <- NULL
      initializeTable(tadat, raw)
      if (!is.null(tadat$original_source)) {
        tadat$original_source <- "Upload"
      }

      shinybusy::remove_modal_spinner(session = shiny::getDefaultReactiveDomain())
    })

    # Read the TADA progress file
    shiny::observe({
      shiny::req(input$progress_file)
      # user uploaded data
      readFile(tadat, input$progress_file$datapath)
    })

    # if user presses example data button, make tadat$raw the nutrients dataset contained within the TADA package.
    shiny::observeEvent(input$example_data_go, {
      # a modal that pops up showing it's working on querying the portal
      shinybusy::show_modal_spinner(
        spin = "double-bounce",
        color = "#0071bc",
        text = "Loading example data...",
        session = shiny::getDefaultReactiveDomain()
      )

      tadat$example_data <- input$example_data
      if (input$example_data == "Shepherdstown (34k results)") {
        raw <- EPATADA::Data_NCTCShepherdstown_HUC12
      }
      if (input$example_data == "Tribal (132k results)") {
        raw <- EPATADA::Data_6Tribes_5y
      }
      if (input$example_data == "Nutrients Utah (15k results)") {
        raw <- EPATADA::Data_Nutrients_UT
      }
      initializeTable(tadat, raw)

      shinybusy::remove_modal_spinner(session = shiny::getDefaultReactiveDomain())
    })

    # this section has widget update commands for the selectizeinputs that have a lot of possible selections - shiny suggested hosting the choices server-side rather than ui-side
    shiny::updateSelectizeInput(
      session,
      "state",
      choices = c(unique(statecodes_df$STUSAB)),
      selected = character(0),
      options = list(placeholder = "Select state", maxItems = 1),
      server = TRUE
    )
    shiny::updateSelectizeInput(session,
      "org",
      choices = c(orgs),
      server = TRUE
    )
    shiny::updateSelectizeInput(
      session,
      "chargroup",
      choices = c(chargroup),
      selected = character(0),
      options = list(placeholder = ""),
      server = TRUE
    )
    shiny::updateSelectizeInput(session,
      "characteristic",
      choices = c(chars),
      server = TRUE
    )
    shiny::updateSelectizeInput(session,
      "project",
      choices = c(projects),
      server = TRUE
    )
    shiny::updateSelectizeInput(
      session,
      "siteid",
      choices = c(mlids),
      options = list(placeholder = "Start typing or use drop down menu"),
      server = TRUE
    )

    
    shiny::updateSelectizeInput(
      session,
      "countryocean",
      choices = countryocean_choices,
      selected = character(0),
      options = list(placeholder = "Start typing or use drop down menu"),
      server = TRUE
    )
    

    # this observes when the user inputs a state into the drop down and subsets the choices for counties to only those counties within that state.
    shiny::observeEvent(input$state, {
      state_counties <- subset(county, county$STUSAB == input$state)
      shiny::updateSelectizeInput(
        session,
        "county",
        choices = c(unique(state_counties$COUNTY_NAME)),
        selected = character(0),
        options = list(
          placeholder = "Select county",
          maxItems = 1
        ),
        server = TRUE
      )
    })

    # remove the modal once the dataset has been pulled
    shinybusy::remove_modal_spinner(session = shiny::getDefaultReactiveDomain())


    # this event observer is triggered when the user hits the "Query Now" button, and then runs the TADAdataRetrieval function
    shiny::observeEvent(input$querynow, {
      tadat$original_source <- "Query"
      # convert to null when needed
      if (input$state == "") {
        # changing inputs of "" or NULL to "null"
        tadat$statecode <- "null"
      } else {
        tadat$statecode <- input$state
      }
      if (input$county == "") {
        tadat$countycode <- "null"
      } else {
        tadat$countycode <- input$county
      }
      # this is an overloaded field which can be 2-character Country or Ocean
      if (is.null(input$countryocean)) {
        tadat$countrycode <- "null"
      } else {
        tadat$countrycode <- input$countryocean
      }
      if (is.null(input$providers)) {
        tadat$providers <- "null"
      } else {
        tadat$providers <- input$providers
      }
      if (input$huc == "") {
        tadat$huc <- "null"
      } else {
        tadat$huc <- input$huc
      }
      if (is.null(input$type)) {
        tadat$siteType <- "null"
      } else {
        tadat$siteType <- input$type
      }
      if (is.null(input$chargroup)) {
        tadat$characteristicType <- "null"
      } else {
        tadat$characteristicType <- input$chargroup
      }
      if (is.null(input$characteristic)) {
        tadat$characteristicName <- "null"
      } else {
        tadat$characteristicName <- input$characteristic
      }
      if (is.null(input$media)) {
        tadat$sampleMedia <- "null"
      } else {
        tadat$sampleMedia <- input$media
      }
      if (is.null(input$project)) {
        tadat$project <- "null"
      } else {
        tadat$project <- paste(input$project, collapse = ",")
      }
      if (is.null(input$org)) {
        tadat$organization <- "null"
      } else {
        tadat$organization <- input$org
      }
      if (is.null(input$siteid)) {
        tadat$siteid <- "null"
      } else {
        tadat$siteid <- input$siteid
        # siteid = stringr::str_trim(unlist(strsplit(input$siteids,",")))
      }
      if (length(input$endDate) == 0) {
        # ensure if date is empty, the query receives a proper input ("null")
        tadat$endDate <- "null"
      } else {
        tadat$endDate <- as.character(input$endDate)
      }
      if (length(input$startDate) == 0) {
        # ensure if date is empty, the query receives a proper input ("null")
        tadat$startDate <- "null"
      } else {
        tadat$startDate <- as.character(input$startDate)
      }
      # a modal that pops up showing it's working on querying the portal
      shinybusy::show_modal_spinner(
        spin = "double-bounce",
        color = "#0071bc",
        text = "Querying WQP database...",
        session = shiny::getDefaultReactiveDomain()
      )

      # storing the output of TADAdataRetrieval with the user's input choices as a reactive object named "raw" in the tadat list.
      raw <- EPATADA::TADA_DataRetrieval(
        statecode = tadat$statecode,
        countycode = tadat$countycode,
        countrycode = tadat$countrycode,
        huc = tadat$huc,
        siteid = tadat$siteid,
        siteType = tadat$siteType,
        characteristicName = tadat$characteristicName,
        characteristicType = tadat$characteristicType,
        sampleMedia = tadat$sampleMedia,
        project = tadat$project,
        organization = tadat$organization,
        startDate = tadat$startDate,
        endDate = tadat$endDate,
        providers = tadat$providers,
        applyautoclean = TRUE
      )

      # remove the modal once the dataset has been pulled
      shinybusy::remove_modal_spinner(session = shiny::getDefaultReactiveDomain())

      # show a modal dialog box when tadat$raw is empty and the query didn't return any records.
      # but if tadat$raw isn't empty, perform some initial QC of data that aren't media type water or have NA Resultvalue and no detection limit data
      if (dim(raw)[1] < 1) {
        shiny::showModal(
          shiny::modalDialog(
            title = "Empty Query",
            "Your query returned zero results. Please adjust your search inputs and try again. Remember to update the start and end dates."
          )
        )
      } else {
        initializeTable(tadat, raw)
      }
    })

    # Update the run parameters if example data is selected
    shiny::observeEvent(input$example_data_go, {
      tadat$original_source <- "Example"
    })

    # Populate the boxes if a progress file is loaded
    shiny::observeEvent(tadat$load_progress_file, {
      if (!is.na(tadat$load_progress_file)) {
        if (tadat$original_source == "Example") {
          shiny::updateSelectInput(session, "example_data", selected = tadat$example_data)
        } else if (tadat$original_source == "Query") {
          shiny::updateSelectizeInput(session, "state", selected = tadat$statecode)
          shiny::updateSelectizeInput(session, "county", selected = tadat$countycode)
          shiny::updateTextInput(session, "huc")
          shiny::updateSelectizeInput(session, "siteid", selected = tadat$siteid)
          shiny::updateSelectizeInput(session, "type", selected = tadat$siteType)
          shiny::updateSelectizeInput(session,
            "characteristic",
            selected = tadat$characteristicName
          )
          shiny::updateSelectizeInput(session, "chargroup", selected = tadat$characteristicType)
          shiny::updateSelectizeInput(session, "media", selected = tadat$sampleMedia)
          shiny::updateSelectizeInput(session, "project", selected = tadat$project)
          shiny::updateSelectizeInput(session, "org", selected = tadat$organization)
          shiny::updateDateInput(session, "startDate", value = tadat$startDate)
          shiny::updateDateInput(session, "endDate", value = tadat$endDate)
        }
      }
    })
  })
}

initializeTable <- function(tadat, raw) {
  # Test to see if this is a raw table or one previously worked on in TADA
  if ("TADA.Remove" %in% names(raw)) {
    tadat$reup <- TRUE
    tadat$ovgo <- FALSE
    shinyjs::enable(selector = '.nav li a[data-value="Overview"]')
    shinyjs::enable(selector = '.nav li a[data-value="Flag"]')
    shinyjs::enable(selector = '.nav li a[data-value="Filter"]')
    shinyjs::enable(selector = '.nav li a[data-value="Censored"]')
    shinyjs::enable(selector = '.nav li a[data-value="Harmonize"]')
    shinyjs::enable(selector = '.nav li a[data-value="Figures"]')
    shinyjs::enable(selector = '.nav li a[data-value="Review"]')
  } else {
    tadat$new <-
      TRUE # this is used to determine if the app should go to the overview page first - only for datasets that are new to TADAShiny
    tadat$ovgo <- TRUE # load data into overview page
    shinyjs::enable(selector = '.nav li a[data-value="Overview"]')
    shinyjs::enable(selector = '.nav li a[data-value="Flag"]')
    # shinyjs::enable(selector = '.nav li a[data-value="Figures"]')
    # Set flagging column to FALSE
    raw$TADA.Remove <- FALSE
  }

  removals <- data.frame(matrix(nrow = nrow(raw), ncol = 0))
  tadat$raw <- raw
  tadat$removals <- removals
}


## To be copied in the UI
# mod_query_data_ui("query_data_1")

## To be copied in the server
# mod_query_data_server("query_data_1")
