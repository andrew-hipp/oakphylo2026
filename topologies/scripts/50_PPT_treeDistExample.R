## edited by Claude Code in an interactive session with Andrew Hipp -- 2026-07-20 (~65% of characters changed)
##
## PPT illustration of tree-to-tree distance. Builds an example tree, makes SPR
## rearrangements of it, and writes two PDFs to out/figures/:
##   PPT_50_treeGallery.pdf   original + SPR trees, ascending Robinson-Foulds
##                            distance, each captioned with a letter ID and d (RF).
##   PPT_50_MDSpositions.pdf  MDS ordination of the trees (clustering-information
##                            distance), each dot with a thumbnail of its tree.
## Letter IDs are shared between the two figures so a tree's RF-distance rank
## (gallery) can be compared against its MDS position.
##
## Figure 2 layout notes:
##  - Thumbnails can't use ggrepel (it only repels text/points), so repelBoxes()
##    is a small base-graphics rectangle repeller: a weak spring pulls each box
##    toward its dot, pairwise separation pushes overlapping boxes apart, all in
##    normalized device coordinates and clamped to the page.
##  - Dot positions are converted data -> device with grconvertX/Y(..., 'ndc')
##    while the scatter's coordinate system is still current (before any par(fig=)
##    change); this correctly accounts for the axis margins.
##  - A slender leader arrow is drawn from each box edge to its dot (drawn before
##    the thumbnail so the thumbnail hides the stub inside its own box).
##  - Thumbnails are pushed outward from the centre of the dot cloud (`expand`) so
##    their spread and the dot each connects to are clear; the letter IDs sit right
##    next to the dots.
##  - The original tree is red, largest, and drawn last (on top); all lettered
##    (SPR) trees, A included, are smaller and semi-transparent (alpha = 0.6).
##  - Tuning knobs: outward push `expand`; thumbnail sizes wIn / hIn; repel
##    behaviour pull / iter in repelBoxes(); arrow look in the arrows(...) call.
##
library(ape)
library(TreeDist)
library(ggplot2)
library(TreeTools)
library(phangorn)

    ## unroot: rtree() is rooted (degree-2 root), but phangorn::rSPR needs an
    ## unrooted binary tree or its SPR moves can yield a non-binary intermediate
    ## and abort with "trees must be binary" (more likely with many moves).
    tr <- unroot(rtree(15))
    repsPerTree <- 3
    trs <- c(
        tr, 
        rSPR(tr, 2, repsPerTree), 
        rSPR(tr, 5, repsPerTree), 
        rSPR(tr, 8, repsPerTree+2)
    )

    trs <- lapply(trs, MakeTreeBinary)

    trs.d <- ClusteringInfoDistance(trs)
    trs.mds <- cmdscale(trs.d, 2) |> as.data.frame()

xrange <- range(trs.mds$V1)
yrange <- range(trs.mds$V2)
xpad <- 0.75 * diff(xrange)
ypad <- 0.75 * diff(yrange)
xlim <- xrange + c(-xpad, xpad)
ylim <- yrange + c(-ypad, ypad)

## Robinson-Foulds distance of every tree to the original (tree 1); used to order
## and label the figure-1 gallery. (Figure 2's MDS ordination still uses the
## clustering-information distance trs.d computed above.)
trs.rf <- RobinsonFoulds(trs)
distToOrig <- as.matrix(trs.rf)[, 1]

## clustering-information distance to the original, used only to break ties in the
## (coarse, integer) RF ordering. trs.d may not survive a cached environment.
if(!exists('trs.d')) trs.d <- ClusteringInfoDistance(trs)
ciToOrig <- as.matrix(trs.d)[, 1]

## order the SPR trees least- to most-different from the original, and give each a
## capital-letter ID (A = least different). Reused to label the MDS plot so slide
## viewers can match a tree's distance rank against its ordination position.
others <- setdiff(seq_along(trs), 1)
## primary sort: RF distance; secondary sort (ties): clustering-information distance
ord <- others[order(distToOrig[others], ciToOrig[others], decreasing = FALSE)]
treeLetters <- character(length(trs))
treeLetters[1]   <- NA
treeLetters[ord] <- LETTERS[seq_along(ord)]

