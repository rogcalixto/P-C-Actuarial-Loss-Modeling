# Personal Auto Insurance Pricing & Risk Analysis

## Project Overview

This project develops a personal auto insurance pricing framework using historical policy and claims data. The objective is to estimate expected claim costs, model policyholder risk, and calculate indicated insurance premiums using actuarial methods and statistical modeling in R.

The analysis combines claim frequency and severity models to estimate pure premiums and evaluate how expected insurance costs vary across driver characteristics, vehicle age, and geographic territories.

## Project Objectives

- Clean and prepare historical insurance policy and claims datasets.
- Perform exploratory data analysis to identify patterns in claim frequency and severity.
- Develop statistical models to estimate expected claim frequency and claim severity.
- Calculate policy-level and portfolio-level pure premiums.
- Develop an illustrative rate indication incorporating expenses, commissions, taxes, and profit.
- Compare indicated premiums across different risk characteristics.

## Dataset

This project uses the French motor third-party liability insurance datasets:

- `freMTPL2freq`: Policy-level information, including exposure, claim counts, driver age, vehicle characteristics, and geographic information.
- `freMTPL2sev`: Individual claim amounts linked to policy identifiers.

The policy dataset contains approximately 678,000 policies, while the claims dataset contains 26,444 individual claim records.

Key variables include:

| Variable | Description |
|---|---|
| `Exposure` | Policy exposure measured in years |
| `ClaimNb` | Number of claims reported per policy |
| `ClaimAmount` | Individual claim amount |
| `DrivAge` | Driver age |
| `VehAge` | Vehicle age |
| `BonusMalus` | Driver bonus-malus rating |
| `VehPower` | Vehicle power |
| `Area` | Geographic classification |
| `Density` | Population density |
| `Region` | Geographic region |

## Methodology

### 1. Data Cleaning and Preparation

Policy and claims datasets were cleaned and prepared for statistical analysis.

Key steps included:
- Checking missing values and duplicate policy identifiers.
- Validating exposure and claim amounts.
- Creating driver age and vehicle age categories.
- Linking individual claims to policy-level information.
- Retaining zero-claim policies for frequency modeling.

### 2. Exploratory Data Analysis

Exploratory analysis was performed to understand differences in claim frequency and severity across policyholder characteristics.

Key findings included:
- Young drivers exhibited higher observed claim frequency than other age groups.
- Claim frequency varied across geographic areas.
- Claim severity displayed a heavily right-skewed distribution.
- The largest claims contributed disproportionately to total incurred losses.

### 3. Claim Frequency Modeling

A Negative Binomial Generalized Linear Model (GLM) was developed to estimate expected claim frequency.

The initial Poisson model exhibited overdispersion, with a Pearson dispersion statistic of approximately 1.81.

A Negative Binomial model was subsequently fitted to account for additional variability in claim counts.

An exposure offset was included to account for differences in policy exposure.

**Model specification:**

```r
ClaimNb ~ AgeGroup + VehicleAgeGroup + BonusMalus +
  VehPower + Area + log(Density) + VehBrand +
  VehGas + Region + offset(log(Exposure))
```

The Negative Binomial model produced a lower AIC than the Poisson model and was selected for frequency estimation.

### 4. Claim Severity Modeling

A Gamma GLM with a log link was developed to estimate average claim severity.

The model incorporated driver, vehicle, and geographic characteristics to evaluate their relationships with expected claim amounts.

**Model specification:**

```r
ClaimAmount ~ AgeGroup + VehicleAgeGroup + BonusMalus +
  VehPower + Area + log(Density) + VehBrand +
  VehGas + Region
```

The Gamma model estimated an average claim severity of approximately $2,214, compared with an observed average of approximately $2,266.

The severity data exhibited substantial variability and a heavy right tail, which remains an important model limitation.

### 5. Pure Premium Estimation

Expected pure premiums were calculated by combining predicted claim frequency and predicted claim severity.

**Actuarial pricing formula:**

\[
\text{Pure Premium} =
\text{Expected Frequency} \times
\text{Expected Severity}
\]

The resulting estimates represent expected claim costs per policy-year.

The portfolio-level modeled pure premium was approximately $164 per policy-year.

