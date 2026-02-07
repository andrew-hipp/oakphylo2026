# standardize tips between trees
# efuller@mortonarb.org, 18 Jan 2026

library(ape)
library(tidyverse)
library(tidytree)
library(purrr)

## define tip identifiers (here, epithets)
species_list <- c("acerifolia", "acrodonta", "acuta", "acutifolia", "acutissima", "afares", "transmontana", "affinis", "agrifolia", "ajoensis", "alba", "albocinta", "aliena", "alnifolia", "annulata", "arbutifolia", "ariifolia", "aristata", "arizonica", "arkansana", "aucheri", "augustini", "austrina", "austrocochinchinensis", "baloot", "baronii", "bawangliensis", "bella", "benthamii", "berberidifolia", "bicolor", "blakei", "boissieri", "boyntonii", "brandegeei", "brantii", "buckleyi", "bumelioides", "calliprinos", "calophylla", "canariensis", "canby", "castanea", "castaneifolia", "cedrorum", "cedrosensis", "cerris", "miquihuanensis", "championii", "chapensis", "chapmanii", "chenii", "chihuahuensis", "chrysocalyx", "chrysolepis", "chungii", "ciliaris", "coccifera", "cocciferoides", "coccinea", "coffeicolor", "convallata", "conzattii", "copeyensis", "corrugata", "cortesii", "costaricensis", "crassifolia", "crassipes", "crenata", "crispifolia", "cupreata", "daimingshanensis", "dalechampii", "delavayi", "delgadoana", "depressipes", "deserticola", "diversifolia", "dolicholepis", "douglasii", "dumosa", "durata", "durifolia", "eduardi", "elliottii", "ellipsoidalis", "elliptica", "emoryi", "engelmannii", "engleriana", "eugeniifolia", "eumorpha", "fabri", "faginea", "falcata", "fleuryi", "floribunda", "frainetto", "franchetii", "frutex", "fulva", "fusiformis", "galeanensis", "garryana", "geminata", "gentryi", "georgiana", "germana", "gilva", "glabrescens", "glaucescens", "glaucoides", "graciliformis", "grahamii", "gravesii", "greggii", "griffithii", "grisea", "gujavifolia", "hartwissiana", "havardii", "hemisphaerica", "hinckleyi", "huicholensis", "humboldtii", "hypoleucoides", "hypoxantha", "ilex", "ilicifolia", "iltisii", "imbricaria", "incana", "infectoria", "inopina", "insignis", "intricata", "invaginata", "ithaburensis", "jenseniana", "jonesii", "kelloggii", "kerrii", "kingiana", "kiukiangensis", "kotschyana", "kouangsiensis", "laceyi", "laevis", "lamellosa", "lanata", "lancifolia", "langbianensis", "laurifolia", "laurina", "leucotrichophora", "liaotungensis", "libani", "liebmannii", "lineata", "litoralis", "lobata", "longispica", "look", "lowilliamsii", "lusitanica", "lyrata", "macdougallii", "macranthera", "macrocarpa", "macrolepis", "magnoliifolia", "margarettae", "marilandica", "marlipoensis", "martinezii", "meavei", "mexicana", "michauxii", "minima", "miquihuanensis", "mohriana", "mongolica", "monimotricha", "montana", "muehlenbergii", "multinervis", "myrsinifolia", "myrtifolia", "nigra", "nudinervis", "oblongifolia", "obtusata", "ocoteifolia", "oglethorpensis", "oleoides", "opaca", "oxyodon", "pachyloma", "pacifica", "pagoda", "palmeri", "palustris", "pannosa", "parvula", "patelliformis", "peduncularis", "peninsularis", "pennivenia", "petraea", "phanera", "phellos", "phillyreoides", "pinnativenulosa", "planipocula", "poilanei", "polymorpha", "pontica", "porphyrogenita", "pringlei", "prinoides", "pubescens", "pungens", "purulhana", "pyrenaica", "radiata", "rehderiana", "resinosa", "rex", "robur", "robusta", "rotundifolia", "rubra", "rugosa", "rysophylla", "sadleriana", "sagraeana", "salicifolia", "salicina", "sapotifolia", "sartorii", "schottkyana", "scytophylla", "sebifera", "segoviensis", "semecarpifolia", "senescens", "serrata", "sessilifolia", "setulosa", "shumardii", "sichourensis", "sideroxyla", "similis", "sinuata", "spinosa", "stellata", "stewardiana", "striatula", "suber", "subspathulata", "tarahumara", "tarokoensis", "texana", "tomentella", "toumeyi", "trojana", "tuitensis", "turbinella", "utilis", "uxoris", "vacciniifolia", "variabilis", "vaseyana", "velutina", "viminea", "virginiana", "vulcanica", "wislizeni", "xalapensis", "yiwuensis", "yunnanensis")

## standardize tips using tip identifiers
standardize_tips <- function(tree, species_list) {
  tree@phylo$tip.label <- map_chr(tree@phylo$tip.label, function(x) {
    hit <- species_list[str_detect(str_trim(x), fixed(species_list, ignore_case = TRUE))]
    if (length(hit) == 0) return(NA_character_)
    hit[1]   # if multiple matches, take the first. hit [2] gives error, so no duplicates
  })
  tree
}

node_dated <- standardize_tips(node_dated, species_list)
tip_dated <- standardize_tips(tip_dated, species_list)
