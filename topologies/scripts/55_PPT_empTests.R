# what explains the variance in just the empirical data?

library(ggplot2)
library(grid)

cbbP2 <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

trees.dist.emp <- as.matrix(trees.dist)
empNames <- grep('empirical', dimnames(trees.dist.emp)[[1]], value = TRUE)
trees.dist.emp <- trees.dist.emp[empNames, empNames] |> dist()
trees.points.emp <- 
    cmdscale(trees.dist.emp, 2) |>
    as.data.frame()
names(trees.points.emp) <- c('mds1', 'mds2')
# plot(trees.points.emp)
trees.points.emp$reference <- strsplit(row.names(trees.points.emp), '[_.]') |>
    sapply(FUN = '[', 3)
trees.points.emp$reference[trees.points.emp$ref == 'novo'] <- 'denovo'
trees.points.emp$treeType <- 'ML'
trees.points.emp$treeType[grep('bt', row.names(trees.points.emp))] <- 'bootstrap' 
trees.points.emp <- trees.points.emp[!is.na(trees.points.emp$reference), ]
trees.points.emp <- trees.points.emp[rev(seq_len(nrow(trees.points.emp))), ]

trees.points.emp <- cbind(trees.points.emp, monophylyMat[row.names(trees.points.emp), ])

p.emp <- ggplot(trees.points.emp, aes(
    x = mds1, y = mds2, 
    fill = reference,
    size = treeType, 
    shape = treeType))
p.emp <- p.emp + 
    geom_point() + 
    scale_fill_manual(values = cbbP2) + 
    scale_shape_manual(values = c(bootstrap = 21, ML = 24)) +
    guides(fill = guide_legend(override.aes = list(
        shape = 21,      # Changes legend symbols to shape 21
        color = "black",  # Adds black border to legend symbols
        fill = cbbP2,
        size = 3)
        )
        )
# add loading vectors for just roburoids-albae and mac-bic
cols <- intersect(c('roburoids_albae', 'mac_bic'), names(trees.points.emp))
if(length(cols) > 0) {
    # compute loadings as coefficients from linear models of each variable on the MDS axes
    loadings <- t(sapply(cols, function(nm) {
        df <- trees.points.emp[, c('mds1','mds2', nm)]
        names(df)[3] <- 'var'
        fit <- lm(var ~ mds1 + mds2, data = df)
        coef(fit)[c('mds1','mds2')]
    }))
    colnames(loadings) <- c('x','y')
    # scale vectors to fit the ordination extent
    mds_range <- apply(trees.points.emp[, c('mds1','mds2')], 2, function(x) max(x, na.rm=TRUE) - min(x, na.rm=TRUE))
    scale_factor <- min(mds_range) * 0.6 / max(abs(loadings))
    make_label <- function(x) {
        x <- gsub('_', ' ', x)
        x <- gsub('([a-z])([A-Z])', '\\1 \\2', x)
        x <- gsub('\b([a-z])', '\\U\\1', x, perl = TRUE)
        x
    }
    vecs <- data.frame(label = make_label(cols), xend = loadings[, 'x'] * scale_factor, yend = loadings[, 'y'] * scale_factor)
    p.emp <- p.emp +
        geom_segment(data = vecs, aes(x = 0, y = 0, xend = xend, yend = yend),
                                 arrow = arrow(length = grid::unit(0.2, "cm")), colour = "black",
                                 linewidth = 1.1,
                                 inherit.aes = FALSE) +
        geom_text(data = vecs, aes(x = xend, y = yend, label = label), hjust = 0.5, vjust = -0.5, size = 3.2,
                  inherit.aes = FALSE)
}

print(p.emp)


