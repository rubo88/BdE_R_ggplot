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
- **`bde_bar_style_layers()`**: A macro that applies scales and legend formatting for bar charts in one line.
- **`bde_apply_labels()`**: A helper to effortlessly format the plot title (uppercase by default) and properly position the Y-axis label.
- **`bde_save_png()`**: Export your plot to precise, pre-defined organizational pixel dimensions.

## Available Background Modes
Most rendering functions and themes accept a `background` parameter:
* `"blue"` (Default traditional BDE Dark Blue)
* `"white"`
* `"transparent"`

## Fast Rendering Mode
Patterned bars (SVG hatched textures) can take seconds to render. If you are doing exploratory data analysis or adjusting layout and want instant feedback, set `render_mode = "fast"` in `bde_geom_col_pattern()`. This turns off textures and uses strictly solid colors.

## Examples

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
  bde_geom_col_pattern(layout = "stacked", render_mode = "quality") +
  geom_hline(yintercept = 0, color = "#7F7F7F", linewidth = 0.6)

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

### Example Usage: Line Charts

```r
library(ggplot2)
library(bdeplot)

bg_mode <- "white"
style_variant <- bde_style_variant(background = bg_mode)

p <- ggplot(df_long, aes(x = year, y = value, group = series)) +
  # Map standard aesthetics
  geom_line(aes(color = series, linetype = series), linewidth = 1.1) +
  geom_point(aes(color = series, shape = series), size = 2.8, na.rm = TRUE)

p <- p +
  theme_bde(background = bg_mode) +
  
  # Inject BDE specific styles
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
  title = "ECONOMIC INDICATORS",
  y_label = "Base 100 = 2000",
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
