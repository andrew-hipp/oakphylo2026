# a bunch of little stuff, scratch space, prob not needed for paper

## checking the topology of what I'm writing in the results for the strict consensus:
tr.check <- read.tree(text = '(((sectCerris, sectIlex), sectCyclobalanopsis)subgCerris, (sectLobatae, (sectChrysolepis, (sectPonticae, (sectVirentes, sectQuercus))))subgQuercus);')

## avg bootstrap support for sect Quercus in the refRAD datasets
sectQuercus = mean(
    c(
        alba = 44,
        glauca = 67,
        longispica = 57,
        rubra = 77,
        tomentella = 43,
        variabilis = 47,
        virginiana = 60
    )
)

# check for quercus monophyly
quercusMonophyletic <- sapply(unlist(boots$refRAD, recursive = FALSE), function(x){
    tips <- grep('Quercus', x$tip.label)
    out <- is.monophyletic(x, tips)
    return(out)
})

quercusMonophyletic_bundled <- 
    tapply(
        quercusMonophyletic, 
        sapply(
            strsplit(names(quercusMonophyletic), '_', fixed = T), 
            '[', 2),
            list)
sapply(quercusMonophyletic_bundled, sum)


## added 2026-04-21 -- cut from 20_ordinations, moved into 00_readData
treesAll.pruned_orig <- treesAll.pruned
class(treesAll.pruned) <- 'multiPhylo'
treesAll.pruned <- c(tr2020, treesAll.pruned)
allNames <- intersect(
  treesAll.pruned[[1]]$tip.label,
  treesAll.pruned[[2]]$tip.label)
treesAll.pruned <- lapply(treesAll.pruned, keep.tip, allNames)
names(treesAll.pruned)[1] <- 'empiricalRAD.OakRAD2020'
# treesAll.pruned <- treesAll.pruned_orig
