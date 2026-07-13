###############################################################################
# Hospital LOS Scenario Dashboard
#
# Machine Learning-Based Length of Stay Prediction
# Scenario-Based Decision Support Tool

###############################################################################

## ============================================================================
## Load packages
## ============================================================================

library(shiny)
library(bslib)
library(shinyWidgets)
library(shinycssloaders)
library(DT)
library(plotly)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)
library(ranger)
library(randomForest)

## ============================================================================
## Global options
## ============================================================================

options(
  shiny.maxRequestSize = 100 * 1024^2,   # 100 MB
  shiny.autoreload = TRUE
)

## ============================================================================
## Project directories
## ============================================================================

R_DIR      <- "R"
DATA_DIR   <- "data"
MODEL_DIR  <- "models"
WWW_DIR    <- "www"

## ============================================================================
## Source application modules
## ============================================================================

source(file.path(R_DIR, "helpers.R"))
source(file.path(R_DIR, "scenario_engine.R"))
source(file.path(R_DIR, "prediction_engine.R"))
source(file.path(R_DIR, "plots.R"))
source(file.path(R_DIR, "summary.R"))
source(file.path(R_DIR, "ui.R"))
source(file.path(R_DIR, "server.R"))

## ============================================================================
## Load representative cohort
## ============================================================================

message("Loading representative cohort...")

cohort <- readRDS(
  file.path(DATA_DIR, "cohort.rds")
)

## ============================================================================
## Load trained ML model
## ============================================================================

message("Loading trained model...")

rf_model <- readRDS(
  file.path(MODEL_DIR, "rf_final.rds")
)

## ============================================================================
## Load metadata 
## ============================================================================

variable_levels <- readRDS(
  file.path(DATA_DIR, "variable_levels.rds")
)

predictor_names <- readRDS(
  file.path(DATA_DIR, "predictor_names.rds")
)

## ============================================================================
## Global objects available to all modules
## ============================================================================

app_data <- list(

  cohort = cohort,

  model = rf_model,

  variable_levels = variable_levels,

  predictor_names = predictor_names

)

## ============================================================================
## Launch application
## ============================================================================

shinyApp(

  ui = app_ui(),

  server = function(input, output, session){

    app_server(

      input = input,

      output = output,

      session = session,

      app_data = app_data

    )

  }

)
