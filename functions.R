
create_ipc_plot <- function(ipc_plot, split_date,caption="") {
  ggplot(data = ipc_plot, aes(x = month, y = variation)) +
    # Background light green rectangle for dates > split_date and light red for dates < split_date
    annotate(geom = "rect", xmin = as.Date(split_date), xmax = max(ipc_plot$month) + 30, ymin = 0 - 0.02, ymax = max(ipc_plot$variation) + 0.03, fill = "#08d6a2", alpha = 0.05) +
    annotate(geom = "rect", xmin = as.Date("2022-01-01") - 30, xmax = as.Date(split_date), ymin = 0 - 0.02, ymax = max(ipc_plot$variation) + 0.03, fill = "#bc191e", alpha = 0.05) +
    # Make red geom_line smooth but force it to pass through points
    geom_xspline(color = "red", spline_shape = -0.5) +
    aes(lwd = 1.4) +
    scale_linewidth_identity() +
    #add a dotted gray vertical line at split_date
    geom_vline(size= 1.5,xintercept = as.Date(split_date), linetype = "dotted", color = "#252525") +
    # I want geom_points to be light blue if month < split_date, and purple if not
    geom_point(aes(fill = month > as.Date("2023-11-01")), size = 3, shape = 21, stroke = 1, color = "black") +
    # Legend title "Presidente", first value named "Milei", second named "Fernández"
    scale_fill_manual(name = "Presidente", values = c("cyan", "purple"), labels = c("Fernández","Milei")) +
    scale_x_date(date_labels = "%Y-%m", date_breaks = "1 month", minor_breaks = NULL, expand = c(0, 10)) +
    scale_y_continuous(labels = scales::percent,breaks = seq(0, max(ipc_plot$variation) + 0.01, 0.05)) +
    coord_cartesian(ylim = c(0, max(ipc_plot$variation) + 0.01), xlim = c(as.Date("2022-01-01") - 10, max(ipc_plot$month) + 10)) +
    labs(title = "Inflación mensual por presidencia",
         x = "Año-Mes",
         y = "IPC mensual") +
    theme_light(base_size = 16) +
    # Add left aligned text label "Período\nPre-Milei" in red at x = 2022-01-01+35 and "Perído\nMilei" in green at x = 2023-12-01+35
    annotate(geom = "text", size = 7, x = as.Date("2022-01-01") + 65, y = max(ipc_plot$variation) - 0.01, label = expression(bold("Período\nPre-Milei")), color = "#bc191e") +
    annotate(geom = "text", size = 7, x = as.Date("2023-12-01") + 65, y = max(ipc_plot$variation) - 0.01, label = expression(bold("Período\nMilei")), color = "#08d6a2") +
    # Put legend on top and rotate x axis labels 90 degrees
    theme(legend.position = "top", axis.text.x = element_text(angle = 90, vjust = 0.5),plot.title = element_text(hjust = 0.5))+
    labs(caption = caption)
}

