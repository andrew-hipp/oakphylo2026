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

if(globalDoPDF) {
pdf('out/treesAll.cophylo.pdf', 8.5, 11)
for(i in names(treesAll.cophylos)) {
  # par(mar = c(5.1, 4.1, 8, 2.1))
  plot(treesAll.cophylos[[i]])
  title(i, line = -1)
}
dev.off()
}
## get tree islands
trees.dist2d <- dist(as.matrix(trees.points))
trees.islands <- Islands(trees.dist2d, 0.2)
do <- which(table(trees.islands)> 10) |> names()
if(globalDoPDF) {
pdf('out/ordinations/treesIslands.pdf', 10,10)
plot(trees.points[which(trees.islands %in% do), c('mds1', 'mds2')], type = 'n')
text(trees.points[which(trees.islands %in% do), c('mds1', 'mds2')], 
    labels = trees.islands[which(trees.islands %in% do)])
dev.off()
}

## plot consensus trees
trees.con <- list(
  refRAD_allBoots = consensus(unlist(boots$refRAD, recursive = FALSE), rooted = T),
  refRAD_alb_var = consensus(unlist(boots$refRAD[c('ref_alba_raxml', 'rev_variabilis_raxml')], recursive = FALSE), rooted = T),
  simRAD_allBoots = consensus(unlist(boots$simRAD, recursive = FALSE), rooted = T),
  reSeq_allBoots = consensus(unlist(boots$reSeq, recursive = FALSE), rooted = T),
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
  allBoots = consensus(treesAll.pruned, rooted = TRUE),
  allML = consensus(treesAll.pruned[grep('bt', names(treesAll.pruned), invert = T)], rooted = TRUE)
)

for(i in do) {
    trees.con[[paste('isle', i, sep = '')]] <- 
    consensus(treesAll.pruned[which(trees.islands == i)], rooted = TRUE)
    }

if(globalDoPDF) {
  pdf('out/trees/treesConsensus.pdf', 8.5, 11)
  for(i in names(trees.con)) {
    plot(
      trees.con[[i]], 
      cex = ifelse(length(trees.con[[i]]$tip.label) > 100, 0.1, 0.7)
      ) # close plot
    title(i, line = -1)
  }
  dev.off()

  temp_qCons <- plot(qCons, use.edge.length = F, node.depth = 2, cex = 0.6, plot = F)
  
  pdf('out/figures/FIG4_allConsensus.pdf', 7, 5.5)
  qCons <- trees.con$allBoots
  qCons$tip.label <- gsub('Quercus ', '', qCons$tip.label)
  plot(qCons, use.edge.length = F, node.depth = 2, cex = 0.4, 
      x.lim = temp_qCons$x.lim * 1.5)
  cladelabels(text = c('Cyclobalanopsis','Cerris','Ilex',
                      'Lobatae','Protobalanus','Ponticae','Virentes','Quercus'),
              node = c(84,81,79,74,73,72,71,66),
              orientation = 'horizontal', cex = 0.8)
  cladelabels(text = 'Roburoids', node = 68, cex = 0.6)
  dev.off()
}