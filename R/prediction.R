###############################################################################
# prediction.R
#
# Prediction Engine
#
# Hospital LOS Scenario Dashboard
###############################################################################

library(dplyr)

###############################################################################
# Predict LOS using trained model
###############################################################################

predict_los <- function(model,
                        newdata){

  ## Remove previous prediction columns if present

  remove_cols <- c(
    "LOS_prediction",
    "LOS_midpoint"
  )

  newdata <- newdata |>
    select(-any_of(remove_cols))

  ###########################################################################
  # ranger model
  ###########################################################################

  if(inherits(model, "ranger")){

    pred <- predict(
      model,
      data = newdata,
      type = "response"
    )

    prediction <- pred$predictions

    if(is.matrix(prediction)){

      prediction <- colnames(prediction)[
        max.col(prediction)
      ]

    }

  }

  ###########################################################################
  # randomForest package
  ###########################################################################

  else if(inherits(model, "randomForest")){

    prediction <- predict(
      model,
      newdata = newdata,
      type = "response"
    )

  }

  ###########################################################################
  # xgboost (future support)
  ###########################################################################

  else if(inherits(model,"xgb.Booster")){

    stop(
      "XGBoost prediction engine not yet implemented."
    )

  }

  ###########################################################################
  # unsupported model
  ###########################################################################

  else{

    stop(
      "Unsupported model class."
    )

  }

  ###########################################################################
  # Convert factor to character
  ###########################################################################

  prediction <- as.character(prediction)

  ###########################################################################
  # Convert numeric classes to labels
  ###########################################################################

  prediction <- dplyr::recode(

    prediction,

    "0" = "0-4",

    "1" = "5-9",

    "2" = "10-19",

    "3" = "20-29",

    "4" = "30-90"

  )

  ###########################################################################
  # Store prediction
  ###########################################################################

  newdata$LOS_prediction <- factor(

    prediction,

    levels = c(
      "0-4",
      "5-9",
      "10-19",
      "20-29",
      "30-90"
    )

  )

  ###########################################################################
  # Midpoint for bed-day estimation
  ###########################################################################

  midpoint_lookup <- c(

    "0-4" = 2,

    "5-9" = 7,

    "10-19" = 15,

    "20-29" = 25,

    "30-90" = 60

  )

  newdata$LOS_midpoint <-

    midpoint_lookup[
      as.character(
        newdata$LOS_prediction
      )
    ]

  ###########################################################################
  # Prediction probabilities (ranger only)
  ###########################################################################

  if(inherits(model,"ranger")){

    pred_prob <- predict(
      model,
      data = newdata,
      type = "response"
    )

    if(is.matrix(pred_prob$predictions)){

      probs <- as.data.frame(
        pred_prob$predictions
      )

      names(probs) <-
        paste0(
          "Prob_",
          names(probs)
        )

      newdata <-
        bind_cols(
          newdata,
          probs
        )

    }

  }

  ###########################################################################
  # Return data frame
  ###########################################################################

  return(newdata)

}

###############################################################################
# Predict summary only
###############################################################################

predict_summary <- function(model,
                            newdata,
                            beds = 450){

  prediction_df <-
    predict_los(
      model,
      newdata
    )

  calculate_summary(
    prediction_df,
    beds
  )

}

###############################################################################
# Confusion matrix helper
###############################################################################

prediction_distribution <- function(prediction_df){

  prediction_df |>

    count(
      LOS_prediction
    ) |>

    mutate(

      Percent =

        round(

          100*n/sum(n),

          1

        )

    )

}

###############################################################################
# Expected bed-days
###############################################################################

expected_beddays <- function(prediction_df){

  sum(

    prediction_df$LOS_midpoint,

    na.rm = TRUE

  )

}

###############################################################################
# Expected occupancy
###############################################################################

expected_occupancy <- function(prediction_df,
                               beds,
                               period = 30){

  100 *

    expected_beddays(
      prediction_df
    ) /

    (beds*period)

}

###############################################################################
# Mean predicted LOS
###############################################################################

mean_los <- function(prediction_df){

  mean(

    prediction_df$LOS_midpoint,

    na.rm = TRUE

  )

}

###############################################################################
# Long-stay patients
###############################################################################

longstay_patients <- function(prediction_df){

  sum(

    prediction_df$LOS_prediction %in%

      c(
        "20-29",
        "30-90"
      )

  )

}

###############################################################################
# End of prediction.R
###############################################################################
