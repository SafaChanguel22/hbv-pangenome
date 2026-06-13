# HBV Pangenome Graph Construction

**Internship project at Lyon Hepatology Institute (UMR PaThLiv), 2025**    
École Centrale de Nantes · Option: Digital Sciences for Life Sciences & Healthcare

---

## Context

Hepatitis B virus (HBV) infects over 254 million people worldwide and causes more than 1 million deaths per year. Its high genetic diversity with 10 genotypes (A–J) and 40+ subgenotypes, makes a single linear reference genome insufficient for genomic analysis.

This project builds a **graph-based pangenome** of HBV from 43 reference sequences representing all known genotypes. A pangenome captures the full genetic diversity of a species rather than relying on a single reference, enabling more accurate alignment, variant calling, and cross-genotype data sharing within the scientific community.

These results provide a solid foundation for understanding the challenges related to constructing a graph pangenome to represent the genetic diversity of the hepatitis B virus.

This work is part of a larger project aimed at developing an open-source **HBV genome browser** for the research community.

---

## Biological Questions

> How can we construct a pangenome graph that faithfully represents the genetic diversity of HBV across all known genotypes?

> What criteria can be used to assess the quality of a pangenome obtained in this way?

---

## Main objective 

Construction of a graph-based pangenome for the hepatitis B virus using DNA sequences representing the reference genotypes, and the qualitative and quantitative evaluation of this pangenome. 

---

## Strategy & Sub-objectives
- Construction of several graph-based pangenomes using various bioinformatics tools based on sequences representing the reference genotypes.
- Comparison of the results obtained using visualisation, analysis and alignment quality control tools.
- Varying the parameters and attributes of each tool used to construct 
graph-based pan-genomes and compare the results obtained in order to optimise them. 

---

## Methods

