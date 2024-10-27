# Load required libraries
library(tidyverse)

# Define the folder path
folder_path <- "D:/24S2/clade-profile-mixtures/data/result2csv/"

# Get all .csv files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Initialize an empty data frame to store the Models and BIC ranks from different files
rank_table <- data.frame(Model = character(), stringsAsFactors = FALSE)

# Loop through each file, read, and process the data
for (file in file_list) {
  # Read the csv file and remove the first column
  data <- read.csv(file, header = TRUE)[, -1]

  # Extract the file name without ".csv" and keep only the leading numbers
  file_name <- gsub(".csv", "", basename(file))
  file_name <- gsub("[^0-9]", "", file_name)

  # Process model names: remove content inside parentheses and strip everything after the first "+"
  data$Model <- gsub("\\(.*?\\)", "", data$Model)  # Remove parentheses and contents
  data$Model <- gsub("\\+.*", "", data$Model)      # Remove everything after the first "+"

  # Rank models based on BIC (smaller BIC gets a better rank)
  data <- data %>%
    arrange(BIC) %>%
    mutate(Rank = row_number())

  # Select Model and Rank columns
  data_to_add <- data %>%
    select(Model, Rank) %>%
    distinct()

  # Rename the Rank column to the file's number
  colnames(data_to_add)[2] <- file_name

  # Merge into the main rank_table, using "Model" as the key
  rank_table <- full_join(rank_table, data_to_add, by = "Model")
}

# Step 1: Replace specific model names
rank_table$Model <- rank_table$Model %>%
  str_replace_all("MF\\.F10", "MF+C10") %>%
  str_replace_all("MF\\.F2", "MF+F2")

# Step 2: Convert to long format, preparing for bump plot
rank_long <- rank_table %>%
  pivot_longer(cols = -Model, names_to = "File", values_to = "Rank") %>%
  mutate(File = as.numeric(File))  # Ensure that File is treated as numeric for plotting

# Step 3: Adjust the order of levels in the legend
rank_long$Model <- factor(rank_long$Model,
                          levels = c("MF", "Q.plantF1", "MF+F2", "Q.plantF2", "MF+C10", "Q.plantF10"))

# Step 4: Create bump plot
ggplot(rank_long, aes(x = File, y = Rank, color = Model, group = Model)) +
  geom_line(size = 0.55) +
  geom_point(size = 1.2) +
  theme_minimal() +
  labs(x = "Gene locus", y = "Rank") +
  theme(
    legend.position = "right",
    legend.title = element_text(face = "bold", size = 12, hjust = 0.5),
    legend.text = element_text(size = 10),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    legend.background = element_rect(colour = "black", fill = "white")
  ) +
  scale_color_manual(values = c("#5f5f5f", "#2e7ebb", "#2e974e", "#F1AEA7", "purple", "#d92523")) +
  scale_y_reverse(breaks = 1:max(rank_long$Rank)) +
  guides(color = guide_legend(title = "model"))
