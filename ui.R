##############################################################################
# ui.R
#
# Hospital Length of Stay Decision Support Dashboard
##############################################################################

ui <- dashboardPage(
  
  ##############################################################################
  # HEADER
  ##############################################################################
  
  dashboardHeader(
    
    title = "LOS Dashboard"
    
  ),
  
  ##############################################################################
  # SIDEBAR
  ##############################################################################
  
  dashboardSidebar(
    
    width = 300,
    
    sidebarMenu(
      
      id = "tabs",
      
      menuItem(
        "Dashboard",
        tabName = "dashboard",
        icon = icon("chart-line")
      ),
      
      menuItem(
        "Individual Prediction",
        tabName = "prediction",
        icon = icon("user")
      ),
      
      menuItem(
        "Scenario Analysis",
        tabName = "scenario",
        icon = icon("sliders")
      ),
      
      menuItem(
        "Model Interpretation",
        tabName = "interpretation",
        icon = icon("chart-bar")
      ),
      
      menuItem(
        "About",
        tabName = "about",
        icon = icon("info-circle")
      )
      
    )
    
  ),
  
  ##############################################################################
  # BODY
  ##############################################################################
  
  dashboardBody(
    
    fluidRow(
      
      valueBoxOutput("cohort_box", width = 3),
      
      valueBoxOutput("class_box", width = 3),
      
      valueBoxOutput("beds_box", width = 3),
      
      valueBoxOutput("beddays_box", width = 3)
      
    ),
    
    tabItems(
      
      ##############################################################################
      # DASHBOARD
      ##############################################################################
      
      tabItem(
        
        tabName = "dashboard",
        
        fluidRow(
          
          box(
            
            title = "Predicted LOS Distribution",
            
            width = 7,
            
            status = "primary",
            
            solidHeader = TRUE,
            
            plotlyOutput("los_distribution", height = 450)
            
          ),
          
          box(
            
            title = "Estimated Bed Requirements",
            
            width = 5,
            
            status = "primary",
            
            solidHeader = TRUE,
            
            plotlyOutput("bed_plot", height = 450)
            
          )
          
        ),
        
        fluidRow(
          
          box(
            
            title = "Summary",
            
            width = 12,
            
            status = "primary",
            
            solidHeader = TRUE,
            
            DTOutput("summary_table")
            
          )
          
        )
        
      ),
      
      ##############################################################################
      # INDIVIDUAL PREDICTION
      ##############################################################################
      
      tabItem(
        
        tabName = "prediction",
        
        fluidRow(
          
          ###########################################################
          # LEFT PANEL
          ###########################################################
          
          box(
            
            width = 4,
            
            title = "Patient Information",
            
            status = "primary",
            
            solidHeader = TRUE,
            
            h4("Patient"),
            
            selectInput(
              
              "age_group",
              
              "Age group",
              
              choices = c(
                
                "0–4",
                
                "5–17",
                
                "18–44",
                
                "45–71",
                
                "72+"
                
              )
              
            ),
            
            radioButtons(
              
              "sex",
              
              "Sex",
              
              choices = c(
                
                "Female",
                
                "Male"
                
              )
              
            ),
            
            radioButtons(
              
              "residence",
              
              "Residence",
              
              choices = c(
                
                "Urban",
                
                "Rural"
                
              )
              
            ),
            
            hr(),
            
            h4("Admission"),
            
            radioButtons(
              
              "admission",
              
              "Admission Type",
              
              choices = c(
                
                "Emergency",
                
                "Elective"
                
              )
              
            ),
            
            hr(),
            
            h4("Hospital"),
            
            radioButtons(
              
              "ownership",
              
              "Ownership",
              
              choices = c(
                
                "Government",
                
                "Private"
                
              )
              
            ),
            
            selectInput(
              
              "level",
              
              "Hospital Level",
              
              choices = c(
                
                "Regional",
                
                "Republican",
                
                "National"
                
              )
              
            ),
            
            selectInput(
              
              "region",
              
              "Region",
              
              choices = c(
                
                "North",
                
                "South",
                
                "East",
                
                "West",
                
                "Central"
                
              )
              
            ),
            
            hr(),
            
            h4("Clinical"),
            
            selectInput(
              
              "diagnosis",
              
              "Major Diagnosis Group",
              
              choices = c(
                
                "Blood",
                
                "Circulatory",
                
                "Digestive",
                
                "Endocrine",
                
                "Eye",
                
                "External",
                
                "Genitourinary",
                
                "Infectious",
                
                "Injury",
                
                "Mental",
                
                "Musculoskeletal",
                
                "Neoplasms",
                
                "Nervous",
                
                "Perinatal",
                
                "Pregnancy",
                
                "Respiratory",
                
                "Skin"
                
              )
              
            ),
            
            selectInput(
              
              "specialty",
              
              "Clinical Specialty",
              
              choices = c(
                
                "Internal Medicine",
                
                "Surgery",
                
                "Obstetrics & Gynecology",
                
                "Pediatrics",
                
                "Orthopedics & Trauma",
                
                "Neurology & Neurosurgery",
                
                "Cardiology & Cardiovascular Surgery",
                
                "Oncology & Hematology",
                
                "Critical Care",
                
                "Nephrology",
                
                "ENT / Ophthalmology / Dental"
                
              )
              
            ),
            
            br(),
            
            actionButton(
              
              "predict",
              
              "Predict LOS",
              
              icon = icon("play"),
              
              class = "btn-primary"
              
            )
            
          ),
          
          ###########################################################
          # RIGHT PANEL
          ###########################################################
          
          box(
            
            width = 8,
            
            title = "Prediction Results",
            
            status = "success",
            
            solidHeader = TRUE,
            
            h3(textOutput("predicted_class")),
            
            br(),
            
            plotlyOutput(
              
              "probability_plot",
              
              height = 450
              
            ),
            
            br(),
            
            DTOutput(
              
              "probability_table"
              
            )
            
          )
          
        )
        
      ),
      
      ##############################################################################
      # SCENARIO ANALYSIS
      ##############################################################################
      
      tabItem(
        
        tabName = "scenario",
        
        fluidRow(
          
          box(
            
            width = 4,
            
            title = "Scenario",
            
            status = "warning",
            
            solidHeader = TRUE,
            
            sliderInput(
              
              "scenario_emergency",
              
              "Emergency Admissions (%)",
              
              0,
              
              100,
              
              40
              
            ),
            
            sliderInput(
              
              "scenario_older",
              
              "Patients ≥72 years (%)",
              
              0,
              
              100,
              
              20
              
            ),
            
            sliderInput(
              
              "scenario_monthly",
              
              "Monthly Admissions",
              
              500,
              
              10000,
              
              2500,
              
              step = 100
              
            ),
            
            actionButton(
              
              "runScenario",
              
              "Run Scenario",
              
              class = "btn-success"
              
            )
            
          ),
          
          box(
            
            width = 8,
            
            title = "Scenario Results",
            
            status = "warning",
            
            solidHeader = TRUE,
            
            plotlyOutput(
              
              "scenario_plot",
              
              height = 500
              
            )
            
          )
          
        ),
        
        fluidRow(
          
          box(
            
            width = 12,
            
            title = "Scenario Summary",
            
            status = "warning",
            
            solidHeader = TRUE,
            
            DTOutput(
              
              "scenario_table"
              
            )
            
          )
          
        )
        
      ),
      
      ##############################################################################
      # INTERPRETATION
      ##############################################################################
      
      tabItem(
        
        tabName = "interpretation",
        
        fluidRow(
          
          box(
            
            width = 6,
            
            title = "Random Forest Feature Importance",
            
            status = "success",
            
            solidHeader = TRUE,
            
            plotOutput(
              
              "importance_plot",
              
              height = 600
              
            )
            
          ),
          
          box(
            
            width = 6,
            
            title = "SHAP Summary Plot",
            
            status = "success",
            
            solidHeader = TRUE,
            
            plotOutput(
              
              "shap_plot",
              
              height = 600
              
            )
            
          )
          
        )
        
      ),
      
      ##############################################################################
      # ABOUT
      ##############################################################################
      
      tabItem(
        
        tabName = "about",
        
        fluidRow(
          
          box(
            
            width = 12,
            
            title = "About",
            
            status = "info",
            
            solidHeader = TRUE,
            
            HTML("

<h3>Hospital Length of Stay Decision Support Dashboard</h3>

<p>

This dashboard demonstrates the practical application of a
Random Forest model for predicting hospital length of stay categories.

</p>

<ul>

<li>Individual patient prediction</li>

<li>Scenario analysis</li>

<li>Hospital resource planning</li>

<li>Model interpretation</li>

</ul>

")
            
          )
          
        )
        
      )
      
    )
    
  )
  
)