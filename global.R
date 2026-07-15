##############################################################################
# global.R
#
# Hospital Length of Stay Decision Support Dashboard
#
# Global settings and objects
##############################################################################

##############################################################################
# Packages
##############################################################################

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)

library(ranger)

library(dplyr)
library(tidyr)

library(ggplot2)
library(plotly)

library(DT)

library(scales)

##############################################################################
# Global options
##############################################################################

options(stringsAsFactors = FALSE)

theme_set(theme_bw())

##############################################################################
# Load Random Forest model
##############################################################################

load("models/RF.RData")

if (!exists("rf_final")) {
  stop("ERROR: rf_final was not found inside models/RF.RData")
}

##############################################################################
# Load representative synthetic cohort
##############################################################################

cohort <- readRDS("data/synthetic_external2023.rds")

##############################################################################
# Basic checks
##############################################################################

if (!inherits(rf_final, "ranger"))
  stop("rf_final is not a ranger model.")

if (!"los_class" %in% names(cohort))
  stop("los_class not found in synthetic cohort.")

##############################################################################
# Outcome classes
##############################################################################

los_levels <- c(
  "0",
  "1",
  "2",
  "3",
  "4"
)

los_labels <- c(
  "0–4 days",
  "5–9 days",
  "10–19 days",
  "20–29 days",
  "30–90 days"
)

##############################################################################
# Representative LOS values
#
# Used ONLY for estimating bed-days from predicted probabilities.
##############################################################################

los_midpoints <- c(
  
  "0" = 2.5,
  
  "1" = 7,
  
  "2" = 15,
  
  "3" = 25,
  
  "4" = 60
  
)

##############################################################################
# Predictor variables
##############################################################################

predictors <-
  
  setdiff(
    
    names(cohort),
    
    "los_class"
    
  )

##############################################################################
# Dashboard colours
##############################################################################

los_palette <- c(
  
  "0" = "#4daf4a",
  
  "1" = "#377eb8",
  
  "2" = "#ff7f00",
  
  "3" = "#984ea3",
  
  "4" = "#e41a1c"
  
)

##############################################################################
# Planning defaults
##############################################################################

default_monthly_admissions <- 2500

default_days_per_month <- 30

##############################################################################
# Variable importance
##############################################################################

importance_df <-
  
  data.frame(
    
    Variable = names(rf_final$variable.importance),
    
    Importance = rf_final$variable.importance
    
  ) |>
  
  arrange(
    
    desc(Importance)
    
  )

##############################################################################
# Dashboard metadata
##############################################################################

dashboard_title <-
  
  "Hospital Length of Stay Decision Support Dashboard"

dashboard_subtitle <-
  
  "Machine Learning-based Resource Planning"

##############################################################################
# Startup information
##############################################################################

cat("\n")

cat("===========================================\n")

cat("LOS Dashboard\n")

cat("===========================================\n")

cat("Model loaded          : Random Forest\n")

cat("Trees                 :", rf_final$num.trees, "\n")

cat("Predictors            :", length(predictors), "\n")

cat("Synthetic cohort size :", nrow(cohort), "\n")

cat("Outcome classes       :", length(los_levels), "\n")

cat("===========================================\n")