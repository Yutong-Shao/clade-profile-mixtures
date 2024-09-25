# Load required libraries
library(tidyverse)

# Define the folder path
folder_path <- "D:/24S2/clade-profile-mixtures/data/result2csv/"

# Get all .csv files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Initialize an empty data frame to store the Models from different statistical metrics
model_count <- data.frame(Model = character(), Metric = character(), stringsAsFactors = FALSE)

# Loop through each file, read, and process the data
for (file in file_list) {
  # Read the csv file and remove the first column
  data <- read.csv(file, header = TRUE)[, -1]

  # Find the row with the smallest BIC
  min_bic_row <- data[which.min(data$BIC), ]
  model_bic <- str_split(min_bic_row$Model, "\\+", simplify = TRUE)[1]

  # Find the row with the smallest AIC
  min_aic_row <- data[which.min(data$AIC), ]
  model_aic <- str_split(min_aic_row$Model, "\\+", simplify = TRUE)[1]

  # Find the row with the smallest AICc
  min_aicc_row <- data[which.min(data$AICc), ]
  model_aicc <- str_split(min_aicc_row$Model, "\\+", simplify = TRUE)[1]

  # Find the row with the largest LogL
  max_logl_row <- data[which.max(data$LogL), ]
  model_logl <- str_split(max_logl_row$Model, "\\+", simplify = TRUE)[1]

  # Add the results to the model_count data frame
  model_count <- rbind(model_count,
                       data.frame(Model = model_bic, Metric = "BIC", stringsAsFactors = FALSE),
                       data.frame(Model = model_aic, Metric = "AIC", stringsAsFactors = FALSE),
                       data.frame(Model = model_aicc, Metric = "AICc", stringsAsFactors = FALSE),
                       data.frame(Model = model_logl, Metric = "LogL", stringsAsFactors = FALSE))
}

# Count the occurrence of each Model in different statistical metrics
model_summary <- model_count %>%
  group_by(Model, Metric) %>%
  summarise(count = n()) %>%
  ungroup()

model_summary <- rbind(model_summary,
                       data.frame(Model = "MF", Metric = "BIC", count = 0),
                       data.frame(Model = "MF", Metric = "AIC", count = 0),
                       data.frame(Model = "MF", Metric = "AICc", count = 0),
                       data.frame(Model = "MF", Metric = "LogL", count = 0))

model_summary <- model_summary %>%
  mutate(Model = ifelse(Model == "MF(Q.plant).F2", "MF(Q.plant)+F2",
                        ifelse(Model == "MF(JTT).C10", "MF(JTT)+C10",
                               ifelse(Model == "MF(Q.plant).C10", "MF(Q.plant)+C10", Model))))

# Plot the bar chart
ggplot(model_summary, aes(x = Model, y = count, fill = Metric)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.85), width = 0.7, color = "black") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    axis.ticks = element_line(),
    axis.ticks.length = unit(0.2, "cm"),
    axis.line = element_line(colour = "black"),
    plot.title = element_blank()
  ) +
  labs(y = "Count") +
  scale_y_continuous(limits = c(0, 25), breaks = seq(0, 25, by = 5), expand = c(0, 0)) + # Set y-axis range from 0 to 25, with breaks every 5 units
  scale_x_discrete(limits = c("MF", "Q.plantF1", "MF(Q.plant)+F2", "Q.plantF2","MF(JTT)+C10", "MF(Q.plant)+C10", "Q.plantF10")) + # Set x-axis category order
  scale_fill_manual(values = c("#059554", "#65BA94", "#ABDCAF", "#D3D79B")) +
  guides(fill = guide_legend(title = NULL))






