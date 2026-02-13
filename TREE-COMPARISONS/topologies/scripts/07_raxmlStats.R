## read first line of phylip files and raxml info files

phyfiles <- 0 # function needed here to get all the file paths

dat_phy <- sapply(raxphy, function(x){
    # go get all the rax info files and parse out -- FINISH
    con <- gzfile(, open = "r")
    lines <- readLines(con, n = 1)
    close(con)
    return(lines)}
) # close sapply
names(dat_phy) <- 0 # ... and give them nice clean names -- FINISH



## make supplement table
summary_cols <- c(
    'dataset', # or as row.name
    'min4 loci', # loci in the min 4 ipyrad dataset
    'locus coverage', # mean +/- sd loci per individual
    'bp phy', # bp in phylip file analyzed
    'patterns phy' # unique site patterns in phylip file analyzed
)

