#' Get canonical background color based on preset string
#'
#' @param background The preset background ("blue", "transparent", "white").
#' @param blue The exact hex code for the blue background.
#' @return A valid R color string or "transparent".
#' @export
bde_background_color <- function(
    background = c("blue", "transparent", "white"),
    blue = "#124380") {
    background <- match.arg(background)
    if (background == "blue") {
        return(blue)
    }
    if (background == "white") {
        return("#FFFFFF")
    }
    "transparent"
}

#' Ensure Roboto font is available and registered
#'
#' @param enable_showtext Whether to automatically enable showtext
#' @param quiet Whether to suppress warnings
#' @return Logical indicating success
#' @export
bde_ensure_roboto <- function(enable_showtext = TRUE, quiet = TRUE) {
    cache <- getOption("bde_roboto_ready", default = NULL)
    if (isTRUE(cache)) {
        if (enable_showtext && requireNamespace("showtext", quietly = TRUE)) {
            showtext::showtext_auto(enable = TRUE)
        }
        return(TRUE)
    }

    family_name <- "Roboto"
    family_lower <- tolower(family_name)

    roboto_system_paths <- character()
    has_system_roboto <- FALSE
    if (requireNamespace("systemfonts", quietly = TRUE)) {
        sf <- tryCatch(systemfonts::system_fonts(), error = function(e) NULL)
        if (!is.null(sf) && "family" %in% names(sf)) {
            idx <- which(tolower(sf$family) == family_lower)
            has_system_roboto <- length(idx) > 0
            if (has_system_roboto && "path" %in% names(sf)) {
                roboto_system_paths <- unique(sf$path[idx])
            }
        }
    }

    has_registered_roboto <- FALSE
    if (requireNamespace("sysfonts", quietly = TRUE)) {
        registered <- tryCatch(sysfonts::font_families(), error = function(e) character())
        has_registered_roboto <- any(tolower(registered) == family_lower)
    }

    used_showtext_fallback <- FALSE

    # Prefer static Roboto files with real bold/italic faces for correct title boldness.
    if (!has_registered_roboto && requireNamespace("sysfonts", quietly = TRUE)) {
        roboto_cache_dir <- file.path(path.expand("~"), ".cache", "bde_fonts", "roboto")
        roboto_local <- c(
            regular = file.path(roboto_cache_dir, "Roboto-Regular.ttf"),
            bold = file.path(roboto_cache_dir, "Roboto-Bold.ttf"),
            italic = file.path(roboto_cache_dir, "Roboto-Italic.ttf"),
            bolditalic = file.path(roboto_cache_dir, "Roboto-BoldItalic.ttf")
        )
        roboto_urls <- c(
            regular = "https://raw.githubusercontent.com/googlefonts/roboto-2/main/src/hinted/Roboto-Regular.ttf",
            bold = "https://raw.githubusercontent.com/googlefonts/roboto-2/main/src/hinted/Roboto-Bold.ttf",
            italic = "https://raw.githubusercontent.com/googlefonts/roboto-2/main/src/hinted/Roboto-Italic.ttf",
            bolditalic = "https://raw.githubusercontent.com/googlefonts/roboto-2/main/src/hinted/Roboto-BoldItalic.ttf"
        )

        if (!all(file.exists(roboto_local))) {
            dir.create(roboto_cache_dir, recursive = TRUE, showWarnings = FALSE)
            for (nm in names(roboto_local)) {
                if (!file.exists(roboto_local[[nm]])) {
                    tryCatch(
                        utils::download.file(roboto_urls[[nm]], roboto_local[[nm]], mode = "wb", quiet = quiet),
                        error = function(e) NULL
                    )
                }
            }
        }

        if (all(file.exists(roboto_local))) {
            added_static <- tryCatch(
                {
                    sysfonts::font_add(
                        family = family_name,
                        regular = roboto_local[["regular"]],
                        bold = roboto_local[["bold"]],
                        italic = roboto_local[["italic"]],
                        bolditalic = roboto_local[["bolditalic"]]
                    )
                    TRUE
                },
                error = function(e) FALSE
            )
            if (added_static) {
                registered <- tryCatch(sysfonts::font_families(), error = function(e) character())
                has_registered_roboto <- any(tolower(registered) == family_lower)
            }
        }
    }

    # If Roboto exists in system but is not registered for showtext, register local files
    # to avoid device-specific "Unable to load font: Roboto" warnings.
    if (has_system_roboto && !has_registered_roboto && requireNamespace("sysfonts", quietly = TRUE)) {
        regular_path <- roboto_system_paths[!grepl("italic", roboto_system_paths, ignore.case = TRUE)][1]
        italic_path <- roboto_system_paths[grepl("italic", roboto_system_paths, ignore.case = TRUE)][1]
        if (is.na(regular_path) || !nzchar(regular_path)) regular_path <- roboto_system_paths[1]
        if (is.na(italic_path) || !nzchar(italic_path)) italic_path <- regular_path

        added_local <- tryCatch(
            {
                sysfonts::font_add(
                    family = family_name,
                    regular = regular_path,
                    bold = regular_path,
                    italic = italic_path,
                    bolditalic = italic_path
                )
                TRUE
            },
            error = function(e) FALSE
        )

        if (added_local) {
            registered <- tryCatch(sysfonts::font_families(), error = function(e) character())
            has_registered_roboto <- any(tolower(registered) == family_lower)
        }
    }

    # Fast path: if Roboto exists in system fonts, do not attempt network registration.
    if (!has_registered_roboto && !has_system_roboto) {
        if (!requireNamespace("sysfonts", quietly = TRUE)) {
            if (!quiet) {
                warning("Package 'sysfonts' is not available; cannot register Roboto automatically.")
            }
            return(has_system_roboto)
        }

        added <- tryCatch(
            {
                sysfonts::font_add_google("Roboto", "Roboto")
                TRUE
            },
            error = function(e) FALSE
        )

        if (!added) {
            if (!quiet && !has_system_roboto) {
                warning("Could not download/register Roboto automatically.")
            }
            return(has_system_roboto)
        }

        registered <- tryCatch(sysfonts::font_families(), error = function(e) character())
        has_registered_roboto <- any(tolower(registered) == family_lower)
    }

    # Enable showtext whenever Roboto is registered (local or downloaded).
    if (enable_showtext && has_registered_roboto) {
        if (requireNamespace("showtext", quietly = TRUE)) {
            showtext::showtext_auto(enable = TRUE)
            used_showtext_fallback <- TRUE
        } else if (!quiet) {
            warning("Package 'showtext' is not available; Roboto rendering may fall back.")
        }
    }

    ok <- (has_system_roboto || has_registered_roboto) && (!enable_showtext || used_showtext_fallback || has_system_roboto)
    if (ok) {
        options(bde_roboto_ready = TRUE)
    }
    ok
}

