library(tidyverse)
library(ggplot2)
library(scales)

data <- read_csv("merged_ridership.csv", show_col_types = FALSE)

#Total Ridership by Year
data_yearly <- data %>%
  mutate(Year = lubridate::year(Month)) %>%
  group_by(Year) %>%
  summarize(Total_Ridership = sum(Count, na.rm = TRUE))

p1 <- ggplot(data_yearly, aes(x = Year, y = Total_Ridership, fill = factor(Year))) + 
  geom_col(alpha = 0.8) +
  scale_fill_viridis_d() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Total Metro Ridership by Year", 
       x = "Year", 
       y = "Total Ridership") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave(file.path(output_dir, "ridership_by_year.png"), plot = p1, width = 10, height = 6, dpi = 300)

#Ridership by Time of Day
time_levels <- c("AM Peak (Open-9:30am)", "Midday (9:30am-3pm)", 
                 "PM Peak (3pm-7pm)", "Evening (7pm-12am)", 
                 "Late Night (12am-Close)")
data$`Time Period` <- factor(data$`Time Period`, levels = time_levels, ordered = TRUE)

p2 <- ggplot(data, aes(x = `Time Period`, y = Count, fill = `Time Period`)) +
  geom_col(alpha = 0.8) +
  scale_fill_viridis_d() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Metro Ridership by Time of Day", x = "Time Period", y = "Total Ridership") +
  theme_minimal()
ggsave(file.path(output_dir, "time_period_ridership.png"), plot = p2, width = 10, height = 6, dpi = 300)
