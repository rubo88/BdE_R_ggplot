#' Geom configurations for grouped and stacked bars
#' @param layout character, stacked or grouped
#' @param stacked_width width
#' @param stacked_reverse logical
#' @param grouped_width width
#' @param grouped_dodge_width width
#' @param grouped_padding padding
#' @noRd
bde_bar_geom <- function(
    layout = c("stacked", "grouped"),
    stacked_width = 0.72,
    stacked_reverse = TRUE,
    grouped_width = 0.70,
    grouped_dodge_width = 0.96,
    grouped_padding = 0.00) {
    layout <- match.arg(layout)

    if (layout == "stacked") {
        return(list(
            width = stacked_width,
            position = ggplot2::position_stack(reverse = stacked_reverse)
        ))
    }

    list(
        width = grouped_width,
        position = ggplot2::position_dodge2(
            width = grouped_dodge_width,
            preserve = "single",
            padding = grouped_padding
        )
    )
}

#' Automatic mapping for complex patterned bars
#' @param series_col The name of the column that guides coloring.
#' @noRd
bde_bar_pattern_aes <- function(series_col = "series") {
    if (!is.character(series_col) || length(series_col) != 1 || !nzchar(series_col)) {
        stop("series_col must be a non-empty string.")
    }

    s <- rlang::sym(series_col)
    ggplot2::aes(
        fill = !!s,
        group = !!s,
        pattern = !!s,
        pattern_fill = !!s,
        pattern_fill2 = !!s,
        pattern_colour = !!s,
        pattern_angle = !!s,
        pattern_spacing = !!s,
        pattern_density = !!s,
        pattern_size = !!s,
        pattern_type = !!s,
        pattern_frequency = !!s,
        pattern_grid = !!s
    )
}

#' BDE Patterned Bar layer
#'
#' @param series_col Explicit series guiding layer.
#' @param layout Stacked or grouped design.
#' @param stacked_reverse Default True.
#' @param render_mode Fast bypasses patterns completely. Balanced drops resolution.
#' @param pattern_res Resolution control.
#' @param pattern_filter Anti-alias filtering.
#' @param width Bar Width.
#' @param color Bar Stroke.
#' @param pattern_alpha Opacity.
#' @param ... Passed to geom_col_pattern.
#' @export
bde_geom_col_pattern <- function(
    series_col = "series",
    layout = c("stacked", "grouped"),
    stacked_reverse = TRUE,
    render_mode = c("quality", "balanced", "fast"),
    pattern_res = NULL,
    pattern_filter = NULL,
    width = NULL,
    color = NA,
    pattern_alpha = 1,
    ...) {
    layout <- match.arg(layout)
    render_mode <- match.arg(render_mode)
    geom <- bde_bar_geom(layout = layout, stacked_reverse = stacked_reverse)
    if (!is.null(width)) {
        geom$width <- width
    }

    # Fast mode: draw plain solid bars (no patterns) for much faster rendering.
    if (render_mode == "fast") {
        s <- rlang::sym(series_col)
        dots <- list(...)
        if (length(dots) > 0 && !is.null(names(dots))) {
            keep <- !(nzchar(names(dots)) & startsWith(names(dots), "pattern_"))
            dots <- dots[keep]
        }

        layer_args <- c(
            list(
                mapping = ggplot2::aes(fill = !!s, group = !!s),
                width = geom$width,
                position = geom$position,
                color = color,
                alpha = pattern_alpha
            ),
            dots
        )
        return(do.call(ggplot2::geom_col, layer_args))
    }

    if (!requireNamespace("ggpattern", quietly = TRUE)) {
        stop("ggpattern is required for patterned bar geoms.")
    }

    # Rendering speed controls for heavy patterned bars.
    if (render_mode == "balanced" && is.null(pattern_res)) {
        pattern_res <- 54
    } else if (render_mode == "fast" && is.null(pattern_res)) {
        pattern_res <- 36
    }
    if (render_mode != "quality" && is.null(pattern_filter)) {
        pattern_filter <- "box"
    }

    layer_args <- list(
        mapping = bde_bar_pattern_aes(series_col = series_col),
        width = geom$width,
        position = geom$position,
        color = color,
        pattern_alpha = pattern_alpha,
        ...
    )
    if (!is.null(pattern_res)) layer_args$pattern_res <- pattern_res
    if (!is.null(pattern_filter)) layer_args$pattern_filter <- pattern_filter

    do.call(ggpattern::geom_col_pattern, layer_args)
}
