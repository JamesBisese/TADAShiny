# Launch the ShinyApp (Do not remove this comment)
# To deploy, run: rsconnect::deployApp()
# Or use the blue button on top of this file
library(devtools)

# pkgload::load_all(export_all = FALSE,helpers = FALSE,attach_testthat = FALSE)

options( "golem.app.prod" = FALSE)

# detach all attached packages and clean your environment
golem::detach_all_attached()

golem::set_golem_options()

# document and reload your package
golem::document_and_reload()

options(shiny.launch.browser = .rs.invokeShinyWindowExternal)

# TADAShiny::run_app() # add parameters here (if any)
run_app()
run
# pkgload::load_all(export_all = FALSE,helpers = FALSE,attach_testthat = FALSE)
# options( "golem.app.prod" = TRUE)
# TADAShiny::run_app() # add parameters here (if any)
