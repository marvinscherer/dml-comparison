# Balanced Treatment with Complex CATE (Complex Non-Linear) (DGP 4)
# Author: Marvin Scherer


# Settings  

# Packages
library(causalToolbox)
library(causalDML)
library(grf)
library(tidyverse)

# Working directory
setwd("YOUR WORKING DIRECTORY")

# Setting the seed
set.seed(12345)

# Parameters --------------------------------------------------------------
N <- 10000 # Max number of observations
r <- 100   # Number of iterations (repetitions)

start_time <- Sys.time()
for(rep in 1:r) {
    print(paste0("Iteration #", rep))
    
    n_range <- c(2000, 5000, 10000, 20000, 100000, 300000)
    n_range <- n_range[which(n_range <= N)]
    
    # Initialize the results data frame
    results <- data.frame(N = n_range)
    results$NDR_CATE <- NA
    results$GRF_CATE <- NA
    results$NDR_ATE <- NA
    results$GRF_ATE <- NA
    results$HYBRID_ATE <- NA
    filename <- paste0("Results/complex_nonlinear", rep, "EMSE.csv")
    
    
    # Create components of ensemble
    forest <- create_method("forest_grf", args = list(tune.parameters = "all"))
    
    
    for (n in n_range) {
        
        # Experiment setting (DGP 4) ----
        exp <- simulate_causal_experiment(ntrain = n, ntest = 1000, dim = 20, alpha = 0,
                                          feat_distribution = "normal",
                                          pscore = "rct5",
                                          mu0 = "complexNonLinear",
                                          tau = "complexNonLinear")
        
        
        # Training set
        feature_train <- exp$feat_tr
        w_train <- exp$W_tr
        yobs_train <- exp$Yobs_tr
        
        # Testing set
        feature_test <- exp$feat_te
        
        
        # Train the NDR Learner
        print(paste0("Training NDR, N = ", n))
        ndr <- ndr_oos(y = yobs_train, w = w_train, x = feature_train,
                       xnew = feature_test,
                       ml_w = list(forest),
                       ml_y = list(forest), 
                       compare_all = FALSE,
                       quiet = TRUE)
        
        # Train Causal Forest (GRF)
        print(paste0("Training Causal Forest, N = ", n))
        causal_forest <- causal_forest(X = feature_train,  Y = yobs_train, W = w_train,
                                       tune.parameters = "all")
        
        
        # Estimate the CATEs
        cate_esti_ndr <- ndr$cates[, 2]
        cate_esti_grf <- predict(causal_forest, feature_test)$predictions
        
        # Estimate the ATEs
        ate_esti_ndr <- ndr$ATE$results
        ate_esti_grf <- average_treatment_effect(causal_forest, target.sample = "all")
        
        # Hybrid ATE
        # These are estimates of m(X) = E[Y | X]
        Y_hat <- causal_forest$Y.hat
        
        # These are estimates of the propensity score E[W | X]
        W_hat <- causal_forest$W.hat
        
        # tau_hat from NDR
        tau_hat <- cate_esti_ndr
        
        # E[Y | X, W = 0]
        mu_hat_0 <- Y_hat - W_hat * tau_hat
        # E[Y | X, W = 1]
        mu_hat_1 <- Y_hat + (1 - W_hat) * tau_hat
        
        # Average Potential Outcomes
        APO_0 <- mean(mu_hat_0)
        APO_1 <- mean(mu_hat_1)
        APO_0
        APO_1
        
        # Average Treatment Effect
        ate_esti_hybrid <- APO_1 - APO_0
        
        
        # Evaluate the CATE performance
        cate_true <- exp$tau_te
        
        results$NDR_CATE[which(results$N == n)] <- mean((cate_esti_ndr - cate_true)^2)
        results$GRF_CATE[which(results$N == n)] <- mean((cate_esti_grf - cate_true)^2)
        
        # Evaluate the ATE performance
        ate_true <- mean(exp$tau_te)
        
        
        results$NDR_ATE[which(results$N == n)]    <- (ate_esti_ndr[1] - ate_true)^2 
        results$GRF_ATE[which(results$N == n)]    <- (ate_esti_grf[1] - ate_true)^2
        results$HYBRID_ATE[which(results$N == n)] <- (ate_esti_hybrid - ate_true)^2
        
        # Save the intermediate results
        write.csv(results,
                  file = filename,
                  row.names = FALSE)
        
        # Clean up the environment
        rm(ndr, causal_forest)
    }
}
end_time <- Sys.time()
end_time - start_time
