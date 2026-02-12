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
