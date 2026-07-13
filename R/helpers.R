###############################################################################
# helpers.R
#
# Helper functions for Hospital LOS Scenario Dashboard
#
# These functions are used throughout the application.
###############################################################################

library(dplyr)
library(scales)

###############################################################################
# LOS CATEGORY DEFINITIONS
###############################################################################

# Midpoints of LOS categories used to estimate bed-days
# Modify these if your categories change.

los_lookup <- data.frame(
  LOS = factor(
    c("0-4", "5-9", "10-19", "20-29", "30-90"),
    levels = c("0-4", "5-9", "10-19", "20-29", "30-90")
  ),
  midpoint = c(2, 7, 15, 25, 60)
)

###############################################################################
# Convert predicted LOS category to midpoint
###############################################################################

los_midpoint <- function(x){

  lookup <- setNames(
    los_lookup$midpoint,
    los_lookup$LOS
  )

  unname(lookup[as.character(x)])

}

###############################################################################
# Estimate bed-days
###############################################################################

estimate_beddays <- function(prediction){

  sum(
    los_midpoint(prediction),
    na.rm = TRUE
  )

}

###############################################################################
# Estimate occupancy
###############################################################################

estimate_occupancy <- function(
    prediction,
    beds,
    period_days = 30){

  bed_days <- estimate_beddays(prediction)

  occupancy <-
    100 *
    bed_days /
    (beds * period_days)

  round(occupancy,1)

}

###############################################################################
# Long stay definition
###############################################################################

count_longstay <- function(prediction){

  sum(
    prediction %in% c("20-29","30-90"),
    na.rm = TRUE
  )

}

###############################################################################
# LOS distribution
###############################################################################

los_distribution <- function(prediction){

  tibble(

    LOS = factor(
      prediction,
      levels = levels(los_lookup$LOS)
    )

  ) |>

    count(LOS) |>

    mutate(

      Percent = round(
        100*n/sum(n),
        1
      )

    )

}

###############################################################################
# Scenario summary
###############################################################################

calculate_summary <- function(
    data,
    beds){

  prediction <- data$LOS_prediction

  tibble(

    Mean_LOS =
      round(mean(los_midpoint(prediction)),2),

    Bed_Days =
      estimate_beddays(prediction),

    Occupancy =
      estimate_occupancy(
        prediction,
        beds
      ),

    Long_Stay =
      count_longstay(prediction),

    Admissions =
      nrow(data)

  )

}

###############################################################################
# Baseline vs Scenario comparison
###############################################################################

compare_scenarios <- function(
    baseline,
    scenario,
    beds){

  base <- calculate_summary(
    baseline,
    beds
  )

  scen <- calculate_summary(
    scenario,
    beds
  )

  tibble(

    Metric = c(
      "Mean LOS",
      "Bed-days",
      "Occupancy (%)",
      "Long-stay patients"
    ),

    Baseline = c(

      base$Mean_LOS,

      base$Bed_Days,

      base$Occupancy,

      base$Long_Stay

    ),

    Scenario = c(

      scen$Mean_LOS,

      scen$Bed_Days,

      scen$Occupancy,

      scen$Long_Stay

    )

  ) |>

    mutate(

      Difference =

        round(

          Scenario-Baseline,

          2

        ),

      Percent_Change =

        round(

          100*

            (Scenario-Baseline)/Baseline,

          1

        )

    )

}

###############################################################################
# Format percentages
###############################################################################

fmt_percent <- function(x){

  paste0(round(x,1),"%")

}

###############################################################################
# Format integers
###############################################################################

fmt_number <- function(x){

  comma(round(x))

}

###############################################################################
# Validate cohort
###############################################################################

validate_cohort <- function(df){

  required <- c(

    "age",

    "sex",

    "admission",

    "LOS_prediction"

  )

  missing <-
    setdiff(
      required,
      names(df)
    )

  if(length(missing)>0){

    stop(

      paste(

        "Missing variables:",

        paste(missing,collapse=", ")

      )

    )

  }

  invisible(TRUE)

}

###############################################################################
# Safely replace values
###############################################################################

replace_random <- function(
    x,
    condition,
    value){

  idx <- which(condition)

  if(length(idx)==0)
    return(x)

  x[idx] <- value

  x

}

###############################################################################
# Convert probabilities to class
###############################################################################

max_class <- function(prob){

  colnames(prob)[

    max.col(prob)

  ]

}

###############################################################################
# Timestamp
###############################################################################

timestamp <- function(){

  format(

    Sys.time(),

    "%Y-%m-%d %H:%M:%S"

  )

}

###############################################################################
# Export summary
###############################################################################

export_summary <- function(
    summary_table,
    file){

  write.csv(

    summary_table,

    file,

    row.names = FALSE

  )

}

###############################################################################
# End of helpers.R
###############################################################################
