# extract node data and match nodes across trees
# efuller@mortonarb.org, 18 Jan 2026

library(ape)
library(tidyverse)
library(phytools)
library(purrr)

extract_node_data <- function(tree, node_vec) {
  tree@data %>%
    filter(node %in% node_vec) %>%
    select(node, height, height_0.95_HPD)
}

nd_df <- extract_node_data(node_dated, df_clades$node1)
td_df <- extract_node_data(tip_dated, df_clades$node2)

final_df <- df_clades %>%
  left_join(nd_df, by = c("node1" = "node"), suffix = c("", "_node_dated")) %>%
  left_join(td_df, by = c("node2" = "node"), suffix = c("_node_dated", "_tip_dated"))