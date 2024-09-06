# Load necessary libraries
library(ggplot2)
library(reshape2)
library(ggrepel)
library(ggforce)
library(viridis)

# Step 1: Read matrix file and generate a symmetric matrix
read_matrix_file <- function(file_path) {
  mat_df <- read.csv(file_path, header = FALSE, stringsAsFactors = FALSE)

  # Extract row and column labels
  row_labels <- mat_df[-1, 1]
  col_labels <- mat_df[1, -1]

  # Extract the matrix part
  mat <- as.matrix(mat_df[-1, -1])

  # Convert character type to numeric
  mat <- apply(mat, 2, as.numeric)

  # Generate a symmetric matrix
  sym_mat <- mat + t(mat) - diag(diag(mat))

  # Set row and column names
  rownames(sym_mat) <- row_labels
  colnames(sym_mat) <- col_labels

  return(sym_mat)
}

# Step 2: Iterate over all files in the Q folder and generate a list of symmetric matrices
read_matrices <- function(folder_path) {
  file_list <- list.files(folder_path, full.names = TRUE)
  matrix_list <- list()

  for (file in file_list) {
    sym_mat <- read_matrix_file(file)
    matrix_list[[file]] <- sym_mat
  }

  return(matrix_list)
}

# Step 3: Flatten the matrix into a vector
flatten_matrix <- function(matrix_list) {
  flattened_list <- lapply(matrix_list, function(mat) {
    return(as.vector(mat))
  })

  data_matrix <- do.call(rbind, flattened_list)
  return(data_matrix)
}

# Step 4: Calculate pairwise Pearson correlations between matrices
calculate_correlations <- function(matrix_list, file_names) {
  num_matrices <- length(matrix_list)
  correlation_matrix <- matrix(NA, nrow = num_matrices, ncol = num_matrices)
  colnames(correlation_matrix) <- file_names
  rownames(correlation_matrix) <- file_names

  # Iterate through all matrix pairs and calculate Pearson correlation
  for (i in 1:num_matrices) {
    for (j in 1:i) {
      correlation_matrix[i, j] <- cor(as.vector(matrix_list[[i]]), as.vector(matrix_list[[j]]), method = "pearson")
    }
  }

  return(correlation_matrix)
}

# Step 5: Visualize the correlation matrix
visualize_correlation_matrix <- function(correlation_matrix) {
  # Convert to long format for ggplot2
  corr_df <- melt(correlation_matrix, varnames = c("Var1", "Var2"), value.name = "Correlation")
  corr_df <- na.omit(corr_df)  # Remove NA values

  ggplot(corr_df, aes(x = Var2, y = Var1, fill = Correlation)) +
    geom_tile(color = "white") +
    geom_text(aes(label = format(Correlation, digits = 4)), color = "black", size = 3) +
    scale_fill_viridis_c(option = "viridis", direction = -1,
                         alpha = 0.9,
                         guide = guide_colorbar(barheight = unit(12, "cm"),
                                                barwidth = unit(0.3, "cm"))) +
    scale_x_discrete(position = "top", limits = rev(levels(corr_df$Var2))) +
    labs(x = NULL, y = NULL, fill = NULL) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 0, vjust = 0.5, color = "black",
                                     face = "bold"),
          axis.text.y = element_blank(),
          panel.grid = element_blank(),
          panel.border = element_blank(),
          axis.ticks = element_blank(),
          axis.line = element_blank(),
          plot.margin = unit(c(1, 1, 1, 2), "cm")) +
    coord_cartesian(clip = "off") +
    geom_text(data = corr_df[corr_df$Var1 == corr_df$Var2, ],
              aes(x = Var2, y = Var1, label = Var1),
              hjust = 1, vjust = 0.5, color = "black", size = 3.2, fontface = "bold",
              nudge_x = - 0.7)
}

# Main program
folder_path <- "Q"
matrix_list <- read_matrices(folder_path)
file_names <- gsub("\\.csv$", "", list.files(folder_path, full.names = FALSE))

# Calculate the correlation matrix
correlation_matrix <- calculate_correlations(matrix_list, file_names)

# Visualize the lower triangular correlation matrix
visualize_correlation_matrix(correlation_matrix)
