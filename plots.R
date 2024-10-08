library(ggplot2)
library(dplyr)
library(ggrepel)
library(ggalt)

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

caption="Fuente: INDEC. Elaboración: @rquiroga777.\nConsultar código en: https://github.com/rquiroga7/UFM-Milei"
split_date <- "2023-12-10"
plot <- create_ipc_plot(ipc_plot, split_date,caption)+
#Add an annotation that says "Engañoso!" at 2023-08-01
annotate("text", size = 7, x = as.Date("2023-08-01"), y = max(ipc_plot$variation) - 0.01, label = "Engañoso!", hjust = 0, size = 5, color = "black")
ggsave("ipc_mensual_mal.png", plot = plot, width = 15, height = 9, dpi = 300)

split_date <- "2023-11-01"
plot <- create_ipc_plot(ipc_plot, split_date,caption)
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
  mutate(salario_base = salario_ajustado) %>%
  select(salario_base) %>%
  ungroup() %>%
  mutate(anio=anio+1) %>%
  rename(aniogob=anio)

all3<-all2 %>%
  mutate(mesgob=mes+2) %>%
  mutate(aniogob=ifelse(mesgob>=13,anio+1,anio)) %>%
  mutate(mesgob=ifelse(mesgob==13,1,mesgob)) %>%
  mutate(mesgob=ifelse(mesgob==14,2,mesgob))

all3<-merge(all3, salario_base_nov, by = "aniogob", all.x = TRUE) %>%
  mutate(salario_base = salario_base.y) %>%
  mutate(salario_base = ifelse(is.na(salario_base),salario_base.x,salario_base)) %>%
  mutate(salario_base100 = salario_ajustado / salario_base*100)
  


#Use all2 to plot monthly salario_base100, color by anio


# Define custom colors for specific years
custom_colors <- c("2017" = "#e4c931", "2018" = "#e4c931", "2019" = "#e4c931",
                   "2020" = "#009FE3", "2021" = "#009FE3", "2022" = "#009FE3", "2023" = "#009FE3",
                   "2024" = "#6C4C99")

# Create a new column for the labels
all2 <- all2 %>%
  group_by(anio) %>%
  mutate(label = ifelse(mes == max(mes), paste0(anio, ": ", round(salario_base100,1)), NA)) %>%
  ungroup()

caption= "Fuente: INDEC. Salario real = Índice de salarios totales (públicos, privados, registrados y no registrados), ajustados por IPC. Elaboración: @rquiroga777.\nCódigo disponible en: https://github.com/rquiroga7/UFM-Milei"
# Plot the first graph
plot_salary( data = all2 %>% filter(anio > 2016) %>% mutate(anio=factor(anio)),
  title = "Salario real (ajustado por inflación) con base=100 para enero de cada año",
  x_labels = c("Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"),
  file_name = "salario_base100_enero_MAL.png",
  annotate_text = "Engañoso!",
  caption = caption
)


all3 <- all3 %>%
  group_by(aniogob) %>%
  mutate(label = ifelse(mesgob == max(mesgob), paste0(aniogob, ": ", round(salario_base100,1)), NA)) %>%
  ungroup() %>%
  #delete mes and anio
  select(-mes, -anio) %>%
  rename(anio=aniogob,mes=mesgob)

# Plot the second graph
plot_salary( data = all3 %>% filter(anio > 2016) %>% mutate(anio=factor(anio)),
  title = "Salario real (ajustado por inflación) con base=100 para nov del año anterior",
  x_labels = c("Nov", "Dic", "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct"),
  file_name = "salario_base100_enero_BIEN.png",
    caption = caption
)




# Combine the original data with the duplicated rows
all5<-process_salary_data(variable="total_indice",dataset="all2")
#Now generate a similar plot but with a continous line using all2 for 2017-2024
plot_salary( data = all5,
  title = "Salario real promedio (ajustado por inflación) con base=100 para enero de 2017",
  x_var = "month.y",   y_var= "salario_ipc_base",   
  file_name = "salario_continuo.png",
  caption = caption,   set_y_limits = FALSE,   repel_direction = "y",   nudge_x = 0,   nudge_y=7
)

all5b<-process_salary_data(variable="publico",dataset="all2")
caption= "Fuente: INDEC. Salario real = Índice de salarios públicos, ajustados por IPC. Elaboración: @rquiroga777.\nCódigo disponible en: https://github.com/rquiroga7/UFM-Milei"
plot_salary( data = all5b,
  title = "Salario real del sector público (ajustado por inflación) con base=100 para enero de 2017",
  x_var = "month.y",   y_var= "salario_ipc_base",   
  file_name = "salario_continuo_publico.png",
  caption = caption,   set_y_limits = FALSE,   repel_direction = "y",   nudge_x = 0,   nudge_y=7
)

all5c<-process_salary_data(variable="privado_registrado",dataset="all2")
caption= "Fuente: INDEC. Salario real = Índice de salarios privados registrados, ajustados por IPC. Elaboración: @rquiroga777.\nCódigo disponible en: https://github.com/rquiroga7/UFM-Milei"
plot_salary( data = all5c,
  title = "Salario real del sector privado registrado (ajustado por inflación) con base=100 para enero de 2017",
  x_var = "month.y",   y_var= "salario_ipc_base",   
  file_name = "salario_continuo_privreg.png",
  caption = caption,   set_y_limits = FALSE,   repel_direction = "y",   nudge_x = 0,   nudge_y=7
)

all5d<-process_salary_data(variable="privado_no_registrado",dataset="all2")
caption= "Fuente: INDEC. Salario real = Índice de salarios privados no registrados, ajustados por IPC. Elaboración: @rquiroga777.\nCódigo disponible en: https://github.com/rquiroga7/UFM-Milei"
plot_salary( data = all5d,
  title = "Salario real del sector privado no registrado (ajustado por inflación) con base=100 para enero de 2017",
  x_var = "month.y",   y_var= "salario_ipc_base",   
  file_name = "salario_continuo_privnoreg.png",
  caption = caption,   set_y_limits = FALSE,   repel_direction = "y",   nudge_x = 0,   nudge_y=7
)





all6<- all4 %>% filter(month.x>="2021-01-01") %>% mutate(month.y=as.Date(month.y))
salario_base_2021<-all6 %>% filter(month.x=="2021-01-01") %>% pull(salario_ipc_base)
all6<-all6 %>% mutate(salario_aj_2021 = as.numeric(salario_ipc_base/salario_base_2021*100)) %>% ungroup()
#Now do a red line lineplot using all5

split_date <- "2023-12-10"
plot <- create_salary_plot(all6, split_date,caption)+
#Add an annotation that says "Engañoso!" at 2023-08-01
annotate("text", size = 7, x = as.Date("2023-07-15"), y = min(all6$salario_aj_2021) + 2, label = "Engañoso!", hjust = 0, size = 5, color = "black")
ggsave("salario_mensual_mal.png", plot = plot, width = 15, height = 9, dpi = 300)

split_date <- "2023-11-01"
plot <- create_salary_plot(all6, split_date,caption)
ggsave("salario_mensual_bien.png", plot = plot, width = 15, height = 9, dpi = 300)
