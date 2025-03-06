library(tidyverse)
library(ggplot2)
library(sf)
library(lubridate)

data <- read_csv("merged_ridership.csv", show_col_types = FALSE)

data <- data %>%
  mutate(
    Month = as.Date(Month),
    Season = case_when(
      month(Month) %in% c(12, 1, 2) ~ "Winter",
      month(Month) %in% c(3, 4, 5) ~ "Spring",
      month(Month) %in% c(6, 7, 8) ~ "Summer",
      month(Month) %in% c(9, 10, 11) ~ "Fall"
    )
  )

time_levels <- c("AM Peak (Open-9:30am)", "Midday (9:30am-3pm)", 
                 "PM Peak (3pm-7pm)", "Evening (7pm-12am)", 
                 "Late Night (12am-Close)")


data$`Time Period` <- factor(data$`Time Period`, levels = time_levels)

set.seed(42) 
data_sampled <- data %>% sample_frac(0.3)

dc_map <- st_read("DC.geojson")

output_heatmaps <- "output_heatmaps"
if (!dir.exists(output_heatmaps)) {
  dir.create(output_heatmaps)
}

clean_theme <- theme(
  axis.title = element_blank(),
  axis.text = element_blank(),   
  axis.ticks = element_blank()   
)

color_scale <- scale_color_viridis_c(option = "magma", direction = -1)  

#Overall Metro Ridership
p1 <- ggplot() +
  geom_sf(data = dc_map, fill = NA, color = "black", linewidth = 1) +
  geom_point(data = data_sampled, aes(x = Longitude, y = Latitude, color = Count), 
             alpha = 0.8, size = 2) + 
  color_scale +  
  theme_minimal() + clean_theme +  
  labs(title = "Overall DC Metro Ridership Heatmap")

ggsave(file.path(output_heatmaps, "dc_metro_heatmap.png"), plot = p1, width = 10, height = 6, dpi = 300)


#Seasonal Metro Ridership
p2 <- ggplot() +
  geom_sf(data = dc_map, fill = NA, color = "black", linewidth = 1) + 
  geom_point(data = data_sampled, aes(x = Longitude, y = Latitude, color = Count), 
             alpha = 0.8, size = 2) +  
  color_scale +  
  theme_minimal() + clean_theme +  
  facet_wrap(~Season, ncol = 2) + 
  labs(title = "Seasonal Metro Ridership Heatmap")

ggsave(file.path(output_heatmaps, "seasonal_dc_metro_heatmap.png"), plot = p2, width = 12, height = 8, dpi = 300)


#Metro Ridership by Time Period
p3 <- ggplot() +
  geom_sf(data = dc_map, fill = NA, color = "black", linewidth = 1) +  
  geom_point(data = data_sampled, aes(x = Longitude, y = Latitude, color = Count), 
             alpha = 0.8, size = 2) +  
  color_scale +  
  theme_minimal() + clean_theme + 
  facet_wrap(~`Time Period`, ncol = 3) +  
  labs(title = "Metro Ridership by Time of Day")

ggsave(file.path(output_heatmaps, "time_of_day_metro_heatmap.png"), plot = p3, width = 12, height = 8, dpi = 300)
