# compare topologies of the trees pruned to major groups


## compare topologies
clades <- c(
    gilva = 'Cyclobalanopsis',
    cerris = 'Cerris',
    ilex = 'Ilex',
    rubra = 'Lobatae',
    vacciniifolia = 'Protobalanus - core',
    cedrosensis = 'Protobalanus - cedrosensis',
    pontica = 'Ponticae',
    virginiana = 'Virentes',
    dumosa = 'Quercus_CA_dumosa',
    lobata = 'Quercus_CA_lobata',
    rugosa = 'Quercus_MX_rugosa',
    engelmannii = 'Quercus_MX_engelmannii',
    muehlenbergii = 'Quercus_ENA_muehlenbergii',
    macrocarpa = 'Quercus_ENA_macrocarpa',
    bicolor = 'Quercus_ENA_bicolor',
    stellata = 'Quercus_ENA_stellatae',
    alba = 'Quercus_ENA_albae',
    robur = 'Quercus_EUR_roburoids'
)

treesAll.clades <- treesAll.pruned
for(i in names(treesAll.clades)) {
    treesAll.clades[[i]] <- 
        keep.tip(treesAll.clades[[i]], 
            which(gsub('Quercus ', '',treesAll.clades[[i]]$tip.label) %in% names(clades)))
    treesAll.clades[[i]]$tip.label <- clades[gsub('Quercus ', '', treesAll.clades[[i]]$tip.label)]    
}

# fix up ref_variabilis, in which Protobalanus is polyphyletic
temp <- treesAll$refRAD.ref_variablis_raxml
temp$tip.label <- strsplit(temp$tip.label, '|', fixed = T)
temp$tip.label <- sapply(temp$tip.label, '[', 1) |>
  gsub(pattern = "Quercus ", replacement = "", fixed = T)
temp <- keep.tip(temp, names(clades))
temp$tip.label <- clades[temp$tip.label]
treesAll.clades$refRAD.ref_variablis_raxml <- temp
rm(temp)

if(globalDoPDF) {
  pdf('out/trees/treesAll.pruned.clades.pdf', 8.5, 11)
  for (i in names(treesAll.clades)) {
    tr = treesAll.clades[[i]]
    plot(tr, cex = 1, main = i)
    nodelabels(tr$node.label, node = seq(from = length(tr$tip.label) + 1, to = length(tr$tip.label) + tr$Nnode + 1),
    frame = 'n', cex = 0.5, adj = c(1.5, -.5))
  }
  dev.off()
}

if(globalDoPDF) {
  pdf('out/figures/FIG2_treesAll.pruned.clades.pdf', 7, 10)
  par(mar = c(1,2,2,2))
  layout(matrix(c(1,1:7), 4, 2, byrow = T))
  todo <- names(treesAll.clades) |> 
    grep (patt = 'bt', invert = T, value = T) |> 
    grep(patt = 'refRAD', value = T)
  counter = 0
  for (i in todo) {
    counter <- counter + 1
    adjName <- substitute(
      expr = paste(
        '(', bold(thisLetter), ') Reference: ', 
        italic('Quercus '), italic(epithet),
        sep = ''),
      env = list(
        thisLetter = letters[counter],
        epithet = strsplit(i, '_')[[1]][2])
    )
    if(i != "refRAD.ref_alba_raxml") {
      tr <- drop.tip(treesAll.clades[[i]], c(
        "Cyclobalanopsis", "Ilex", "Cerris", "Lobatae"
      ))
    } else tr <- treesAll.clades[[i]]
    plot(tr, cex = 1, main = adjName)
    nodelabels(tr$node.label, node = seq(from = length(tr$tip.label) + 1, to = length(tr$tip.label) + tr$Nnode + 1),
    frame = 'n', cex = 0.5, adj = c(1.5, -.5))
  }
  dev.off()
  }

## check monophyly of clades
clades_check <- list(
    Quercus_CA = c(
    'Quercus_CA_dumosa',
    'Quercus_CA_lobata'
    ),
    Quercus_MX = c(
    'Quercus_MX_rugosa',
    'Quercus_MX_engelmannii'
    ),
    Quercus_MX_stellatae = c(
    'Quercus_ENA_stellatae',
    'Quercus_MX_rugosa',
    'Quercus_MX_engelmannii'
    ),
    roburoids_albae = c(
    'Quercus_ENA_albae',
    'Quercus_EUR_roburoids'
    ),
    mac_bic = c(
    'Quercus_ENA_macrocarpa',
    'Quercus_ENA_bicolor'
    ),
    mac_bic_lob = c(
    'Quercus_CA_lobata',
    'Quercus_ENA_macrocarpa',
    'Quercus_ENA_bicolor'
    )
)

monophylyMat <- matrix(
  NA,
  nrow = length(treesAll.clades),
  ncol = length(clades_check),
  dimnames = list(names(treesAll.clades), names(clades_check))
) # close matrix

for(i in names(treesAll.clades)){
  trTest <- treesAll.clades[[i]]
  for(j in names(clades_check)){
    tipsCheck <- clades_check[[j]]
    monophylyMat[i,j] <- is.monophyletic(trTest, tipsCheck)
  }
}

write.csv(monophylyMat, 'out/tables/monophylyMat.csv')