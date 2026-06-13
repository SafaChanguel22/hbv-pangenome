#!/usr/bin/env Rscript
# =============================================================================
# beehave_adapted.R - Pangenome Quality Metrics Visualization
# =============================================================================
# Adapted from the original beehave.R script by Heinrich Heumos (PGGE project).
# Original: https://github.com/pangenome/pgge/blob/master/scripts/beehave.R
#
# Modifications made:
#   - Added an 'origin' column to distinguish graphs from different builders
#     (Minigraph-Cactus variants and PGGB) in a single merged TSV
#   - Replaced violin plots with box plots for clearer median/quartile reading
#     when comparing multiple graphs simultaneously
#   - Removed overlapping sequence labels (ggrepel overlap issue with 44+ points)
#
# Metrics visualized:
#   - aln.id  : alignment identity (proportion of identical bases)
#   - qsc     : query sequence containment (coverage of input sequences)
#   - uniq    : unique query matches (alignment specificity)
#   - nonaln  : non-aligned bases (proportion not covered by graph)
#
# Input:  TSV file with PGGE metrics + 'origin' column indicating graph builder
# Output: PNG with 4 boxplots (one per metric)
#
# Author (adaptation): Safa Changuel
# Context: Internship - Lyon Hepatology Institute (UMR PaThLiv), 2025
# =============================================================================

require(tidyverse)
require(ggrepel)
require(gridExtra)

## Input: TSV file containing PGGE metrics with an added 'origin' column
## The 'origin' column identifies the pangenome graph builder (e.g. MC-clip, PGGB)

args <- commandArgs(trailingOnly = TRUE)

# Input TSV path
input.pgge <- read.table(args[1],
                         sep = '\t', header = T)

## Output PNG path
output.png <- args[2]

# -----------------------------------------------------------------------------
# Plot 1: Alignment Identity (aln.id)
# Higher is better — measures how faithfully sequences align to the graph
# -----------------------------------------------------------------------------
aln.id <- ggplot(input.pgge, aes(x = as.factor(origin), y = aln.id)) +
  geom_boxplot() +
  geom_point() +
  xlab("%_Identity") +
  theme(text = element_text(size = 16)) +
  scale_y_continuous(labels = scales::number_format(accuracy = 0.0001)) +
  scale_x_discrete(guide = guide_axis(angle = 90))

# -----------------------------------------------------------------------------
# Plot 2: Query Sequence Containment (qsc)
# Higher is better — measures what proportion of each input sequence is covered
# -----------------------------------------------------------------------------
qsc <- ggplot(input.pgge, aes(x = as.factor(origin), y = qsc)) +
  geom_boxplot() +
  geom_point() +
  xlab("Query Sequence Containment") +
  theme(text = element_text(size = 16)) +
  scale_y_continuous(labels = scales::number_format(accuracy = 0.0001)) +
  scale_x_discrete(guide = guide_axis(angle = 90))

# -----------------------------------------------------------------------------
# Plot 3: Unique Query Matches (uniq)
# Higher is better — measures alignment specificity (no redundant alignments)
# Note: uses cons.jump column as x-axis grouping variable
# -----------------------------------------------------------------------------
uniq <- ggplot(input.pgge, aes(x = as.factor(origin), y = uniq)) +
  geom_boxplot() +
  geom_point() +
  xlab("Unique Query Matches") +
  theme(text = element_text(size = 16)) +
  scale_y_continuous(labels = scales::number_format(accuracy = 0.0001)) +
  scale_x_discrete(guide = guide_axis(angle = 90))

# -----------------------------------------------------------------------------
# Plot 4: Non-aligned Bases (nonaln / divergence)
# Lower is better — measures proportion of bases not covered by any graph path
# -----------------------------------------------------------------------------
nonaln <- ggplot(input.pgge, aes(x = as.factor(origin), y = nonaln)) +
  geom_boxplot() +
  geom_point() +
  xlab("% Divergence") +
  theme(text = element_text(size = 16)) +
  scale_y_continuous(labels = scales::number_format(accuracy = 0.0001)) +
  scale_x_discrete(guide = guide_axis(angle = 90))

# -----------------------------------------------------------------------------
# Combine all 4 plots into a single PNG (1 row, 4 columns)
# -----------------------------------------------------------------------------
png(output.png, width = 2000, height = 500, pointsize = 25)
g <- grid.arrange(aln.id, qsc, uniq, nonaln, nrow = 1)
dev.off()
