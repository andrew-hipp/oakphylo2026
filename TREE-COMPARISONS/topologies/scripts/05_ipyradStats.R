# read and summarize ipyrad stats

dat_ipy <- lapply(dir('data/ipyrad-stats', patt = 'ipyrad', full = T), readLines)
names(dat_ipy) <- 
    dir('data/ipyrad-stats', patt = 'ipyrad') |>
    gsub(pattern = 'ipyradStats_|.txt', replacement = '')

dat_indVects <- lapply(dat_ipy, function(x) {
    start <- grep('sample_coverage', x) + 1
    end <- grep('The number of loci for which', x) - 2
    tab <- read.table(text = x[start:end], row.names = 1)
    out <- tab[[1]]
    names(out) <- row.names(tab)
    return(out)
})

hilo <- function(x, extremes = 10) {
    list(
        lo = sort(x)[1:extremes],
        hi = sort(x, decreasing = T)[1:extremes]
        )
}

dat_hilo <- lapply(dat_indVects, hilo)
for(i in names(dat_hilo)){
    for(j in names(dat_hilo[[i]])){
        names(dat_hilo[[i]][[j]]) <- (
            dat_meta$refRAD[
                names(dat_hilo[[i]][[j]]),
                c('TAXA-Current_determination', 'SPMCODE')
                ] |> 
                apply(1, paste, collapse = '|') |> 
                as.character()
                ) # close names <-
    } # close j
} # close i
