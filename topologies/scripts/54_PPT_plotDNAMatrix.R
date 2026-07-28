## 54_PPT_plotDNAMatrix.R
## Plot the concatenated DNA supermatrix (data present vs. missing) for the
## oakphylo2026 PowerPoint figures.
##
##   present data  -> yellow
##   missing data  -> black   (N, n, ?, -, .)
##
## Input : data/Hipp2020_oaksall_v1_2.m15.singles.2019-03-13.phy.gz
##         (261 taxa x 1,969,938 sites, sequential/relaxed PHYLIP)
## Output: out/figures/PPT_54_DNAmatrix.pdf        (sized 13.333 x 7.5 in, 16:9)
##         out/figures/PPT_54_DNAmatrix.info.txt   (per-individual missing-data summary)
##
## The gzipped matrix is read directly from a gzfile() connection, so it is
## never unzipped to disk -- nothing needs to be re-gzipped afterward and the
## large matrix stays compressed in the repo (GitHub-friendly).
##
## NOTE on downsampling: 261 x 1,969,938 = ~5.1e8 cells cannot be rendered (or
## seen on a slide). Columns are binned into `nBins`; each cell is colored by
## the PROPORTION of present sites in that bin on a black->yellow ramp
## (yellow = all present, black = all missing). Set `binarize = TRUE` for a
## hard present/absent cut at `binThreshold` instead.
##
## written by Claude Code in an interactive session with Andrew Hipp — 2026-07-28 08:03 CDT
## edited by Claude Code in an interactive session with Andrew Hipp — 2026-07-28 (~20% of characters added: per-individual missing-data summary file)
## -----------------------------------------------------------------------------

## ---- parameters -------------------------------------------------------------
infile        <- "data/Hipp2020_oaksall_v1_2.m15.singles.2019-03-13.phy.gz"
outfile       <- "out/figures/PPT_54_DNAmatrix.pdf"

nBins         <- 3000          # number of horizontal (site) bins to render
missingChars  <- c("N", "n", "?", "-", ".")   # characters treated as MISSING
binarize      <- FALSE         # TRUE -> hard present/absent; FALSE -> proportion ramp
binThreshold  <- 0.5           # if binarize: bin is "present" when >= this fraction present
showTipLabels <- FALSE         # 261 taxa is usually too many to read on a slide
pdfWidth      <- 7 # going for a panel on the right side
# pdfWidth      <- 13.333        # inches, standard 16:9 PowerPoint slide
pdfHeight     <- 7.5

## ---- resolve paths (works whether wd is topologies/ or the repo root) -------
if (!file.exists(infile) && file.exists(file.path("topologies", infile))) {
  infile  <- file.path("topologies", infile)
  outfile <- file.path("topologies", outfile)
}
if (!file.exists(infile)) stop("Cannot find input matrix: ", infile)
dir.create(dirname(outfile), recursive = TRUE, showWarnings = FALSE)

## ---- read + bin the matrix (streaming, low memory) --------------------------
## Read one taxon line at a time from the gz stream, convert to a present/absent
## vector, then collapse to `nBins` bin proportions via a cumulative sum. Only
## one full-length sequence lives in memory at any moment.
##
## This is wrapped in a function so that on.exit(close(con)) fires correctly:
## at top level under source() an on.exit() closes the connection immediately,
## before it can be read.
readMatrixBins <- function(infile, nBins, missingChars) {
  missingRaw <- as.raw(utf8ToInt(paste(missingChars, collapse = "")))

  con <- gzfile(infile, open = "rt")
  on.exit(close(con), add = TRUE)

  hdr   <- as.integer(strsplit(trimws(readLines(con, n = 1L)), "\\s+")[[1]])  # ntax, nchar
  nTax  <- hdr[1]
  nChar <- hdr[2]

  edges <- floor(seq(0, nChar, length.out = nBins + 1))    # bin boundaries in site coords
  binW  <- diff(edges)                                     # sites per bin

  mat     <- matrix(NA_real_, nrow = nTax, ncol = nBins)   # taxa x bins, proportion present
  tipLab  <- character(nTax)
  nPresent <- integer(nTax)                                # EXACT count of present sites per taxon

  i <- 0L
  repeat {
    line <- readLines(con, n = 1L)
    if (length(line) == 0L || !nzchar(line)) break
    i <- i + 1L
    if (i > nTax) break

    tipLab[i] <- sub("\\s.*$", "", line)                   # name = first whitespace-delimited token
    seq       <- sub("^\\S+\\s+", "", line)                # sequence = remainder

    present <- as.integer(!(charToRaw(seq) %in% missingRaw))  # 1 = present, 0 = missing
    nPresent[i] <- sum(present)                            # exact, from the full-length sequence
    cs      <- c(0L, cumsum(present))
    counts  <- cs[edges[-1] + 1] - cs[edges[-(nBins + 1)] + 1]
    mat[i, ] <- counts / binW                              # proportion present per bin
  }
  if (i != nTax) warning("Read ", i, " taxa but header declared ", nTax, ".")

  list(mat = mat, tipLab = tipLab, nPresent = nPresent, nTax = nTax, nChar = nChar)
}

