## edited by Claude Code in an interactive session with Andrew Hipp -- 2026-07-20 (~10% of characters changed)
library(ape)
library(TreeDist)
library(ggplot2)
library(TreeTools)
library(phangorn)

if(!exists('trs')) {
    tr <- rtree(15)
    repsPerTree <- 3
    trs <- c(
        tr, 
        rSPR(tr, 1, repsPerTree), 
        rSPR(tr, 2, repsPerTree), 
        rSPR(tr, 3, repsPerTree)
    )

    trs <- lapply(trs, MakeTreeBinary)

    trs.d <- ClusteringInfoDistance(trs)
    trs.mds <- cmdscale(trs.d, 2) |> as.data.frame()
}

xrange <- range(trs.mds$V1)
yrange <- range(trs.mds$V2)
xpad <- 0.75 * diff(xrange)
ypad <- 0.75 * diff(yrange)
xlim <- xrange + c(-xpad, xpad)
ylim <- yrange + c(-ypad, ypad)
xnorm <- (trs.mds$V1 - xlim[1]) / diff(xlim)
ynorm <- (trs.mds$V2 - ylim[1]) / diff(ylim)

pdf('out/figures/31_PPT_treeDistExample.pdf', width = 8, height = 6)
plot(trs.mds$V1, trs.mds$V2, type = "n",
     xlim = xlim, ylim = ylim,
     xlab = "MDS1", ylab = "MDS2",
     main = "Tree positions from MDS")
point.cols <- c("red", rep("blue", length(trs) - 1))
point.pch <- c(24, rep(21, length(trs) - 1))
point.bg <- c("red", rep("blue", length(trs) - 1))
points(trs.mds$V1, trs.mds$V2, pch = point.pch, col = point.cols, bg = point.bg, cex = 2)
title(sub = "Red filled triangle: original tree; blue filled circles: SPR trees", cex.sub = 0.8)

## SPR rearrangement + MakeTreeBinary can leave edge matrices in a non-canonical
## order that plot.phylo rejects ("tree badly conformed; cannot plot"), and can
## introduce degree-2 singleton nodes. reorder() restores the cladewise edge
## order plot.phylo expects; collapse.singles() drops any singleton nodes.
trs.plot <- lapply(trs, function(t) collapse.singles(reorder(t, "cladewise")))

old_par <- par(no.readonly = TRUE)
for (i in seq_along(trs.plot)) {
    size <- 0.05
    fig <- c(xnorm[i] - size, xnorm[i] + size,
             ynorm[i] - size, ynorm[i] + size)
    fig[1] <- max(0, fig[1]); fig[2] <- min(1, fig[2])
    fig[3] <- max(0, fig[3]); fig[4] <- min(1, fig[4])
    par(fig = fig, new = TRUE, mar = c(0, 0, 0, 0))
    tree.col <- ifelse(i == 1, "red", "blue")
    plot(trs.plot[[i]], show.tip.label = FALSE, direction = "rightwards",
         edge.color = tree.col, tip.color = tree.col, no.margin = TRUE)
}
par(old_par)
dev.off()