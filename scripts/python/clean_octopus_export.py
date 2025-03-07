# Cleans an email export from EmailOctopus by extracting only the email addresses and writing them to a new file (used for imports to Google & Apple)

import csv
import os

def main():
    input_file = os.path.expanduser(input('Enter the path to the input file: ').strip())
    output_file = os.path.expanduser(input('Enter the path to the output file: ').strip())

    with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.writer(outfile)

        # Write email addresses
        for row in reader:
            writer.writerow([row['Email address']])
            
      

if __name__ == "__main__":
    main()