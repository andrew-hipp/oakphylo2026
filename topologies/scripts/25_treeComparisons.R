## inspecting treesAll -- cophyloplots and strict consensuses
attach(treesAll.pruned)
treesAll.cophylos <- list(
  simRADalb_refalb = cophylo(simRAD.simRAD_Qalba_ref_snps, empiricalRAD.ref_alba_raxml),
  simRADalb_reseqalb = cophylo(simRAD.simRAD_Qalba_ref_snps, reSeq.reseq_Qalba),
  reseqalb_refalb = cophylo(reSeq.reseq_Qalba, empiricalRAD.ref_alba_raxml),
  simRADalb_simRADvar = cophylo(simRAD.simRAD_Qalba_ref_snps, simRAD.simRAD_Qvar_ref_snps),
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
  empiricalRAD_allBoots = consensus(unlist(boots$empiricalRAD, recursive = FALSE), rooted = T),
  empiricalRAD_alb_var = consensus(unlist(boots$empiricalRAD[c('ref_alba_raxml', 'rev_variabilis_raxml')], recursive = FALSE), rooted = T),
  simRAD_allBoots = consensus(unlist(boots$simRAD, recursive = FALSE), rooted = T),
  reSeq_allBoots = consensus(unlist(boots$reSeq, recursive = FALSE), rooted = T),
  reSeq_simRAD_allBoots = 
    consensus(
        c(unlist(boots$reSeq, recursive = FALSE),
        unlist(boots$simRAD, recursive = FALSE)), 
        rooted = T
        ),
  empiricalRAD_ACLT = consensus(treesAll.pruned[c(
    "empiricalRAD.ref_alba_raxml",
    "empiricalRAD.ref_longispica_raxml",
    "empiricalRAD.ref_tomentella_raxml", 
    "empiricalRAD.ref_variablis_raxml")], 
    rooted = TRUE),
  empiricalRAD_RGV = consensus(treesAll.pruned[c(
    "empiricalRAD.ref_glauca_raxml",
    "empiricalRAD.ref_rubra_raxml",
    "empiricalRAD.ref_virginiana_raxml")],
    rooted = TRUE),
  simRAD = consensus(
    treesAll.pruned[c(
      "simRAD.simRAD_Qalba_denovo_snps",
      "simRAD.simRAD_Qvar_denovo_snps",
      "simRAD.simRAD_Qalba_ref_snps",
      "simRAD.simRAD_Qvar_ref_snps")],
    rooted = TRUE),
  allBoots = consensus(treesAll.pruned, rooted = TRUE),
  allNodenovo = consensus(treesAll.pruned[-grep('de_novo', names(treesAll.pruned))]),
  allML_noDenovo = consensus(treesAll.pruned[grep('bt|de_novo', names(treesAll.pruned), invert = T)], rooted = TRUE)
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

  qCons <- trees.con$allML_noDenovo
  qCons$tip.label <- gsub('Quercus ', '', qCons$tip.label)
  temp_qCons <- plot(qCons, use.edge.length = F, node.depth = 2, cex = 0.6, plot = F)
  
  pdf('out/figures/FIG4_allML-no_denovo.pdf', 7, 5.5)
  plot(qCons, use.edge.length = F, node.depth = 2, cex = 0.4, 
      x.lim = temp_qCons$x.lim * 1.5)
  cladeNodes <- c(
    Cyclobalanopsis = findMRCA(qCons, c('chungii', 'fleuryi')),
    Cerris = findMRCA(qCons, c('chenii','cerris')),
    Ilex = findMRCA(qCons, c('ilex','longispica')),
    Lobatae = findMRCA(qCons, c('agrifolia','texana')),
    Protobalanus = findMRCA(qCons, c('tomentella','chrysolepis')),
    Ponticae = findMRCA(qCons, c('pontica', 'sadleriana')),
    Quercus = findMRCA(qCons, c('lobata', 'aliena')),
    Virentes = findMRCA(qCons, c('virginiana', 'fusiformis'))
  )
  
  cladelabels(text = names(cladeNodes),
              node = as.integer(cladeNodes),
              orientation = 'horizontal', cex = 0.8)
  cladelabels(
    text = 'Roburoids', 
    node = findMRCA(qCons, c('robur', 'aliena')), 
    cex = 0.6)
  dev.off()
}

trees.dist.rf <- RobinsonFoulds(treesAll.pruned) |> 
    as.matrix()
dimnames(trees.dist.rf) <- list(
    names(treesAll.pruned),
    names(treesAll.pruned))

### ARE ANY RESEQ BOOTS the same as any simRAD trees? 
### the reseq ML trees are not the same as any non-reseq boot or tree