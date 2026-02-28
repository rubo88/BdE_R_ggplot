#!/usr/bin/env Rscript

# Load necessary libraries
suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
})

# Load the custom bdeplot package
if (!requireNamespace("bdeplot", quietly = TRUE)) {
    devtools::load_all("bdeplot", quiet = TRUE)
} else {
    library(bdeplot)
}

# 1. Generate Fake Data
set.seed(123)
years <- 2000:2020
series_levels <- c("Macroeconomic Index", "Growth Rate", "Inflation (Core)", "Unemployment Drift")

df_wide <- data.frame(
    year = years,
    `Macroeconomic Index` = cumsum(rnorm(length(years), 2, 1.5)) + 100,
    `Growth Rate` = cumsum(rnorm(length(years), 1, 2.0)) + 90,
    `Inflation (Core)` = cumsum(rnorm(length(years), 0.5, 1.2)) + 95,
    `Unemployment Drift` = cumsum(rnorm(length(years), -1, 1.8)) + 110,
    check.names = FALSE
)

# Convert to long format for ggplot
df_long <- df_wide %>%
    pivot_longer(
        cols = all_of(series_levels),
        names_to = "series",
        values_to = "value"
    ) %>%
    mutate(series = factor(series, levels = series_levels))


# 2. Build the Plot
# We'll use the 'white' background variant for this specific presentation
bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)

p <- ggplot(df_long, aes(x = year, y = value, group = series)) +
    # Standard line configuration using mapped aesthetics
    geom_line(aes(color = series, linetype = series), linewidth = 1.1) +
    # BDE lines typically have markers for the last two entries if needed,
    # or you can just add points for all lines relying on the BDE shape scales.
    geom_point(aes(color = series, shape = series), size = 2.8, na.rm = TRUE)

# 3. Apply the BDE Theme & Scales
p <- p +
    bde_theme(background = bg_mode) +
    # Apply the custom BDE line scales individually
    # (this could also be wrapped in a single helper in the future)
    scale_color_bde(variant = style_variant) +
    scale_linetype_bde(variant = style_variant) +
    scale_shape_bde(variant = style_variant) +
    # Standard legend formatting for lines
    guides(
        color = bde_line_guide(series_levels, variant = style_variant),
        linetype = "none",
        shape = "none"
    )

p <- bde_apply_labels(
    p,
    title = "ECONOMIC INDICATORS PROJECTIONS (2000-2020)",
    y_label = "Base 100 = 2000",
    duplicate_y_axis = TRUE, # Duplicates the Y-axis onto the right side
    x_label_right = "Years", # Adds a horizontal label to the far-right of the X-axis
    add_100_line = TRUE, # Adds a solid white horizontal line at Y = 100
    background = bg_mode
)

# 4. Save the Output
output_path <- "../graphs_example/example_4_lines.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto",
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
