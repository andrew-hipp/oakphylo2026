## written by Claude Code in an interactive session with Andrew Hipp -- 2026-07-17
## Overlay selected envfit clade-monophyly vectors (trees.envfit$all) onto the
## main tree ordination (treeplot.Final from 20_ordination.R), styled for a
## 16:9 PowerPoint slide.
##
## Depends on:
##   treeplot.Final  <- 20_ordination.R
##   trees.points    <- 20_ordination.R (mds1 / mds2 coordinates)
##   trees.envfit    <- 30_cladeLoadings.R (vegan envfit on cmdscale(trees.dist, 2))
##   maxBoots        <- 10_compareTrees.R (via 00_readData.R)

library(vegan)
library(ggplot2)
library(ggrepel)

if(!exists('treeplot.Final'))
  stop('35_ordWithLoadings.R needs treeplot.Final; run 20_ordination.R first.')
if(!exists('trees.envfit'))
  stop('35_ordWithLoadings.R needs trees.envfit; run 30_cladeLoadings.R first.')

## which clade vectors to draw, and how to label them on the figure
loadingsLabels <- c(
  roburoids_albae = "Roburoids + Albae",
  Quercus_CA      = "CA white oaks",
  Quercus_MX      = "MX white oaks"
)

ef <- trees.envfit$all

## scores(..., 'vectors') returns arrow directions already scaled by sqrt(r2);
## same cmdscale(trees.dist, 2) space as trees.points$mds1 / mds2
loadings <- as.data.frame(scores(ef, display = 'vectors'))
names(loadings) <- c('mds1', 'mds2')
loadings <- loadings[names(loadingsLabels), ]
loadings$clade <- loadingsLabels[row.names(loadings)]

## scale arrows so the longest fills ~85% of the ordination extent
ordExtent <- max(abs(c(trees.points$mds1, trees.points$mds2)))
mul <- 0.85 * ordExtent / max(sqrt(loadings$mds1^2 + loadings$mds2^2))
loadings$mds1s <- loadings$mds1 * mul
loadings$mds2s <- loadings$mds2 * mul

## Two figures for successive slides: (1) the ordination alone, (2) the same
## plot with the clade vectors added. Fixed coordinate limits are applied to
## both so the point cloud sits in exactly the same place when the second
## slide overlays the first.
xr <- range(trees.points$mds1)
yr <- range(trees.points$mds2)
pad <- 0.10
pptLimits <- coord_cartesian(
  xlim = xr + c(-1, 1) * diff(xr) * pad,
  ylim = yr + c(-1, 1) * diff(yr) * pad
)

## shared styling: keep FIG7's native (default) ggplot style; legend hidden
pptStyle <- list(
  pptLimits,
  labs(x = 'MDS axis 1', y = 'MDS axis 2'),
  theme(text = element_text(size = 14), legend.position = 'none')
)

## slide 1: base ordination
treeplot.base <- treeplot.Final + pptStyle

## slide 2: same ordination + clade vectors. inherit.aes = FALSE so the DataSet
## colour aesthetic from treeplot.Final is not required for these layers.
treeplot.loadings <- treeplot.Final +
  geom_segment(
    data = loadings, inherit.aes = FALSE,
    aes(x = 0, y = 0, xend = mds1s, yend = mds2s),
    arrow = arrow(length = unit(0.025, 'npc'), type = 'closed'),
    colour = 'grey25', linewidth = 0.7
  ) +
  # geom_text_repel(
  #   data = loadings, inherit.aes = FALSE,
  #   aes(x = mds1s, y = mds2s, label = clade),
  #   size = 4, fontface = 'bold', colour = 'grey15',
  #   segment.colour = 'grey60', min.segment.length = 0,
  #   box.padding = 0.4, point.padding = 0.2
  # ) +
  pptStyle

if(globalDoPDF) {
  ## 16:9 for slides (10 x 5.625 in = 1.778 aspect)
  ggsave(
    paste('out/figures/PPT-version_FIG7b_a_ordination_16x9_mx', maxBoots, 'bt.pdf', sep = ''),
    plot = treeplot.base, width = 10, height = 5.625, units = 'in')
  ggsave(
    paste('out/figures/PPT-version_FIG7b_b_withLoadings_16x9_mx', maxBoots, 'bt.pdf', sep = ''),
    plot = treeplot.loadings, width = 10, height = 5.625, units = 'in')
}
