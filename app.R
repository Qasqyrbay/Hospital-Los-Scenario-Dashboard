##############################################################################
# app.R
#
# Hospital Length of Stay Decision Support Dashboard
#
# Companion application for:
#
# Machine Learning-Based Length of Stay Prediction to Support Hospital
# Resource Allocation: A Nationally Representative Study from Kazakhstan
##############################################################################

rm(list = ls())

##############################################################################
# Load application files
##############################################################################

source("global.R")
source("ui.R")
source("server.R")

##############################################################################
# Launch application
##############################################################################

shinyApp(
  ui = ui,
  server = server
)