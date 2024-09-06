import os
import pandas as pd
import numpy as np
import sys

def convert_matrices_to_csv(folder_path):
    # Define the list of amino acids
    amino_acids = [
        'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I',
        'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V'
    ]
    
    # Define the output folder name
    output_folder = os.path.join(os.getcwd(), 'Q')
    
    # Create the output folder if it does not exist
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    # Check if the input path exists
    if not os.path.exists(folder_path):
        print(f"The path {folder_path} does not exist. Please check the input path.")
        return
    
    # Iterate over each file in the folder
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        
        # Only process files, skip directories
        if os.path.isfile(file_path):
            # Read the file content
            with open(file_path, 'r') as file:
                lines = file.readlines()

            # Strip each line of whitespace and newline characters
            lines = [line.strip() for line in lines if line.strip()]

            # Convert the data into a list for further processing
            data = []
            for line in lines:
                data.extend(line.split())

            # Calculate the number of elements needed for a 19x19 lower triangular matrix
            expected_length = sum(range(1, 20))
            if len(data) < expected_length:
                print(f"File {filename} does not have enough data. Expected at least {expected_length} elements, but got {len(data)}.")
                continue

            # Create a 19x19 zero matrix
            matrix = np.zeros((19, 19))

            # Fill the lower triangular matrix with the first 19 rows
            index = 0
            for i in range(19):
                for j in range(i + 1):
                    matrix[i, j] = float(data[index])
                    index += 1

            # Create a DataFrame
            # Row names: second to twentieth amino acids ('R' to 'V')
            # Column names: first 19 amino acids ('A' to 'Y')
            df = pd.DataFrame(matrix, columns=amino_acids[:19], index=amino_acids[1:])
            
            # Generate the CSV file path within the 'Q' folder
            csv_filename = f"{filename}.csv"
            csv_path = os.path.join(output_folder, csv_filename)
            
            # Save as a CSV file
            df.to_csv(csv_path)

    print("All files have been successfully converted to CSV format and saved in the 'Q' folder.")

if __name__ == "__main__":
    # Get the folder path from the command line input
    if len(sys.argv) != 2:
        print("Usage: python Qcsv.py <folder_path>")
    else:
        folder_path = sys.argv[1]
        convert_matrices_to_csv(folder_path)
