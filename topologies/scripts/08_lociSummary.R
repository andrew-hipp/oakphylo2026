## summarize retained_loci (from the total_filtered_loci row of the
## ipyrad s7_filters table) across the per-clade ipyrad stats files
## modelled on 09_sitePatterns.R

## written by claude code with review by Andrew Hipp

files_ipy <- dir('data/ipyrad-stats', recursive = TRUE,
                 pattern = '^ipyradStats.*\\.txt$', full.names = TRUE)

## dataset labels and a distinctive substring per ipyrad-stats filename.
## order matters: more specific patterns must come first because the first
## match wins via ds_hit[1]. simRAD_ref is matched by 'referenceGuided' before
## simRAD_denovo's broader '_sim_' pattern could claim it; empiricalRAD's
## 'ipyradStats_ref_' is anchored enough not to collide with the simulated set.
datasets <- c(
    simRAD_ref          = 'referenceGuided',
    simRAD_denovo       = '_sim_',
    empiricalRAD        = 'ipyradStats_ref_',
    empiricalRAD_denovo = 'ipyradStats_denovo'
)

## extract retained_loci from the total_filtered_loci row
parse_retained <- function(f) {
    lines <- readLines(f, warn = FALSE)
    hit <- grep('^total_filtered_loci', lines, value = TRUE)
    nums <- strsplit(trimws(hit[1]), '\\s+')[[1]]
    as.integer(nums[length(nums)])
}

dat_retained <- data.frame(
    file     = files_ipy,
    dataset  = NA_character_,
    retained = NA_integer_,
    stringsAsFactors = FALSE
)

for (i in seq_along(files_ipy)) {
    ds_hit <- names(datasets)[sapply(datasets, grepl, x = files_ipy[i], fixed = TRUE)]
    dat_retained$dataset[i]  <- if (length(ds_hit)) ds_hit[1] else NA_character_
    dat_retained$retained[i] <- parse_retained(files_ipy[i])
}

## summarize: mean and SD of retained loci per dataset
out_retained <- do.call(rbind, lapply(names(datasets), function(ds) {
    vals <- dat_retained$retained[dat_retained$dataset == ds]
    data.frame(
        dataset           = ds,
        n                 = length(vals),
        mean_retainedLoci = mean(vals, na.rm = TRUE) |> round(1),
        sd_retainedLoci   = sd(vals,   na.rm = TRUE) |> round(1)
    )
}))

## percent difference of each clustering's mean retained loci vs the
## reference-mapped baseline within the same simulated/empirical group.
## ref-mapped rows are 0.0% by definition (compared against themselves).
ref_for <- c(
    simRAD_ref          = 'simRAD_ref',
    simRAD_denovo       = 'simRAD_ref',
    empiricalRAD        = 'empiricalRAD',
    empiricalRAD_denovo = 'empiricalRAD'
)
means    <- setNames(out_retained$mean_retainedLoci, out_retained$dataset)
ref_vals <- means[ref_for[out_retained$dataset]]
out_retained$pct_diff_vs_ref <- sprintf('%.1f%%',
    (out_retained$mean_retainedLoci - ref_vals) / ref_vals * 100)

print(out_retained)
if(globalDoPDF) write.csv(out_retained, 'out/tables/total_retained_loci.csv', row.names = FALSE)
