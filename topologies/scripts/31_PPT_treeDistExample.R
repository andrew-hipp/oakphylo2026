library(ape)
library(TreeDist)
library(ggplot2)

tr <- rtree(5)
trs <- c(
    tr, 
    rSPR(tr, 1, 2), 
    rSPR(tr, 2, 2), 
    rSPR(tr, 3, 2)
)

trs <- lapply(trs, multi2di)

trs.d <- ClusteringInfoDistance(trs)
trs.mds <- cmdscale(trs.d, 2) |> as.data.frame()

xrange <- range(trs.mds$V1)
yrange <- range(trs.mds$V2)
xpad <- 0.05 * diff(xrange)
ypad <- 0.05 * diff(yrange)
xlim <- xrange + c(-xpad, xpad)
ylim <- yrange + c(-ypad, ypad)
xnorm <- (trs.mds$V1 - xlim[1]) / diff(xlim)
ynorm <- (trs.mds$V2 - ylim[1]) / diff(ylim)

plot(trs.mds$V1, trs.mds$V2, type = "n",
     xlim = xlim, ylim = ylim,
     xlab = "MDS1", ylab = "MDS2",
     main = "Tree positions from MDS")
points(trs.mds$V1, trs.mds$V2, pch = 19, col = "blue")

old_par <- par(no.readonly = TRUE)
for (i in seq_along(trs)) {
    size <- 0.12
    fig <- c(xnorm[i] - size, xnorm[i] + size,
             ynorm[i] - size, ynorm[i] + size)
    fig[1] <- max(0, fig[1]); fig[2] <- min(1, fig[2])
    fig[3] <- max(0, fig[3]); fig[4] <- min(1, fig[4])
    par(fig = fig, new = TRUE, mar = c(0, 0, 0, 0))
    plot(trs[[i]], show.tip.label = FALSE, direction = "rightwards",
         no.margin = TRUE)
}
par(old_par)
