# read beast output
# efuller@mortonarb.org, 18 Jan 2026

library(tidyverse)
library(tidytree)
library(phytools)

node_dated <- read.beast("20240321_fixedtree_p04_annotated.trees")
tip_dated <- read.beast("20250801_FBD_lobedness_v8_annotated.trees")

## identify and keep only extant tips
tip_dated_extant <- getExtant(tip_dated@phylo)
tip_dated <- tidytree::keep.tip(tip_dated, tip_dated_extant)

node_dated@data$node <- as.integer(node_dated@data$node) # defaults as ch vector
tip_dated@data$node <- as.integer(tip_dated@data$node) # ""
