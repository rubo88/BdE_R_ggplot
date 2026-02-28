#' BDE Plot Theme
#'
#' @param base_family Font family, defaults to "Roboto"
#' @param background The plot background preset: "blue", "transparent", "white"
#' @param chart_bg Explicit background color override
#' @param axis_gray Explicit axis stroke color override
#' @param text_color Explicit text color override
#' @param axis_text_size Axis text font size
#' @param axis_title_size Axis title font size
#' @param legend_text_size Legend font size
#' @param title_size Plot title font size
#' @param ensure_roboto Logical to download/register missing Roboto
#' @param enable_showtext Logical to enable showtext auto loading
#' @export
bde_theme <- function(
    base_family = "Roboto",
    background = c("blue", "transparent", "white"),
    chart_bg = NULL,
    axis_gray = NULL,
    text_color = NULL,
    axis_text_size = 34,
    axis_title_size = 32,
    legend_text_size = 36,
    title_size = 42,
    ensure_roboto = TRUE,
    enable_showtext = TRUE) {
    background <- match.arg(background)
    if (is.null(chart_bg)) {
        chart_bg <- bde_background_color(background = background)
    }
    if (is.null(axis_gray)) {
        axis_gray <- "#7F7F7F"
    }
    if (is.null(text_color)) {
        text_color <- if (background == "white") "#000000" else "#FFFFFF"
    }
    if (tolower(base_family) == "roboto" && !ensure_roboto) {
        base_family <- "sans"
    } else if (ensure_roboto && tolower(base_family) == "roboto") {
        ok <- bde_ensure_roboto(enable_showtext = enable_showtext, quiet = TRUE)
        if (!ok) {
            warning("Roboto is not available; falling back to 'sans'.")
            base_family <- "sans"
        }
    }

    ggplot2::theme_minimal(base_family = base_family) +
        ggplot2::theme(
            plot.title.position = "plot",
            plot.background = ggplot2::element_rect(fill = chart_bg, colour = NA),
            panel.background = ggplot2::element_rect(fill = chart_bg, colour = NA),
            panel.grid.minor = ggplot2::element_blank(),
            panel.grid.major.x = ggplot2::element_blank(),
            panel.grid.major.y = ggplot2::element_line(color = axis_gray, linetype = "dashed", linewidth = 0.5),
            axis.line = ggplot2::element_line(color = text_color, linewidth = 0.6),
            axis.ticks = ggplot2::element_line(color = text_color, linewidth = 0.5),
            axis.text = ggplot2::element_text(color = text_color, size = axis_text_size),
            axis.text.x = ggplot2::element_text(
                angle = 0,
                vjust = 0.5,
                hjust = 0.5,
                margin = ggplot2::margin(t = 7)
            ),
            axis.title = ggplot2::element_text(color = text_color, size = axis_title_size),
            plot.title = ggplot2::element_text(
                color = text_color,
                face = "bold",
                family = base_family,
                size = title_size,
                hjust = 0.5,
                margin = ggplot2::margin(t = -18, b = 22)
            ),
            legend.position = "bottom",
            legend.title = ggplot2::element_blank(),
            legend.background = ggplot2::element_rect(fill = chart_bg, colour = NA),
            legend.key = ggplot2::element_rect(fill = chart_bg, colour = NA),
            legend.key.width = grid::unit(16, "mm"),
            legend.key.height = grid::unit(8, "mm"),
            legend.text = ggplot2::element_text(color = text_color, size = legend_text_size),
            legend.box = "horizontal",
            plot.margin = grid::unit(c(34, 12, 12, 20), "pt")
        )
}

#' Internal theme exported for users as theme_bde per convention
#'
#' @inherit bde_theme
#' @export
theme_bde <- bde_theme

#' Change Plot Orientation
#'
#' @param p A ggplot object.
#' @param horizontal Logical. If TRUE, apply coord_flip.
#' @param clip The clip parameter.
#' @export
bde_apply_bar_orientation <- function(p, horizontal = FALSE, clip = "on") {
    if (!inherits(p, "ggplot")) stop("p must be a ggplot object.")
    if (horizontal) {
        return(p + ggplot2::coord_flip(clip = clip))
    }
    p
}

