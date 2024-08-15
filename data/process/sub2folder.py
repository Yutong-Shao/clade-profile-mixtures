"""
Extract the required species sequences from each gene alignment file, write them 
to a new NEXUS file, and store them in a new folder.

Usage:
    python sub2folder.py <base_folder> <species_file> <output_folder>
"""

import os
import pandas as pd
import random
import shutil

def read_species_list(species_file):
    """Read the species list from the CSV file, starting from the second row."""
    try:
        species_df = pd.read_csv(species_file, header=0)
        species_list = species_df["Code"].iloc[1:].tolist()
        print(f"Read {len(species_list)} species from {species_file}")
        return species_list
    except Exception as e:
        print(f"Error reading species file: {e}")
        raise

def process_gene_folder(folder_path, species_list, output_folder, folder_name):
    """Process a single gene folder to extract and filter species sequences."""
    fasta_file = os.path.join(folder_path, 'FAA-upp-masked.fasta.mask10sites.mask33taxa.fasta')
    
    if not os.path.isfile(fasta_file):
        print(f"FASTA file not found in {folder_path}")
        return
    
    try:
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

        # Filter out the species present in the species list
        filtered_seqs = {species: seq_data[species] for species in species_list if species in seq_data}

        # Write to a new NEXUS file
        ntax = len(filtered_seqs)
        nchar = len(next(iter(filtered_seqs.values()))) if ntax > 0 else 0
        output_nexus_file = os.path.join(output_folder, f"GENE_{folder_name}.nex")
        
        with open(output_nexus_file, 'w') as out_f:
            out_f.write("#NEXUS\n")
            out_f.write(f"[\nPartition: CDS_{folder_name}\n]\n")
            out_f.write("begin data;\n")
            out_f.write(f"\tdimensions ntax={ntax} nchar={nchar};\n")
            out_f.write("	format datatype=protein missing=X gap=-;\n")
            out_f.write("matrix\n")
            
            for species, seq in filtered_seqs.items():
                out_f.write(f"{species} {seq}\n")
            
            out_f.write(";\nend;\n")
        
        print(f"Processed {ntax} species from {folder_name}")

    except Exception as e:
        print(f"Error processing folder {folder_name}: {e}")
        raise

def process_genes(base_folder, species_file, output_folder):
    """Main function to process all gene folders and filter species sequences."""
    try:
        # Ensure the output folder exists
        os.makedirs(output_folder, exist_ok=True)
        print(f"Output folder created: {output_folder}")

        # Read the species list
        species_list = read_species_list(species_file)

        # Iterate over all subfolders
        all_folders = sorted([folder for folder in os.listdir(base_folder) if os.path.isdir(os.path.join(base_folder, folder))])
        print(f"Found {len(all_folders)} folders to process in {base_folder}")

        for folder in all_folders:
            folder_path = os.path.join(base_folder, folder)
            process_gene_folder(folder_path, species_list, output_folder, folder)

        print(f"Filtered NEXUS files have been saved in {output_folder}")
        
        # Split the output NEXUS files into train and test subfolders
        split_train_test(output_folder)
    
    except Exception as e:
        print(f"Error in process_genes: {e}")
        raise

def split_train_test(output_folder):
    """Split the NEXUS files into train and test subfolders."""
    # Create train and test subfolders
    train_folder = os.path.join(output_folder, 'train')
    test_folder = os.path.join(output_folder, 'test')
    os.makedirs(train_folder, exist_ok=True)
    os.makedirs(test_folder, exist_ok=True)

    # List all NEXUS files in the output folder
    all_nexus_files = [file for file in os.listdir(output_folder) if file.endswith('.nex')]

    # Shuffle the list of NEXUS files
    random.shuffle(all_nexus_files)

    # Calculate the number of files for the train set (90%)
    train_count = int(len(all_nexus_files) * 0.9)
    
    # Split the files into train and test sets
    train_files = all_nexus_files[:train_count]
    test_files = all_nexus_files[train_count:]

    # Move the files to the respective folders
    for file in train_files:
        shutil.move(os.path.join(output_folder, file), os.path.join(train_folder, file))
    for file in test_files:
        shutil.move(os.path.join(output_folder, file), os.path.join(test_folder, file))

    print(f"Moved {len(train_files)} files to {train_folder}")
    print(f"Moved {len(test_files)} files to {test_folder}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 4:
        print("Usage: python sub2folder.py <base_folder> <species_file> <output_folder>")
    else:
        base_folder = sys.argv[1]
        species_file = sys.argv[2]
        output_folder = sys.argv[3]
        print(f"Running sub2folder with base_folder={base_folder}, species_file={species_file}, output_folder={output_folder}")
        process_genes(base_folder, species_file, output_folder)
