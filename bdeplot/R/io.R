#' Read PNG Dimensions
#' @param path Path to image
#' @export
bde_png_dimensions <- function(path) {
    if (!file.exists(path)) stop(sprintf("File does not exist: %s", path))

    con <- file(path, open = "rb")
    on.exit(close(con), add = TRUE)

    sig <- readBin(con, what = "raw", n = 8, size = 1)
    png_sig <- as.raw(c(137, 80, 78, 71, 13, 10, 26, 10))
    if (length(sig) != 8 || any(sig != png_sig)) {
        stop(sprintf("File is not a valid PNG: %s", path))
    }

    ihdr_len <- readBin(con, what = "integer", n = 1, size = 4, endian = "big")
    ihdr_type <- rawToChar(readBin(con, what = "raw", n = 4, size = 1))
    if (ihdr_len != 13 || ihdr_type != "IHDR") {
        stop(sprintf("PNG header is invalid (IHDR missing): %s", path))
    }

    width <- readBin(con, what = "integer", n = 1, size = 4, endian = "big")
    height <- readBin(con, what = "integer", n = 1, size = 4, endian = "big")

    c(width = as.numeric(width), height = as.numeric(height))
}


#' Package internal helper to save BDE plots.
#'
#' @param plot ggplot instance
#' @param filename String name.
#' @param size_preset Default `NULL`. Fallbacks to manual dimension injection.
#' @param figures_dir Defunct.
#' @param width_px Custom width
#' @param height_px Custom Height
#' @param output_format Auto resolves to png or pdf based on end pattern.
#' @param dpi DPI.
#' @param background Target color space.
#' @param bg Exact Hex Target.
#' @param scale Size Factor.
#' @param device Target R device mapped.
#' @export
bde_save_png <- function(
    plot,
    filename,
    size_preset = NULL,
    figures_dir = NULL,
    width_px = NULL,
    height_px = NULL,
    output_format = c("auto", "png", "pdf"),
    dpi = 300,
    background = c("blue", "transparent", "white"),
    bg = NULL,
    scale = 1,
    device = NULL) {
    if (!inherits(plot, "ggplot")) stop("plot must be a ggplot object.")
    output_format <- match.arg(output_format)
    if (output_format == "auto") {
        ext <- tolower(tools::file_ext(filename))
        output_format <- if (ext %in% c("png", "pdf")) ext else "png"
    }

    background <- match.arg(background)
    if (is.null(bg)) {
        bg <- bde_background_color(background = background)
    }

    use_custom_size <- !is.null(width_px) || !is.null(height_px)
    if (use_custom_size) {
        if (is.null(width_px) || is.null(height_px)) {
            stop("Provide both width_px and height_px for custom size.")
        }
        width_px <- as.numeric(width_px)
        height_px <- as.numeric(height_px)
        if (length(width_px) != 1 || length(height_px) != 1 || is.na(width_px) || is.na(height_px)) {
            stop("width_px and height_px must be numeric scalars.")
        }
        if (width_px <= 0 || height_px <= 0) {
            stop("width_px and height_px must be > 0.")
        }

        preset <- list(
            preset = "custom",
            width_px = width_px,
            height_px = height_px,
            source_file = NA_character_
        )
    } else {
        preset <- bde_get_size_preset(size_preset = size_preset, figures_dir = figures_dir)
    }

    if (is.null(device)) {
        if (output_format == "png") {
            if (requireNamespace("ragg", quietly = TRUE)) {
                device <- ragg::agg_png
            } else {
                device <- "png"
            }
        } else {
            if (capabilities("cairo")) {
                device <- grDevices::cairo_pdf
            } else {
                device <- grDevices::pdf
            }
        }
    }

    ggplot2::ggsave(
        filename = filename,
        plot = plot,
        width = preset$width_px / dpi,
        height = preset$height_px / dpi,
        units = "in",
        dpi = dpi,
        bg = bg,
        scale = scale,
        device = device,
        limitsize = FALSE
    )

    invisible(preset)
}
