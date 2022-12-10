#!/usr/bin/env python
import pandas as pd

if __name__ == "__main__":

    recomb_df = pd.read_csv("query_fasta/recombinant_metadata.tsv", sep='\t')
    sample = recomb_df.groupby("pango_lineage").head(1)
    with open('query_fasta/recombinant_sample_accessions.txt', 'w') as fh:
        for acc in sample['strain']:
            fh.write(acc + '\n')
