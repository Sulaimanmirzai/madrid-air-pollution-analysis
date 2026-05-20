library(dplyr)

folder_path <- "/Users/sulaimanmirzai/Desktop/visualisation in Data Science/Project Design/VDS2526_Madrid/"

# Get all years Madrid files (2001–2018)

files <- list.files(
  path = folder_path,
  pattern = "^madrid_(200[1-9]|201[0-8])\\.csv$",
  full.names = TRUE
)

# Read and combine all files
madrid_all <- files %>%
  lapply(function(f) read.csv(f, stringsAsFactors = FALSE)) %>%
  bind_rows()
nrow(madrid_all)
head(madrid_all)
#Convert date and create year

madrid_all$date <- as.Date(as.character(madrid_all$date))
madrid_all$year <- as.integer(format(madrid_all$date, "%Y"))


# 6. Clean station column

madrid_all$station <- trimws(as.character(madrid_all$station))


# 7. Load stations file

stations <- read.csv(
  file.path(folder_path, "stations.csv"),
  stringsAsFactors = FALSE
)

# Prepare stations dataset

stations <- stations %>%
  rename(station = id) %>%
  mutate(station = trimws(as.character(station))) %>%
  distinct(station, .keep_all = TRUE)


# Merge (LEFT JOIN - KEEP ALL DATA)

madrid_all <- left_join(madrid_all, stations, by = "station")
madrid_all$year

unique(madrid_all$name)
# 10. Check results (IMPORTANT)
ncol(madrid_all)
nrow(madrid_all)                
unique(madrid_all$year)         #  show 2001–2018
sum(is.na(madrid_all$name))     # check missing station info
str(madrid_all)
summary(madrid_all)

head(madrid_all)
## Extra information, checking the trendind of NO2 over the years 

yearly_NO2 <- madrid_all %>%
  group_by(year) %>%
  summarise(avg_NO2 = mean(NO_2, na.rm = TRUE))

## for Part 2.2
summary(madrid_all$NO_2)
summary(madrid_all$CO)
summary(madrid_all$PM10)
  

# Tasks Plots 
library(ggplot2)
library(scales)
# Question 1
yearly_NO2 <- madrid_all %>%
  group_by(year) %>%
  summarise(avg_NO2 = mean(NO_2, na.rm = TRUE))
ggplot(yearly_NO2, aes(x = year, y = avg_NO2)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 2) +
  scale_y_continuous(labels = comma) +
  labs(title = "Trend of NO2 Levels Over Time",
       x = "Year",
       y = "Average NO2") +
  theme_classic()

# Question 2 
station_NO2 <- madrid_all %>%
  group_by(station) %>%
  summarise(avg_NO2 = mean(NO_2, na.rm = TRUE)) %>%
  arrange(desc(avg_NO2))
# TOP
top10 <- station_NO2 %>% head(10)

ggplot(top10, aes(x = reorder(station, avg_NO2), y = avg_NO2)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Stations with Highest NO2",
       x = "Station",
       y = "Average NO2") +
  theme_classic()
# Bottom
bottom10 <- station_NO2 %>% tail(10)

ggplot(bottom10, aes(x = reorder(station, avg_NO2), y = avg_NO2)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() +
  labs(title = "Lowest 10 Stations with NO2",
       x = "Station",
       y = "Average NO2") +
  theme_classic()



library(leaflet)

# Prepare station-level data
map_data <- madrid_all %>%
  filter(!is.na(name)) %>%
  group_by(name, lon, lat) %>%
  summarise(
    avg_NO2 = mean(NO_2, na.rm = TRUE),
    avg_PM10 = mean(PM10, na.rm = TRUE),
    .groups = "drop"
  )



