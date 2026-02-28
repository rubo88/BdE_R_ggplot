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
set.seed(42)
categories <- c("Country A", "Country B", "Country C", "Country D", "Country E")
series_levels <- c("Component 1", "Component 2", "Component 3")

df_wide <- data.frame(
    category = factor(categories, levels = rev(categories)), # Reverse for top-down
    `Component 1` = runif(5, 1, 5),
    `Component 2` = runif(5, 2, 6),
    `Component 3` = runif(5, -2, 3),
    check.names = FALSE
)

df_long <- df_wide %>%
    pivot_longer(
        cols = all_of(series_levels),
        names_to = "series",
        values_to = "value"
    ) %>%
    mutate(series = factor(series, levels = series_levels))

# Create a net total dot for each category
df_dot <- df_wide %>%
    mutate(
        category = factor(category, levels = levels(df_long$category)),
        net_total = rowSums(across(all_of(series_levels)))
    )

# 2. Build the Plot (Horizontal Stacked Bar + Dot purely with aesthetics)
bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)

# Use the 4th line color (usually orange/yellow in BDE) for the dot
dot_color <- bde_line_spec(variant = style_variant)$color[[4]]

p <- ggplot(df_long, aes(y = category, x = value)) +
    bde_geom_col_pattern(layout = "stacked", render_mode = "quality") +

    # Add the dot representing the net total
    geom_point(
        data = df_dot,
        aes(y = category, x = net_total),
        fill = dot_color,
        color = "#000000",
        shape = 21,
        size = 4.5,
        stroke = 1.0
    )

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
    title = "HORIZONTAL STACKED BARS WITH NET TOTAL",
    y_label = "Percentage (%)",
    background = bg_mode,
    y_hjust = 0,
    y_vjust = -1
)

# 4. Save the Output
output_path <- "graphs_example/example_horizontal_stacked_dots.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto",
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
