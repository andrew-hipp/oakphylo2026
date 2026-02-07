# define clades by tips
# efuller@mortonarb.org, 18 Jan 2026

library(ape)
library(tidyverse)
library(tidytree)
library(purrr)

get_clade_species <- function(tree) {
  phy <- tree@phylo
  n_tips <- length(phy$tip.label)
  purrr::map(
     (n_tips + 1):(n_tips + phy$Nnode),
     function(node) {
       desc <- phangorn::Descendants(phy, node, type = "tips")[[1]]
       sort(unique(phy$tip.label[desc]))
     }
   )
 }

nd_clade_species <- get_clade_species(node_dated)
td_clade_species <- get_clade_species(tip_dated)

clade_key <- function(species_vec) paste(species_vec, collapse = ";")

nd_keys <- purrr::map_chr(nd_clade_species, clade_key)
td_keys <- purrr::map_chr(td_clade_species, clade_key)
shared_keys <- intersect(nd_keys, td_keys)

df_clades <- tibble(
  clade_key = shared_keys,
  species_list = str_split(shared_keys, ";"),
  node1 = match(shared_keys, nd_keys) + length(node_dated@phylo$tip.label),
  node2 = match(shared_keys, td_keys) + length(tip_dated@phylo$tip.label)
)