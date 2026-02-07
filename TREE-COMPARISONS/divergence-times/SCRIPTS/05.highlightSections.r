# highlight points of interest
# efuller@mortonarb.org, 18 Jan 2026

library(ape)
library(tidyverse)
library(phytools)
library(purrr)

clades_of_interest <- list(
  Protobalanus = c("vacciniifolia", "cedrosensis"),
  Quercus = c("infectoria", "durata"),
  Virentes = c("brandegeei", "sagraeana"),
  Ponticae = c("pontica", "sadleriana"),
  Cyclobalanopsis = c("kerrii", "eumorpha"),
  Lobatae = c("parvula", "falcata"),
  Ilex = c("yiwuensis", "lanata"),
  Cerris = c("cerris", "acutissima")
)

find_youngest_clade <- function(final_df, target_tips) {
  final_df %>%
    filter(map_lgl(species_list, ~ all(target_tips %in% .x))) %>%
    arrange(height_node_dated) %>%
    slice(1)
}

highlight_rows <- imap_dfr(
  clades_of_interest,
  ~ find_youngest_clade(final_df, .x) %>% mutate(clade_id = .y)
) %>% 
extract(
    col = height_0.95_HPD_node_dated,
    into = c("nd_HPD_min", "nd_HPD_max"),
    regex = "c\\((.*),\\s*(.*)\\)",
    convert = TRUE, 
    remove = TRUE 
  ) %>% 
extract(
    col = height_0.95_HPD_tip_dated,
    into = c("td_HPD_min", "td_HPD_max"),
    regex = "c\\((.*),\\s*(.*)\\)",
    convert = TRUE,
    remove = TRUE
  )
