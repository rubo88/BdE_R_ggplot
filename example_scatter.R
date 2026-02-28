#!/usr/bin/env Rscript

# Load necessary libraries
suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
})

# Load the custom bdeplot package
if (!requireNamespace("bdeplot", quietly = TRUE)) {
    devtools::load_all("bdeplot", quiet = TRUE)
} else {
    library(bdeplot)
}

# 1. Generate Fake Scatter Data
set.seed(42)
series_levels <- c("Group A", "Group B")

df_scatter <- data.frame(
    x = c(rnorm(10, mean = 10, sd = 5), rnorm(10, mean = 30, sd = 5)),
    y = c(rnorm(10, mean = 50, sd = 15), rnorm(10, mean = 70, sd = 15)),
    series = rep(series_levels, each = 10)
) %>%
    mutate(series = factor(series, levels = series_levels))


# 2. Build the Plot
# We'll use the 'white' background variant for this specific presentation
bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)

p <- ggplot(df_scatter, aes(x = x, y = y, color = series)) +
    # Create the scatter plot using geom_point (using explicitly defined shapes)
    geom_point(aes(shape = series), size = 4, alpha = 0.8) +
    # Add an optional linear trendline for each group without confidence intervals
    geom_smooth(method = "lm", se = FALSE, linewidth = 1.2, linetype = "solid")

# 3. Apply the BDE Theme & Scales
p <- p +
    bde_theme(background = bg_mode) +
    # Apply the custom BDE line/point scales
    scale_color_bde(variant = style_variant) +
    # Map valid shapes since bde_scale_shape defaults to NA for the first 3 lines
    scale_shape_manual(values = c(16, 17), name = NULL) +
    # Use bde_line_guide to format the legend markers nicely
    guides(
        color = bde_line_guide(series_levels, variant = style_variant),
        shape = "none"
    )

# 4. Apply BDE labels and optional reference lines
p <- bde_apply_labels(
    p,
    title = "SCATTER PLOT: RELATIONSHIP BETWEEN X AND Y",
    y_label = "Y Values",
    x_label_right = "X Values",
    add_zero_line = FALSE,
    duplicate_y_axis = TRUE,
    background = bg_mode
)

# 5. Save the Output
output_path <- "graphs_example/example_scatter.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto",
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
