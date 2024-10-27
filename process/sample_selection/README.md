Here is a short description of the `sample_selection` folder:

## Sample Selection

#### <span style="color: lightblue;">Includes custom functions and important intermediate files used for sample selection.</span>

1. `species_classified.R`: Uses the "rgbif" package to provide taxonomic annotations for each species in the dataset.

    ```{r}
    source("species_classified.R")
    species_classified(input_path, output_path)
    ```

2. `species_subsample.py`: Filters the annotated species list file. Randomly selects 100 species based on family and generates a subsample list. 

    Run the script with:

    ```
    python species_subsample.py <input_file> <output_file>
    ```

3. `sub2folder.py`: Based on the subsample list, extracts the corresponding species from the original gene folder, generating training and test gene folders each containing 100 species. 

    Run the script with:

    ```
    python sub2folder.py <base_folder> <species_file> <output_folder>
    ```
