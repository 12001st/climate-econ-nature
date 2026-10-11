# The Economic Nature of Climate Shocks

**English** | [한국어](README.ko.md)

MATLAB code for Chapter 3, "The Economic Nature of Climate Shocks," of a 2023 research report on climate risk in ASEAN+3 economies.

## The question

When extreme weather hits an economy, does it act like a **supply shock** (output falls, prices rise), a **demand shock** (output and prices move together), or both? The answer matters for monetary policy: a central bank should look through a pure supply shock but lean against a demand shock.

The chapter studies 14 economies: Brunei, Cambodia, Indonesia, Lao PDR, Malaysia, Myanmar, the Philippines, Singapore, Thailand, Vietnam, China, Japan, Korea, and Hong Kong.

## Method

1. **Identify macro shocks.** For each economy, estimate a quarterly small-open-economy VAR (1981Q1–2022Q4):
   - endogenous: real GDP growth, CPI inflation, deposit rate
   - exogenous: U.S. real GDP growth, world commodity-price inflation
   - 2 lags, constant and trend

   Aggregate supply, aggregate demand, and monetary policy shocks are identified with sign restrictions held for two quarters:

   | Shock | GDP growth | Inflation | Interest rate |
   |---|---|---|---|
   | Supply | + | − | free |
   | Demand | + | + | + |
   | Monetary | + | + | − |

2. **Relate them to climate.** Regress the identified supply and demand shocks on a climate-extremes index (AECI) and its components (heat, cold, drought, precipitation, wind), in panel and country-by-country regressions.

This repository contains step 1 and supporting monthly and yearly analysis. The climate index itself and the step 2 regressions are not included.

## Repository layout

```
code/
  load_Quarterly.m            load and transform the quarterly panel
  run_VAR_Quarterly_Sign.m    main model: sign-restricted VARX for each economy, saves the shocks
  load_Monthly.m              load and transform the monthly panel
  run_VAR_Monthly_Sign.m      monthly counterpart of the main model
  run_VAR_Monthly_Choleski.m  monthly VAR with the climate index ordered first (recursive identification)
  plot_Monthly.m              charts of monthly economic and climate series, per economy
  load_Yearly.m, plot_Yearly.m  yearly climate-index charts
data/                         input workbooks go here (not distributed)
output/                       figures and shock series are written here
```

## Requirements

- MATLAB R2021a or later. `plot_Monthly.m` also needs the Econometrics Toolbox (`crosscorr`).
- Ambrogio Cesa-Bianchi's [VAR Toolbox](https://github.com/ambropo/VAR-Toolbox) on the MATLAB path (`VARmodel`, `SR`, `VARir`, `VARirband`, `SaveFigure`, …).

## Data

The input data are not distributed. They combine national macro series with the climate index. To run the code, place these workbooks in `data/` (sheet `data`, countries stacked in the order listed above):

| File | Frequency | Used by |
|---|---|---|
| `data_Quarterly_1981_2022_final.xlsx` | quarterly, 1981Q1–2022Q4 | `load_Quarterly.m` |
| `data_Monthly_1981_2022_final.xlsx` | monthly, 1981M1–2022M12 | `load_Monthly.m` |
| `Yearly_1981_2019_final.xlsx` | yearly, 1981–2019 | `load_Yearly.m` |

The expected variable names are listed at the top of each `load_*.m` file.

## Running

Run everything from the repository root:

```matlab
addpath code
run_VAR_Quarterly_Sign      % main model; loads the data itself

load_Monthly                % the monthly scripts expect the data in the workspace
run_VAR_Monthly_Sign
run_VAR_Monthly_Choleski
```

The main model writes impulse-response figures to `output/Quarterly/figures_det2/` and the identified shocks of all economies to `output/Quarterly/eps_sign_3x3_L2_LX2_det2_Q.xlsx` (columns: date, country id, supply, demand, monetary).
