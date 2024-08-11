"""Concatenate all gene sequences of the selected species into a sequence alignment 
file ("alignment.nex") and partition model files ("train.nex"/"test.nex"). 
Below is the code for creating example files (12 species and 10 genes):
"""

import os
import pandas as pd

# Set file paths
base_folder = 'D:/24S2/project/smalldata/genes'  # Path to the genes folder
species_file = 'D:/24S2/project/smalldata/12.csv'  # Path to the 12.csv file
output_alignment_file = 'D:/24S2/clade-profile-mixtures/data/example_alignment.nex'
output_train_file = 'D:/24S2/clade-profile-mixtures/data/example_train.nex'

# Read species list, starting from the second row
species_df = pd.read_csv(species_file, header=0)
species_list = species_df.iloc[:, 0].tolist()

# Initialize sequence storage
sequences = {species: '' for species in species_list}
charsets = []

# Iterate over all subfolders
all_folders = sorted([folder for folder in os.listdir(base_folder) if os.path.isdir(os.path.join(base_folder, folder))])

total_length = 0

for folder in all_folders:
    folder_path = os.path.join(base_folder, folder)
    fasta_file = os.path.join(folder_path, 'FAA-upp-masked.fasta.mask10sites.mask33taxa.fasta')
    
    if os.path.isfile(fasta_file):
        with open(fasta_file, 'r') as f:
            lines = f.readlines()
        
        # Parse the FASTA file
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
        
        seq_length = len(next(iter(seq_data.values())))
        total_length += seq_length
        charsets.append(f"CHARSET OG{folder} = {total_length - seq_length + 1} - {total_length};")
        
        # Concatenate sequences
        for species in species_list:
            if species in seq_data:
                sequences[species] += seq_data[species]
            else:
                sequences[species] += '-' * seq_length

# Write the alignment.nex file
max_species_length = max(len(species) for species in species_list)
with open(output_alignment_file, 'w') as f:
    # Write the number of species and total sequence length
    f.write(f"{len(species_list)} {total_length}\n")
    for species in species_list:
        # Ensure the second column is aligned
        f.write(f"{species.ljust(max_species_length + 1)}{sequences[species]}\n")

# Write the train.nex file
with open(output_train_file, 'w') as f:
    f.write("#nexus\nbegin sets;\n")
    for charset in charsets:
        f.write(f"\t{charset}\n")
    f.write("end;")

print(f"Alignment file saved as: {output_alignment_file}")
print(f"Train file saved as: {output_train_file}")
