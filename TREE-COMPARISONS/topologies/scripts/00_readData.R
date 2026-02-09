# read and format data for reference-guided empirical rad
# ahipp@mortonarb.org, 8 Jan 2026

library(ape)
library(openxlsx)
library(ggplot2)

## reading data

trees <- list(
  refRAD = lapply(dir('data/REF_raxml', full = T), function(x) {
    read.tree(grep('bipartitions.', dir(x, full = T), fixed = T, value = T))}),
  simRAD = lapply(dir('data/simulated_RAD', full = T), function(x) {
    read.tree(grep('bipartitions.', dir(x, full = T), fixed = T, value = T))}),
  reSeq = lapply(dir('data/ReSeq_phylos', full = T), function(x){
    read.tree(grep('bipartitions.', dir(x, full = T), fixed = T, value = T))})
) # close list

names(trees$refRAD) <- dir('data/REF_raxml')
names(trees$simRAD) <- dir('data/simulated_RAD')
names(trees$reSeq) <- dir('data/ReSeq_phylos')

boots <- list(
  refRAD = lapply(dir('data/REF_raxml', full = T), function(x) {
    read.tree(grep('bootstrap', dir(x, full = T), fixed = T, value = T))}),
  simRAD = lapply(dir('data/simulated_RAD', full = T), function(x) {
    read.tree(grep('bootstrap', dir(x, full = T), fixed = T, value = T))}),
  reSeq = lapply(dir('data/ReSeq_phylos', full = T), function(x){
    read.tree(grep('bootstrap', dir(x, full = T), fixed = T, value = T))})
)

names(boots$refRAD) <- dir('data/REF_raxml')
names(boots$simRAD) <- dir('data/simulated_RAD')
names(boots$reSeq) <- dir('data/ReSeq_phylos')

## futzing with metadata

dat_meta <- list(
  refRAD = read.xlsx('data/OakSpmTableExtract-322SingleTipPhylo-20250516.xlsx', 1),
  simRAD = read.xlsx('data/Oak_wgs_sampling.xlsx', rowNames = T)
)
dat_meta$refRAD <- dat_meta$refRAD[!is.na(dat_meta$refRAD[[1]]), ]
row.names(dat_meta$refRAD) <- dat_meta$refRAD$'RAD-SEQ-FLORAGENEX'

## relabelling trees (labelled bipartition trees)

for(i in names(trees)) {
  message(paste('doing',i))
  # write.tree(trees[[i]], paste('out/tempTree_', i, '.tre', sep = ''))
  trees[[i]] <- lapply(trees[[i]], function(x) {
    if(i == 'refRAD') {
      x$tip.label <- dat_meta[[i]][x$tip.label, c('TAXA-Current_determination', 'SPMCODE')] |> apply(1, paste, collapse = '|') |> as.character()
      og <- grep('Castan', x$tip.label)
    } # close if refRAD
    if(i == 'simRAD') {
      x$tip.label <- gsub('_randbase', '', x$tip.label, fixed = T)
      x$tip.label <- dat_meta[[i]][x$tip.label, 'Organism.Name']
      og <- grep('Lithocarpus', x$tip.label)
    } # close if simRAD
    if(i == 'reSeq') {
      x$tip.label <- gsub('/N/project/oakphylo2025/Bams/', 
        '', x$tip.label, fixed = T)
      x$tip.label <- gsub('.Qalba.sorted.markdups.bam', 
        '', x$tip.label, fixed = T)
      x$tip.label <- gsub('.Qvar.sorted.markdups.bam', 
        '', x$tip.label, fixed = T)
      x$tip.label <- dat_meta$simRAD[x$tip.label, 'Organism.Name']
      og <- grep('Lithocarpus', x$tip.label)
    }
    x <- root(x, og) |> ladderize()
    return(x)
  })

  for(j in names(trees[[i]])) {
    message(paste('doing', j))
    pdf(paste('out/', j, '.pdf'), 10, 30)
    plot(trees[[i]][[j]], cex = 0.6)
    nodelabels(text = trees[[i]][[j]]$node.label, frame = 'n', cex = 0.5, adj = c(1.5, -.5))
    dev.off()
    } # close j
    } # close i

## relabelling bootstrap sets

for(i in names(boots)) {
  message(paste('doing',i))
  for(j in names(boots[[i]])) {
    message(paste('doing',i,'of',j))
    boots[[i]][[j]] <- lapply(boots[[i]][[j]], function(x) {
      if(i == 'refRAD') {
        x$tip.label <- dat_meta[[i]][x$tip.label, c('TAXA-Current_determination', 'SPMCODE')] |> apply(1, paste, collapse = '|') |> as.character()
        og <- grep('Castan', x$tip.label)
      } # close if refRAD
      if(i == 'simRAD') {
        x$tip.label <- gsub('_randbase', '', x$tip.label, fixed = T)
        x$tip.label <- dat_meta[[i]][x$tip.label, 'Organism.Name']
        og <- grep('Lithocarpus', x$tip.label)
      } # close if simRAD
      if(i == 'reSeq') {
        x$tip.label <- gsub('/N/project/oakphylo2025/Bams/', '', x$tip.label, fixed = T)
        x$tip.label <- gsub('.Qalba.sorted.markdups.bam', '', x$tip.label, fixed = T)
        x$tip.label <- gsub('.Qvar.sorted.markdups.bam', '', x$tip.label, fixed = T)
        x$tip.label <- dat_meta$simRAD[x$tip.label, 'Organism.Name']
        og <- grep('Lithocarpus', x$tip.label)
      }
      x <- root(x, og) |> ladderize()
      return(x)
      })
      } # close j
    } # close i

## Pruning data and creating tree sets

maxBoots = 100 # set this to decide how many bootstraps to include

treesML <- unlist(trees, recursive = F, use.names = T)

treesBoots <- unlist(boots, recursive = F, use.names = T)
treesBoots <- lapply(treesBoots, function(x) x[1:min(length(x), maxBoots)])

for(i in names(treesBoots)) {
  names(treesBoots[[i]]) <- paste('bt', sprintf("%03d", seq(length(treesBoots[[i]]))), sep = '')
  } # close i

treesBoots <- unlist(treesBoots, recursive = F, use.names = T)

treesAll <- c(treesML, treesBoots)

treesAll.pruned <- lapply(treesAll, function(x) {
    temp <- strsplit(x$tip.label, '|', fixed = T)
    temp <- sapply(temp, '[', 1)
    x$tip.label <- temp
    return(x)
})

allNames <- 
    lapply(treesAll.pruned, '[[', 'tip.label') 
allNames <- Reduce(intersect, allNames)

treesAll.pruned <- lapply(treesAll.pruned, keep.tip, allNames)

pdf('out/treesAll.pruned.pdf', 8.5, 11)
for (i in names(treesML)) {
  tr = treesAll.pruned[[i]]
  plot(tr, cex = 0.6, main = i)
  nodelabels(tr$node.label, node = seq(from = length(tr$tip.label) + 1, to = length(tr$tip.label) + tr$Nnode + 1),
  frame = 'n', cex = 0.5, adj = c(1.5, -.5))
}
dev.off()
