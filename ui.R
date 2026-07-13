###############################################################################
# ui.R
#
# User Interface
# Hospital LOS Scenario Dashboard
###############################################################################

app_ui <- function() {

page_navbar(

title = "Hospital LOS Scenario Dashboard",

theme = bs_theme(
version = 5,
bootswatch = "flatly",
primary = "#2C3E50"
),

################################################################################
# Sidebar
################################################################################

sidebar = sidebar(

width = 340,

h4("Scenario Settings"),

hr(),

sliderInput(
"emergency",
"Emergency admissions (%)",
min = 0,
max = 100,
value = 45
),

sliderInput(
"elective",
"Elective admissions (%)",
min = 0,
max = 100,
value = 55
),

sliderInput(
"elderly",
"Patients ≥65 years (%)",
min = 0,
max = 100,
value = 22
),

sliderInput(
"male",
"Male patients (%)",
min = 0,
max = 100,
value = 48
),

sliderInput(
"surgical",
"Surgical admissions (%)",
min = 0,
max = 100,
value = 35
),

numericInput(
"admissions",
"Monthly admissions",
5000,
min = 100
),

numericInput(
"beds",
"Available beds",
450,
min = 10
),

selectInput(
"region",
"Region",
choices = NULL
),

selectInput(
"ownership",
"Hospital ownership",
choices = NULL
),

selectInput(
"level",
"Hospital level",
choices = NULL
),

br(),

actionButton(
"runScenario",
"Run Scenario",
class = "btn-primary"
),

actionButton(
"resetScenario",
"Reset",
class = "btn-secondary"
),

width = 320

),

################################################################################
# Dashboard
################################################################################

################################################################################
# HOME
################################################################################

nav_panel(

"Dashboard",

layout_column_wrap(

width = 1/4,

value_box(
title = "Mean LOS",
value = textOutput("meanLOS"),
theme = "primary"
),

value_box(
title = "Bed-days",
value = textOutput("bedDays"),
theme = "success"
),

value_box(
title = "Bed Occupancy",
value = textOutput("occupancy"),
theme = "warning"
),

value_box(
title = "Long LOS",
value = textOutput("longStay"),
theme = "danger"
)

),

hr(),

layout_columns(

card(

full_screen = TRUE,

card_header("Baseline vs Scenario"),

plotlyOutput(
"baselineScenarioPlot",
height = "500px"
)

),

card(

full_screen = TRUE,

card_header("Predicted LOS Distribution"),

plotlyOutput(
"losDistribution",
height = "500px"
)

)

)

),

################################################################################
# LOS Distribution
################################################################################

nav_panel(

"LOS Distribution",

layout_columns(

card(

full_screen = TRUE,

card_header("Predicted LOS Categories"),

plotlyOutput(
"losBar",
height = "600px"
)

),

card(

full_screen = TRUE,

card_header("LOS Proportions"),

plotlyOutput(
"losPie",
height = "600px"
)

)

)

),

################################################################################
# Bed Occupancy
################################################################################

nav_panel(

"Bed Occupancy",

layout_columns(

card(

full_screen = TRUE,

card_header("Estimated Bed Occupancy"),

plotlyOutput(
"occupancyPlot",
height = "600px"
)

),

card(

full_screen = TRUE,

card_header("Expected Bed-days"),

plotlyOutput(
"beddayPlot",
height = "600px"
)

)

)

),

################################################################################
# Scenario Comparison
################################################################################

nav_panel(

"Scenario Comparison",

card(

full_screen = TRUE,

card_header("Baseline vs Scenario Summary"),

DT::DTOutput("scenarioTable")

)

),

################################################################################
# Representative Cohort
################################################################################

nav_panel(

"Representative Cohort",

card(

full_screen = TRUE,

card_header("Modified Patient Cohort"),

DT::DTOutput("cohortTable")

)

),

################################################################################
# About
################################################################################

nav_panel(

"About",

card(

card_header("Hospital LOS Scenario Dashboard"),

HTML("

<h4>Purpose</h4>

<p>
This dashboard demonstrates how machine learning can support
hospital planning through scenario analysis.
Users can modify characteristics of a representative patient cohort
and estimate the impact on predicted LOS distribution,
bed occupancy and hospital resource requirements.
</p>

<h4>Workflow</h4>

<ol>

<li>Modify patient mix.</li>

<li>Run the scenario.</li>

<li>The trained machine learning model predicts LOS for each patient.</li>

<li>Predictions are aggregated into operational metrics.</li>

<li>Baseline and scenario results are compared.</li>

</ol>

")

)

)

)

}
