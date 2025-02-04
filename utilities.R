
custom_theme <- function(font_size = 10, 
                         bg_color = "gray92",
                         legend_position = 'bottom', 
                         family_ = local_family) {
  theme_light() +
    theme(
      text = element_text(family = family_, size = font_size),
      plot.title = element_text(family = family_, size = 2*font_size, hjust = .5),
      axis.title = element_text(family = family_, size = font_size),
      legend.text = element_text(family = family_, size = .9*font_size),
      legend.position = legend_position,
      legend.title = element_text(family= family_, size = .9*font_size),
      axis.text = element_text(family = family_, size = font_size),
      strip.text = element_text(size = font_size),  # Set font size for facet labels
      strip.background = element_rect(fill = bg_color, color = NA)  # Set background color for facet labels
    )
}

theme_clean <- function(base_size = 12, base_family = "sans", legend_position_ = "bottom") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.title = element_text(size = base_size * 1.2, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = base_size, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = base_size * 0.8, hjust = 1, color = "grey50"),
      axis.text = element_text(size = base_size * 0.9),
      axis.ticks = element_blank(),
      panel.grid.major = element_line(color = "grey90"),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      legend.position = legend_position_,
      legend.text = element_text(size = base_size * 0.9)
    )
}


clean_palette <- c(
  "#0072B2", # Blue
  "#D55E00", # Orange
  "#009E73", # Green
  "#CC79A7", # Pink
  "#F0E442", # Yellow
  "#56B4E9", # Light Blue
  "#E69F00"  # Goldenrod
)

#