parsed   <- readMatrixBins(infile, nBins, missingChars)
mat      <- parsed$mat
tipLab   <- parsed$tipLab
nPresent <- parsed$nPresent
nTax     <- parsed$nTax
nChar    <- parsed$nChar

## ---- per-individual missing-data summary ------------------------------------
## Exact percent missing per taxon = 100 * (nChar - present) / nChar.
pctMissing <- 100 * (nChar - nPresent) / nChar
ord        <- order(pctMissing, decreasing = TRUE)   # worst (most missing) first

infofile <- sub("\\.pdf$", ".info.txt", outfile)
info <- c(
  sprintf("Missing-data summary for %s", basename(infile)),
  sprintf("%d taxa x %s sites; missing characters = {%s}",
          nTax, format(nChar, big.mark = ","), paste(missingChars, collapse = " ")),
  "Written by scripts/54_PPT_plotDNAMatrix.R (Claude Code / Andrew Hipp) 2026-07-28",
  "",
  sprintf("Percent missing data per individual (n = %d):", nTax),
  sprintf("  mean   = %.2f %%", mean(pctMissing)),
  sprintf("  range  = %.2f %% to %.2f %%", min(pctMissing), max(pctMissing)),
  sprintf("  sd     = %.2f %%", sd(pctMissing)),
  "",
  sprintf("%-32s %14s %12s", "individual", "sites_missing", "pct_missing"),
  sprintf("%-32s %14s %12s", strrep("-", 32), strrep("-", 14), strrep("-", 12)),
  sprintf("%-32s %14s %12.2f",
          tipLab[ord], format(nChar - nPresent[ord], big.mark = ","), pctMissing[ord])
)
writeLines(info, infofile)
message("Wrote ", infofile)

if (binarize) {
  mat <- ifelse(mat >= binThreshold, 1, 0)
}

## ---- plot -------------------------------------------------------------------
## image() draws z[x, y] at (x = column index, y = row index), so transpose to
## get sites on the x-axis and taxa on the y-axis.
pal <- colorRampPalette(c("black", "yellow"))(256)

pdf(outfile, width = pdfWidth, height = pdfHeight)
op <- par(mar = c(4.5, if (showTipLabels) 8 else 4.5, 3, 2), xaxs = "i", yaxs = "i")

image(
  x = seq_len(nBins), y = seq_len(nTax), z = t(mat),
  col = pal, zlim = c(0, 1),
  useRaster = TRUE, axes = FALSE,
  xlab = "", ylab = ""
)

## x-axis in megabases of concatenated alignment
mbTicks <- pretty(c(0, nChar / 1e6))
mbTicks <- mbTicks[mbTicks <= nChar / 1e6]
axis(1, at = mbTicks * 1e6 / nChar * nBins, labels = mbTicks)
mtext("Concatenated alignment position (Mb)", side = 1, line = 2.6)

if (showTipLabels) {
  axis(2, at = seq_len(nTax), labels = tipLab, las = 1, cex.axis = 0.2, tick = FALSE)
} else {
  mtext(sprintf("Taxa (n = %d)", nTax), side = 2, line = 1)
}

title(main = sprintf("Oak supermatrix: data present (yellow) vs. missing (black)  |  %d taxa x %s sites",
                     nTax, format(nChar, big.mark = ",")))

par(op)
dev.off()

message("Wrote ", outfile)
