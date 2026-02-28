#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
})

if (!requireNamespace("bdeplot", quietly = TRUE)) {
    devtools::load_all("bdeplot", quiet = TRUE)
} else {
    library(bdeplot)
}

# 1. Generate Fake Data
set.seed(99)
categories <- c("Category 1", "Category 2", "Category 3")
series_levels <- c("Pre-Crisis", "Post-Crisis")

df_wide <- data.frame(
    category = factor(categories, levels = rev(categories)),
    `Pre-Crisis` = runif(3, 40, 80),
    `Post-Crisis` = runif(3, 20, 90),
    check.names = FALSE
)

df_long <- df_wide %>%
    pivot_longer(
        cols = all_of(series_levels),
        names_to = "series",
        values_to = "value"
    ) %>%
    mutate(series = factor(series, levels = series_levels))

# 2. Build the Plot (Horizontal Grouped Bars purely with aesthetics)
bg_mode <- "white"
style_variant <- bde_style_variant(background = bg_mode)

# For grouped bars we change the layout flag, and map y to the category natively
p <- ggplot(df_long, aes(y = category, x = value)) +
    bde_geom_col_pattern(layout = "grouped", render_mode = "quality") +
    # Add value labels directly on the bars
    geom_text(
        aes(label = round(value, 1), group = series),
        position = position_dodge2(width = 0.96, preserve = "single"),
        hjust = -0.2, # Shift slightly right
        size = 11,
        family = "Roboto",
        fontface = "bold",
        color = "#333333"
    ) +
    # Expand X limits slightly so labels don't clip off the right edge
    scale_x_continuous(expand = expansion(mult = c(0, 0.15)))

# 3. Apply the BDE Theme & Scales
p <- p +
    bde_theme(background = bg_mode) +
    bde_bar_style_layers(
        series_levels = series_levels,
        variant = style_variant,
        nrow = 1
    )

p <- bde_apply_labels(
    p,
    title = "HORIZONTAL GROUPED BARS",
    y_label = "Index Score",
    background = bg_mode,
    # Adjust y label anchor now that axes flipped natively
    y_hjust = 0,
    y_vjust = -1
)

# 4. Save the Output
output_path <- "../graphs_example/example_horizontal_grouped_bars.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto",
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
