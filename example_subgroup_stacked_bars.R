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
# We want 4 hierarchical groups (Countries).
# Inside each country, there are 2 subgroups (e.g. Years like 2023 vs 2024).
# And within each subgroup, the bar is stacked by 4 categories (Sectors).
countries <- c("Spain", "Portugal", "France", "Italy")
years <- c("2023", "2024")
sectors <- c("Services", "Industry", "Agriculture", "Construction")

# Create combinations
df_stacked_grouped <- expand.grid(
    series = sectors,
    year = years,
    country = countries
) %>%
    mutate(
        value = runif(n(), 10, 50),
        country = factor(country, levels = countries),
        year = factor(year, levels = years),
        series = factor(series, levels = sectors)
    )

bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)

# 2. Build the Plot
# To achieve hierarchical 'grouped stacked bars', we map X to the inner subgroup (Year),
# fill to the stack category (Sector), and use facet_grid to group by the outer category (Country).
p <- ggplot(df_stacked_grouped, aes(x = year, y = value, fill = series)) +
    # Draw standard stacked bars
    bde_geom_col_pattern(
        layout = "stacked",
        render_mode = "quality"
    ) +
    # Group them horizontally by country, creating the hierarchical X-axis look.
    # space="free_x" and scales="free_x" ensures the bars take up proportional space
    # and dropping the y-axis keeps them unified.
    facet_grid(~country, switch = "x", scales = "free_x", space = "free_x")

# 3. Apply the BDE Theme & Scales
p <- p +
    bde_theme(background = bg_mode) +
    # We remove the facet background strips so it looks like a clean hierarchical axis
    theme(
        strip.background = element_blank(),
        strip.placement = "outside",
        # Match the country text size to standard BDE axis text sizes (making it slightly larger than year texts)
        strip.text.x = element_text(size = 38, color = ifelse(bg_mode == "blue", "#FFFFFF", "#595959"), margin = margin(t = 10, b = 10)),
        # Reduce spacing between facets to 0 to make them look like grouped bars sharing one Y-axis
        panel.spacing = unit(0, "lines")
    ) +
    # Apply bar scales and legends (pattern formatting) using the 'sector' levels
    bde_bar_style_layers(
        series_levels = sectors,
        variant = style_variant,
        nrow = 1 # Keep the legend in one neat row
    )

# 4. Attach standard BDE headers and labels
p <- bde_apply_labels(
    p,
    title = "GDP COMPOSITION BY COUNTRY & YEAR",
    y_label = "", # Set empty so annotate doesn't duplicate across facets
    add_zero_line = TRUE,
    # Here we show off the new rotation feature for the country labels just in case they are long!
    x_text_angle = 0, # They are short enough here, but you can change it to 45
    background = bg_mode
)

# Manually add the Y-axis label to the first facet only (Spain) to prevent repeating
p <- p +
    coord_cartesian(clip = "off") +
    geom_text(
        data = data.frame(country = factor("Spain", levels = countries)),
        x = -Inf, y = Inf,
        label = "Billions (€)",
        hjust = -0.02, vjust = -0.55,
        colour = ifelse(bg_mode == "white", "#000000", "#FFFFFF"),
        family = "Roboto",
        size = 38 / ggplot2::.pt,
        inherit.aes = FALSE
    )

# 5. Save the Output
output_path <- "graphs_example/example_subgroup_stacked_bars.png"
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

bde_save_png(
    plot = p,
    filename = output_path,
    size_preset = "grafico_y_texto", # 120mm by 88mm ratio
    background = bg_mode
)

message("Successfully generated example chart at: ", output_path)
