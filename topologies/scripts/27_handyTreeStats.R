# stats reported on who has what clades
## all on bootstraps only

### reSim = reseq + simRAD
### refRAD = refRAD 

bootRows <- list(
    reSim = intersect(grep('simRAD|reseq', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    refRAD = intersect(grep('refRAD', row.names(monophylyMat)), grep('bt', row.names(monophylyMat)))
)


ordiStats <- vector('numeric', length(bootRows) * dim(monophylyMat)[2])
counter = 0
for(iboot in names(bootRows)) {
    for(iclade in colnames(monophylyMat)) {
        counter <- counter+1
        names(ordiStats)[counter] <- paste(iboot,iclade,sep = '_')
        ordiStats[counter] <- sum(monophylyMat[bootRows[[iboot]], iclade]) / length(bootRows[[iboot]])
    }
}

ordiStats <- structure(
    paste0(round(ordiStats*100, 1), '%'),
    names = names(ordiStats)
)

write.csv(ordiStats,'out/tables/ordinationStats.csv')
