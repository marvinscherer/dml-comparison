# Plots The Results of the Simulations
# Author: Marvin Scherer


# Packages
library(tidyverse)
library(ggplot2)
library(dplyr)
library(reshape)
library(ggrepel)


# Working directory
setwd("YOUR WORKING DIRECTORY")


experiments <- c("^balanced_treatment", # String start anchor (^) needed to separate balanced from unbalanced
                 "unbalanced_treatment",
                 "complex_linear",
                 "complex_nonlinear",
                 "sparse_linear",
                 "piecewise_linear",
                 "beta_confounded")

for (experiment in experiments) {
    exp_name <- experiment
    results <- data.frame()
    for (file_i in dir("Results", pattern = experiment)) {
        results_i <- read.csv(file = paste0("Results/", file_i))
        results <- rbind(results, results_i)
    }
    
    results %>%
        group_by(N) %>%
        summarise(NDR_CATE = mean(NDR_CATE),
                  GRF_CATE = mean(GRF_CATE),
                  NDR_ATE = mean(NDR_ATE),
                  GRF_ATE = mean(GRF_ATE),
                  HYBRID_ATE = mean(HYBRID_ATE)
        ) %>%
        as.data.frame() -> results
    
    # Needed to have clean titles on the plots 
    if (exp_name == "^balanced_treatment") {
        exp_name <- "balanced_treatment"
    }
    
    min_cate <- min(results %>%
                        melt(id = "N") %>%
                        filter(variable %>% str_detect("_CATE")) %>%
                        select(value))
    
    max_cate <- max(results %>%
                        melt(id = "N") %>%
                        filter(variable %>% str_detect("_CATE")) %>%
                        select(value))
    
    min_ate <- min(results %>%
                       melt(id = "N") %>%
                       filter(variable %>% str_detect("_ATE")) %>%
                       select(value))
    
    max_ate <- max(results %>% 
                       melt(id = "N") %>%
                       filter(variable %>% str_detect("_ATE")) %>% 
                       select(value))
    
    results %>%
        melt(id = "N") %>%
        filter(variable %>% str_detect("_CATE")) %>%
        dplyr::rename(Estimator = variable) %>%
        dplyr::mutate(Estimator = plyr::revalue(Estimator, c("NDR_CATE" = "NDR Learner",
                                                             "GRF_CATE" = "Causal Forest"))) %>%
        ggplot(aes(x = N, y = value, color = Estimator)) +
        geom_line() +
        geom_point() +
        scale_y_log10(limits = c(min_cate, max_cate)) +
        theme_bw() +
        scale_color_manual(values = c("NDR Learner" = "slateblue4",
                                      "Causal Forest" = "seagreen")) +
        labs(title = "IATE", subtitle = str_to_title(str_replace(exp_name, "_", " ")),
             x = "Training Size", y = "EMSE")
    
    ggsave(filename = paste0("Figures/",exp_name,"_CATE.pdf"), height = 6, width = 6)
    
    results %>%
        melt(id = "N") %>%
        filter(variable %>% str_detect("_ATE")) %>%
        dplyr::rename(Estimator = variable) %>%
        dplyr::mutate(Estimator = plyr::revalue(Estimator, c("NDR_ATE" = "NDR Learner",
                                                             "GRF_ATE" = "Causal Forest",
                                                             "HYBRID_ATE" = "Hybrid Approach"))) %>%
        ggplot(aes(x = N, y = value, color = Estimator)) +
        geom_line() +
        geom_point() +
        scale_y_log10(limits = c(min_ate, max_ate)) +
        theme_bw() +
        scale_color_manual(values = c("NDR Learner" = "slateblue4",
                                      "Causal Forest" = "seagreen",
                                      "Hybrid Approach" = "orange")) +
        
        
        labs(title = "ATE", subtitle = str_to_title(str_replace(exp_name, "_", " ")), 
             x = "Training Size", y = "MSE") +
        scale_y_continuous()
    
    
    ggsave(filename = paste0("Figures/",exp_name,"_ATE.pdf"), height = 6, width = 6)
    print(exp_name)
}

