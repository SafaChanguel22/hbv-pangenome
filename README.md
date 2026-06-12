# HBV Pangenome Graph Construction

**Internship project at Lyon Hepatology Institute (UMR PaThLiv), 2025**  
Supervisor: Xavier Grand, PhD & Bioinformatics Research Engineer  
École Centrale de Nantes · Option: Digital Sciences for Life Sciences & Healthcare

---

## Context

Hepatitis B virus (HBV) infects over 254 million people worldwide and causes more than 1 million deaths per year. Its high genetic diversity with 10 genotypes (A–J) and 40+ subgenotypes, makes a single linear reference genome insufficient for genomic analysis.

This project builds a **graph-based pangenome** of HBV from 43 reference sequences representing all known genotypes. A pangenome captures the full genetic diversity of a species rather than relying on a single reference, enabling more accurate alignment, variant calling, and cross-genotype data sharing within the scientific community.

This work is part of a larger project aimed at developing an open-source **HBV genome browser** for the research community.

---

## Biological Question

> How can we construct a pangenome graph that faithfully represents the genetic diversity of HBV across all known genotypes?

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
