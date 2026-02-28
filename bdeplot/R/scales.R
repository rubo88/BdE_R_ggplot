#' Built-in style definitions
#' @noRd
bde_bar_spec <- function(variant = c("default", "white")) {
    variant <- match.arg(variant)

    spec <- data.frame(
        slot = 1:8,
        fill = c(
            "#BFBFBF", # 1 gray
            "#7DB749", # 2 green
            "#FFF0D2", # 3 light beige
            "#FFC000", # 4 orange/yellow
            "#AECEF4", # 5 light blue
            "#D85A5A", # 6 red (new)
            "#CFC3EA", # 7 purple (new, swapped tones)
            "#5A3E29" # 8 brown (new, darker base)
        ),
        pattern = c(
            "stripe",
            "circle",
            "stripe",
            "wave",
            "stripe",
            "stripe",
            "crosshatch",
            "weave"
        ),
        pattern_fill = c(
            "#D9D9D9",
            "#FFFFFF",
            "#FFDB93",
            "#A85A00",
            "#1D5191",
            "#8D2F2F",
            "#9A88CC",
            "#A8835C"
        ),
        pattern_fill2 = c(
            "#D9D9D9",
            "#FFFFFF",
            "#FFDB93",
            "#A85A00",
            "#1D5191",
            "#8D2F2F",
            "#9A88CC",
            "#5A3E29"
        ),
        pattern_colour = c(
            "#D9D9D9",
            "#FFFFFF",
            "#FFDB93",
            "#A85A00",
            "#1D5191",
            "#8D2F2F",
            "#9A88CC",
            "#5A3E29"
        ),
        pattern_angle = c(0, 0, 45, 0, 90, 135, 0, 0),
        pattern_spacing = c(0.020, 0.04, 0.020, 0.020, 0.020, 0.020, 0.034, 0.05),
        pattern_density = c(0.50, 0.18, 0.50, 0.24, 0.50, 0.50, 0.24, 0.98),
        pattern_size = c(0.035, 0.01, 0.035, 0.045, 0.035, 0.035, 0.006, 0.001),
        pattern_type = c(
            NA_character_,
            NA_character_,
            NA_character_,
            "sine",
            NA_character_,
            NA_character_,
            NA_character_,
            "plain"
        ),
        pattern_frequency = c(0.10, 0.10, 0.10, 16.25, 0.10, 0.10, 0.10, 0.10),
        pattern_grid = c(
            "square",
            "hexagonal",
            "square",
            "square",
            "square",
            "square",
            "square",
            "square"
        ),
        stringsAsFactors = FALSE
    )

    # Reorder first five slots globally so blue and dark yellow are swapped
    # relative to the previous setup:
    # 1 gray, 2 green, 3 dark yellow, 4 blue, 5 light yellow.
    style_cols <- setdiff(names(spec), "slot")
    spec[1:8, style_cols] <- spec[c(1, 2, 4, 5, 3, 6, 7, 8), style_cols]

    if (variant == "white") {
        # White-mode first bar: dark horizontal hatch
        spec$fill[1] <- "#595959"
        spec$pattern_fill[1] <- "#030304"
        spec$pattern_fill2[1] <- "#030304"
        spec$pattern_colour[1] <- "#030304"
        spec$pattern[1] <- "stripe"
        spec$pattern_angle[1] <- 0
    }

    spec
}

#' Validate slot bounds
#' @noRd
bde_resolve_slot_order <- function(n_series, slot_order = NULL, max_slots = 8) {
    if (is.null(slot_order)) {
        return(seq_len(n_series))
    }

    slot_order <- as.integer(slot_order)
    if (length(slot_order) < n_series) {
        stop(sprintf("slot_order must contain at least %d entries.", n_series))
    }
    if (any(is.na(slot_order))) {
        stop("slot_order must be an integer vector without NA.")
    }
    if (any(slot_order < 1 | slot_order > max_slots)) {
        stop(sprintf("slot_order values must be between 1 and %d.", max_slots))
    }
    if (length(unique(slot_order)) != length(slot_order)) {
        stop("slot_order values must be unique.")
    }

    slot_order[seq_len(n_series)]
}

