trees.points_refSim <- trees.points[grep('reference|Simulated',trees.points$DataSet), ]
trees.points_refSim$DataSet[which(trees.points_refSim$DataSet=='Pseudoreference genomes')] <- 'Resequencing'
trees.points_refSim$DataSet[which(trees.points_refSim$DataSet=='Simulated RADseq')] <- 'RADseq_simulated'
trees.points_refSim$Reference <- 'variabilis'
trees.points_refSim$Reference[grep('alba', trees.points_refSim$analysis)] <- 'alba'
trees.points_refSim$SNPmap <- 'reference'
trees.points_refSim$SNPmap[grep('denovo', trees.points_refSim$analysis)] <- 'de_novo'

treeplot.refSim <- 
  ggplot(trees.points_refSim, aes(
    x = mds1, y = mds2, 
    shape = DataSet,
    fill = Reference,
    color = SNPmap))
treeplot.refSim <- treeplot.refSim + 
  geom_point() +
#   scale_fill_manual(values = cbbPalette) + 
  scale_color_manual(values = c(reference = 'black', de_novo = 'white'))+
#   geom_label_repel(
#     size = 2, 
#     # alpha = 0.8, 
#     label.r = 0.01,
#     box.padding = 0.1, point.padding = 15, 
#     aes(label = ifelse(TreeType == 'ML', analysis, NA)
#     )
#   ) +
  guides(fill = guide_legend(override.aes = list(shape = 21, size = 3))) +
  scale_shape_manual(values = c(RADseq_simulated = 24, Resequencing = 21)) +

  theme(
    legend.background = element_rect(fill = NA, color = NA),
    legend.title = element_text(face = "bold"),
    legend.position = "inside",
    legend.position.inside = c(1, 0),        # Coordinates: x=1 (right), y=0 (bottom)
    legend.justification.inside = c(1, 0)     # Anchors the bottom-right of the legend box
  )


# p = ggplot(dat.sim, aes(x = mds1, y = mds2, fill = reference, shape = type, size = type))
# p <- p + scale_shape_manual(values = c(RAD = 24, reseq = 21))
# p <- p + geom_point()
# p <- p + guides(fill = guide_legend(override.aes = list(shape = 21, size = 3)))
# p <- p + theme(
#     legend.background = element_rect(fill = NA, color = NA),
#     legend.title = element_text(face = "bold"),
#     legend.position = "inside",
#     legend.position.inside = c(1, 0),        # Coordinates: x=1 (right), y=0 (bottom)
#     legend.justification.inside = c(1, 0)     # Anchors the bottom-right of the legend box
#   )


  ggsave(
    paste('out/figures/PPT_treeordinationFinal_RefSim_v2.pdf', sep = ''),
    plot=treeplot.refSim, width = 7, height = 7
    )