### 6. Rate Indication

An illustrative rate indication was developed by incorporating assumed operating expenses, commissions, taxes, and profit.

The following assumptions were used:

| Pricing Component | Assumption |
|---|---:|
| Operating Expenses | 20% |
| Commission | 10% |
| Taxes and Fees | 3% |
| Profit and Contingency | 5% |
| **Total Loading** | **38%** |

The indicated premium was calculated as:

Indicated Premium} =
(Pure Premium)/ (1-Total Loading)

Using a portfolio pure premium of approximately $164, the illustrative indicated annual premium was approximately $264.

These loading assumptions are illustrative and are not derived from historical premium or expense data.

### 7. Risk-Based Pricing Comparisons

Model predictions were aggregated using exposure-weighted averages to compare indicated annual premiums across different rating characteristics.

**Driver Age**

| Driver Age Group | Average Pure Premium | Indicated Annual Premium |
|---|---:|---:|
| Adult | $146 | $236 |
| Mature | $137 | $220 |
| Senior | $141 | $228 |
| Young | $789 | $1,272 |

Young drivers exhibited substantially higher modeled expected claim costs, reflecting both higher predicted frequency and higher predicted severity.

**Vehicle Age**

| Vehicle Age Group | Average Pure Premium | Indicated Annual Premium |
|---|---:|---:|
| Intermediate | $167 | $269 |
| New | $158 | $256 |
| Old | $163 | $263 |

The differences across vehicle age groups were relatively small compared with the differences observed across driver age groups.

**Geographic Area**

| Area | Average Pure Premium | Indicated Annual Premium |
|---|---:|---:|
| A | $129 | $208 |
| B | $146 | $235 |
| C | $142 | $228 |
| D | $195 | $315 |
| E | $209 | $338 |
| F | $158 | $254 |

Areas D and E exhibited the highest modeled indicated premiums, while Area A had the lowest.

## Tools and Technologies

- **R:** Statistical modeling and actuarial analysis
- **RStudio:** Development environment
- **Tidyverse:** Data manipulation and cleaning
- **MASS:** Negative Binomial regression
- **ggplot2:** Data visualization
- **Generalized Linear Models (GLMs):** Frequency and severity modeling

## Project Structure

```text
Personal_Auto_Insurance_Pricing/
│
├── Data/
│   ├── raw_data.csv
│   ├── claims_data.csv
│   ├── cleaned_data.csv
│   ├── cleaned_claims.csv
│   └── policy_experience.csv
│
├── R/
│   ├── 00_generate_data.R
│   ├── 01_data_cleaning.R
│   ├── 02_exploratory_analysis.R
│   ├── 03_frequency_model.R
│   ├── 04_severity_model.R
│   ├── 05_pure_premium.R
│   ├── 06_rate_indication.R
│   └── 07_risk_comparisons.R
│
├── Outputs/
│   ├── Figures/
│   ├── Tables/
│
├── README.md
└── .gitignore
```

## Limitations and Considerations

- The dataset represents historical French motor insurance experience and should not be interpreted as a representation of current U.S. insurance markets.
- The severity model exhibits substantial unexplained variability due to the heavy-tailed nature of claim amounts.
- The Negative Binomial frequency model continues to exhibit some residual overdispersion.
- The dataset does not contain historical premium information, preventing direct calculation of historical loss ratios or validation of actual rate changes.
- Expense, commission, tax, and profit assumptions are illustrative rather than derived from insurer financial experience.
- Model predictions and rating comparisons are based on historical associations and should not be interpreted as causal relationships.
- Further validation using holdout data and additional model diagnostics would be necessary before practical pricing implementation.

## Conclusion

This project demonstrates an actuarial approach to personal auto insurance pricing by combining statistical modeling, risk analysis, and premium estimation.

By developing separate frequency and severity models, I was able to estimate expected claim costs and translate those estimates into illustrative insurance premiums. The resulting risk comparisons demonstrate how policyholder and geographic characteristics can influence modeled insurance costs.

The project strengthened my understanding of actuarial pricing techniques, Generalized Linear Models, statistical analysis, and the relationship between insurance risk and premium development.