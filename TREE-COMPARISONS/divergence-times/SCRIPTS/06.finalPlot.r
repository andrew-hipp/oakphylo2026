# final plot with highlighted sections
# efuller@mortonarb.org, 18 Jan 2026

library(tidyverse)
library(gghighlight)
library(ggrepel)

all_clades_plot +
  geom_point(data = highlight_rows, color = "black", size = 3) +
  geom_errorbar(data = highlight_rows, aes(ymax = td_HPD_max, ymin = td_HPD_min), na.rm = TRUE, alpha = 0.3) +
  geom_errorbarh(data = highlight_rows, aes(xmax = nd_HPD_max, xmin = nd_HPD_min), na.rm = TRUE, alpha = 0.3) +
  geom_text_repel(
    data = highlight_rows,
    aes(label = clade_id),
    color = "black")

library(deeptime)
plot_epochs <- finalplot +
  coord_geo(
    dat = "epochs",
    xlim = c(0, 55),       
    ylim = c(0, 60),
    pos = c("bottom", "left"),
    abbrv = TRUE,           
    size = 3.5,
  )
