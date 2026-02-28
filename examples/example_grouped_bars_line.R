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
years <- 2018:2023
bar_series_levels <- c("Domestic Sales", "Export Sales")

# Create wide random data
df_wide <- data.frame(
    year = years,
    `Domestic Sales` = runif(length(years), 50, 120),
    `Export Sales` = runif(length(years), 30, 90),
    check.names = FALSE
)

# Convert bars to long format
df_long_bars <- df_wide %>%
    pivot_longer(
        cols = all_of(bar_series_levels),
        names_to = "series",
        values_to = "value"
    ) %>%
    mutate(series = factor(series, levels = bar_series_levels))

# Create data for the line overlay (e.g., Total Profit Margin)
df_line <- data.frame(
    year = years,
    margin = runif(length(years), 10, 25),
    line_series = factor("Profit Margin", levels = c("Profit Margin"))
)

# 2. Build the Plot
bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)
line_color <- bde_line_spec(variant = style_variant)$color[[4]] # Orange/Yellow line

# Note: For combined bar and line plots with different scales, you often use a secondary axis.
# Here we scale the line data to fit the primary y-axis conceptually, or simply plot it if it's in a similar range.
# We will just plot it directly since values (10-25) are visible against the bars (30-120).

p <- ggplot(df_long_bars, aes(x = factor(year), y = value)) +
    # Grouped bars
    bde_geom_col_pattern(layout = "grouped", render_mode = "quality") +

    # Overlaid line (must use the same x-axis scale; since bars use discrete factor(year),
    # the line must map to numeric x using as.numeric(factor(year)) group=1)
    geom_line(
        data = df_line %>% mutate(x_num = as.numeric(factor(year))),
        aes(x = x_num, y = margin, group = 1, color = line_series, linetype = line_series),
        linewidth = 1.5,
        lineend = "round",
        inherit.aes = FALSE
    ) +
    # Points for the line
    geom_point(
        data = df_line %>% mutate(x_num = as.numeric(factor(year))),
        aes(x = x_num, y = margin, color = line_series, shape = line_series),
        fill = line_color,
        size = 4.2,
        stroke = 0.9,
        inherit.aes = FALSE
    )

# 3. Apply the BDE Theme & Scales
p <- p +
    bde_theme(background = bg_mode) +
    # Apply bar scales and legends
    bde_bar_style_layers(
        series_levels = bar_series_levels,
        variant = style_variant,
        nrow = 1,
        mixed_legends = TRUE # <--- Place this here inside the bar config!
    ) +
    # Explicitly map the line styling scales
    scale_color_manual(values = setNames(line_color, "Profit Margin")) +
    scale_linetype_manual(values = setNames("solid", "Profit Margin")) +
    scale_shape_manual(values = setNames(21, "Profit Margin")) +
    guides(
        color = guide_legend(order = 2, title = NULL),
        shape = guide_legend(order = 2, title = NULL),
        linetype = guide_legend(order = 2, title = NULL)
    )

p <- bde_apply_labels(
    p,
    title = "SALES BREAKDOWN AND MARGIN TREND",
    y_label = "Millions (€) / Margin (%)",
    add_zero_line = TRUE,
    x_text_angle = 45,
    background = bg_mode
)

# 4. Save the Output
output_path <- "../graphs_example/example_grouped_bars_line.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto",
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
