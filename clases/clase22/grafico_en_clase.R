# Cargar libreria
library(tidyverse)

# Sacar notacion cientifica
options(scipen=999)
# Rutas archivos 
auxiliar <- "materiales_utiles"

# Temas 
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 13),
      plot.subtitle    = element_text(color = "gray40", size = 10),
      plot.caption     = element_text(color = "gray50", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position  = "bottom"
    )
)

# Paleta para los 5 continentes (consistente en todos los gráficos)
paleta_cont <- c(
  "Americas" = "#7B3023", "Europe" = "#427B23", "Asia" = "#236E7B",
  "Africa"   = "#7B5C23", "Oceania" = "#5C237B"
)

# Cargamos los datos 
pib_pc <- read_csv('https://argendata.fund.ar/data/INDUST/pib_industrial_per_capita.csv')
iso_paises <- read_csv(file.path(auxiliar,'iso_paises_ingles.csv'))
iso_paises <- iso_paises %>% 
  select(iso3 = `alpha-3`,region,sub_region = `sub-region`) %>% 
  filter(!is.na(region))

# Modificar bases 
pib_pc <- pib_pc %>% 
  left_join(iso_paises,c("geocodigoFundar" = "iso3"))

# Graficos 1: boxplot pibpc x region
mean_pib_pc <- pib_pc %>%
  filter(anio == 2023) %>% 
  group_by(region) %>% 
  summarize(promedio = mean(gdp_indust_pc))

pib_pc %>%
  filter(anio == 2023) %>%
  filter(!is.na(region)) %>% 
  ggplot(aes(x=reorder(region,gdp_indust_pc),y=gdp_indust_pc)) + 
  geom_jitter(aes(color=region)) + 
  geom_boxplot(alpha=0.5,aes(fill=region)) +
  geom_point(data = mean_pib_pc %>% filter(!is.na(region)),aes(x=region,y=promedio),
             color='red',size=3,shape=9) + 
  scale_y_log10() + 
  scale_color_manual(values = paleta_cont) +
  scale_fill_manual(values = paleta_cont) +
  xlab('') + 
  ylab('PIB per cápita (log)') + 
  labs(title = 'PIB per cápita por país según continente',
       subtitle = 'Año = 2023, escala logarítmica',
       caption = 'Fuente: Argendata (Fundar). \nNota: el rombo rojo indica el promedio del continente') +
  coord_flip() + 
  theme(legend.title = element_blank())


