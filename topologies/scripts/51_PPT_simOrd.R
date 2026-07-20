# simulated ordinations for ppt presentation
# ahipp@mortonarb.org, 2026-07-19
## edited by Claude Code in an interactive session with Andrew Hipp -- 2026-07-20 (~5% of characters changed)

library(ggplot2)
bootsRAD = 100 # number of radseq boots to show
bootsReseq = 5 # number of reseq boots to show
sdReseq = 0.05 # sd in the reseq distances
refShift.x = 1 # difference in mean (x) betw references
refShift.y = 1 # difference in mean (y) betw refs
plotdims <- c(7,7)

ax <- rnorm(bootsRAD)
ay <- rnorm(bootsRAD)
vx <- rnorm(bootsRAD, mean = refShift.x)
vy <- rnorm(bootsRAD, mean = refShift.y)

ax.ref <- rnorm(bootsReseq, sd = sdReseq)
ay.ref <- rnorm(bootsReseq, sd = sdReseq)
vx.ref <- rnorm(bootsReseq, mean = refShift.x, sd = sdReseq)
vy.ref <- rnorm(bootsReseq, mean = refShift.y, sd = sdReseq)
dat.sim <- data.frame(
    mds1 = c(ax, ax.ref, vx, vx.ref), 
    mds2 = c(ay, ay.ref, vy, vy.ref),
    reference = c(
        rep('alba', length(ax) + length(ax.ref)), 
        rep('variabilis', length(vx) + length(vx.ref))),
    Dataset = c(
        rep('RAD', length(ax)), 
        rep('reseq', length(ax.ref)), 
        rep('RAD', length(vx)), 
        rep('reseq', length(vx.ref))
        ) # close c
    ) # close data.frame

p = ggplot(dat.sim, aes(x = mds1, y = mds2, fill = reference, shape = Dataset, size = Dataset, alpha = Dataset))
p <- p + scale_shape_manual(values = c(RAD = 24, reseq = 21))
p <- p + scale_size_manual(values = c(RAD = 2.5, reseq = 5)) # reseq circles twice the RAD triangles
p <- p + scale_alpha_manual(values = c(RAD = 0.6, reseq = 1)) # RAD triangles semi-transparent
p <- p + geom_point()
p <- p + guides(fill = guide_legend(override.aes = list(shape = 21, size = 3)), size = "none", alpha = "none")
p <- p + theme(
    legend.background = element_rect(fill = NA, color = NA),
    legend.title = element_text(face = "bold"),
    legend.position = "inside",
    legend.position.inside = c(1, 0),        # Coordinates: x=1 (right), y=0 (bottom)
    legend.justification.inside = c(1, 0)     # Anchors the bottom-right of the legend box
  )
ggsave(
    filename='out/figures/PPT_simrad.out.pdf', plot = p, 
    width = plotdims[1], height = plotdims[2]
    )
