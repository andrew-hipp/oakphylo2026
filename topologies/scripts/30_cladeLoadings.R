## do the ordination with clade loadings
## fold this into ordination when I reorganize
## right now depends on matrix from 10_compareTrees.R + ord objects from 05_ordination.R

# stop('**** problem in clade loadings since I did the global refRAD --> empiricalRAD change')

library(vegan)

trees.points2 <- list(
    all = cmdscale(trees.dist, 2),
    empiricalRAD = cmdscale(
        d = as.dist(
            as.matrix(trees.dist)[
                grep('empiricalRAD', names(treesAll)), 
                grep('empiricalRAD', names(treesAll))]), 
        k = 2),
    simRAD = cmdscale(
        d = as.dist(
            as.matrix(trees.dist)[
                grep('simRAD', names(treesAll)), 
                grep('simRAD', names(treesAll))]), 
        k = 2)
)

mm <-ifelse(monophylyMat == TRUE, 1, 0)
trees.envfit <- structure(vector('list', 3), names = names(trees.points2))
for(i in names(trees.points2)) {
    print(paste('doing', i))
    trees.envfit[[i]] <- envfit(
        trees.points2[[i]], 
        mm[attr(trees.points2[[i]],'dimnames')[[1]], ])
    if(globalDoPDF) {
        if(i == 'all') {pdf('out/figures/FIGS2_envfit_all.pdf')
        } else pdf(paste('out/ordinations/envfit_', i, '.pdf', sep = ''))
        plot(trees.points2[[i]])
        plot(trees.envfit[[i]])
        dev.off()
        }
} # close i
    