## SPR rearrangement + MakeTreeBinary can leave edge matrices in a non-canonical
## order that plot.phylo rejects ("tree badly conformed; cannot plot"), and can
## introduce degree-2 singleton nodes. reorder() restores the cladewise edge
## order plot.phylo expects; collapse.singles() drops any singleton nodes.
trs.plot <- lapply(trs, function(t) collapse.singles(reorder(t, "cladewise")))

## simple rectangle "repel": nudge thumbnail boxes apart so they stop overlapping
## while a weak spring keeps each near its target (its dot). All coordinates are in
## normalized device units [0,1]; w/h are full box widths/heights. This is the
## base-graphics stand-in for ggrepel, which cannot place phylo thumbnails.
repelBoxes <- function(tx, ty, w, h, iter = 800, pull = 0.006) {
  n <- length(tx); hw <- w / 2; hh <- h / 2
  px <- tx; py <- ty
  for (it in seq_len(iter)) {
    px <- px + pull * (tx - px)             # spring back toward the dot
    py <- py + pull * (ty - py)
    if (n >= 2) for (i in seq_len(n - 1)) for (j in (i + 1):n) {
      dx <- px[j] - px[i]; dy <- py[j] - py[i]
      ox <- (hw[i] + hw[j]) - abs(dx)       # x-overlap of boxes i,j
      oy <- (hh[i] + hh[j]) - abs(dy)       # y-overlap of boxes i,j
      if (ox > 0 && oy > 0) {               # intersect: separate on the shallower axis
        if (ox < oy) {
          s <- (if (dx >= 0) 1 else -1) * ox / 2
          px[i] <- px[i] - s; px[j] <- px[j] + s
        } else {
          s <- (if (dy >= 0) 1 else -1) * oy / 2
          py[i] <- py[i] - s; py[j] <- py[j] + s
        }
      }
    }
    px <- pmin(pmax(px, hw), 1 - hw)         # keep boxes inside the device
    py <- pmin(pmax(py, hh), 1 - hh)
  }
  data.frame(x = px, y = py)
}

## ---- figure 1: gallery of trees ----------------------------------------------
## original in the upper-left cell, then the SPR trees by descending distance,
## each captioned with its letter ID and its distance to the original.
pdf('out/figures/PPT_50_treeGallery.pdf', width = 8, height = 6)
n <- length(trs.plot)
gcol <- ceiling(sqrt(n))
grow <- ceiling(n / gcol)
galleryOrder <- c(1, ord)
op <- par(mfrow = c(grow, gcol), mar = c(1, 1, 2.5, 1), oma = c(0, 0, 2.5, 0))
for (idx in galleryOrder) {
    tree.col <- ifelse(idx == 1, "red", "blue")
    plot(trs.plot[[idx]], show.tip.label = FALSE, direction = "rightwards",
         edge.color = tree.col, edge.width = ifelse(idx == 1, 2, 1))
    if (idx == 1) {
        title(main = "Original", col.main = "red", font.main = 2, cex.main = 1.1)
    } else {
        title(main = paste0(treeLetters[idx], ":  d = ",
                            formatC(distToOrig[idx], format = "f", digits = 0)),
              col.main = "blue", font.main = 2, cex.main = 1.1)
    }
}
mtext("Trees by ascending Robinson-Foulds distance from the original",
      outer = TRUE, cex = 1, font = 2)
par(op)
dev.off()

## ---- figure 2: tree positions from MDS ---------------------------------------
pdf('out/figures/PPT_50_MDSpositions.pdf', width = 8, height = 6)
plot(trs.mds$V1, trs.mds$V2, type = "n",
     xlim = xlim, ylim = ylim,
     xlab = "MDS1", ylab = "MDS2",
     main = "Tree positions from MDS")
## SPR points first, then the original (red triangle) last, larger, so it sits on
## top and is the most visible point.
points(trs.mds$V1[others], trs.mds$V2[others],
       pch = 21, col = "blue", bg = "blue", cex = 2)
