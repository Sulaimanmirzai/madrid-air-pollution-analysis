# madrid-air-pollution-analysis

This project analyses air pollution trends in Madrid between 2001 and 2018 using data visualisation techniques in R.

The project was developed for the course Visualisation in Data Science and focuses on exploring temporal and spatial patterns of air pollution across monitoring stations in Madrid.

## Main Objectives

- Analyse changes in NO₂ pollution levels over time
- Compare pollution levels across monitoring stations
- Explore PM10 distribution across locations and years
- Identify pollution hotspots in Madrid

## Tools and Libraries

The project was implemented using:

- R
- ggplot2
- dplyr
- plotly
- shiny

## Repository Contents

- Data cleaning and preprocessing scripts
- Exploratory data analysis
- Visualisation design and implementation
- Interactive Shiny dashboard

## Project Set-Up Process

1.Install all the dplyr, plotly, shiny, ggplot2, scales and tidyr libraries into your R environment. 
2.Make sure that you have a folder with all 18 madrid2001 till mardid2018 datasets and the stations.csv file in it. 
3.Make sure data types correspond to data objects, namely their gist and purpose in the dataset, 
4.Remove trailing spaces and normalise columns to the common standard.
4.Left_join on the 'station' key to combine datasets.
5.Build an interactive dashboard using Shiny.
5.1.Build a vector mapping limits to pollutants
5.2.Define the database constrains (e.g. converting units into the universal ones, etc)
5.3.Create a selection bar for pollutants, a slider bar to filter years and a checkbox to choose thresholds.
5.4.Create 4 distinct visual summary cards
6.Build 'filtered' and 'yearly' interacticves to react to users' clicks
6.1.Calculate percentage changes relative to 2001 baseline, using geom_tile in ggplot2
6.2.Convert static graphs to interactives getting from ggplot to ggplotly
7.Tie everything together with the shinyApp

## Dataset

Madrid Air Quality Dataset (2001–2018)

## Authors
- [Sulaiman Mirzai-(2502936)]
- [Zunaira Zafar-(2504869)]
- [Alejandrina Jimenez Guzman-(2467951)]
- [Maryna Poberezhna-(2504257)]
