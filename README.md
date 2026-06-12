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

| Tool | Purpose |
|------|---------|
| Minigraph-Cactus (MC) | Reference-guided pangenome graph construction |
| PGGB | Reference-free pangenome graph construction (all-vs-all) |
| Bandage | Graph visualization |
| GFAtools | Graph statistics (nodes, edges, lengths) |
| ODGI | Path analysis and topology |
| VG toolkit | GFA format conversion (v1.0 ↔ v1.1) |
| PGGE | Alignment quality evaluation |
| Docker / Singularity | Containerized execution of bioinformatics tools |

### Key Technical Challenges

**FASTA header compatibility**: HBVdb headers were not compatible with PGGB's PanSN format. Solved by writing `entete.py` to reformat headers automatically.

**MC parameter tuning**: Minigraph-Cactus is designed for large genomes. HBV's compact genome (~3.2 kb) required specific flags:
- `--permissiveContigFilter`: prevents small contigs from being filtered out
- `--noSplit`: disables reference chromosome splitting

**`--gfa` parameter exploration**: Three MC output variants were compared (--clip, --filter, --full) to determine the best graph complexity for downstream use.

---

## Results

