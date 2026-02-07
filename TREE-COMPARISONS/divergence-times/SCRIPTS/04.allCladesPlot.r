# plot all clades
# efuller@mortonarb.org, 18 Jan 2026

library(tidyverse)

all_clades_plot <- final_df %>%
  ggplot(aes(x = height_node_dated, y = height_tip_dated)) +
  geom_point(alpha = 0.4) +
  labs(x = "Node-dated", y = "Tip-dated") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
  theme_minimal()