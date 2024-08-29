import re
import numpy as np
import sys

def extract_weights_and_frequencies(file_path):
    """
    Extract weights and FO arrays from the specified file path.
    """
    weights = []
    frequencies = []
    
    # Open and read the file content, specify encoding as UTF-8
    with open(file_path, 'r', encoding='utf-8') as file:
        file_content = file.read()
    
    # Find each line's weight and FO array
    matches = re.findall(r'GTR20\s+1\.0000\s+([\d.]+)\s+GTR20\+FO{([\d.,]+)}', file_content)
    
    for match in matches:
        weight = float(match[0])
        freq_array = list(map(float, match[1].split(',')))
        weights.append(weight)
        frequencies.append(freq_array)
    
    return weights, frequencies

def calculate_weighted_frequencies(weights, frequencies):
    """
    Calculate the weighted frequencies.
    """
    weighted_frequencies = np.zeros(len(frequencies[0]))
    
    for weight, freq_array in zip(weights, frequencies):
        weighted_frequencies += np.array(freq_array) * weight
    
    return weighted_frequencies

def append_frequencies_to_file(output_file, frequencies_str):
    """
    Add the calculated frequencies to the specified file's last line,
    and prepend a space to the line.
    """
    # Read the target file content
    with open(output_file, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    # Find the last line with content, overwrite it, and prepend a space to the line
    for i in range(len(lines)-1, -1, -1):
        if lines[i].strip():
            lines[i] = ' ' + frequencies_str + '\n'
            break

    # Write the modified content back to the file
    with open(output_file, 'w', encoding='utf-8') as file:
        file.writelines(lines)

def main():
    # Get the file paths from command line arguments
    if len(sys.argv) != 3:
        print("Usage: python fixQ.py <input_file_path> <output_file_path>")
        sys.exit(1)
    
    input_file_path = sys.argv[1]
    output_file_path = sys.argv[2]

    # Extract weights and FO arrays from the input file
    weights, frequencies = extract_weights_and_frequencies(input_file_path)

    # Calculate the weighted frequencies
    weighted_frequencies = calculate_weighted_frequencies(weights, frequencies)

    # Format the weighted frequencies as a comma-separated string
    weighted_frequencies_str = ' '.join(f"{freq:.8f}" for freq in weighted_frequencies)

    # Add the calculated frequencies to the last line of the target file
    append_frequencies_to_file(output_file_path, weighted_frequencies_str)

    # Print success message
    print(f"Successfully modified {output_file_path}")

if __name__ == "__main__":
    main()

