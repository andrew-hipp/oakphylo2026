# do rogue analyses using `Rogue` package -- not written (2026-02-09)

library(Rogue)

if(!exists('rogues')) {
    rogues <- list(
        allPruned = RogueTaxa(treesAll.pruned),
        boots = lapply(boots, function(x) {
            lapply(x, RogueTaxa)
        })
    )
    }

for(i in names(rogues$boots)){
    for(j in names(rogues$boots[[i]])){
        write.csv(rogues$boots[[i]][[j]], paste('out/rogues_',j,'.csv', sep = ''))
    }
}

write.csv(rogues$allPruned, paste('out/rogues_treesAllPruned.csv'))
