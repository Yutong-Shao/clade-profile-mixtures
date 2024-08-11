Here is a short description of the `process` folder:

## Process

`filter_species.py`: Code used to create `data/example_genes`, which will serve as the sequence files for estimating the Q.plant matrix.

`species2gene.py`: Code used to create `/data/process/total_species.csv`, which will be used for species selection.

`total_species.csv`：

- Column 1 ("select"): `*` indicates that the species is selected as one of the 100 taxa, but currently, this file only updates the selection status for 22 species.

- Column 4 ("COUNT_gene"): Represents the number of gene information entries included for this species in 1KP, which will be one of the main reference factors for my species selection. The table is sorted in descending order based on this value.

- Columns 5 and onwards: Each column corresponds to a gene alignment file, with 1 indicating the presence of information for the species in that gene alignment file, and 0 indicating its absence.