# ==========================================
# 07 - Risk Comparison (Age Groups)  
# ==========================================

library(tidyverse)

# Load policy-level predictions
pricing_data <- read_csv(
  "Outputs/Tables/policy_pure_premium.csv"
)

# Load pricing assumptions
expense_ratio <- 0.20
commission_ratio <- 0.10
tax_ratio <- 0.03
profit_ratio <- 0.05

total_loading <- expense_ratio +
  commission_ratio +
  tax_ratio +
  profit_ratio

# Calculate indicated premium for each policy
pricing_data <- pricing_data %>%
  mutate(
    IndicatedPremium = PurePremium / (1 - total_loading)
  )

# Summarize pricing by driver age
age_pricing <- pricing_data %>%
  group_by(AgeGroup) %>%
  summarise(
    Policies = n(),
    
    Total_Exposure = sum(Exposure),
    
    Average_Pure_Premium =
      sum(PurePremium * Exposure) / sum(Exposure),
    
    Average_Indicated_Premium =
      sum(IndicatedPremium * Exposure) / sum(Exposure),
    
    .groups = "drop"
  )

print(age_pricing, width = Inf)


# Save results
write_csv(
  age_pricing,
  "Outputs/Tables/age_pricing_comparison.csv"
)

# Plot indicated premium by driver age
age_plot <- ggplot(
  age_pricing,
  aes(x = AgeGroup, y = Average_Indicated_Premium)
) +
  geom_col() +
  labs(
    title = "Average Indicated Annual Premium by Driver Age",
    x = "Driver Age Group",
    y = "Average Annual Premium ($)"
  ) +
  theme_minimal()

print(age_plot)

ggsave(
  "Outputs/Figures/indicated_premium_by_age.png",
  age_plot,
  width = 8,
  height = 5
)

# ==========================================
# 07 - Risk Comparison (Vehicle Age)  
# ==========================================

# Pricing comparison by vehicle age
vehicle_age_pricing <- pricing_data %>%
  group_by(VehicleAgeGroup) %>%
  summarise(
    Policies = n(),
    Total_Exposure = sum(Exposure),
    
    Average_Pure_Premium =
      sum(PurePremium * Exposure) / sum(Exposure),
    
    Average_Indicated_Premium =
      sum(IndicatedPremium * Exposure) / sum(Exposure),
    
    .groups = "drop"
  )

print(vehicle_age_pricing, width = Inf)

# Save results
write_csv(
  vehicle_age_pricing,
  "Outputs/Tables/vehicle_age_pricing.csv"
)

# Create chart
vehicle_age_plot <- ggplot(
  vehicle_age_pricing,
  aes(
    x = VehicleAgeGroup,
    y = Average_Indicated_Premium
  )
) +
  geom_col() +
  labs(
    title = "Average Indicated Annual Premium by Vehicle Age",
    x = "Vehicle Age Group",
    y = "Average Annual Premium ($)"
  ) +
  theme_minimal()

print(vehicle_age_plot)

ggsave(
  "Outputs/Figures/indicated_premium_by_vehicle_age.png",
  vehicle_age_plot,
  width = 8,
  height = 5
)

# ==========================================
# 07 - Risk Comparison (Geographical Area)  
# ==========================================

# Pricing comparison by geographic area
area_pricing <- pricing_data %>%
  group_by(Area) %>%
  summarise(
    Policies = n(),
    Total_Exposure = sum(Exposure),
    
    Average_Pure_Premium =
      sum(PurePremium * Exposure) / sum(Exposure),
    
    Average_Indicated_Premium =
      sum(IndicatedPremium * Exposure) / sum(Exposure),
    
    .groups = "drop"
  )

print(area_pricing, width = Inf)

# Save results
write_csv(
  area_pricing,
  "Outputs/Tables/area_pricing.csv"
)

# Create Chart
area_plot <- ggplot(
  area_pricing,
  aes(
    x = Area,
    y = Average_Indicated_Premium
  )
) +
  geom_col() +
  labs(
    title = "Average Indicated Annual Premium by Geographic Area",
    x = "Geographic Area",
    y = "Average Annual Premium ($)"
  ) +
  theme_minimal()

print(area_plot)

ggsave(
  "Outputs/Figures/indicated_premium_by_area.png",
  area_plot,
  width = 8,
  height = 5
)
