library(ggplot2)
library(dplyr)

#import functions
source("functions.R")

#Read ipc.csv
ipc <- read.csv("ipc.csv")
ipc$month <- as.Date(paste0(ipc$período, "-01"))
#Calculate monthly variation as a percentage
if (nrow(ipc) > 1) {
  ipc$variation <- c(0, (ipc$ipc[2:nrow(ipc)] - ipc$ipc[1:(nrow(ipc) - 1)])/ipc$ipc[1:(nrow(ipc) - 1)])
} else {
  ipc$variation <- 0
}

ipc_plot<- ipc[ipc$month >= as.Date("2022-01-01"),]


split_date <- "2023-12-10"
plot <- create_ipc_plot(ipc_plot, split_date)+
#Add an annotation that says "Engañoso!" at 2023-08-01
annotate("text", size = 7, x = as.Date("2023-08-01"), y = max(ipc_plot$variation) - 0.01, label = "Engañoso!", hjust = 0, size = 5, color = "black")
ggsave("ipc_mensual_mal.png", plot = plot, width = 15, height = 9, dpi = 300)

split_date <- "2023-11-01"
plot <- create_ipc_plot(ipc_plot, split_date)
ggsave("ipc_mensual_bien.png", plot = plot, width = 15, height = 9, dpi = 300)


#Now read the salary data
salario <- read.csv("salarios.csv")
salario$month <- as.Date(paste0(salario$período, "-01"))

#Now create year and month columns
salario$anio <- as.numeric(format(salario$month, "%Y"))
salario$mes <- as.numeric(format(salario$month, "%m"))

salario <- salario %>% filter(month>=as.Date("2016-12-01"))

#Merge salario and ipc
all <- merge(ipc, salario, by = "período") %>% arrange(month.x)
all2 <- all %>%
  mutate(salario_ajustado = (total_indice / ipc)) %>%
  #Recalculate salario_ajustado, doing total_registrado divided by the ipc of the previous month
  group_by(anio) %>%
  #Get the salario_ajustado for m = 1
  mutate(salario_base = first(salario_ajustado)) %>%
  mutate( salario_base100 = salario_ajustado / salario_base*100)

#Now create all3, where the base salario is not the first of each year, but the last of the previous year
salario_base_nov <- all2 %>% filter(mes == 11) %>%
  group_by(anio) %>%
  mutate(salario_base = last(salario_ajustado)) %>%
  select(salario_base) %>%
  ungroup() %>%
  mutate(anio=anio+1)

all3<-merge(all2, salario_base_nov, by = "anio") %>%
  mutate(salario_base = salario_base.y) %>%
  mutate(salario_base100 = salario_ajustado / salario_base*100) %>%
  mutate(mesgob=mes+1) %>%
  mutate(aniogob=ifelse(mesgob==13,anio+1,anio)) %>%
  mutate(mesgob=ifelse(mesgob==13,1,mesgob))
  


#Use all2 to plot monthly salario_base100, color by anio
library(ggrepel)
library(ggalt)

# Define custom colors for specific years
custom_colors <- c("2017" = "orange", "2018" = "orange", "2019" = "orange",
                   "2020" = "cyan", "2021" = "cyan", "2022" = "cyan", "2023" = "cyan",
                   "2024" = "purple")

# Create a new column for the labels
all2 <- all2 %>%
  group_by(anio) %>%
  mutate(label = ifelse(mes == max(mes), paste0(anio, ": ", round(salario_base100,1)), NA)) %>%
  ungroup()

ggplot(all2 %>% filter(anio > 2016), aes(x = mes, y = salario_base100, color = factor(anio))) +
  geom_xspline() +
  aes(lwd = 2) +
  scale_linewidth_identity() +
  geom_label_repel(aes(label = label), na.rm = TRUE, show.legend = FALSE, nudge_x = 0.2, hjust = 0, fontface = "bold") +
  scale_color_manual(name = "Gobierno",
                     values = custom_colors,
                     breaks = c("2017", "2020", "2024"),
                     labels = c("Macri", "Fernández", "Milei")) +
  labs(x = "Mes", y = "Salario base (%)", title = "Salario real con base=100 para enero de cada año") +
  scale_x_continuous(limits=c(1,13),breaks = seq(1, 12, 1), labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"),minor_breaks = NULL) +
  scale_y_continuous(limits = c(80, 107), breaks = seq(80, 110, 5), minor_breaks = NULL) +
  theme_light(base_size = 16) +
  theme(legend.position = "top")+
  annotate("text", size = 7, x = 4, y = 107, label = "Engañoso!", hjust = 0, size = 5, color = "black")

ggsave("salario_base100_enero.png", width = 15, height = 9, dpi = 300)






all3 <- all3 %>%
  group_by(anio) %>%
  mutate(label = ifelse(mes == max(mes), paste0(anio, ": ", round(salario_base100,1)), NA)) %>%
  ungroup()

ggplot(all3 %>% filter(anio > 2016), aes(x = mesgob, y = salario_base100, color = factor(anio))) +
  geom_xspline() +
  aes(lwd = 2) +
  scale_linewidth_identity() +
  geom_label_repel(aes(label = label), na.rm = TRUE, show.legend = FALSE, nudge_x = 0.2, hjust = 0, fontface = "bold") +
  scale_color_manual(name = "Gobierno",
                     values = custom_colors,
                     breaks = c("2017", "2020", "2024"),
                     labels = c("Macri", "Fernández", "Milei")) +
  labs(x = "Mes", y = "Salario base (%)", title = "Salario real con base=100 para nov del año anterior") +
  scale_x_continuous(limits=c(1,13),breaks = seq(1, 12, 1), labels = c("Dic","Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov"),minor_breaks = NULL) +
  scale_y_continuous(limits = c(80, 107), breaks = seq(80, 110, 5), minor_breaks = NULL) +
  theme_light(base_size = 16) +
  theme(legend.position = "top")
  

ggsave("salario_base100_enero_BIEN.png", width = 15, height = 9, dpi = 300)