#' Determine BDE style variant based on background
#'
#' @param background The intended plot background.
#' @param variant Optional explicit override.
#' @return The recognized variant string ("default", "white").
#' @export
bde_style_variant <- function(
    background = c("blue", "transparent", "white"),
    variant = NULL) {
    background <- match.arg(background)
    if (!is.null(variant)) {
        variant <- as.character(variant)[1]
        if (!variant %in% c("default", "white")) {
            stop("variant must be one of: 'default', 'white'.")
        }
        return(variant)
    }
    if (background == "white") "white" else "default"
}

#' Format titles for BDE plots
#'
#' @param title String to optionally uppercase
#' @param uppercase Logical whether to force uppercase
#' @export
bde_format_title <- function(title, uppercase = TRUE) {
    if (is.null(title) || !nzchar(title)) {
        return(title)
    }
    if (uppercase) toupper(title) else title
}

#' Return size presets dataframe
#'
#' @export
bde_size_presets <- function(figures_dir = NULL) {
    data.frame(
        preset = c(
            "dos_graficos_y_texto_1",
            "dos_graficos_y_textoinferior_1",
            "grafico_y_texto",
            "grafico_y_texto_inferior",
            "layuout_imagen",
            "texto_e_imagen",
            "tres_graficos_y_textoinferior_1"
        ),
        width_px = c(1430, 2025, 3322, 4092, 4092, 1805, 1306),
        height_px = c(1622, 1370, 1640, 1237, 1773, 1773, 1145),
        source_file = NA_character_,
        stringsAsFactors = FALSE
    )
}

#' Resolve target preset specifications
#'
#' @export
bde_get_size_preset <- function(size_preset, figures_dir = NULL) {
    if (missing(size_preset) || is.null(size_preset) || !nzchar(size_preset)) {
        stop("size_preset must be a non-empty string.")
    }

    presets <- bde_size_presets(figures_dir = figures_dir)
    idx <- match(as.character(size_preset), presets$preset)
    if (is.na(idx)) {
        stop(
            sprintf(
                "Unknown size_preset '%s'. Available presets: %s",
                size_preset,
                paste(presets$preset, collapse = ", ")
            )
        )
    }

    list(
        preset = presets$preset[[idx]],
        width_px = as.numeric(presets$width_px[[idx]]),
        height_px = as.numeric(presets$height_px[[idx]]),
        source_file = presets$source_file[[idx]]
    )
}
