# Load necessary libraries
library(ggplot2)
library(reshape2)
library(ggrepel)
library(ggforce)

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

# Step 4: PCA analysis
perform_pca <- function(data_matrix) {
  pca_result <- prcomp(data_matrix, scale. = TRUE)
  return(pca_result)
}

# Step 5: PCA result visualization with customized legend
plot_pca <- function(pca_result, file_names) {
  pca_df <- as.data.frame(pca_result$x)

  # Process file names, keeping only the basename
  pca_df$file <- gsub("^.*/|\\.csv$", "", file_names)

  # Define groups based on file names
  pca_df$group <- "other"  # Default group
  general_indices <- which(pca_df$file %in% c("LG", "JTT", "WAG"))
  pca_df$group[general_indices] <- "general"

  Q.otherclade_indices <- which(pca_df$file %in% c("Q.insect", "Q.mammal", "Q.bird", "Q.yeast", "Q.pfam"))
  pca_df$group[Q.otherclade_indices] <- "Q.other-clade"

  Q.plant_indices <- which(pca_df$file %in% c("Q.plant", "Q.plantF1(1)", "Q.plantF1(2)", "Q.plantF1(3)", "Q.plantF1(4)", "Q.plantF1(5)", "Q.plantF1(6)"))
  pca_df$group[Q.plant_indices] <- "Q.plant"

  # Define colors for groups
  colors <- c("Q.other-clade" = "#F5A433", "Q.plant" = "#48ad64", "general" = "#529ac9", "other" = "black")

  # Extract variance percentage explained by PCA
  variance_percent <- round(100 * pca_result$sdev^2 / sum(pca_result$sdev^2), 2)

  # Get the range of X and Y
  x_range <- range(pca_df$PC1)
  y_range <- range(pca_df$PC2)

  # Expand the range
  x_expand <- x_range[2] - x_range[1]
  y_expand <- y_range[2] - y_range[1]

  # Plot the PCA
  ggplot(pca_df, aes(x = PC1, y = PC2, label = file, color = group)) +
    geom_point(size = 2) +
    geom_text_repel() +  # Use ggrepel to avoid label overlap
    xlim(x_range[1] - x_expand/5, x_range[2] + x_expand/5) +  # Expand X-axis range
    ylim(y_range[1] - y_expand/5, y_range[2] + y_expand/5) +  # Expand Y-axis range
    theme_minimal() +
    theme(legend.position = "right",
          legend.title = element_text(size = 10, face = "bold", hjust = 0.5),  # Centered and bold
          legend.text = element_text(size = 9),
          legend.box.background = element_rect(colour = "black", size= 0.5),  # Add box around legend
          plot.title = element_text(size = 12, face = "bold", hjust = 0.5)) +
    scale_color_manual(values = colors) +
    labs(title = "PCA Plot of Exchangability Matrices",
         x = paste0("PC1 (", variance_percent[1], "%)"),
         y = paste0("PC2 (", variance_percent[2], "%)"),
         color = "Group")  # Set legend title to 'Group'
}

# Main program
folder_path <- "Q"
matrix_list <- read_matrices(folder_path)
data_matrix <- flatten_matrix(matrix_list)
pca_result <- perform_pca(data_matrix)

# Get the list of file names for display
file_names <- list.files(folder_path, full.names = FALSE)
plot_pca(pca_result, file_names)
