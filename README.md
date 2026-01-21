# WESP Data Pipeline

## Overview

- replace the outdated manual download with a more "modern" way to feed data into the **World Economic Forecasting Model** (WEFM) 
- uses the [SDMX](https://www.sdmx.io/) API Schema to access a range of economic databases from different organisations ([IMF](https://data.imf.org/en), [OECD](https://data-explorer.oecd.org/), [OECD](https://ec.europa.eu/eurostat/data/database))
- coded in R (mostly [Quarto](https://quarto.org/) Markdown Files), with a lot of comments in the files itself

This file explains the basic project structure, how the workflow works schematically, as well as how to use it

## Project Structure

Hres a file tree with a little explanation 

```
├── data                    # data 
│   ├── eurostat_processed  # processed eurostat data
│   ├── imf_processed        
│   ├── oecd_processed
│   └── raw                 # raw data files used as inputs
├── docs
├── examples                # examples from the old WEFM
│   ├── eurostat
│   ├── imf
│   └── oecd
├── renv                    # renv environment files
└── src                     # source code
    ├── eurostat
    ├── imf
    ├── oecd
    └── utils               # utility functions
├── README.md               # this file  
└── renv.lock               # renv lock file
```



## Workflow

The basic intution behind the pipeline is like this: take some Databases, clean them, take some additional files to format them to the WEFM expecations, and then output some excel files to be ingested into Eviews.

Here is an example for the IMF annual data:

```mermaid
graph LR

subgraph ./src/imf/*.qmd
R{03_annual_data.qmd}
end

subgraph ./data/imf_processed/
1 & 2 & 3
end

subgraph ./data/raw
A[["Regions.xlsx (via src/utils/)"]] & B[[imf_CONV.xlsx]]
end

I[(IMF Databases)] --SDMX API--> R 
A --"country grouping"--> R 
B --code translation--> R
R --cleaned--> 1[[adv_annual.xlsx]] & 2[[developing_annual.xlsx]] & 3[[other_annual.xlsx]] 
R --timestamp--> 4[./data/LOG.csv]

```

1. access some IMF databases (e.g for Interest Rates or Balance of Payments) via the SDMX API
2. clean and transform it using the *tidyverse* packages
3. add the relevant country codes for WEFM from `imf_CONV.xlsx`
4. split it into the country groupings using `Regions.xlsx` (with a helper function in the utils)
5. output the split excel files into the `data/imf_processed` folder
6. update the timestamp for last accessed in the `LOG.csv` 



## Usage





## Data Sources

**IMF**

Monthly Data:

| IMF-Dataset | IMF Code          | WEFM Code   | WEFM Description                                             |
| ----------- | ----------------- | ----------- | ------------------------------------------------------------ |
| ER          | XDC_USD; PA_RT    | *_rfx_ncdol | Exchange rates, domestic currency per usd, period average, rate |
| MFS_IR      | MFS166_RT_PT_A_PT | *_rird      | Financial, Interest Rates, Monetary Policy-Related Interest Rate, Percent per annum |

Annual Data

| IMF Dataset | IMF Code               | WEFM Code        | WEFM Description                                             |
| ----------- | ---------------------- | ---------------- | ------------------------------------------------------------ |
| ER          | XDC_USD, PA_RT         | *_rft_ncdol      | Exchange rates, domestic currency per usd, period average, rate |
| CPI         | CPI; _T; IX            | *PCPI            | Prices, Consumer Price Index, All items, Index               |
| CPI         | CPI; _T;YOY_PCH_PA_PT; | *PCP_GR          | Prices, Consumer Price Index, All items, Percentage change, Corresponding period previous year, Percent |
| WEO         | BCA                    | *BCANET$         | Supplementary Items, Current Account, Net (Excluding Exceptional Financing), US Dollars |
| MFS_MA      | BM_MAI                 | *mnm2            | Monetary, M2, Domestic Currency                              |
| QGFS        | G24_T_XDC; S13         | *gg_gei_g01_xdc  | Fiscal, General Government, Expense, Interest, 2001 Manual, Domestic Currency |
| QGFS        | G24_T_XDC; S1311B      | *bcg_gei_g01_xdc | Fiscal, Budgetary Central Government, Expense, Interest, 2001 Manual, Domestic Currency |







## TODO

- [ ] Log Tracker Script
- [ ] Regions Utils Script
- [ ] Runner Script
- [ ] Key Creation Transparency
- [x] Workflow explanation
- [ ] Slides for the Workshop
