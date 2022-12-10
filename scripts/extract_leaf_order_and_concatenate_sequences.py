#!/usr/bin/env python

import ete3
from Bio import SeqIO
from Bio import Seq
from Bio import SeqRecord
from tqdm import tqdm

if __name__ == '__main__':

    sequences = "fasta/open_sc2_10k.fasta"
    seq_dict = {}
    for record in tqdm(SeqIO.parse(sequences, "fasta")):
        seq_dict[record.id] = record

    tree = ete3.Tree("phylo/open_sc2_10k.tree", quoted_node_names=True)

    leaf_ordered_accs = []
    leaf_ordered_fasta = []
    leaf_ordered_concatenated_seq = Seq.Seq("")
    # by default this is a postorder traversal so should get the correct order
    for leaf in tqdm(tree.iter_leaves()):
        leaf_seq = seq_dict[leaf.name]

        leaf_ordered_fasta.append(leaf_seq)
        leaf_ordered_accs.append(leaf_seq.id)
        leaf_ordered_concatenated_seq += leaf_seq.seq

    with open("ordered_fasta/open_sc2_10k_leaf_ordered.fasta", "w") as fh:
        SeqIO.write(leaf_ordered_fasta, fh, "fasta-2line")

    with open("ordered_fasta/open_sc2_10k_leaf_ordered_concatenated.fasta", "w") as fh:
        SeqIO.write(SeqRecord.SeqRecord(leaf_ordered_concatenated_seq,
                                        id="$".join(leaf_ordered_accs),
                                        name='',
                                        description=''),
                    fh, 'fasta-2line')