create_salary_plot <- function(ipc_plot, split_date, caption = "") {
  # Identify the last data point
  last_point <- ipc_plot[which.max(ipc_plot$month.x), ]
  
  ggplot(data = ipc_plot, aes(x = month.x, y = salario_aj_2021)) +
    # Background light green rectangle for dates > split_date and light red for dates < split_date
    annotate(geom = "rect", xmin = as.Date(split_date), xmax = max(ipc_plot$month.x) + 30, ymin = min(ipc_plot$salario_aj_2021) - 2, ymax = max(ipc_plot$salario_aj_2021) + 3, fill = "#08d6a2", alpha = 0.05) +
    annotate(geom = "rect", xmin = as.Date("2021-01-01") - 30, xmax = as.Date(split_date), ymin = min(ipc_plot$salario_aj_2021) - 2, ymax = max(ipc_plot$salario_aj_2021) + 3, fill = "#bc191e", alpha = 0.05) +
    # Make red geom_line smooth but force it to pass through points
    geom_xspline(color = "red", spline_shape = -0.5) +
    aes(lwd = 1.4) +
    scale_linewidth_identity() +
    # Add a dotted gray vertical line at split_date
    geom_vline(size = 1.5, xintercept = as.Date(split_date), linetype = "dotted", color = "#252525") +
    scale_x_date(date_labels = "%Y-%m", date_breaks = "1 month", minor_breaks = NULL, expand = c(0, 10)) +
    scale_y_continuous(breaks = seq(0, max(ipc_plot$salario_aj_2021) + 10, 5)) +
    coord_cartesian(ylim = c(min(ipc_plot$salario_aj_2021) - 0.01, max(ipc_plot$salario_aj_2021) + 0.01), xlim = c(as.Date("2021-01-01") - 10, max(ipc_plot$month.x) + 40)) +
    labs(title = "Salario real en Argentina (2021-2024)",
         x = "Año-Mes",
         y = "Salario real (ajustado por inflación)") +
    theme_light(base_size = 16) +
    # Add left aligned text label "Período\nPre-Milei" in red at x = 2022-01-01+35 and "Perído\nMilei" in green at x = 2023-12-01+35
    annotate(geom = "text", size = 7, x = as.Date("2021-01-01") + 85, y = min(ipc_plot$salario_aj_2021) + 1, label = expression(bold("Período\nPre-Milei")), color = "#bc191e") +
    annotate(geom = "text", size = 7, x = as.Date("2023-12-01") + 85, y = max(ipc_plot$salario_aj_2021) - 2, label = expression(bold("Período\nMilei")), color = "#08d6a2") +
    # Add label for the last data point using geom_text_repel
    geom_text_repel(data = last_point, aes(label = round(salario_aj_2021,1)), color = "red", size = 5, nudge_x = 0.02) +
    # Put legend on top and rotate x axis labels 90 degrees
    theme(legend.position = "top", axis.text.x = element_text(angle = 90, vjust = 0.5), plot.title = element_text(hjust = 0.5)) +
    labs(caption = caption)
}

plot_salary <- function(data, x_var="mes", y_var="salario_base100", color_var="anio", label_var="label", title="", x_labels=NULL, file_name="", caption=NULL, annotate_text = NULL,set_y_limits=TRUE,repel_direction="both",nudge_x=0.2,nudge_y=0) {
  p <- ggplot(data, aes_string(x = x_var, y = y_var, color = color_var)) +
    geom_label_repel(aes_string(label = label_var), na.rm = TRUE, show.legend = FALSE, nudge_x = nudge_x,nudge_y = nudge_y, hjust = 0, fontface = "bold", direction = repel_direction,min.segment.length = 0.01) +
    scale_color_manual(name = "Gobierno",
                       values = custom_colors,
                       breaks = c("2017", "2020", "2024"),
                       labels = c("Macri", "Fernández", "Milei")) +
    labs(x = "Mes", y = "Salario (índice)", title = title) +
    theme_light(base_size = 16) +
    theme(legend.position = "top") +
    labs(caption = caption)
  
  if (set_y_limits) {
    p <- p + geom_xspline(aes(lwd = 2)) + scale_linewidth_identity()
    p <- p + scale_y_continuous(limits = c(80, 107), breaks = seq(80, 110, 5), minor_breaks = NULL)
  } else {
    p <- p + geom_path(size=1.6)
    p <- p + scale_y_continuous(breaks = seq(50, 110, 5), minor_breaks = NULL)
  }

  if (!is.null(x_labels)) {
    p <- p + scale_x_continuous(limits = c(1, 13), breaks = seq(1, 12, 1), labels = x_labels, minor_breaks = NULL)
  } else {
    x_min <- min(data[[x_var]], na.rm = TRUE)
    x_max <- max(data[[x_var]], na.rm = TRUE) + 45
    p <- p + scale_x_date(date_breaks="1 year", minor_breaks = NULL, limits = c(x_min, x_max)) +
    labs(x="Fecha")
  }
  
  if (!is.null(annotate_text)) {
    p <- p + annotate("text", size = 7, x = 4, y = 107, label = annotate_text, hjust = 0, size = 5, color = "black")
  }
  
  ggsave(file_name, plot = p, width = 15, height = 9, dpi = 300)
}