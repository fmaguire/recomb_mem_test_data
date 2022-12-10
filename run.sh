#!/bin/bash
set -euo pipefail

# 20221208
mkdir -p raw_data
wget -P raw_data https://data.nextstrain.org/files/ncov/open/metadata.tsv.gz
wget -P raw_data https://data.nextstrain.org/files/ncov/open/sequences.fasta.xz
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=MN908947.3&rettype=fasta&retmode=txt" > raw_data/MN908947_3.fasta

num_samples=$(zcat raw_data/metadata.tsv.gz | wc -l)
prop=$(bc -l <<< "($num_samples - 1) / 3")

# sample approximately 10k in a streaming manner from .xz compression 
mkdir -p fasta
xzcat raw_data/sequences.fasta.xz | seqkit sample -p "$prop" -s 42 > fasta/open_sc2_10kish.fasta
# sample exactly 10k
seqkit sample -n 10000 fasta/open_sc2_10kish.fasta -s 11 -w 0 > fasta/open_sc2_10k.fasta
rm fasta/open_sc2_10kish.fasta

# build alignment using quick reference approach (with pangolin trimming params)
mkdir -p phylo
minimap2 -a -x asm20 --sam-hit-only --secondary=no --score-N=0 -t 4 raw_data/MN908947_3.fasta fasta/open_sc2_10k.fasta -o phylo/open_sc2_10k.sam 
gofasta sam toMultiAlign \
     -s phylo/open_sc2_10k.sam \
     -t 4 \
     --reference raw_data/MN908947_3.fasta \
     --trimstart 265 \
     --trimend 29674 \
     --trim \
     --pad > phylo/open_sc2_10k.afa
rm phylo/open_sc2_10k.sam

# generate phylogeny using fasttree
fasttree -nt phylo/open_sc2_10k.afa > phylo/open_sc2_10k.tree

# - parse the tree and extract leaf order 
#   (postorder traversel - top to bottom leaves (R-L in root in classic CS "root at top" format)
# - reorder fasta using this leaf order
# - concatenate fasta following this leaf order (accession includes the leaf order)
mkdir -p ordered_fasta 
python scripts/extract_leaf_order_and_concatenate_sequences.py 

# get recombinants as assigned by nextstrain clade 
zcat head -n1 raw_data/metadata.tsv.gz > query_fasta/headers.txt
zgrep "recombinant" raw_data/metadata.tsv.gz > query_fasta/recombinants.tsv
cat query_fasta/headers.txt query_fasta/recombinants.tsv > query_fasta/recombinant_metadata.tsv
rm query_fasta/headers.txt query_fasta/recombinants.tsv
xzcat raw_data/sequences.fasta.xz | seqtk subseq - query_fasta/recombinant_sample_accessions.txt > query_fasta/recombinant_query_seqs.fasta
rm query_fasta/recombinant_sample_accessions.txt 
