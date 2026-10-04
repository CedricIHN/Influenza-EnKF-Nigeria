rm(list = ls())
graphics.off()

# Packages
library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(viridis)
library(scales)
# 
setwd("D:/MAEPiMS_challenge_2026/Code/")
getwd()

# Files of results
file_resultls <- "Result_Fitting_Influenza.xlsx"
# file_resultls <- "Result_Fitting_Influenza_Akwa Ibom.xlsx"
cat("Uploading of file", file_resultls, "for post-treatment... Done\n")

# Base name of Excel file
base_name <- tools::file_path_sans_ext(basename(file_resultls))

# Reading sheets from Excel
Tab1 <- read_excel(file_resultls, sheet = "Average_estimation")
param_names <- Tab1$Name
initial_vals <- Tab1$initial_values
mean_vals <- Tab1$mean_values
final_vals <- Tab1$final_values
(M <- as.numeric(Tab1$initial_values[Tab1$Name == "M"]))
(mt <- as.numeric(Tab1$initial_values[Tab1$Name == "mt"]))
(mf <- as.numeric(Tab1$initial_values[Tab1$Name == "mf"]))
(m <- as.numeric(Tab1$initial_values[Tab1$Name == "m"]))

#
Tab2 <- read_excel(file_resultls, sheet = "Estimated_parameters")
weeks_fit <- Tab2$Weeks
beta_h0 <- Tab2$beta_h0
beta_h1 <- Tab2$beta_h1
beta_h <- Tab2$betah
epsilon <- Tab2$epsilon
beta_A <- Tab2$beta_A
a_param <- Tab2$a
p_prop <- Tab2$p
sigma <- Tab2$sigma
dH <- Tab2$dH
R0h <- Tab2$R0h
R0a <- Tab2$R0a
R0 <- Tab2$R0
#
Tab3 <- read_excel(file_resultls, sheet = "Estimated_states")
weeks_all <- Tab3$Weeks
S_est <- Tab3$S
I_est <- Tab3$I
H_est <- Tab3$H
R_est <- Tab3$R
A_est <- Tab3$A
#
Tab4 <- read_excel(file_resultls, sheet = "Estimated_cases")
data_cases <- Tab4$data
model_cases <- Tab4$model
#
Tab5 <- read_excel(file_resultls, sheet = "Estimated_hospitalized")
data_hosp  <- Tab5$data
model_hosp <- Tab5$model
#
Tab6 <- read_excel(file_resultls, sheet = "Estimated_death")
data_death <- Tab6$data
model_death <- Tab6$model
#
Tab7 <- read_excel(file_resultls, sheet = "median_Esti_forecast")
med_cases <- Tab7$med_forecast_cases
med_hosp <- Tab7$med_forecast_Hosp
med_death <- Tab7$med_forecast_death
#
Tab8 <- read_excel(file_resultls, sheet = "quantiles_cases")
q5_cases <- Tab8$q5
q25_cases <- Tab8$q25
q50_cases <- Tab8$q50
q75_cases <- Tab8$q75
q95_cases <- Tab8$q95
#
Tab9 <- read_excel(file_resultls, sheet = "quantiles_hosp")
q5_hosp <- Tab9$q5
q25_hosp <- Tab9$q25
q50_hosp <- Tab9$q50
q75_hosp <- Tab9$q75
q95_hosp <- Tab9$q95
#
Tab10 <- read_excel(file_resultls, sheet = "quantiles_death")
q5_death <- Tab10$q5
q25_death <- Tab10$q25
q50_death <- Tab10$q50
q75_death <- Tab10$q75
q95_death <- Tab10$q95
#
Tab11 <- read_excel(file_resultls, sheet = "Estimation_error")
err_type <- Tab11$Error_Type
cases_est_err <- Tab11$Cases_Est
hosp_est_err <- Tab11$Hosp_Est
death_est_err <- Tab11$Death_Est