#' Extract mappings
#' @noRd
bde_bar_vectors <- function(
    series_levels,
    variant = c("default", "white"),
    slot_order = NULL) {
    variant <- match.arg(variant)
    series_levels <- as.character(series_levels)
    if (length(series_levels) < 1) stop("series_levels cannot be empty.")
    if (length(series_levels) > 8) stop("BDE style supports up to 8 bar series.")

    resolved_order <- bde_resolve_slot_order(
        n_series = length(series_levels),
        slot_order = slot_order,
        max_slots = 8
    )
    spec <- bde_bar_spec(variant = variant)[resolved_order, , drop = FALSE]

    list(
        fill = setNames(spec$fill, series_levels),
        pattern = setNames(spec$pattern, series_levels),
        pattern_fill = setNames(spec$pattern_fill, series_levels),
        pattern_fill2 = setNames(spec$pattern_fill2, series_levels),
        pattern_colour = setNames(spec$pattern_colour, series_levels),
        pattern_angle = setNames(spec$pattern_angle, series_levels),
        pattern_spacing = setNames(spec$pattern_spacing, series_levels),
        pattern_density = setNames(spec$pattern_density, series_levels),
        pattern_size = setNames(spec$pattern_size, series_levels),
        pattern_type = setNames(spec$pattern_type, series_levels),
        pattern_frequency = setNames(spec$pattern_frequency, series_levels),
        pattern_grid = setNames(spec$pattern_grid, series_levels)
    )
}

#' Configure color lines
#' @noRd
bde_line_spec <- function(variant = c("default", "white")) {
    variant <- match.arg(variant)

    spec <- data.frame(
        slot = 1:5,
        color = c("#FFFFFF", "#A0CB78", "#FFDB93", "#EF9011", "#AECEF4"),
        # 1 solid, 2 square-dot approximation, 3 round-dot, 4 solid, 5 solid
        linetype = c("solid", "22", "dotted", "solid", "solid"),
        # markers only where requested (line 4 triangle, line 5 square)
        shape = c(NA_real_, NA_real_, NA_real_, 17, 15),
        stringsAsFactors = FALSE
    )

    if (variant == "white") {
        # White-mode first line: black solid.
        spec$color[1] <- "#030304"
    }

    spec
}

#' Helper to extract vectors for lines
#' @noRd
bde_line_vectors <- function(series_levels, variant = c("default", "white")) {
    variant <- match.arg(variant)
    series_levels <- as.character(series_levels)
    if (length(series_levels) < 1) stop("series_levels cannot be empty.")
    if (length(series_levels) > 5) stop("BDE style supports up to 5 line series.")

    spec <- bde_line_spec(variant = variant)[seq_along(series_levels), , drop = FALSE]

    list(
        color = setNames(spec$color, series_levels),
        linetype = setNames(spec$linetype, series_levels),
        shape = setNames(spec$shape, series_levels)
    )
}

#' Generate fully formed pattern scales based on level input.
#'
#' @param series_levels The character levels.
#' @param variant "default" or "white".
#' @param slot_order Reorder indices default.
#' @export
bde_pattern_scales <- function(
    series_levels,
    variant = c("default", "white"),
    slot_order = NULL) {
    variant <- match.arg(variant)
    if (!requireNamespace("ggpattern", quietly = TRUE)) {
        stop("ggpattern is required for patterned bar scales.")
    }
    v <- bde_bar_vectors(series_levels, variant = variant, slot_order = slot_order)
    list(
        ggplot2::scale_fill_manual(values = v$fill, name = NULL),
        ggpattern::scale_pattern_manual(values = v$pattern),
        ggpattern::scale_pattern_fill_manual(values = v$pattern_fill),
        ggpattern::scale_pattern_fill2_manual(values = v$pattern_fill2),
        ggpattern::scale_pattern_colour_manual(values = v$pattern_colour),
        ggpattern::scale_pattern_angle_manual(values = v$pattern_angle),
        ggpattern::scale_pattern_spacing_manual(values = v$pattern_spacing),
        ggpattern::scale_pattern_density_manual(values = v$pattern_density),
        ggpattern::scale_pattern_size_manual(values = v$pattern_size),
        ggpattern::scale_pattern_type_manual(values = v$pattern_type),
        ggpattern::scale_pattern_frequency_manual(values = v$pattern_frequency),
        ggpattern::scale_pattern_grid_manual(values = v$pattern_grid)
    )
}

