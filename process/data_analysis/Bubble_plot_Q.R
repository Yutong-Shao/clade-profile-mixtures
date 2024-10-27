library(ggplot2)
library(reshape2)

# Define amino acid names
amino_acids <- c("A", "R", "N", "D", "C", "Q", "E", "G", "H", "I", "L", "K", "M", "F", "P", "S", "T", "W", "Y", "V")

# Read two matrices
# Assuming you have already defined the functions read_matrices() and flatten_matrix()
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

# Read data from the folder
folder_path <- "Q"
matrix_list <- read_matrices(folder_path)

# Flatten the matrices
data_matrix <- flatten_matrix(matrix_list)

# Retrieve two matrices Q.plant and Q.plantF1_1
Q_plant <- data_matrix["Q/Q.plantF1(6).csv", ]
Q_plantF8 <- data_matrix["Q/Q.plantF10.csv", ]

# Calculate the relative difference between the two matrices (rij1 - rij2) / (rij1 + rij2)
relative_diff <- (Q_plant - Q_plantF8) / (Q_plant + Q_plantF8)

# Create an empty matrix for storing the reconstructed lower triangular matrix
n <- length(amino_acids)  # Number of amino acids
diff_matrix <- matrix(NA, n, n)  # Empty matrix

# Fill the calculated relative differences into the lower triangular part
index <- 1
for (i in 2:n) {
  for (j in 1:(i-1)) {
    diff_matrix[i, j] <- relative_diff[index]
    index <- index + 1
  }
}

# Convert the matrix into a data frame for plotting
df <- melt(diff_matrix, varnames = c("Var1", "Var2"), value.name = "RelativeDiff")
df <- na.omit(df)  # Remove NA values

# Assign amino acid names to the matrix rows and columns
df$Var1 <- factor(df$Var1, levels = 2:n, labels = amino_acids[2:n])
df$Var2 <- factor(df$Var2, levels = 1:(n-1), labels = amino_acids[1:(n-1)])

# Plot One: The Bubble Chart
ggplot(df, aes(x = Var2, y = Var1)) +
  geom_point(aes(size = abs(RelativeDiff), fill = factor(sign(RelativeDiff))), shape = 21) +
  scale_size_continuous(range = c(1, 6), breaks = c(1/3, 2/3, 1), labels = c("1/3", "2/3", "1")) +
  scale_fill_manual(
    values = c("black", "grey", "white"),
    labels = c("Q.plantF1 < Q.plantF10", "Q.plantF1 = Q.plantF10", "Q.plantF1 > Q.plantF10")) +
  labs(x = NULL, y = NULL, fill = "Relative Diff", size = "Relative Size") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 0, vjust = 0.5, hjust = 0.5),
    axis.text.y = element_text(hjust = 1),
    legend.position = c(1, 1),
    legend.justification = c("right", "top"),
    legend.box.background = element_rect(colour = "black"),
    legend.title = element_text(face = "bold")
  ) +
  scale_y_discrete(limits = c(rev(levels(df$Var1)), 'A'))








# Step 4: Compare Q.plant and Q.plantF8 for the element-wise difference
compare_matrices <- function(mat1, mat2) {
  total_elements <- length(mat1)  # Total number of elements

  # Calculate the percentage where mat1 > 2 * mat2
  greater_than_2x <- sum(mat1 > 2 * mat2) / total_elements * 100

  # Calculate the percentage where mat1 > 5 * mat2
  greater_than_5x <- sum(mat1 > 5 * mat2) / total_elements * 100

  # Calculate the percentage where mat2 > 2 * mat1 (reverse comparison)
  less_than_2x <- sum(mat2 > 2 * mat1) / total_elements * 100

  # Calculate the percentage where mat2 > 5 * mat1 (reverse comparison)
  less_than_5x <- sum(mat2 > 5 * mat1) / total_elements * 100

  # Return the calculated percentages
  return(c(greater_than_2x, greater_than_5x, less_than_2x, less_than_5x))
}

# Calculate the percentages for Q.plant and Q.plantF8
percentages <- compare_matrices(Q_plant, Q_plantF1)

# Create a table to store the results
comparison_df <- data.frame(
  Matrix_Comparison = "Q.plant vs Q.plantF1",
  `1/3 (Greater 2x)` = percentages[1],
  `2/3 (Greater 5x)` = percentages[2],
  `-1/3 (Less 2x)` = percentages[3],
  `-2/3 (Less 5x)` = percentages[4]
)

# Print the table
print(comparison_df)

