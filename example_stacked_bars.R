#!/usr/bin/env Rscript

# Load necessary libraries
suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
})

# Load the custom bdeplot package
# (Assuming it's installed or being loaded via devtools for this script)
if (!requireNamespace("bdeplot", quietly = TRUE)) {
    # If not installed, load from the local source directory directly
    devtools::load_all("bdeplot")
} else {
    library(bdeplot)
}

# 1. Generate Fake Data
set.seed(42)
periods <- paste0(2020:2024, "Q", rep(1:4, 5))[1:18] # 18 quarters
series_levels <- c("Factor A", "Factor B", "Factor C", "Factor D")

# Create wide random data for the bars
df_wide <- data.frame(
    period = factor(periods, levels = periods),
    `Factor A` = runif(18, 0.5, 2.5),
    `Factor B` = runif(18, -1.0, 1.5),
    `Factor C` = runif(18, 0.2, 3.0),
    `Factor D` = runif(18, -2.0, 0.5),
    check.names = FALSE
)

# Convert to long format for ggplot2
df_long <- df_wide %>%
    pivot_longer(
        cols = all_of(series_levels),
        names_to = "series",
        values_to = "value"
    ) %>%
    mutate(series = factor(series, levels = series_levels))

# Create a trend line (e.g., net total + some random noise)
df_line <- df_wide %>%
    mutate(
        period = factor(period, levels = periods),
        net_total = rowSums(across(all_of(series_levels))) + rnorm(18, 0, 0.5)
    )

# 2. Build the Plot
# We'll use the 'blue' background variant of the BDE style
bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)
line_color <- bde_line_spec(variant = style_variant)$color[[1]] # Getting the first line color

# Create base plot with stacked patterned bars
p <- ggplot(df_long, aes(x = period, y = value)) +
    # bde_geom_col_pattern applies the correct width and patterns for stacked bars
    bde_geom_col_pattern(layout = "stacked", render_mode = "quality") +

    # Add the overlaid line
    geom_line(
        data = df_line,
        aes(x = period, y = net_total, group = 1),
        color = line_color,
        linewidth = 1.5,
        lineend = "round"
    ) +
    # Add points/markers to the line
    geom_point(
        data = df_line,
        aes(x = period, y = net_total),
        fill = line_color,
        color = "#000000",
        shape = 21,
        size = 4.2,
        stroke = 0.9
    ) +
    # Standard zero-line
    geom_hline(yintercept = 0, color = "#7F7F7F", linewidth = 0.6)

# 3. Apply the BDE Theme & Scales
p <- p +
    bde_theme(background = bg_mode) +
    # This single function adds the colors, patterns, and formats the legend!
    bde_bar_style_layers(
        series_levels = series_levels,
        variant = style_variant,
        nrow = 1 # Display legend in 1 row
    )

p <- bde_apply_labels(
    p,
    title = "EXAMPLE: STACKED BARS WITH TREND LINE",
    y_label = "Contributions (pp)",
    background = bg_mode
)

# 4. Save the Output
output_path <- "graphs_example/example_stacked_bars_line.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto",
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
