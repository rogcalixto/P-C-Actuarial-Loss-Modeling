# ==========================================
# 06 - Rate Indication  
# ==========================================

library(tidyverse)

# Load portfolio pricing results 
portfolio_summary <- read_csv(
  "Outputs/Tables/portfolio_pricing_summary.csv"
)

# Extract modeled pure premium 
pure_premium <- portfolio_summary$Portfolio_Pure_Premium

# Set pricing assumptions 
expense_ratio <- 0.20
commission_ratio <- 0.10
tax_ratio <- 0.03
profit_ratio <- 0.05

# Calculate Total Loading 
total_loading <- expense_ratio + 
  commission_ratio + 
  tax_ratio + 
  profit_ratio

# Calculate the indicated premium 
indicated_premium <- pure_premium / (1-total_loading)

# Calculate dollar loading 
loading_amount <- indicated_premium - pure_premium

# Create rate indication summary
rate_indication <- tibble(
  Pure_Premium = pure_premium, 
  Expense_Ratio = expense_ratio, 
  Commission_Ration = commission_ratio, 
  Tax_Ratio = tax_ratio, 
  Profit_Ratio = profit_ratio, 
  Total_Loading = total_loading, 
  Loading_Amount = loading_amount, 
  Indicated_Annual_Premium = indicated_premium
)

# Display Results 
print(rate_indication)

#Save Results
# Save results
write_csv(
  rate_indication,
  "Outputs/Tables/rate_indication.csv"
)
