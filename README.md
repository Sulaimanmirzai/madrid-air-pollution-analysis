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

1.Install all the required libraries into your R environment. 
*Since we are working with dplyr, plotly, shiny, ggplot2, scales and tidyr, you need to install them.
2.Get to the folder structure next. Make sure that you have a folder with all dedicated files in it. 
*In our case those were 18 datasets madrid2001.csv till madrid2018.csv and the stations.csv file
3.Bind 18 individual tables on top of each other vertically and save them in one dataframe.
*Make sure data types correspond to data objects, namely their gist and purpose in the dataset, 
remove any spaces and normalise columns to the common standard.
4.Join on the data, in our case, we used a left_join on the 'station' key
5.Build an interactive dashboard using Shiny.
*Build a vector mapping limits to pollutants
*Define the database constrains (e.g. converting units into the universal ones, etc)
*Create a selection bar for pollutants, a slider bar to filter years and a checkbox to choose thresholds.
*Create 4 distinct visual summary cards
6.Build interactives 'filtered' and 'yearly' to react to users' clicks
*Calculate percentage changes relatively to 2001 baseline, using geom_tile in ggplot2
*Convert static graphs to interactives getting from ggplot to ggplotly
7.Tie everything together with the shinyApp

## Dataset

Madrid Air Quality Dataset (2001–2018)

## Authors
- [Sulaiman Mirzai-(2502936)]
- [Zunaira Zafar-(2504869)]
- [Alejandrina Jimenez Guzman-(2467951)]
- [Maryna Poberezhna-(2504257)]
