
create_ipc_plot <- function(ipc_plot, split_date) {
  ggplot(data = ipc_plot, aes(x = month, y = variation)) +
    # Background light green rectangle for dates > split_date and light red for dates < split_date
    annotate(geom = "rect", xmin = as.Date(split_date), xmax = max(ipc_plot$month) + 30, ymin = 0 - 0.02, ymax = max(ipc_plot$variation) + 0.03, fill = "green", alpha = 0.1) +
    annotate(geom = "rect", xmin = as.Date("2022-01-01") - 30, xmax = as.Date(split_date), ymin = 0 - 0.02, ymax = max(ipc_plot$variation) + 0.03, fill = "red", alpha = 0.1) +
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
    annotate(geom = "text", size = 7, x = as.Date("2022-01-01") + 65, y = max(ipc_plot$variation) - 0.01, label = expression(bold("Período\nPre-Milei")), color = "red") +
    annotate(geom = "text", size = 7, x = as.Date("2023-12-01") + 65, y = max(ipc_plot$variation) - 0.01, label = expression(bold("Período\nMilei")), color = "green") +
    # Put legend on top and rotate x axis labels 90 degrees
    theme(legend.position = "top", axis.text.x = element_text(angle = 90, vjust = 0.5),plot.title = element_text(hjust = 0.5))
}