#' Apply standard BDE labels
#'
#' Applies BDE title constraints and puts the ylabel correctly above the axis.
#' @param p A ggplot object.
#' @param title Title string.
#' @param y_label Y-Axis string.
#' @param uppercase_title Logical.
#' @param y_label_size Font size.
#' @param base_family Font family.
#' @param ensure_roboto Check for roboto.
#' @param background Chart background (determines label color).
#' @param text_color Explicit text color override.
#' @param y_hjust Adjust horizontal anchor.
#' @param y_vjust Adjust vertical anchor.
#' @param duplicate_y_axis Logical. If TRUE, adds a duplicated Y axis to the right.
#' @param x_label_right String. If provided, adds a right-aligned horizontal axis label for X.
#' @param add_zero_line Logical. If TRUE, adds a solid horizontal line at Y = 0.
#' @param add_100_line Logical. If TRUE, adds a solid horizontal line at Y = 100.
#' @param x_text_angle Numeric. Angle for X-axis tick labels (e.g. 0, 45, 90).
#' @export
bde_apply_labels <- function(
    p,
    title = NULL,
    y_label = NULL,
    uppercase_title = TRUE,
    y_label_size = 38,
    base_family = "Roboto",
    ensure_roboto = TRUE,
    background = c("blue", "transparent", "white"),
    text_color = NULL,
    y_hjust = -0.02,
    y_vjust = -0.55,
    duplicate_y_axis = FALSE,
    x_label_right = NULL,
    add_zero_line = FALSE,
    add_100_line = FALSE,
    x_text_angle = 0) {
    if (!inherits(p, "ggplot")) stop("p must be a ggplot object.")
    background <- match.arg(background)
    if (is.null(text_color)) {
        text_color <- if (background == "white") "#000000" else "#FFFFFF"
    }

    if (tolower(base_family) == "roboto" && !ensure_roboto) {
        base_family <- "sans"
    } else if (tolower(base_family) == "roboto" && !bde_ensure_roboto(enable_showtext = TRUE, quiet = TRUE)) {
        base_family <- "sans"
    }

    p <- p + ggplot2::labs(
        title = bde_format_title(title, uppercase = uppercase_title),
        x = NULL,
        y = NULL
    )

    if (!is.null(y_label) && nzchar(y_label)) {
        if (inherits(p$coordinates, "CoordFlip")) {
            p <- p + ggplot2::coord_flip(clip = "off")
        } else {
            p <- p + ggplot2::coord_cartesian(clip = "off")
        }
        p <- p +
            ggplot2::annotate(
                "text",
                x = -Inf,
                y = Inf,
                label = y_label,
                hjust = y_hjust,
                vjust = y_vjust,
                colour = text_color,
                family = base_family,
                size = y_label_size / ggplot2::.pt
            )
    }

    if (duplicate_y_axis && !inherits(p$coordinates, "CoordFlip")) {
        p <- p + ggplot2::scale_y_continuous(
            sec.axis = ggplot2::dup_axis(name = NULL)
        )
    }

    if (!is.null(x_label_right) && nzchar(x_label_right)) {
        p <- p +
            ggplot2::annotate(
                "text",
                x = Inf,
                y = -Inf,
                label = x_label_right,
                hjust = 1.05,
                vjust = 4.0,
                colour = text_color,
                family = base_family,
                size = y_label_size / ggplot2::.pt
            )
    }

    if (add_zero_line) {
        if (inherits(p$coordinates, "CoordFlip")) {
            p <- p + ggplot2::geom_vline(xintercept = 0, color = text_color, linewidth = 0.6)
        } else {
            p <- p + ggplot2::geom_hline(yintercept = 0, color = text_color, linewidth = 0.6)
        }
    }

    if (add_100_line) {
        if (inherits(p$coordinates, "CoordFlip")) {
            p <- p + ggplot2::geom_vline(xintercept = 100, color = text_color, linewidth = 0.6)
        } else {
            p <- p + ggplot2::geom_hline(yintercept = 100, color = text_color, linewidth = 0.6)
        }
    }

    if (!is.null(x_text_angle) && x_text_angle != 0) {
        if (x_text_angle == 45) {
            p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, vjust = 1))
        } else if (x_text_angle == 90 || x_text_angle == -90) {
            p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = x_text_angle, hjust = 1, vjust = 0.5))
        } else {
            p <- p + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = x_text_angle))
        }
    }

    p
}
