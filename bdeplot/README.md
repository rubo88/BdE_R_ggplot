# bdeplot: Banco de España Style Plots for ggplot2

The `bdeplot` package provides custom `ggplot2` themes, geoms, and scales to easily create charts that align with the Banco de España (BDE) style guide. It supports grouped/stacked bars with sophisticated texture patterns (via `ggpattern`) and clean line charts, correctly applying BDE colors, lines, and shapes.

## Installation

Since this package is internal, you can install it directly from the local directory or a shared network drive using `devtools`:

```r
# Install from the local folder
# Make sure to point to the directory containing the 'bdeplot' folder
devtools::install("path/to/bdeplot")

# Or load directly without installing (good for development)
devtools::load_all("path/to/bdeplot")
```

Dependencies like `ggplot2`, `ggpattern`, `sysfonts`, and `showtext` will be installed automatically if you use `devtools::install()`.

## Core Features

- **`theme_bde()`**: A clean, minimal `ggplot2` theme with the correct gridlines, axis colors, legend spacing, and automatic `Roboto` font registration.
- **`bde_geom_col_pattern()`**: A drop-in replacement for BDE bar charts. Automatically maps the correct textures and fill colors (supports up to 8 bar categories).
- **`scale_color_bde()`, `scale_fill_bde()`, etc.**: Standard `ggplot2` scale wrappers to apply the BDE color palettes to continuous or discrete categories.
- **`bde_bar_style_layers()`**: A macro that applies scales and legend formatting for bar charts in one line. Contains an optional `mixed_legends = TRUE` flag if overlaying lines or points that also need legends.
- **`bde_apply_labels()`**: A helper to effortlessly format the plot title (uppercase by default) and properly position the Y-axis label.
- **`bde_save_png()`**: Export your plot to precise, pre-defined organizational pixel dimensions.

## Available Background Modes
Most rendering functions and themes accept a `background` parameter:
* `"blue"` (Default traditional BDE Dark Blue)
* `"white"`
* `"transparent"`

## Fast Rendering Mode
Patterned bars (SVG hatched textures) can take seconds to render. If you are doing exploratory data analysis or adjusting layout and want instant feedback, set `render_mode = "fast"` in `bde_geom_col_pattern()`. This turns off textures and uses strictly solid colors.

## Configuration Options

### 1. Plot Dimensions (`bde_save_png`)
The `bde_save_png()` function supports precise predefined pixel layouts aligned with BDE organizational documents. You can select the correct size by passing the `size_preset` argument:
* `"dos_graficos_y_texto_1"` (1430 x 1622)
* `"dos_graficos_y_textoinferior_1"` (2025 x 1370)
* `"grafico_y_texto"` (3322 x 1640)
* `"grafico_y_texto_inferior"` (4092 x 1237)
* `"layuout_imagen"` (4092 x 1773)
* `"texto_e_imagen"` (1805 x 1773)
* `"tres_graficos_y_textoinferior_1"` (1306 x 1145)

You optionally can provide custom absolute dimensions by providing `width_px` and `height_px` instead.

### 2. Choosing Pattern / Color Order (`slot_order`)
By default, standard BDE aesthetics apply to up to 8 chart series in a strict order:
1: Gray, 2: Green, 3: Dark Yellow, 4: Orange/Yellow, 5: Light Blue, 6: Red, 7: Purple, 8: Brown. 

If your data contains only 3 series but you want them to map to colors 1, 4, and 6 exactly, use the `slot_order` argument when initializing the styling layers:

```r
p <- p + theme_bde(background = bg_mode) +
  bde_bar_style_layers(
    series_levels = unique(df_long$series),
    variant = style_variant,
    slot_order = c(1, 4, 6) # Selects Gray, Orange, and Red
  )
```

### 3. Axis Configuration Extras (`bde_apply_labels`)
Sometimes you need to label the X-axis when it's not simply categorical, or you want the horizontal gridlines to be easier to track across a wide chart. You can configure this during the label application phase:

```r
p <- bde_apply_labels(
    p,
    title = "MY BDE CHART",
    y_label = "Index Score",
    duplicate_y_axis = TRUE, # Duplicates the Y-axis onto the right side
    x_label_right = "Years", # Adds a horizontal label to the far-right of the X-axis
    add_zero_line = TRUE,    # Adds a solid white horizontal line at Y = 0
    add_100_line = TRUE,     # Adds a solid white horizontal line at Y = 100
    x_text_angle = 45,       # Rotates the X-axis tick labels to 45 degrees
    background = bg_mode
)
```

## Examples

### Example Usage: Scatter Plot

