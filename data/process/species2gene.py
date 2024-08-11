"""Traverse all species in the 1kp dataset to obtain the presence of their alignment sequences at each gene position.
"""

import os
import csv

# Set the folder path and species file path
base_folder = 'D:/24S2/1kp-zenodo/alignments/genes'
species_file = 'D:/24S2/1kp-zenodo/names.csv'

# Read the existing species list
species_list = []
with open(species_file, 'r') as csvfile:
    csv_reader = csv.reader(csvfile)
    header = next(csv_reader)
    for row in csv_reader:
        if len(row) > 1:  # Ensure there are enough columns
            species_list.append(row[1].strip())

# Initialize a dictionary to store results
results = {species: [] for species in species_list}

# Get all subfolder names
all_folders = sorted([folder for folder in os.listdir(base_folder) if os.path.isdir(os.path.join(base_folder, folder))])
len(all_folders)

# Iterate over all subfolders and read FASTA files
for folder in all_folders:
    folder_path = os.path.join(base_folder, folder)
    fasta_file = os.path.join(folder_path, 'FAA-upp-masked.fasta.mask10sites.mask33taxa.fasta')
    folder_results = {species: 0 for species in species_list}
    if os.path.isfile(fasta_file):
        with open(fasta_file, 'r') as f:
            species_set = set()
            for line in f:
                if line.startswith('>'):
                    species = line[1:15].strip()
                    species_set.add(species)
            for species in species_set:
                if species in folder_results:
                    folder_results[species] = 1
    for species in species_list:
        results[species].append(folder_results[species])

# Write the results to the existing CSV file, extending the column names with subfolder names
output_file = 'D:/24S2/1kp-zenodo/updated_names.csv'
with open(species_file, 'r') as infile, open(output_file, 'w', newline='') as outfile:
    csv_reader = csv.reader(infile)
    csv_writer = csv.writer(outfile)
    header = next(csv_reader)
    new_header = header + all_folders
    csv_writer.writerow(new_header)
    for row in csv_reader:
        species = row[1].strip()  # Ensure reading the species name from the second column
        if species in results:
            new_row = row + results[species]
            csv_writer.writerow(new_row)

print(f'Results have been written to {output_file}')
