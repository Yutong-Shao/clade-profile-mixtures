"""Extract the required species sequences from each gene alignment file, write them 
to a new FASTA file, and store them in a new folder.
"""

import os
import pandas as pd

# Set file paths
base_folder = 'D:/24S2/project/smalldata/genes'  # Path to the genes folder
species_file = 'D:/24S2/project/smalldata/12.csv'  # Path to the 12.csv file
output_folder = 'D:/24S2/project/smalldata/filtered_genes'  # Output folder path

# Ensure the output folder exists
os.makedirs(output_folder, exist_ok=True)

# Read the species list, starting from the second row
species_df = pd.read_csv(species_file, header=0)
species_list = species_df.iloc[:, 0].tolist()

# Iterate over all subfolders
all_folders = sorted([folder for folder in os.listdir(base_folder) if os.path.isdir(os.path.join(base_folder, folder))])

for folder in all_folders:
    folder_path = os.path.join(base_folder, folder)
    fasta_file = os.path.join(folder_path, 'FAA-upp-masked.fasta.mask10sites.mask33taxa.fasta')
    
    if os.path.isfile(fasta_file):
        with open(fasta_file, 'r') as f:
            lines = f.readlines()
        
        # Parse the FASTA file and extract the required species and their sequences
        current_species = None
        seq_data = {}
        for line in lines:
            if line.startswith('>'):
                current_species = line[1:15].strip()
            elif current_species:
                if current_species not in seq_data:
                    seq_data[current_species] = line.strip()
                else:
                    seq_data[current_species] += line.strip()

        # Filter out the species present in 12.csv
        filtered_seqs = {species: seq_data[species] for species in species_list if species in seq_data}

        # Write to a new FASTA file
        output_fasta_file = os.path.join(output_folder, f"GENE_{folder}.fasta")
        with open(output_fasta_file, 'w') as out_f:
            for species, seq in filtered_seqs.items():
                out_f.write(f'>{species}\n{seq}\n')

print(f"Filtered FASTA files have been saved in {output_folder}")
