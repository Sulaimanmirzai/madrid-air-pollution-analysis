# ============================================================
# Madrid Air Quality - Interactive Shiny Dashboard
# Run AFTER data loading & merging code
# Launch with: shiny::runApp("madrid_shiny.R")
# ============================================================

library(shiny)
library(dplyr)
library(ggplot2)
library(tidyr)
library(scales)
library(plotly)   

# ── CONSTANTS ────────────────────────────────────────────────
EU_LIMITS <- c(NO_2 = 40, PM10 = 40, O_3 = 120, SO_2 = 125)

POLLUTANTS <- c("NO_2", "PM10", "O_3", "SO_2", "CO")

POLLUTANT_LABELS <- c(
  "NO_2" = "NO₂ (µg/m³)",
  "PM10" = "PM10 (µg/m³)",
  "O_3"  = "O₃ (µg/m³)",
  "SO_2" = "SO₂ (µg/m³)",
  "CO"   = "CO (mg/m³)"
)

# ── UI ───────────────────────────────────────────────────────
ui <- fluidPage(
  
  tags$head(tags$style(HTML("
    body { font-family: 'Georgia', serif; background-color: #f9f9f7; }
    h2   { color: #1a1a2e; font-weight: bold; margin-bottom: 4px; }
    .well { background: #ffffff; border: 1px solid #e0e0e0;
            border-radius: 8px; padding: 16px; }
    .nav-tabs > li > a { color: #444; }
    .nav-tabs > li.active > a { font-weight: bold; color: #1a1a2e; }
    .subtitle { color: #666; font-size: 13px; margin-bottom: 20px; }
  "))),
  
  titlePanel(
    div(
      h2("Air Quality in Madrid (2001–2018)"),
      p("Explore pollution trends, station comparisons, and pollutant patterns.",
        class = "subtitle")
    )
  ),
  
  # ── Shared controls (shown on all tabs) ──
  fluidRow(
    column(4,
           wellPanel(
             selectInput("pollutant", "Pollutant:",
                         choices  = setNames(POLLUTANTS, POLLUTANT_LABELS),
                         selected = "NO_2"),
             sliderInput("year_range", "Year range:",
                         min = 2001, max = 2018,
                         value = c(2001, 2018), step = 1, sep = ""),
             checkboxInput("show_eu", "Show EU limit reference line", value = TRUE)
           )
    ),
    column(8,
           # KPI summary boxes
           fluidRow(
             column(3, div(class = "well", style = "text-align:center",
                           strong("Avg (all years)"), br(),
                           textOutput("kpi_avg"))),
             column(3, div(class = "well", style = "text-align:center",
                           strong("Peak year"), br(),
                           textOutput("kpi_peak"))),
             column(3, div(class = "well", style = "text-align:center",
                           strong("Best year"), br(),
                           textOutput("kpi_best"))),
             column(3, div(class = "well", style = "text-align:center",
                           strong("% change"), br(),
                           textOutput("kpi_change")))
           )
    )
  ),
  
  hr(),
  
  # ── Tabs ──
  tabsetPanel(
    
    # TAB 1: Trend over time
    tabPanel("📈 Trend Over Time",
             br(),
             plotlyOutput("plot_trend", height = "420px"),
             br(),
             p("Tip: hover over points for exact values. Click the legend to hide/show series.",
               class = "subtitle")
    ),
    
    # TAB 2: Station ranking
    tabPanel("🏙️ Station Ranking",
             br(),
             fluidRow(
               column(3,
                      selectInput("rank_year", "Select year:",
                                  choices  = 2001:2018,
                                  selected = 2018),
                      radioButtons("rank_order", "Show:",
                                   choices  = c("Top 10 highest" = "top",
                                                "Bottom 10 lowest" = "bottom",
                                                "All stations" = "all"),
                                   selected = "top")
               ),
               column(9, plotlyOutput("plot_ranking", height = "500px"))
             )
    ),
    
    # TAB 3: Heatmap (station × year)
    tabPanel("🗓️ Station × Year Heatmap",
             br(),
             p("Shows which stations were worst in which years. 
        Click a cell to filter the trend chart on Tab 1.",
               class = "subtitle"),
             plotlyOutput("plot_heatmap", height = "550px")
    ),
    
    # TAB 4: Multi-pollutant comparison
    tabPanel("🔬 Multi-Pollutant Trends",
             br(),
             checkboxGroupInput("multi_poll_select", "Select pollutants to compare:",
                                choices  = setNames(POLLUTANTS, POLLUTANT_LABELS),
                                selected = POLLUTANTS,
                                inline   = TRUE),
             plotlyOutput("plot_multi", height = "420px"),
             br(),
             p("Values normalised to % change from 2001 baseline — allows comparison across units.",
               class = "subtitle")
    )
  )
)


# ── SERVER ───────────────────────────────────────────────────
server <- function(input, output, session) {
  
  # ── Reactive: filtered data ──
  filtered <- reactive({
    madrid_all %>%
      filter(year >= input$year_range[1],
             year <= input$year_range[2])
  })
  
  yearly <- reactive({
    filtered() %>%
      group_by(year) %>%
      summarise(avg = mean(.data[[input$pollutant]], na.rm = TRUE),
                .groups = "drop")
  })
  
  # ── KPI boxes ──
  output$kpi_avg <- renderText({
    val  <- mean(filtered()[[input$pollutant]], na.rm = TRUE)
    unit <- ifelse(input$pollutant == "CO", "mg/m³", "µg/m³")
    paste0(round(val, 1), " ", unit)
  })
  
  output$kpi_peak <- renderText({
    d <- yearly()
    d$year[which.max(d$avg)]
  })
  
  output$kpi_best <- renderText({
    d <- yearly()
    d$year[which.min(d$avg)]
  })
  
  output$kpi_change <- renderText({
    d <- yearly()
    if (nrow(d) < 2) return("N/A")
    first <- d$avg[1]
    last  <- d$avg[nrow(d)]
    pct   <- round((last - first) / first * 100, 1)
    paste0(ifelse(pct < 0, "▼ ", "▲ "), abs(pct), "%")
  })
  
  # ── TAB 1: Trend ──
  output$plot_trend <- renderPlotly({
    d    <- yearly()
    poll <- input$pollutant
    eu   <- EU_LIMITS[poll]
    
    unit <- ifelse(poll == "CO", "mg/m³", "µg/m³")
    
    p <- ggplot(d, aes(x = year, y = avg, group = 1,
                       text = paste0("Year: ", year,
                                     "<br>Avg: ", round(avg, 1), " ", unit))) +
      geom_line(colour = "steelblue", linewidth = 1) +
      geom_point(colour = "steelblue", size = 2.5) +
      scale_x_continuous(breaks = seq(input$year_range[1],
                                      input$year_range[2], by = 2)) +
      scale_y_continuous(labels = comma) +
      labs(title = paste("Yearly average:", POLLUTANT_LABELS[poll]),
           x = "Year", y = POLLUTANT_LABELS[poll]) +
      theme_classic(base_size = 13)
    
    # Conditionally add EU limit
    if (input$show_eu && !is.na(eu)) {
      p <- p +
        geom_hline(yintercept = eu,
                   linetype = "dashed", colour = "#d73027", linewidth = 0.8) +
        annotate("text", x = min(d$year), y = eu + (max(d$avg, na.rm = TRUE) * 0.03),
                 label = paste0("EU limit (", eu, " ", unit, ")"),
                 colour = "#d73027", hjust = 0, size = 3.5)
    }
    
    ggplotly(p, tooltip = "text") %>%
      layout(hovermode = "x unified")
  })
  
  # ── TAB 2: Ranking ──
  output$plot_ranking <- renderPlotly({
    poll <- input$pollutant
    eu   <- EU_LIMITS[poll]
    unit <- ifelse(poll == "CO", "mg/m³", "µg/m³")
    
    d <- madrid_all %>%
      filter(year == as.integer(input$rank_year)) %>%
      group_by(name) %>%
      summarise(avg = mean(.data[[poll]], na.rm = TRUE), .groups = "drop") %>%
      filter(!is.na(avg), !is.na(name)) %>%
      arrange(desc(avg))
    
    # Subset based on radio button
    d <- switch(input$rank_order,
                "top"    = head(d, 10),
                "bottom" = tail(d, 10),
                "all"    = d
    )
    
    d <- d %>%
      mutate(name = factor(name, levels = rev(name)))
    
    p <- ggplot(d, aes(x = name, y = avg, fill = avg,
                       text = paste0(name, "<br>Avg: ",
                                     round(avg, 1), " ", unit))) +
      geom_col() +
      scale_fill_gradient(low = "#fee08b", high = "#d73027",
                          name = unit) +
      coord_flip() +
      scale_y_continuous(labels = comma) +
      labs(title = paste0(POLLUTANT_LABELS[poll], " by station (", input$rank_year, ")"),
           x = NULL, y = POLLUTANT_LABELS[poll]) +
      theme_classic(base_size = 12)
    
    if (input$show_eu && !is.na(eu)) {
      p <- p +
        geom_hline(yintercept = eu, linetype = "dashed",
                   colour = "black", linewidth = 0.7)
    }
    
    ggplotly(p, tooltip = "text")
  })
  
  # ── TAB 3: Heatmap ──
  output$plot_heatmap <- renderPlotly({
    poll <- input$pollutant
    
    d <- filtered() %>%
      group_by(year, name) %>%
      summarise(avg = mean(.data[[poll]], na.rm = TRUE), .groups = "drop") %>%
      filter(!is.na(avg), !is.na(name))
    
    unit <- ifelse(poll == "CO", "mg/m³", "µg/m³")
    
    p <- ggplot(d, aes(x = year, y = name, fill = avg,
                       text = paste0(name, "<br>Year: ", year,
                                     "<br>Avg: ", round(avg, 1), " ", unit))) +
      geom_tile(colour = "white", linewidth = 0.3) +
      scale_fill_gradient(low = "#ffffcc", high = "#800026",
                          name = unit, na.value = "grey90") +
      scale_x_continuous(breaks = 2001:2018) +
      labs(title = paste(POLLUTANT_LABELS[poll], "— station × year"),
           x = "Year", y = NULL) +
      theme_minimal(base_size = 11) +
      theme(axis.text.x  = element_text(angle = 45, hjust = 1),
            axis.text.y  = element_text(size = 8),
            panel.grid   = element_blank())
    
    ggplotly(p, tooltip = "text")
  })
  
  # ── TAB 4: Multi-pollutant ──
  output$plot_multi <- renderPlotly({
    req(input$multi_poll_select)
    
    d <- filtered() %>%
      group_by(year) %>%
      summarise(across(all_of(input$multi_poll_select),
                       \(x) mean(x, na.rm = TRUE)),
                .groups = "drop") %>%
      pivot_longer(-year, names_to = "pollutant", values_to = "avg") %>%
      group_by(pollutant) %>%
      mutate(
        baseline   = avg[year == min(year)],
        pct_change = (avg - baseline) / baseline * 100
      ) %>%
      ungroup() %>%
      mutate(label = case_match(pollutant,
                                "NO_2" ~ "NO₂", "PM10" ~ "PM10",
                                "O_3"  ~ "O₃",  "SO_2" ~ "SO₂", "CO" ~ "CO",
                                .default = pollutant
      ))
    
    p <- ggplot(d, aes(x = year, y = pct_change,
                       colour = label, group = label,
                       text = paste0(label, "<br>Year: ", year,
                                     "<br>Change: ", round(pct_change, 1), "%"))) +
      geom_hline(yintercept = 0, colour = "grey60", linewidth = 0.6) +
      geom_line(linewidth = 1) +
      geom_point(size = 1.8) +
      scale_x_continuous(breaks = seq(input$year_range[1],
                                      input$year_range[2], by = 2)) +
      labs(title = "% change from baseline year — all selected pollutants",
           x = "Year", y = "% change from baseline",
           colour = "Pollutant") +
      theme_classic(base_size = 13)
    
    ggplotly(p, tooltip = "text") %>%
      layout(hovermode = "x unified")
  })
}

# ── RUN ──────────────────────────────────────────────────────
shinyApp(ui = ui, server = server)