#' @title Retrieve Classification Information for Species in a Data Frame
#'
#' @description This function takes a CSV file containing species information, retrieves their classification information using the rgbif package, and outputs a new CSV file with additional columns for each taxonomic rank.
#'
#' @param input_path The file path to the input CSV file containing species information.
#' @param output_path The file path where the output CSV file with classification information will be saved.
#'
#' @return A data frame with the original columns plus additional columns for each taxonomic rank.
#'
#' @examples
#' \dontrun{
#'   # Example usage
#'   classify_species("input.csv", "output.csv")
#' }
#'
#' @import dplyr
#' @import readr
#' @import rgbif
#' @import foreach
#' @import doParallel
#' @export

species_classified <- function(input_path, output_path) {
  input_table <- read_csv(input_path)
  species_col <- "Species"
  if (!species_col %in% colnames(input_table)) {
    stop("Error: The input file does not contain a 'Species' column.")
  }

  # Initialize an empty data frame to store the final results
  final_df <- input_table
  interested_cols <- c("Code", "Species", "Classification", "kingdom", "phylum", "class", "order", "family", "genus", "species")
  for (col in interested_cols) {
    final_df[[col]] <- NA
  }

  # Register parallel backend
  num_cores <- detectCores() - 1
  cl <- makeCluster(num_cores)
  registerDoParallel(cl)

  # Process the list of species names in parallel and retrieve classification information
  results_list <- foreach(i = 1:nrow(input_table), .packages = c("rgbif", "dplyr")) %dopar% {
    species <- input_table[[species_col]][i]
    result_row <- input_table[i, ]

    # Initialize a result row with NA values
    result_template <- as.data.frame(matrix(NA, ncol = length(interested_cols), dimnames = list(NULL, interested_cols)))

    tryCatch({
      classification <- name_backbone(name = species)

      if (is.null(classification) || length(classification) == 0) {
        stop("Species not found")
      }

      # Fill classification information into the result template
      result_template$Code <- result_row$Code
      result_template$Species <- result_row$Species
      result_template$Classification <- result_row$Classification
      result_template$kingdom <- classification$kingdom
      result_template$phylum <- classification$phylum
      result_template$class <- classification$class
      result_template$order <- classification$order
      result_template$family <- classification$family
      result_template$genus <- classification$genus
      result_template$species <- classification$species
    }, error = function(e) {
      result_template$Code <- result_row$Code
      result_template$Species <- result_row$Species
    })

    return(result_template)
  }

  stopCluster(cl)

  # Ensure all result data frames contain the required columns
  results_list <- lapply(results_list, function(df) {
    missing_cols <- setdiff(interested_cols, names(df))
    for (col in missing_cols) {
      df[[col]] <- NA
    }
    return(df)
  })

  # Convert the results list to a data frame and combine it into the final data frame
  final_df <- do.call(rbind, results_list)

  write.csv(final_df, output_path, row.names = FALSE)
}