### Data
- 43 HBV reference sequences from [HBVdb](https://hbvdb.lyon.inserm.fr/), selected following McNaughton et al. (2020)
- Covers all 10 known HBV genotypes (A–J)
- Input format: multiFASTA

### Pipeline Overview

```
HBVdb sequences (multiFASTA)
        │
        ▼
[entete.py] — FASTA header adaptation to PanSN format
        │
        ├──────────────────────┐
        ▼                      ▼
[Minigraph-Cactus]         [PGGB]
(reference-guided)         (all-vs-all)
        │                      │
        └──────────┬───────────┘
                   ▼
          GFA pangenome graphs
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   [Bandage]  [GFAtools]   [ODGI]
  (visualize) (statistics) (path analysis)
                   │
                   ▼
              [VG toolkit]
          (format conversion)
                   │
                   ▼
              [PGGE + beehave_adapted.R]
          (quality evaluation + visualization)
```

### Tools Used

| Tool | Purpose | Link |
|---|---|---|
| PGGB | Reference-free pangenome graph construction using all-vs-all genome alignment | https://github.com/pangenome/pggb |
| Cactus | Multiple genome alignment and pangenome graph generation | https://github.com/ComparativeGenomicsToolkit/cactus |
| Bandage | Visualization and exploration of assembly and pangenome graphs | https://rrwick.github.io/Bandage/ |
| GFAtools | Graph statistics and manipulation of GFA files | https://github.com/lh3/gfatools |
| ODGI | Pangenome graph analysis, path extraction and graph topology operations | https://github.com/pangenome/odgi |
| VG toolkit | Variation graph construction, manipulation, analysis and format conversion | https://github.com/vgteam/vg |
| PGGE | Evaluation of pangenome graph alignment quality | https://github.com/pangenome/pgge |

### Key Technical Challenges

**FASTA header compatibility**: HBVdb headers were not compatible with PGGB's PanSN format. Solved by writing `entete.py` to reformat headers automatically.

**MC parameter tuning**: Minigraph-Cactus is designed for large genomes. HBV's compact genome (~3.2 kb) required specific flags:
- `--permissiveContigFilter`: prevents small contigs from being filtered out
- `--noSplit`: disables reference chromosome splitting

**`--gfa` parameter exploration**: Three MC output variants were compared (--clip, --filter, --full) to determine the best graph complexity for downstream use.

---

## Results

### Graph Statistics

| Metric | PGGB | MC-clip | MC-filter | MC-full |
|--------|------|---------|-----------|---------|
| Nodes | 3534 | 2602 | 2142 | 2607 |
| Edges | 5298 | 3789 | 2810 | 3795 |
| Total length (bp) | 7357 | 4392 | 3905 | 4397 |
| Avg segment length (bp) | 2.08 | 1.69 | 1.82 | 1.69 |
| Paths (input sequences) | 43 | 28 | 28 | 28 |

### Alignment Quality (PGGE Metrics)

Both graphs successfully represent HBV genetic diversity with high quality:

- **Alignment identity (aln.id)**: >0.97 for most sequences in both graphs
- **Query sequence containment (qsc)**: >0.95, near-complete coverage
- **Unique alignments (uniq)**: >0.95, high specificity
- **Non-aligned bases (nonaln)**: ~0, minimal uncovered sequence

**MC-clip outperforms PGGB** on all four metrics, with higher median identity, better coverage, and fewer non-aligned bases.

### Conclusion

Minigraph-Cactus with `--gfa clip` was selected as the optimal configuration for HBV pangenome construction, providing better alignment fidelity and a more compact graph structure compared to PGGB.

---

## Scripts

### `scripts/entete.py`
Reformats HBVdb FASTA headers to PanSN format required by PGGB and PGGE.

```bash
python scripts/entete.py
# Enter input FASTA path and output FASTA path when prompted
```
**Dependencies**: `biopython`

### `scripts/beehave_adapted.R`
Generates boxplot visualizations of PGGE alignment metrics, adapted from the original [beehave.R](https://github.com/pangenome/pgge/blob/master/scripts/beehave.R) by Heinrich Heumos.

**Modifications from original**:
- Replaced violin plots with boxplots for clearer multi-graph comparison
- Removed overlapping sequence labels (ggrepel overlap issue with 44+ points)

Metrics visualized:
   - aln.id  : alignment identity (proportion of identical bases)
   - qsc     : query sequence containment (coverage of input sequences)
   - uniq    : unique query matches (alignment specificity)
   - nonaln  : non-aligned bases (proportion not covered by graph)

 Input:  TSV file with PGGE metrics + 'origin' column indicating graph builder
 Output: PNG with 4 boxplots (one per metric)

**Dependencies**: `tidyverse`, `ggrepel`, `gridExtra`

## Usage

### Step 1 — Run PGGE for each graph
```bash
pgge -g graph_MC.gfa -f sequences.fasta -o output_MC.tsv
pgge -g graph_PGGB.gfa -f sequences.fasta -o output_PGGB.tsv
```

### Step 2 — Add the `origin` column to each TSV
Before merging, add a column identifying which graph each file comes from:

```bash
# Add 'origin' column to each TSV
awk 'BEGIN{OFS="\t"} NR==1{print $0, "origin"} NR>1{print $0, "MC-clip"}' output_MC.tsv > output_MC_labeled.tsv
awk 'BEGIN{OFS="\t"} NR==1{print $0, "origin"} NR>1{print $0, "PGGB"}' output_PGGB.tsv > output_PGGB_labeled.tsv
```

### Step 3 — Merge the labeled TSV files
```bash
# Keep header from first file only
head -1 output_MC_labeled.tsv > input.tsv
tail -n +2 output_MC_labeled.tsv >> input.tsv
tail -n +2 output_PGGB_labeled.tsv >> input.tsv
```

### Step 4 — Run the visualization script
```bash
Rscript beehave_adapted.R input.tsv output.png
```

---

## Environment

- OS: Linux Ubuntu (Bash terminal)
- Containers: Docker, Singularity
- Languages: Python (BioPython), R (tidyverse)

---

## References

- McNaughton et al. (2020). Analysis of genomic-length HBV sequences. *J Gen Virol*
- Hickey et al. (2024). Pangenome graph construction with Minigraph-Cactus. *Nat Biotechnol*
- Garrison et al. (2024). Building pangenome graphs (PGGB). *Nat Methods*
- HBVdb: https://hbvdb.lyon.inserm.fr/

---

## Author

**Safa Changuel** 
Engineering student, École Centrale de Nantes  
safa.changuel.pro@gmail.com | [LinkedIn](https://linkedin.com/in/safa-changuel)