# Function that plot all the estimation
plot_results_estimation <- function(weeks_vec, values_vec, y_label, title_text, is_fitting = FALSE, data_vec = NULL) {
  
  # M values
  df_est <- data.frame(
    Index = 1:M,
    Weeks_char = weeks_vec[1:M],
    Model = values_vec[1:M]
  ) %>%
    mutate(Weeks = factor(Weeks_char, levels = unique(Weeks_char)))
  
  if (is_fitting && !is.null(data_vec)) {
    df_est$Data <- data_vec[1:M]
  }
  
  # Set of date
  selected_dates <- levels(df_est$Weeks)[seq(1, M, by = 30)]
  
  p <- ggplot(df_est, aes(x = Weeks, group = 1)) +
    geom_line(aes(y = Model), color = "blue", size = 1.1) +
    scale_x_discrete(breaks = selected_dates) +
    theme_bw(base_size = 13) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
      plot.title = element_text(face = "bold", hjust = 0.5)
    ) +
    labs(title = title_text, x = "Time (Week)", y = y_label)
  # For available data
  if (is_fitting && !is.null(data_vec)) {
    p <- p + geom_point(aes(y = Data), color = "red", shape = 8, size = 2, na.rm = TRUE)
  }
  return(p)
}

#  Function that plot the test and the forecast with 90% CI
# -----------------------------------------------------------------------------
plot_test_forecast_IC <- function(data_tab, quantiles_tab, y_label, title_text){
  all_weeks_levels <- unique(data_tab$Weeks)
  df_tf <- data.frame(Index_global = 1:nrow(data_tab),
                      Weeks_char = data_tab$Weeks,
                      Data = data_tab$data,
                      q5 = quantiles_tab$q5,
                      q50 = quantiles_tab$q50,
                      q95 = quantiles_tab$q95
  ) %>%
    filter(Index_global > M) %>% # Consider values from M+1 to M+m
    mutate(
      Index_local = row_number(),
      Weeks = factor(Weeks_char, levels = all_weeks_levels),
      Phase = if_else(Index_global <= (M + mt), "Test", "Forecast"),
      Phase = factor(Phase, levels = c("Test", "Forecast")),
      # No available data for forecast
      Data_clean = if_else(Phase == "Test", Data, NA_real_)
    )
  
  n_points <- nrow(df_tf)
  idx_dates <- seq(from = 1, to = n_points, by = 10)
  selected_dates <- levels(droplevels(df_tf$Weeks))[idx_dates]
  x_sep_position <- mt
  
  p <- ggplot(df_tf, aes(x = Weeks)) +
    
    # Confidence interval 90% 
    geom_ribbon(aes(ymin = q5, ymax = q95, fill = Phase, group = Phase), 
                alpha = 0.25, show.legend = FALSE) +
    
    # Median forecast
    geom_line(aes(y = q50, color = Phase, group = Phase), size = 1.2) +
    
    # Data points 
    geom_point(aes(y = Data_clean), color = "magenta", shape = 8, size = 2.2, na.rm = TRUE) +
    
    # Separating line between Test and Forecast
    geom_vline(xintercept = x_sep_position, linetype = "dashed", color = "black", size = 0.8) +
    
    scale_x_discrete(breaks = selected_dates) +
    scale_color_manual(values = c("Test" = "forestgreen", "Forecast" = "red")) +
    scale_fill_manual(values = c("Test" = "forestgreen", "Forecast" = "red")) +
    #
    theme_bw(base_size = 13) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
      legend.position = "top",
      plot.title = element_text(face = "bold", hjust = 0.5)
    ) +
    labs(
      title = title_text,
      x = "Time (Week)", 
      y = y_label, 
      color = ""
    )
  
  return(p)
}

# S
p_est_S <- plot_results_estimation(weeks_all, S_est, "S", "Estimation of susceptible")

# I
p_est_I <- plot_results_estimation(weeks_all, I_est, "I", "Estimation of Infected")

# H
p_est_H <- plot_results_estimation(weeks_all, H_est, "H", "Estimation of hospitalized")

# R
p_est_R <- plot_results_estimation(weeks_all, R_est, "R", "Estimation of Recovered")

# A
p_est_A <- plot_results_estimation(weeks_all, A_est, "A", "Estimation of load in aerosols")

# beta_h0
p_est_beta0 <- plot_results_estimation(weeks_fit, beta_h0, expression(beta[h0]), bquote("Estimation of " ~ beta[h0]))

# beta_h1
p_est_beta1 <- plot_results_estimation(weeks_fit, beta_h1, expression(beta[h1]),  bquote("Estimation of " ~ beta[h1]))

# beta_h
p_est_betah <- plot_results_estimation(weeks_fit, beta_h, expression(beta[h]),  bquote("Estimation of " ~ beta[h]))

