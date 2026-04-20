# Ordinations of trees

### STILL TO DO
### 1. make nice legends
### 2. add repel-labels for the ML trees (11)

library(MASS)

library(TreeDist)
library(ape)
library(phytools)

library(ggplot2)
library(ggrepel)

## plotting parameters and distance
cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
plotalpha <- c(ML = 1, Bootstrap = 0.5)
plotpch.all <- 
  c(ML_robalb = 19, Bootstrap_robalb = 1,
  ML_robsister = 17, Bootstrap_robsister = 2)
plotsize <- c(ML = 5, Bootstrap = 1)

# trees.dist <- RobinsonFoulds(treesAll.pruned)
if(!exists('trees.dist')) trees.dist <- ClusteringInfoDistance(treesAll.pruned)

trees.points <- cmdscale(trees.dist, 2) |>
  as.data.frame()
names(trees.points) <- c('mds1', 'mds2')
DataSet <- c(
    empiricalRAD = "Reference-guided RADseq (empirical)",
    reSeq = "Aligned reference genomes and reseq data",
    simRAD = "Simulated RADseq (from aligned reference and reseq)"
)

trees.points$DataSet <- 
  DataSet[sapply(strsplit(row.names(trees.points), '.', fixed = T),'[',1)]
trees.points$TreeType <- 'Bootstrap'
trees.points$TreeType[grep('.bt', row.names(trees.points), invert = T)] <- 'ML'
trees.points$analysis <- 
  sapply(strsplit(row.names(trees.points), '.', fixed = T),'[',2)

trees.points$analysis <- gsub('_raxml', '', trees.points$analysis)
trees.points$analysis <- gsub('ref_', 'empiricalRAD_', trees.points$analysis)
trees.points$analysis <- gsub('Qalba', 'alba', trees.points$analysis)
trees.points$analysis <- gsub('Qvar', 'variabilis', trees.points$analysis)

trees.points$RobType <- NA
trees.points$RobType[
  which(trees.points$TreeType == 'ML' & monophylyMat[, 'roburoids_albae'])
  ] <- 'ML_robalb'
trees.points$RobType[
  which(trees.points$TreeType == 'ML' & !monophylyMat[, 'roburoids_albae'])
  ] <- 'ML_robsister'
trees.points$RobType[
  which(trees.points$TreeType != 'ML' & monophylyMat[, 'roburoids_albae'])
  ] <- 'Bootstrap_robalb'
trees.points$RobType[
  which(trees.points$TreeType != 'ML' & !monophylyMat[, 'roburoids_albae'])
  ] <- 'Bootstrap_robsister'

trees.points <- cbind(trees.points, monophylyMat)

treeplot.all <- 
  ggplot(trees.points, aes(
    x = mds1, y = mds2, 
    color = DataSet))
treeplot.Final <- treeplot.all + 
  geom_point(size = plotsize[trees.points$TreeType],
            # alpha = plotalpha[trees.points$TreeType],
            pch = plotpch.all[trees.points$RobType]) + 
  scale_fill_manual(values = cbbPalette) + 
  # geom_label_repel(label = row.names(trees.points)) +
  geom_label_repel(
    size = 2, 
    # alpha = 0.8, 
    label.r = 0.01,
    box.padding = 0.1, point.padding = 15, 
    aes(label = ifelse(TreeType == 'ML', analysis, NA)
    )
  ) +
  theme(
      # legend.position = 'inside',
      # legend.position.inside = c(0.3,0.9)
      # legend.position = 'bottom'
      legend.position = 'none'
  ) 

if(globalDoPDF) {
  ggsave(
    paste('out/figures/FIG7_treeordinationFinal_v2_mx', maxBoots, 'bt.pdf', sep = ''),
    plot=treeplot.Final, width = 7, height = 7)
}

## Plotting individual ordinations, symbols by clades
treeplot.clades <- structure(
  vector('list', dim(monophylyMat)[2]), 
  names = colnames(monophylyMat)
  )

for(i in names(treeplot.clades)) {
  treeplot.clades[[i]] <- treeplot.all + 
  geom_point(size = plotsize[trees.points$TreeType],
            # alpha = plotalpha[trees.points$TreeType],
            aes(shape = .data[[i]])
   ) + 
  scale_fill_manual(values = cbbPalette) 
  # theme(
  #    legend.position = 'bottom'
  # )
if(globalDoPDF) {
  ggsave(paste('out/ordinations/treeordinationSupplement_', i, '.pdf', sep = ''), 
        plot=treeplot.clades[[i]], 
        width = 11, height = 8.5, units = 'in')
  if(i == "Quercus_MX") {
    ggsave(paste('out/figures/FIGS3_treeordinationSupplement_', i, '.pdf', sep = ''), 
      plot=treeplot.clades[[i]], 
      width = 11, height = 8.5, units = 'in')
  }
}
}



plotpch.empiricalRAD <- c(
  ref_alba_raxml = 'A', 
  ref_glauca_raxml = 'G',
  ref_longispica_raxml = 'L',
  ref_rubra_raxml = 'R',
  ref_tomentella_raxml = 'T',
  ref_variablis_raxml = 'C',
  ref_virginiana_raxml = 'V',
  de_novo = 'D'
  )

treeplot.empiricalRAD <- 
  ggplot(trees.points[grep('empiricalRAD', row.names(trees.points)), ], 
    aes(x = mds1, y = mds2, color = analysis)
    )
treeplot.empiricalRAD <- treeplot.empiricalRAD + 
  geom_point(
    size = plotsize[trees.points[grep('empiricalRAD', row.names(trees.points)), 'TreeType']],
    pch = plotpch.empiricalRAD[trees.points[grep('empiricalRAD', row.names(trees.points)), 'analysis']]
    ) + 
  scale_fill_manual(values = cbbPalette) + 
  theme(legend.position = 'bottom')
if(globalDoPDF) {
ggsave(paste('out/ordinations/treeordination_empiricalRAD_mx', maxBoots, 'bt.pdf', sep = ''), plot=treeplot.empiricalRAD)
}

