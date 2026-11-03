# Dataset Documentation

## 1. Dataset Overview

This project uses the **freMTPL2 French Motor Third-Party Liability (MTPL) Insurance Dataset**, a historical insurance dataset containing policyholder characteristics, vehicle information, claim frequencies, and individual claim costs.

The dataset is used to explore actuarial risk factors and develop statistical models for personal auto insurance pricing.

The original dataset consists of two separate data files:

- **freMTPL2freq:** Policy-level information, including exposure, driver characteristics, vehicle characteristics, and number of claims.
- **freMTPL2sev:** Individual claim records containing policy identifiers and associated claim amounts.

The original data represents French motor insurance experience and should not be interpreted as a representation of current U.S. auto insurance markets.

## 2. Data Source

The dataset is documented in the `CASdatasets` R package.

**Original source and documentation:**

- CASdatasets documentation: https://dutangc.github.io/CASdatasets/
- Dataset reference: https://github.com/dutangc/CASdatasets/blob/master/man-md/freMTPL2freq.md
- Dataset package: `CASdatasets`

The original data was collected from an unnamed private insurance company. 

## 3. Dataset Structure

The project uses two primary datasets.

### Policy-Level Data (`raw_data.csv`)

Each observation represents an individual insurance policy.

| Variable | Description |
|---|---|
| IDpol | Unique insurance policy identifier |
| ClaimNb | Number of claims reported during the exposure period |
| Exposure | Length of policy exposure in years |
| VehPower | Vehicle power classification |
| VehAge | Age of the insured vehicle |
| DrivAge | Age of the policyholder/driver |
| BonusMalus | French insurance bonus-malus rating |
| VehBrand | Vehicle manufacturer category |
| VehGas | Vehicle fuel type |
| Area | Geographic area classification |
| Density | Population density of the policyholder's area |
| Region | Geographic region in France |

### Claims-Level Data (`claims_data.csv`)

Each observation represents an individual insurance claim.

| Variable | Description |
|---|---|
| IDpol | Policy identifier used to link claims to insurance policies |
| ClaimAmount | Reported monetary cost of the individual claim |

The two datasets have a one-to-many relationship through `IDpol`, since an individual policy can have multiple claims.

## 4. Data Preparation and Cleaning

Before conducting exploratory analysis and developing predictive models, the data undergoes several preparation steps.

These include:

- Removing observations with invalid or non-positive exposure.
- Checking claim frequency values for invalid observations.
- Removing observations with non-positive population density where required.
- Converting categorical variables into appropriate factor formats.
- Handling missing values in modeling variables.
- Engineering additional features, including driver age and vehicle age groupings.
- Combining policy-level and claims-level information where necessary for analysis.

The cleaned datasets are generated locally and are not included in this repository.

## 5. Data Availability

To keep the GitHub repository lightweight and avoid distributing the original raw datasets, the CSV files are intentionally excluded.

Users interested in reproducing the analysis should obtain the original `freMTPL2freq` and `freMTPL2sev` datasets through the CASdatasets documentation and package resources.

The repository contains the analysis scripts, documentation, and project code rather than the original insurance records.

## 6. Important Considerations

- The data represents historical French motor third-party liability insurance experience.
- Claim frequency and severity should be evaluated separately because they measure different components of insurance risk.
- The data contains policy-level and claim-level observations, which should be joined carefully to avoid duplication or incorrect aggregation.
- Historical relationships in this dataset may not generalize to other insurance markets or time periods.

## 7. Intended Use

This dataset supports an educational actuarial pricing project focused on:

- Exploratory data analysis.
- Insurance claim frequency analysis.
- Claim severity analysis.
- Risk segmentation.
- Statistical modeling and predictive analysis.
- Understanding the relationship between policyholder characteristics and insurance losses.

The project is intended for educational and portfolio demonstration purposes.