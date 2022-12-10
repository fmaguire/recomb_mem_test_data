# MEM/Recomb Test Data 

Test data for Travis' idea for using MEMs to try and identify recombination.
All data was generated using `run.sh` (see `env.yaml` for specific dependencies used) with the open global SARS-CoV-2 dataset (~1/2 of all data but saves dealing with GISAID) as processed by Nexstrain.

Briefly:
- 10,000 sequences were randomly sampled from this dataset and used to generate a phylogeny.
- Leaf order was extracted using a post-order traversal (top to bottom or I guess right to left in classic CS root at the top tree orientations).
- This was used to reorder the 10k fasta to match and also generate a concatenated genomic sequence (both can be found in `ordered_fasta/`)
- Finally, I manually compressed everything to squeeze it onto github!

I also grabbed 91 sample queries from the nexstrain dataset (1 of each lineage assignment amongst all putatively recombinant samples in open dataset) to test the approach (`query_fasta/recombinant_query_seqs.fasta`).
