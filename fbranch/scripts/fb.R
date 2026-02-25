# Parse fBranch results file and identify top 3 values
library(readr)
library(tidyr)
library(tidyverse)

## Read files
dat_alba <- read_delim(
    "data/Results_fBranch.oakphylo2025.Qalba.merged_calls.2026_02_06",
    delim = "\t",
    skip = 0
) |> as.data.frame()

dat_var <- read_delim(
    "data/Results_fBranch.oakphylo2025.Qvar.merged_calls.2026_02_06",
    delim = "\t",
    skip = 0
    ) |> as.data.frame()

dat_taxa <- read.csv('data/reseqTaxa.csv') 
dat_taxa <- structure(dat_taxa$section, names = dat_taxa$species)

## reformat data
row.names(dat_alba) <- dat_alba$branch
row.names(dat_alba)[grep(',', dat_alba$branch_descendants, fixed = T, invert = T)] <- 
    grep(',', dat_alba$branch_descendants, fixed = T, invert = T, value = T)

row.names(dat_var) <- dat_var$branch
row.names(dat_var)[grep(',', dat_var$branch_descendants, fixed = T, invert = T)] <- 
    grep(',', dat_var$branch_descendants, fixed = T, invert = T, value = T)


dat.descendants_alba <- structure(dat_alba$branch_descendants, names = row.names(dat_alba))
dat_alba[c('branch_descendants', 'branch', 'Outgroup')] <- NULL
fb_max_alba <- apply(dat_alba, 1, max, na.rm = T) |>
  sort(decrrownames_to_columneasing = T)

dat.descendants_var <- structure(dat_var$branch_descendants, names = row.names(dat_var))
dat_var[c('branch_descendants', 'branch', 'Outgroup')] <- NULL
fb_max_var <- apply(dat_var, 1, max, na.rm = T) |>
  sort(decreasing = T)

dat_var_trim <- dat_var[grep('Quercus', row.names(dat_var)), grep('Quercus', colnames(dat_var))]
dat_alba_trim <- dat_alba[grep('Quercus', row.names(dat_alba)), grep('Quercus', colnames(dat_alba))]

### and then this just to match up the dat_alba and dat_var results:
dat_var_trim_adj <- dat_var_trim[row.names(dat_alba_trim), row.names(dat_alba_trim)]

### this for a long matrix to plot results by section:
dat_alba_long <- dat_alba |>
    as.data.frame() |>
    rownames_to_column(var = "row") |>
    pivot_longer(cols = -row, names_to = "col", values_to = "value")

### now add in the sections:

#### 1. return `colSect`
dat_alba_long$colSect <- dat_taxa[dat_alba_long$col]

#### 2a. If row is a sp, return `rowSect` of row...
dat_alba_long$rowSect <- NA
dat_alba_long$rowSect[grep('Quercus', dat_alba_long$row)] <- 
    dat_taxa[dat_alba_long$row[grep('Quercus', dat_alba_long$row)]]
    
#### 2b. ... else get sect of all descendants and...

#### 2b1. ... if all descendents of row are the same, return sect of row...

#### 2b2. ... else return "MIXED"

#### 3a. If rowSect == colSect, return compareSect = rowSect

#### 3b. ... else return compareSect = "INTERSECTION"

## function to find the top fb values for all rows
find.top <- function(m = head(fb_max_alba, 10), d = dat_alba, desc = NULL) {
    out <- structure(character(length(m)), names = names(m))
    for(i in names(m)) out[i] <- names(d)[which(d[i, ] == m[i])]
    out = cbind(fb_max = m, partner = out)
    if(!is.null(desc)) out <- list(
        fb_max_mat = out,
        descendants = as.list(desc[names(m)])[grep("^b[0-9]+$", names(m))]
    )
    return(out)
}

albaResults = find.top(fb_max_alba[1:30], desc = dat.descendants_alba)
write.csv(albaResults$fb_max_mat, 'out/fb_max_alba.csv', row.names = T)


dat_compare <- data.frame(

)

## Here I'd like a function that bins nodes to sections
## just to give a histogram of intra vs intersectional hybrids inferred