points(trs.mds$V1[1], trs.mds$V2[1],
       pch = 24, col = "red", bg = "red", cex = 2.8, lwd = 2)
title(sub = "Red filled triangle: original tree; blue filled circles: SPR trees", cex.sub = 0.8)

## thumbnail box sizes (inches -> NDC). the original is largest; all lettered
## (SPR) trees, A included, share one smaller size.
din       <- par("din")                     # device size in inches
isOrig    <- seq_along(trs) == 1
isLettered <- !isOrig                        # every SPR tree (A, B, C, ...)
wIn <- ifelse(isOrig, 1.35, 0.95)
hIn <- ifelse(isOrig, 1.05, 0.72)
wN  <- wIn / din[1]; hN <- hIn / din[2]

## dot positions in normalized device coordinates. MUST be read now, while the
## scatter's coordinate system is current, before any par(fig=) change.
dotx <- grconvertX(trs.mds$V1, from = "user", to = "ndc")
doty <- grconvertY(trs.mds$V2, from = "user", to = "ndc")

## push the thumbnails outward from the centre of the dot cloud so their spread is
## obvious and each leader arrow is long enough to read. `expand` scales each dot's
## offset from the centroid (1 = no push); the boxes are then settled around these
## exploded targets. Arrows still point back to the true dots.
expand <- 2.2
cxo <- mean(dotx); cyo <- mean(doty)
tgtx <- cxo + expand * (dotx - cxo)
tgty <- cyo + expand * (doty - cyo)
box  <- repelBoxes(tgtx, tgty, wN, hN)

old_par <- par(no.readonly = TRUE)

## 1) leader arrows box-edge -> dot, drawn first so the thumbnail covers the stub
##    inside its own box. Overlay spans the whole device, so user coords == NDC.
par(fig = c(0, 1, 0, 1), new = TRUE, mar = c(0, 0, 0, 0))
plot.new(); plot.window(xlim = c(0, 1), ylim = c(0, 1), xaxs = "i", yaxs = "i")
for (i in seq_along(trs)) {
    dirx <- dotx[i] - box$x[i]; diry <- doty[i] - box$y[i]
    tX <- if (dirx != 0) (wN[i] / 2) / abs(dirx) else Inf
    tY <- if (diry != 0) (hN[i] / 2) / abs(diry) else Inf
    tEdge <- min(tX, tY, 1)
    if (tEdge < 1) {                        # dot lies outside the box: draw a leader
        ex <- box$x[i] + tEdge * dirx; ey <- box$y[i] + tEdge * diry
        arrows(ex, ey, dotx[i], doty[i], length = 0.05, angle = 18,
               lwd = 0.8, col = "grey40")
    }
}

## 2) thumbnails at the settled box centres; original LAST so it sits on top. All
##    lettered (SPR) trees are drawn semi-transparent (alpha = 0.6) and smaller.
for (i in c(others, 1)) {
    par(fig = c(box$x[i] - wN[i] / 2, box$x[i] + wN[i] / 2,
                box$y[i] - hN[i] / 2, box$y[i] + hN[i] / 2),
        new = TRUE, mar = c(0, 0, 0, 0))
    base.col <- if (isOrig[i]) "red" else "blue"
    tree.col <- if (isLettered[i]) adjustcolor(base.col, alpha.f = 0.6) else base.col
    plot(trs.plot[[i]], show.tip.label = FALSE, direction = "rightwards",
         edge.color = tree.col, tip.color = tree.col,
         edge.width = if (isOrig[i]) 2 else 1, no.margin = TRUE)
}
par(old_par)

## 3) letter IDs right next to their dots (device coords == NDC), drawn last so
##    they sit on top of everything and identify which dot each thumbnail links to.
par(fig = c(0, 1, 0, 1), new = TRUE, mar = c(0, 0, 0, 0))
plot.new(); plot.window(xlim = c(0, 1), ylim = c(0, 1), xaxs = "i", yaxs = "i")
text(dotx, doty, labels = treeLetters, pos = 4, offset = 0.3,
     font = 2, cex = 0.9, col = ifelse(isOrig, "red", "black"))

dev.off()