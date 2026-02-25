# Parse fBranch results file and identify top 3 values
library(readr)

# Read the file
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

row.names(dat_alba) <- dat_alba$branch
row.names(dat_alba)[grep(',', dat_alba$branch_descendants, fixed = T, invert = T)] <- 
    grep(',', dat_alba$branch_descendants, fixed = T, invert = T, value = T)

row.names(dat_var) <- dat_var$branch
row.names(dat_var)[grep(',', dat_var$branch_descendants, fixed = T, invert = T)] <- 
    grep(',', dat_var$branch_descendants, fixed = T, invert = T, value = T)


dat.descendants_alba <- structure(dat_alba$branch_descendants, names = row.names(dat_alba))
dat_alba[c('branch_descendants', 'branch', 'Outgroup')] <- NULL
fb_max_alba <- apply(dat_alba, 1, max, na.rm = T) |>
  sort(decreasing = T)

dat.descendants_var <- structure(dat_var$branch_descendants, names = row.names(dat_var))
dat_var[c('branch_descendants', 'branch', 'Outgroup')] <- NULL
fb_max_var <- apply(dat_var, 1, max, na.rm = T) |>
  sort(decreasing = T)

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
write.csv(results$fb_max_mat, 'out/fb_max_alba.csv', row.names = T)

dat_var_trim <- dat_var[grep('Quercus', row.names(dat_var)), grep('Quercus', colnames(dat_var))]
dat_alba_trim <- dat_alba[grep('Quercus', row.names(dat_alba)), grep('Quercus', colnames(dat_alba))]


plotResults = list(
    alba = find.top(fb_max_alba, d = dat_alba, desc = dat.descendants_alba)$fb_max_mat[,1],
    var = find.top(fb_max_var, d = dat_var, desc = dat.descendants_var)$fb_max_mat[,1]
)
