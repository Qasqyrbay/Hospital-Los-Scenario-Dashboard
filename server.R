##############################################################################
# server.R
##############################################################################

server <- function(input, output, session) {
  
  ##############################################################################
  # BASELINE PREDICTION
  ##############################################################################
  
  baseline_prediction <- reactive({
    
    pred <- predict(
      rf_final,
      data = cohort[, predictors, drop = FALSE],
      type = "response"
    )
    
    prob <- as.data.frame(pred$predictions)
    colnames(prob) <- los_levels
    
    pred_class <- factor(
      colnames(prob)[max.col(prob)],
      levels = los_levels
    )
    
    list(
      prob = prob,
      class = pred_class
    )
    
  })
  
  ##############################################################################
  # BUILD PATIENT FROM USER INPUT
  ##############################################################################
  
  build_patient <- function(input){
    
    ## Start with one template patient
    patient <- cohort[1, predictors, drop = FALSE]
    
    ## Reset all predictors
    patient[,] <- 0
    
    ############################################################
    ## AGE
    ############################################################
    
    switch(input$age_group,
           
           "0–4"   = patient$newborn       <- 1,
           "5–17"  = patient$child         <- 1,
           "18–44" = patient$young_adult   <- 1,
           "45–71" = patient$middle_adult  <- 1,
           "72+"   = patient$senior        <- 1
    )
    
    ############################################################
    ## SEX
    ############################################################
    
    if(input$sex == "Female"){
      patient$F <- 1
    }else{
      patient$M <- 1
    }
    
    ############################################################
    ## RESIDENCE
    ############################################################
    
    if(input$residence == "Urban"){
      patient$city <- 1
    }else{
      patient$rural <- 1
    }
    
    ############################################################
    ## ADMISSION
    ############################################################
    
    if(input$admission == "Emergency"){
      patient$emergency <- 1
    }else{
      patient$planned <- 1
    }
    
    ############################################################
    ## OWNERSHIP
    ############################################################
    
    if(input$ownership == "Government"){
      patient$gov <- 1
    }else{
      patient$person <- 1
    }
    
    ############################################################
    ## HOSPITAL LEVEL
    ############################################################
    
    if(input$level == "Regional")
      patient$regional <- 1
    
    if(input$level == "Republican")
      patient$republican <- 1
    
    if(input$level == "National")
      patient$National_status <- 1
    
    ############################################################
    ## REGION
    ############################################################
    
    patient[[input$region]] <- 1
    
    ############################################################
    ## DIAGNOSIS
    ############################################################
    
    diagnosis_map <- c(
      
      "Blood"="blood",
      "Circulatory"="circulatory",
      "Digestive"="digestive",
      "Endocrine"="endocrine",
      "Eye"="eye",
      "External"="external",
      "Genitourinary"="genitourinary",
      "Infectious"="infectious",
      "Injury"="injury",
      "Mental"="mental",
      "Musculoskeletal"="musculoskeletal",
      "Neoplasms"="neoplasms",
      "Nervous"="nervous",
      "Perinatal"="perinatal",
      "Pregnancy"="pregnancy",
      "Respiratory"="respiratory",
      "Skin"="skin"
      
    )
    
    patient[[ diagnosis_map[input$diagnosis] ]] <- 1
    
    ############################################################
    ## SPECIALTY
    ############################################################
    
    specialty_map <- c(
      
      "Internal Medicine"="InternalMedicine",
      "Surgery"="Surgery",
      "Obstetrics & Gynecology"="ObstetricsGynecology",
      "Pediatrics"="Pediatrics",
      "Orthopedics & Trauma"="Orthopedics_Trauma",
      "Neurology & Neurosurgery"="NeurologyNeurosurgery",
      "Cardiology & Cardiovascular Surgery"="Cardiology_CardiovascularSurgery",
      "Oncology & Hematology"="Oncology_Hematology",
      "Critical Care"="Critical_Care",
      "Nephrology"="Nephrology",
      "ENT / Ophthalmology / Dental"="ENT_Ophthalmology_Dental"
      
    )
    
    patient[[ specialty_map[input$specialty] ]] <- 1
    
    ############################################################
    ## DEFAULT VALUES
    ############################################################
    
    patient$public <- 1
    patient$special <- 0
    patient$clinical_findings <- 0
    patient$complication <- 0
    patient$no_complication <- 1
    patient$referred <- 0
    
    patient
    
  }
  
  ##############################################################################
  # INDIVIDUAL PREDICTION
  ##############################################################################
  
  individual_prediction <- eventReactive(input$predict, {
    
    patient <- build_patient(input)
    
    pred <- predict(
      
      rf_final,
      
      data = patient,
      
      type = "response"
      
    )
    
    probs <- as.numeric(pred$predictions)
    
    names(probs) <- los_labels
    
    list(
      
      patient = patient,
      
      probability = probs,
      
      predicted = names(probs)[which.max(probs)]
      
    )
    
  })
  
  ##############################################################################
  # PREDICTED CLASS
  ##############################################################################
  
  output$predicted_class <- renderText({
    
    req(individual_prediction())
    
    paste(
      
      "Predicted LOS class:",
      
      individual_prediction()$predicted
      
    )
    
  })
  
  ##############################################################################
  # PROBABILITY TABLE
  ##############################################################################
  
  output$probability_table <- renderDT({
    
    req(individual_prediction())
    
    df <- data.frame(
      
      LOS_Class = los_labels,
      
      Probability = round(
        
        individual_prediction()$probability,
        
        4
        
      )
      
    )
    
    datatable(
      
      df,
      
      rownames = FALSE,
      
      options = list(
        
        pageLength = 5,
        
        dom = "t"
        
      )
      
    )
    
  })
  
  ##############################################################################
  # PROBABILITY PLOT
  ##############################################################################
  
  output$probability_plot <- renderPlotly({
    
    req(individual_prediction())
    
    df <- data.frame(
      
      LOS = los_labels,
      
      Probability = individual_prediction()$probability
      
    )
    
    p <- ggplot(
      
      df,
      
      aes(
        
        LOS,
        
        Probability,
        
        fill = LOS
        
      )
      
    ) +
      
      geom_col(width = .7) +
      
      geom_text(
        
        aes(
          
          label = scales::percent(
            
            Probability,
            
            accuracy = 0.1
            
          )
          
        ),
        
        vjust = -0.3,
        
        size = 5
        
      ) +
      
      scale_fill_manual(values = los_palette) +
      
      scale_y_continuous(labels = scales::percent) +
      
      labs(
        
        x = "",
        
        y = "Predicted probability"
        
      ) +
      
      theme_bw(14) +
      
      theme(
        
        legend.position = "none"
        
      )
    
    ggplotly(p)
    
  })
  
  ##############################################################################
  # BASELINE LOS DISTRIBUTION
  ##############################################################################
  
  baseline_distribution <- reactive({
    
    baseline_prediction()$class |>
      table() |>
      prop.table() |>
      as.data.frame() |>
      rename(
        LOS_Class = Var1,
        Proportion = Freq
      ) |>
      mutate(
        Label = los_labels[match(LOS_Class, los_levels)]
      )
    
  })
  
  ##############################################################################
  # EXPECTED LOS
  #
  # Estimated from predicted probabilities
  ##############################################################################
  
  expected_los <- reactive({
    
    probs <- as.matrix(
      baseline_prediction()$prob
    )
    
    los <- probs %*% matrix(
      los_midpoints,
      ncol = 1
    )
    
    mean(los)
    
  })
  
  ##############################################################################
  # BED-DAYS
  ##############################################################################
  
  bed_days <- reactive({
    
    expected_los() *
      default_monthly_admissions
    
  })
  
  ##############################################################################
  # REQUIRED BEDS
  ##############################################################################
  
  required_beds <- reactive({
    
    bed_days() /
      default_days_per_month
    
  })
  
  ##############################################################################
  # VALUE BOXES
  ##############################################################################
  
  output$cohort_box <- renderValueBox({
    
    valueBox(
      
      scales::comma(nrow(cohort)),
      
      "Representative cohort",
      
      icon = icon("users"),
      
      color = "light-blue"
      
    )
    
  })
  
  ##############################################################################
  
  output$class_box <- renderValueBox({
    
    dist <- baseline_distribution()
    
    valueBox(
      
      dist$Label[which.max(dist$Proportion)],
      
      "Most likely LOS class",
      
      icon = icon("hospital"),
      
      color = "green"
      
    )
    
  })
  
  ##############################################################################
  
  output$beddays_box <- renderValueBox({
    
    valueBox(
      
      scales::comma(round(bed_days())),
      
      "Expected bed-days",
      
      icon = icon("calendar"),
      
      color = "yellow"
      
    )
    
  })
  
  ##############################################################################
  
  output$beds_box <- renderValueBox({
    
    valueBox(
      
      round(required_beds()),
      
      "Required beds",
      
      icon = icon("bed"),
      
      color = "red"
      
    )
    
  })
  
  ##############################################################################
  # LOS DISTRIBUTION
  ##############################################################################
  
  output$los_distribution <- renderPlotly({
    
    p <-
      
      ggplot(
        
        baseline_distribution(),
        
        aes(
          
          Label,
          
          Proportion,
          
          fill = Label
          
        )
        
      ) +
      
      geom_col(width = .7) +
      
      geom_text(
        
        aes(
          
          label = scales::percent(
            Proportion,
            accuracy = .1
          )
          
        ),
        
        vjust = -.35,
        
        size = 5
        
      ) +
      
      scale_fill_manual(
        
        values = los_palette
        
      ) +
      
      scale_y_continuous(
        
        labels = scales::percent,
        
        limits = c(0, 0.7)
        
      ) +
      
      labs(
        
        x = NULL,
        
        y = "Predicted proportion"
        
      ) +
      
      theme_bw(15) +
      
      theme(
        
        legend.position = "none"
        
      )
    
    ggplotly(p)
    
  })
  
  ##############################################################################
  # BED REQUIREMENTS
  ##############################################################################
  
  output$bed_plot <- renderPlotly({
    
    df <- data.frame(
      
      Metric = c(
        
        "Expected LOS",
        
        "Bed-days",
        
        "Required beds"
        
      ),
      
      Value = c(
        
        expected_los(),
        
        bed_days(),
        
        required_beds()
        
      )
      
    )
    
    p <-
      
      ggplot(
        
        df,
        
        aes(
          
          Metric,
          
          Value,
          
          fill = Metric
          
        )
        
      ) +
      
      geom_col(width = .6) +
      
      geom_text(
        
        aes(
          
          label = round(Value, 1)
          
        ),
        
        vjust = -.3,
        
        size = 5
        
      ) +
      
      theme_bw(15) +
      
      theme(
        
        legend.position = "none"
        
      )
    
    ggplotly(p)
    
  })
  
  ##############################################################################
  # SUMMARY TABLE
  ##############################################################################
  
  output$summary_table <- renderDT({
    
    datatable(
      
      baseline_distribution() |>
        
        mutate(
          
          Percentage = round(
            Proportion * 100,
            1
          )
          
        ) |>
        
        select(
          
          LOS_Class = Label,
          
          Percentage
          
        ),
      
      rownames = FALSE,
      
      options = list(
        
        dom = "t",
        
        paging = FALSE,
        
        searching = FALSE,
        
        ordering = FALSE,
        
        info = FALSE
        
      )
      
    )
    
  })
  
  ##############################################################################
  # END SERVER
  ##############################################################################
  
}