#' Generate line scales based on level input
#'
#' @param series_levels Values character vector
#' @param variant "default" or "white"
#' @export
bde_line_scales <- function(series_levels, variant = c("default", "white")) {
    variant <- match.arg(variant)
    v <- bde_line_vectors(series_levels, variant = variant)
    list(
        ggplot2::scale_color_manual(values = v$color, name = NULL),
        ggplot2::scale_linetype_manual(values = v$linetype, name = NULL),
        ggplot2::scale_shape_manual(values = v$shape, name = NULL)
    )
}

#' Hides the sub-pattern legend entries and wraps BDE guidelines
#'
#' @export
bde_bar_guides <- function(
    series_levels,
    nrow = 2,
    order = 1,
    variant = c("default", "white"),
    slot_order = NULL,
    mixed_legends = FALSE) {
    variant <- match.arg(variant)
    guides_args <- list(
        fill = bde_fill_guide(
            series_levels,
            nrow = nrow,
            order = order,
            variant = variant,
            slot_order = slot_order
        ),
        pattern = "none",
        pattern_fill = "none",
        pattern_fill2 = "none",
        pattern_colour = "none",
        pattern_angle = "none",
        pattern_spacing = "none",
        pattern_density = "none",
        pattern_size = "none",
        pattern_type = "none",
        pattern_frequency = "none",
        pattern_grid = "none"
    )

    # If mixed_legends is TRUE, we shouldn't force color/shape/linetype to "none".
    # Since ggplot2 defaults them to visible anyway when an aesthetic is mapped,
    # we don't need to explicitly add them here unless we know we need to suppress them.
    # We'll just pass the pattern-related drops to do.call.
    do.call(ggplot2::guides, guides_args)
}

#' Wraps up BDE Guides and Scales in a single function
#'
#' @export
bde_bar_style_layers <- function(
    series_levels,
    nrow = 2,
    order = 1,
    render_mode = c("quality", "balanced", "fast"),
    variant = c("default", "white"),
    slot_order = NULL,
    mixed_legends = FALSE) {
    render_mode <- match.arg(render_mode)
    variant <- match.arg(variant)

    if (render_mode == "fast") {
        v <- bde_bar_vectors(series_levels, variant = variant, slot_order = slot_order)
        solid_fill <- v$fill

        # In solid-color mode (no patterns), use the alternate tones for
        # purple (darker) and brown (lighter) to match requested appearance.
        if (length(solid_fill) >= 7) {
            solid_fill[[7]] <- v$pattern_fill[[7]]
        }
        if (length(solid_fill) >= 8) {
            solid_fill[[8]] <- v$pattern_fill[[8]]
        }

        return(list(
            ggplot2::scale_fill_manual(values = solid_fill, name = NULL),
            ggplot2::guides(fill = ggplot2::guide_legend(order = order, nrow = nrow))
        ))
    }

    c(
        bde_pattern_scales(series_levels, variant = variant, slot_order = slot_order),
        list(
            bde_bar_guides(
                series_levels,
                nrow = nrow,
                order = order,
                variant = variant,
                slot_order = slot_order,
                mixed_legends = mixed_legends
            )
        )
    )
}

