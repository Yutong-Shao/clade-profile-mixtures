"""
Clean and sample species data from a CSV file.

This script reads a species CSV file, 
removes rows where the 'kingdom' column is not 'Plantae', 
where the 'family' or 'species' columns are 'NA', 
and then randomly samples 100 rows with unique 'family' values 
and saves them to a new CSV file.

Usage:
    python species_subsample.py <input_file> <output_file>
"""

import pandas as pd
import sys

def species_subsample(input_file, output_file):
    df = pd.read_csv(input_file)
    
    # Remove rows
    df = df[df['kingdom'] == 'Plantae']
    df = df[df['family'].notna()]
    df = df[df['species'].notna()]
    
    # Print the total number of rows after cleaning
    print(f"Total rows after cleaning: {len(df)}")
    
    # Randomly sample 100 rows with unique 'family' values
    sampled_df = df.groupby('family').apply(lambda x: x.sample(1)).sample(n=100, random_state=1)
    
    # Save the result to a new CSV file
    sampled_df.to_csv(output_file, index=False)
    print(f"Sampled data saved to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python clean_and_sample_species.py <input_file> <output_file>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        species_subsample(input_file, output_file)

