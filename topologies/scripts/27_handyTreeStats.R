# stats reported on who has what clades
## all on bootstraps only

### reSim = reseq + simRAD
### empiricalRAD = empiricalRAD 

bootRows <- list(
    reseq = intersect(grep('reseq', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    simRAD = intersect(grep('simRAD', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    reSim = intersect(grep('simRAD|reseq', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    empiricalRAD = intersect(grep('empiricalRAD', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_alba = intersect(grep('ref_alba', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_glauca = intersect(grep('ref_glauca', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_longispica = intersect(grep('ref_longispica', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_rubra = intersect(grep('ref_rubra', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_tomentella = intersect(grep('ref_tomentella', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_variabilis = intersect(grep('ref_variablis', row.names(monophylyMat)), grep('bt', row.names(monophylyMat))),
    ref_virginiana = intersect(grep('ref_virginiana', row.names(monophylyMat)), grep('bt', row.names(monophylyMat)))
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