# epsilon
p_est_epsilon <- plot_results_estimation(weeks_fit, epsilon, expression(epsilon),  bquote("Estimation of " ~ epsilon))

# beta_A
p_est_beta_A <- plot_results_estimation(weeks_fit, beta_A, expression(beta[A]),  bquote("Estimation of " ~ beta[A]))

# a
p_est_a_param <- plot_results_estimation(weeks_fit, a_param, expression("a"), bquote("Estimation of a"))

# sigma
p_est_sigma <- plot_results_estimation(weeks_fit, sigma, expression(sigma),  bquote("Estimation of " ~ sigma))

# p
p_est_p_prop <- plot_results_estimation(weeks_fit, p_prop, expression("p"), bquote("Estimation of p"))

# d_H
p_est_dH <- plot_results_estimation(weeks_fit, dH, expression("d"[H]),  bquote("Estimation of d"[H]))

# R0
p_est_R0 <- plot_results_estimation(weeks_fit, R0, expression("R"[0]), bquote("Estimation of R"[0]))

# Fiting (model vs data)
p_est_cases<- plot_results_estimation(Tab5$Weeks, model_cases, "Newly cases", 
                                      bquote("Cases fitting"), is_fitting = TRUE, data_vec = data_cases)

p_est_hosp <- plot_results_estimation(Tab5$Weeks, model_hosp, "Newly hospitalized cases", 
                                      bquote("Hospitalization fitting"), is_fitting = TRUE, data_vec = data_hosp)

p_est_death <- plot_results_estimation(Tab5$Weeks, model_death, "Newly deceased", 
                                       bquote("Death fitting"), is_fitting = TRUE, data_vec = data_death)

print(p_est_S)
print(p_est_I)
print(p_est_H)
print(p_est_R)
print(p_est_A)
ggsave("Fig_Estimated_states_S.png", plot = p_est_S, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_states_I.png", plot = p_est_I, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_states_H.png", plot = p_est_H, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_states_R.png", plot = p_est_R, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_states_A.png", plot = p_est_A, width = 10, height = 6, dpi = 300)
#
print(p_est_beta0)
print(p_est_beta1)
print(p_est_betah)
print(p_est_epsilon)
print(p_est_beta_A)
print(p_est_a_param)
print(p_est_sigma)
print(p_est_p_prop)
print(p_est_dH)
print(p_est_R0)

ggsave("Fig_Estimated_parameter_betah0.png", plot = p_est_beta0, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_betah1.png", plot = p_est_beta1, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_betah.png", plot = p_est_betah, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_epsilon.png", plot = p_est_epsilon, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_betaA.png", plot = p_est_beta_A, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_a.png", plot = p_est_a_param, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_sigma.png", plot = p_est_sigma, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_p.png", plot = p_est_p_prop, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_dH.png", plot = p_est_dH, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_parameter_R0.png", plot = p_est_R0, width = 10, height = 6, dpi = 300)
#
print(p_est_cases)
print(p_est_hosp)
print(p_est_death)

ggsave("Fig_Estimated_data_cases.png", plot = p_est_cases, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_data_hosp.png", plot = p_est_hosp, width = 10, height = 6, dpi = 300)
ggsave("Fig_Estimated_data_death.png", plot = p_est_hosp, width = 10, height = 6, dpi = 300)

# # # test and forecast
# Cases
p_tf_cases <- plot_test_forecast_IC(Tab4, Tab8, "Newly reported cases", bquote("New Cases: Test & forecast with 90% IC"))

# Hospitalized
p_tf_hosp <- plot_test_forecast_IC(Tab5, Tab9, "Newly hospitalized cases", bquote("Hospitalizations: Test & forecast with 90% IC"))

# Death
p_tf_death <- plot_test_forecast_IC(Tab6, Tab10, "Newly deceased", bquote("Deaths: Test & forecast with 90% IC"))

print(p_tf_cases)
print(p_tf_hosp)
print(p_tf_death)


ggsave("Fig_forecast_data_cases.png", plot = p_tf_cases, width = 10, height = 6, dpi = 300)
ggsave("Fig_forecast_data_hosp.png", plot = p_tf_hosp, width = 10, height = 6, dpi = 300)
ggsave("Fig_forecast_data_death.png", plot = p_tf_death, width = 10, height = 6, dpi = 300)
