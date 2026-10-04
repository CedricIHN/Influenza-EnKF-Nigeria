library(sf)           
library(ggplot2)      
library(dplyr)        
library(readxl)       
library(geodata)      
library(stringr)  

working_dir <- "D:/MAEPiMS_challenge_2026/Code/"
setwd(working_dir)

files_list <- list.files(path = working_dir, 
                         pattern = "^Result_Fitting_Influenza_state_.*\\.xlsx$", 
                         full.names = FALSE)

df_predictions <- data.frame(
  state = character(), 
  Cases_Start = numeric(), 
  Cases_Mid = numeric(), 
  Cases_End = numeric(), 
  stringsAsFactors = FALSE
)

date_start <- ""
date_mid   <- ""
date_end   <- ""

for (file_name in files_list) {
  base_name <- tools::file_path_sans_ext(file_name)
  nom_etat <- str_replace(base_name, "Result_Fitting_Influenza_state_", "")
  
  file_path <- file.path(working_dir, file_name)
  
  # Reading sheet quantiles
  Tab9 <- read_excel(file_path, sheet = "quantiles_hosp")
  
  # Reading sheet M value
  Tab1 <- read_excel(file_path, sheet = "Average_estimation")
  M <- as.numeric(Tab1$initial_values[Tab1$Name == "M"])
  
  # Subsetting forecast horizon (M+1 to end)
  df_forecast <- Tab9[(M + 1):nrow(Tab9), ]
  n_forecast <- nrow(df_forecast)
  
  idx_start <- 1
  idx_mid   <- round(n_forecast / 2)
  idx_end   <- n_forecast
  
  # Extracting median forecast values (q50)
  val_start <- df_forecast$q50[idx_start]
  val_mid   <- df_forecast$q50[idx_mid]
  val_end   <- df_forecast$q50[idx_end]
  
  if (date_start == "") {
    date_start <- as.character(df_forecast$Weeks[idx_start])
    date_mid   <- as.character(df_forecast$Weeks[idx_mid])
    date_end   <- as.character(df_forecast$Weeks[idx_end])
  }
  
  df_predictions <- rbind(df_predictions, data.frame(
    state = nom_etat, 
    Cases_Start = val_start, 
    Cases_Mid = val_mid, 
    Cases_End = val_end
  ))
}

# Name 
df_predictions <- df_predictions %>%
  mutate(state = recode(state, "FCT" = "Federal Capital Territory", "Abuja" = "Federal Capital Territory"))

# Cart
nigeria_map <- gadm(country = "NGA", level = 1, path = tempdir()) %>% 
  st_as_sf()

nigeria_cases_map <- nigeria_map %>%
  left_join(df_predictions, by = c("NAME_1" = "state"))

# 
max_val <- max(c(df_predictions$Cases_Start, df_predictions$Cases_Mid, df_predictions$Cases_End), na.rm = TRUE)
min_val <- min(c(df_predictions$Cases_Start, df_predictions$Cases_Mid, df_predictions$Cases_End), na.rm = TRUE)

# Fonction 
make_individual_map <- function(col_name, title_text, date_text) {
  ggplot(data = nigeria_cases_map) +
    geom_sf(aes_string(fill = col_name), color = "white", size = 0.3) +
    scale_fill_gradientn(
      colors = c("#313695", "#4575b4", "#74add1", "#abd9e9", "#fee090", "#fdae61", "#f46d43", "#d73027", "#a50026"),
      limits = c(min_val, max_val),
      labels = scales::comma_format(),
      name = "Values"
    ) +
    geom_sf_text(aes(label = NAME_1), size = 2.2, color = "black", check_overlap = TRUE) +
    theme_minimal(base_size = 13) +
    
    theme(
      axis.text = element_blank(),
      axis.title = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      plot.title = element_text(face = "bold", hjust = 0.5, size = 15),
      plot.subtitle = element_text(hjust = 0.5, size = 11),
      legend.position = "right",
      legend.key.height = unit(1.2, "cm")
    ) +
    labs(
      title = title_text,
      subtitle = paste("Date:", date_text)
    )
}
#
p_start <- make_individual_map("Cases_Start", "Influenza hospotalized forecast", date_start)
ggsave("Nigeria_Predicted_Hosp_Start.png", plot = p_start, width = 10, height = 8, dpi = 300)

#
p_mid <- make_individual_map("Cases_Mid", "Influenza hospotalized forecast", date_mid)
ggsave("Nigeria_Predicted_Hosp_Mid.png", plot = p_mid, width = 10, height = 8, dpi = 300)

# 
p_end <- make_individual_map("Cases_End", "Influenza hospotalized forecast", date_end)
ggsave("Nigeria_Predicted_Hosp_End.png", plot = p_end, width = 10, height = 8, dpi = 300)
