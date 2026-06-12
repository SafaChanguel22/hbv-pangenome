"""
entete.py - FASTA Header Adapter for Pangenome Tools such as PGGB & PGGE
=====================================================
Adapts FASTA sequence headers from HBVdb format to PanSN format,
required for compatibility with pangenome construction tools (PGGB, PGGE).

HBVdb format:
    >gnl|hbvnuc|U95551_FT00000_P-D Feature FT:source ... (length=3182 residues)

PanSN format (required by PGGB/PGGE):
    >U95551#1#HBV Length=3182

Usage:
    python entete.py

Author: Safa Changuel
Context: Internship - Lyon Hepatology Institute (UMR PaThLiv), 2025
Project: HBV Pangenome Graph Construction
"""

from Bio import SeqIO
import os

# Prompt user for input and output file paths
input_file = input("Path to input FASTA file: ")
output_file = input("Path to output FASTA file: ")

# Open output file in write mode
with open(output_file, "w") as out_handle:
    # Iterate over all sequences in the input FASTA
    for record in SeqIO.parse(input_file, "fasta"):

        # Extract sequence identifier
        id = record.id

        # Compute sequence length
        seq_length = len(record.seq)

        # Build new PanSN-compliant header
        # Format: {accession}#1#HBV
        # #1# = chromosome number (default 1 for viral genomes)
        # HBV = species tag
        new_id = f"{id}#1#HBV"
        new_description = f"{id} Length = {seq_length}"

        # Update record fields
        record.id = new_id
        record.description = new_description

        # Write modified record to output file
        SeqIO.write(record, out_handle, "fasta")

print(f"Modified file saved to: {output_file}")