#' Helper defining what the patterns inside the fill square look like.
#'
#' @export
bde_fill_guide <- function(
    series_levels,
    nrow = 2,
    order = 1,
    variant = c("default", "white"),
    slot_order = NULL) {
    variant <- match.arg(variant)
    v <- bde_bar_vectors(series_levels, variant = variant, slot_order = slot_order)

    legend_pattern_spacing <- v$pattern_spacing
    legend_pattern_density <- v$pattern_density
    legend_pattern_size <- v$pattern_size
    legend_pattern_frequency <- v$pattern_frequency
    legend_pattern_key_scale <- setNames(rep(1.25, length(series_levels)), series_levels)

    # Orange zig-zag (wave) in legend: less dense but still recognizable.
    z <- names(v$pattern)[v$pattern == "wave"]
    if (length(z) > 0) {
        legend_pattern_spacing[z] <- v$pattern_spacing[z] * 0.5
        legend_pattern_density[z] <- v$pattern_density[z] * 1
        legend_pattern_size[z] <- v$pattern_size[z] * 1
        legend_pattern_frequency[z] <- 0.03 / legend_pattern_spacing[z]
        legend_pattern_key_scale[z] <- 2.45
    }

    # Brown checkerboard (weave/plain) in legend: keep squares visible.
    b <- names(v$pattern)[v$pattern == "weave"]
    if (length(b) > 0) {
        legend_pattern_spacing[b] <- v$pattern_spacing[b] * 0.9
        legend_pattern_density[b] <- v$pattern_density[b] * 1.0
        legend_pattern_size[b] <- v$pattern_size[b] * 1.0
        legend_pattern_key_scale[b] <- 1.45
    }

    ggplot2::guide_legend(
        order = order,
        nrow = nrow,
        override.aes = list(
            pattern = unname(v$pattern),
            pattern_fill = unname(v$pattern_fill),
            pattern_fill2 = unname(v$pattern_fill2),
            pattern_colour = unname(v$pattern_colour),
            pattern_angle = unname(v$pattern_angle),
            pattern_spacing = unname(legend_pattern_spacing),
            pattern_density = unname(legend_pattern_density),
            pattern_size = unname(legend_pattern_size),
            pattern_type = unname(v$pattern_type),
            pattern_frequency = unname(legend_pattern_frequency),
            pattern_grid = unname(v$pattern_grid),
            fill = unname(v$fill),
            alpha = 1,
            pattern_key_scale_factor = unname(legend_pattern_key_scale)
        )
    )
}

#' Line legends guide
#'
#' @export
bde_line_guide <- function(series_levels, order = 1, variant = c("default", "white")) {
    variant <- match.arg(variant)
    v <- bde_line_vectors(series_levels, variant = variant)
    ggplot2::guide_legend(
        order = order,
        override.aes = list(
            linetype = unname(v$linetype),
            shape = unname(v$shape),
            colour = unname(v$color),
            linewidth = 1.1,
            size = 2.8,
            alpha = 1
        )
    )
}

#' Package shortcut scales
#' @export
scale_fill_bde <- function(variant = c("default", "white"), ...) {
    variant <- match.arg(variant)
    v <- bde_bar_vectors(paste0("s", 1:8), variant = variant)
    ggplot2::scale_fill_manual(values = unname(v$fill), ...)
}

#' Package shortcut scales
#' @export
scale_color_bde <- function(variant = c("default", "white"), ...) {
    variant <- match.arg(variant)
    v <- bde_line_vectors(paste0("s", 1:5), variant = variant)
    ggplot2::scale_color_manual(values = unname(v$color), ...)
}

#' Package shortcut scales
#' @export
scale_linetype_bde <- function(variant = c("default", "white"), ...) {
    variant <- match.arg(variant)
    v <- bde_line_vectors(paste0("s", 1:5), variant = variant)
    ggplot2::scale_linetype_manual(values = unname(v$linetype), ...)
}

#' Package shortcut scales
#' @export
scale_shape_bde <- function(variant = c("default", "white"), ...) {
    variant <- match.arg(variant)
    v <- bde_line_vectors(paste0("s", 1:5), variant = variant)
    ggplot2::scale_shape_manual(values = unname(v$shape), ...)
}
