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
    refRAD = "Reference-guided RADseq (empirical)",
    reSeq = "Aligned reference genomes and reseq data",
    simRAD = "Simulated RADseq (from aligned reference and reseq)"
)

trees.points$DataSet <- 
  DataSet[sapply(strsplit(row.names(trees.points), '.', fixed = T),'[',1)]
trees.points$TreeType <- 'Bootstrap'
trees.points$TreeType[grep('.bt', row.names(trees.points), invert = T)] <- 'ML'
trees.points$analysis <- 
  sapply(strsplit(row.names(trees.points), '.', fixed = T),'[',2)

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
    aes(label = ifelse(TreeType == 'ML', analysis, NA),
    size = 0.1)
  ) +
  theme(
      # legend.position = 'inside',
      # legend.position.inside = c(0.3,0.9)
      legend.position = 'bottom'
  )
ggsave(paste('out/treeordinationFinal_v2_mx', maxBoots, 'bt.pdf', sep = ''), 
        plot=treeplot.Final)

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
  ggsave(paste('out/treeordinationSupplement_', i, '.pdf', sep = ''), 
        plot=treeplot.clades[[i]])
}

plotpch.refRAD <- c(
  ref_alba_raxml = 'A', 
  ref_glauca_raxml = 'G',
  ref_longispica_raxml = 'L',
  ref_rubra_raxml = 'R',
  ref_tomentella_raxml = 'T',
  ref_variablis_raxml = 'C',
  ref_virginiana_raxml = 'V'
  )

treeplot.refRAD <- 
  ggplot(trees.points[grep('refRAD', row.names(trees.points)), ], 
    aes(x = mds1, y = mds2, color = analysis)
    )
treeplot.refRAD <- treeplot.refRAD + 
  geom_point(
    size = plotsize[trees.points[grep('refRAD', row.names(trees.points)), 'TreeType']],
    pch = plotpch.refRAD[trees.points[grep('refRAD', row.names(trees.points)), 'analysis']]
    ) + 
  scale_fill_manual(values = cbbPalette) + 
  theme(legend.position = 'bottom')
ggsave(paste('out/treeordination_refRAD_mx', maxBoots, 'bt.pdf', sep = ''), plot=treeplot.refRAD)

## inspecting treesAll -- cophyloplots and strict consensuses
attach(treesAll.pruned)
treesAll.cophylos <- list(
  simRADalb_refalb = cophylo(simRAD.simRAD_Qalba_raxml, refRAD.ref_alba_raxml),
  simRADalb_reseqalb = cophylo(simRAD.simRAD_Qalba_raxml, reSeq.reseq_Qalba),
  reseqalb_refalb = cophylo(reSeq.reseq_Qalba, refRAD.ref_alba_raxml),
  simRADalb_simRADvar = cophylo(simRAD.simRAD_Qalba_raxml, simRAD.simRAD_Qvar_raxml),
  reseqalb_reseqvar = cophylo(reSeq.reseq_Qalba, reSeq.reseq_Qvar)
)
detach(treesAll.pruned)

pdf('out/treesAll.cophylo.pdf', 8.5, 11)
for(i in names(treesAll.cophylos)) {
  # par(mar = c(5.1, 4.1, 8, 2.1))
  plot(treesAll.cophylos[[i]])
  title(i, line = -1)
}
dev.off()

## get tree islands
trees.dist2d <- dist(as.matrix(trees.points))
trees.islands <- Islands(trees.dist2d, 0.2)
do <- which(table(trees.islands)> 10) |> names()
pdf('out/treesIslands.pdf', 10,10)
plot(trees.points[which(trees.islands %in% do), c('mds1', 'mds2')], type = 'n')
text(trees.points[which(trees.islands %in% do), c('mds1', 'mds2')], 
    labels = trees.islands[which(trees.islands %in% do)])
dev.off()

## plot consensus trees
trees.con <- list(
  refRAD_ACLT = consensus(treesAll.pruned[c(
    "refRAD.ref_alba_raxml",
    "refRAD.ref_longispica_raxml",
    "refRAD.ref_tomentella_raxml", 
    "refRAD.ref_variablis_raxml")], 
    rooted = TRUE),
  refRAD_RGV = consensus(treesAll.pruned[c(
    "refRAD.ref_glauca_raxml",
    "refRAD.ref_rubra_raxml",
    "refRAD.ref_virginiana_raxml")],
    rooted = TRUE),
  simRAD = consensus(treesAll.pruned[c(
    "simRAD.simRAD_Qalba_raxml",
    "simRAD.simRAD_Qvar_raxml")],
    rooted = TRUE),
  allBoots = consensus(treesAll.pruned),
  allML = consensus(treesAll.pruned[grep('bt', names(treesAll.pruned), invert = T)])
)

for(i in do) {
    trees.con[[paste('isle', i, sep = '')]] <- 
    consensus(treesAll.pruned[which(trees.islands == i)])
    }

pdf('out/treesConsensus.pdf', 8.5, 11)
for(i in names(trees.con)) {
  plot(trees.con[[i]])
  title(i, line = -1)
}
dev.off()
