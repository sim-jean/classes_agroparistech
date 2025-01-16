
custom_theme <- function(font_size = 10, 
                         bg_color = "gray92",
                         legend_position = 'bottom', 
                         family_ = local_family) {
  theme_light() +
    theme(
      text = element_text(family = family_, size = 10),
      plot.title = element_text(family = family_, size = 20),
      axis.title = element_text(family = family_, size = 10),
      legend.text = element_text(family = family_, size = 9),
      legend.position = legend_position,
      legend.title = element_text(family= family_, size = 9),
      axis.text = element_text(family = family_, size = 10),
      strip.text = element_text(size = font_size),  # Set font size for facet labels
      strip.background = element_rect(fill = bg_color, color = NA)  # Set background color for facet labels
    )
}