```r
library(ggplot2)
library(bdeplot)

bg_mode <- "white"
style_variant <- bde_style_variant(background = bg_mode)

p <- ggplot(df_scatter, aes(x = x, y = y, color = series)) +
    # Create the scatter plot using geom_point
    geom_point(aes(shape = series), size = 4, alpha = 0.8) +
    # Add an optional linear trendline safely
    geom_smooth(method = "lm", se = FALSE, linewidth = 1.2, linetype = "solid")

p <- p +
    bde_theme(background = bg_mode) +
    # Apply standard BDE line colors
    scale_color_bde(variant = style_variant) +
    # Because BDE line guides only have shapes for series 4 and 5 by default,
    # supply standard solid shapes manually for standard scatter plots
    scale_shape_manual(values = c(16, 17, 15), name = NULL) +
    guides(
        color = bde_line_guide(series_levels, variant = style_variant),
        shape = "none"
    )

p <- bde_apply_labels(
    p,
    title = "SCATTER PLOT: RELATIONSHIP BETWEEN X AND Y",
    y_label = "Y Values",
    x_label_right = "X Values",
    add_zero_line = FALSE,
    background = bg_mode
)
```

### Example Usage: Stacked Pattern Bars

```r
library(ggplot2)
library(bdeplot)

# 1. Start with your data
# df_long must have a categorical 'series' variable for the fill/pattern mapping.
# 'series' should ideally be a factor to enforce legend order.

bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)

# 2. Build the basic plot using bde_geom_col_pattern
p <- ggplot(df_long, aes(x = period, y = value)) +
  bde_geom_col_pattern(layout = "stacked", render_mode = "quality")

# 3. Apply the BDE Theme & Scales
p <- p +
  theme_bde(background = bg_mode) +
  bde_bar_style_layers(
    series_levels = unique(df_long$series),
    variant = style_variant,
    nrow = 1 # Force legend into 1 row
  )

# 4. Attach standard BDE headers and labels
p <- bde_apply_labels(
    p,
    title = "MY STACKED BAR CHART",
    y_label = "Contributions (pp)",
    add_zero_line = TRUE,
    background = bg_mode
)

# 5. Save accurately
bde_save_png(
    plot = p,
    filename = "output.png",
    size_preset = "grafico_y_texto",
    background = bg_mode
)
```

### Example Usage: Hierarchical Grouped Stacked Bars

If you want a hierarchical X-axis where independent stacked columns are grouped by a higher-level category (e.g., comparing 2023 vs 2024 GDP composition for 4 different countries), you map the `x` aesthetic to the inner subgroup and use `facet_grid` for the outer category:

```r
countries <- c("Spain", "Portugal", "France", "Italy")
years <- c("2023", "2024")
sectors <- c("Services", "Industry", "Agriculture", "Construction")

# The dataframe must contain the inner group (year), outer group (country), and fill group (series)
p <- ggplot(df_stacked_grouped, aes(x = year, y = value, fill = series)) +
    # Draw standard stacked bars
    bde_geom_col_pattern(layout = "stacked", render_mode = "quality") +
    # Group them horizontally by country, creating the hierarchical X-axis look
    # space="free_x" and scales="free_x" ensures bars take up proportional space and unified Y-axis
    facet_grid(~country, switch = "x", scales = "free_x", space = "free_x")

p <- p +
    bde_theme(background = bg_mode) +
    # Remove the facet strips background to make them look like a clean hierarchical axis
    theme(
        strip.background = element_blank(),
        # Match the country text size to standard BDE axis text sizes
        strip.text.x = element_text(size = 38, color = ifelse(bg_mode == "blue", "#FFFFFF", "#595959"), margin = margin(t = 10, b = 10)),
        panel.spacing = unit(0, "lines")
    ) +
    bde_bar_style_layers(
        series_levels = sectors,
        variant = style_variant,
        nrow = 1
    )

p <- bde_apply_labels(
    p,
    title = "GDP COMPOSITION BY COUNTRY & YEAR",
    y_label = "", # Set empty so annotate doesn't duplicate across facets
    add_zero_line = TRUE,
    background = bg_mode
)

# Manually add the Y-axis label to the first facet only (e.g. "Spain") to prevent repeating
p <- p + 
    coord_cartesian(clip = "off") +
    geom_text(
        data = data.frame(country = factor("Spain", levels = countries)),
        x = -Inf, y = Inf,
        label = "Billions (€)",
        hjust = -0.02, vjust = -0.55,
        colour = ifelse(bg_mode == "white", "#000000", "#FFFFFF"),
        family = "Roboto",
        size = 38 / 2.8346, # Convert ggplot2 pts
        inherit.aes = FALSE
    )
```

