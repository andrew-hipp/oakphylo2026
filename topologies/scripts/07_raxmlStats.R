## identify files

files_phy <- dir('data', recursive = T, patt = 'phy.gz', full = T) 
files_rax <- dir('data', recursive = T, patt = '_info.', full = T) 

## extract bp from phylip files
dat_bp <- sapply(files_phy, function(x){
    con <- gzfile(x, open = "r")
    lines <- readLines(con, n = 1) |>
        strsplit(split = ' ', fixed = T) |>
        getElement(name = 1) |>
        getElement(name = 2) |>
        as.integer()
    close(con)
    return(lines)}
) # close sapply

names(dat_bp) <- 
    strsplit(files_phy, '/') |>
    sapply(FUN = getElement, 3)

## extract elements from raxml summaries
dat_rax <- sapply(files_rax, function(x) {
    temp <- readLines(x)
}) # close sapply
names(dat_rax) <-

## make supplement table from ipyrad
summary_cols <- c(
    'dataset', # or as row.name
    'min4 loci', # loci in the min 4 ipyrad dataset
    'locus coverage', # mean +/- sd loci per individual
    'bp phy', # bp in phylip file analyzed
    'patterns phy' # unique site patterns in phylip file analyzed
)