### Example Usage: Grouped Vertical Bars with a Line Overlay

When overlaying a line chart onto categorical grouped bars, you must map the line's `x` to a continuous variable representation of the underlying factor:

```r
bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)
line_color <- bde_line_spec(variant = style_variant)$color[[4]]

# Bars scale is categorical factor(year)
p <- ggplot(df_long_bars, aes(x = factor(year), y = value)) +
    # Grouped bars
    bde_geom_col_pattern(layout = "grouped", render_mode = "quality") +

    # Overlaid line (must use the same x-axis scale; map to numeric x group=1)
    geom_line(
        data = df_line %>% mutate(x_num = as.numeric(factor(year))),
        aes(x = x_num, y = margin, group = 1),
        color = line_color,
        linewidth = 1.5,
        inherit.aes = FALSE
    ) +
    # Points for the line
    geom_point(
        data = df_line %>% mutate(x_num = as.numeric(factor(year))),
        aes(x = x_num, y = margin),
        fill = line_color,
        color = "#000000",
        shape = 21,
        size = 4.2,
        inherit.aes = FALSE
    )

p <- p + bde_theme(background = bg_mode) +
    bde_bar_style_layers(bar_series_levels, variant = style_variant, nrow = 1)
```

### Example Usage: Line Charts

```r
library(ggplot2)
library(bdeplot)

bg_mode <- "blue"
style_variant <- bde_style_variant(background = bg_mode)

p <- ggplot(df_long, aes(x = year, y = value, group = series)) +
  # Map standard aesthetics
  geom_line(aes(color = series, linetype = series), linewidth = 1.1) +
  geom_point(aes(color = series, shape = series), size = 2.8, na.rm = TRUE)

p <- p +
  theme_bde(background = bg_mode) +
  # Inject BDE specific line styles
  scale_color_bde(variant = style_variant) +
  scale_linetype_bde(variant = style_variant) +
  scale_shape_bde(variant = style_variant) +
  # Format the legend for lines
  guides(
    color = bde_line_guide(series_levels = unique(df_long$series), variant = style_variant),
    linetype = "none",
    shape = "none"
  )

p <- bde_apply_labels(
  p,
  title = "ECONOMIC INDICATORS PROJECTIONS (2000-2020)",
  y_label = "Base 100 = 2000",
  duplicate_y_axis = TRUE, # Duplicates the Y-axis onto the right side
  x_label_right = "Years", # Adds a horizontal label to the far-right of the X-axis
  add_100_line = TRUE,     # Adds a solid white horizontal line at Y = 100
  background = bg_mode
)
```

### Example Usage: Horizontal Bars

`ggplot2` natively supports horizontal orientation by simply mapping the categorical variable to the `y` aesthetic instead of the `x` axis!

```r
p <- ggplot(df_long, aes(y = category, x = value)) +
  
  # For grouped bars, change the layout natively
  bde_geom_col_pattern(layout = "grouped", render_mode = "quality") +
  
  # Add value labels directly next to the bars
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

p <- p + 
  theme_bde(background = bg_mode) +
  bde_bar_style_layers(
    series_levels = series_levels,
    variant = style_variant,
    nrow = 1 
  ) 

# Be sure to attach the ylabel to the TOP of the graph still!
p <- bde_apply_labels(
  p,
  title = "HORIZONTAL GROUPED BARS",
  y_label = "Index Score",
  background = bg_mode,
  # Adjust the label anchor explicitly so it rests over the new Y axis
  y_hjust = 0,
  y_vjust = -1
)
```

### Example Usage: Horizontal Stacked Bars with a Dot Overlay

Use a dot (e.g. `shape = 21`) to represent the net total of stacked bars.

```r
# Get the 4th line color (Orange/Yellow in BDE)
dot_color <- bde_line_spec(variant = style_variant)$color[[4]]

p <- ggplot(df_long, aes(y = category, x = value)) +
    # Render stacked horizontal bars
    bde_geom_col_pattern(layout = "stacked", render_mode = "quality") +
    # Add a dot for the net total column (df_dot)
    geom_point(
        data = df_dot, 
        aes(y = category, x = net_total),
        fill = dot_color, color = "#000000", shape = 21, size = 4.5, stroke = 1.0
    )

p <- p +
    bde_theme(background = bg_mode) +
    bde_bar_style_layers(series_levels = series_levels, variant = style_variant, nrow = 1)

p <- bde_apply_labels(
    p,
    title = "HORIZONTAL STACKED BARS WITH NET TOTAL",
    y_label = "Percentage (%)",
    background = bg_mode,
    y_hjust = 0,
    y_vjust = -1
)
```
