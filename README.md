# WESP Data Pipeline

## Overview

- replace the outdated manual download with a more "modern" way to feed data into the **World Economic Forecasting Model** (WEFM) 
- uses the [SDMX](https://www.sdmx.io/) API Schema to access a range of economic databases from different organisations ([IMF](https://data.imf.org/en), [World Bank](https://data.worldbank.org/) , [OECD](https://ec.europa.eu/eurostat/data/database))
- coded in R (mostly [Quarto](https://quarto.org/) Markdown Files), with a lot of comments in the files itself



## Workflow

The basic intution behind the pipeline is like this: take some Databases, clean them, take some additional files to format them to the WEFM expecations, and then output some excel files to be ingested into Eviews.

Here is an example for the IMF annual data:

```mermaid
graph LR

subgraph ./src/imf/
R(03_annual_data.qmd)
end

subgraph ./data/imf_processed/
1 & 2 & 3
end

subgraph ./data/raw/
B[[imf_CONV.xlsx]]
end

subgraph ./src/utils
a(save_timestamp.R)
b(imf_split.R)
end

I[(IMF Databases)] --SDMX API--> R  
B --ISO translation--> R
R <--calls--> b --cleaned--> 1[[adv_annual.xlsx]] & 2[[developing_annual.xlsx]] & 3[[other_annual.xlsx]] 
R <--calls--> a --timestamp--> 4[last_successful_run.csv]

```

1. access some IMF databases (e.g for Interest Rates or Balance of Payments) via the SDMX API
2. clean and transform it using the *tidyverse* packages
3. add the relevant country codes for WEFM from `imf_CONV.xlsx`
4. split it into the country groupings using the utility script `imf_split.qmd`
5. save the excel files into the `data/imf_processed` folder
6. update the timestamp for last accessed in the `last_successful_run.csv` 



## Usage

1. To get started with the project, you have to use `renv`, which is used to keep the package versions synced and up to date.
```
install.packages("renv") # install renv if you don't have it yet renv::restore() # restore the environment
```

2. After that, run the respective quarto files in the folder `src/` 
   (e.g `src/imf/03_annual_data.qmd` for annual IMF data). Each of these files is independent and can be run separately.
   - Either open the files in RStudio and run them from there (easier)
     - Make sure to use the option in the top right **Run -> Restart R and run all Chunks** to have a clean slate in each run
   - Alternatively, run the whole file via the command line:
   ```
   quarto render src/imf/03_annual_data.qmd
   ```
   - *In the long run, this could be automated using a Makefile or similar, but for now, this is sufficient.*

3. Check in the `last_successful_run.csv` file to see when the last run was for each data source.

*Feel free to go into each Quarto Code file and look at it before running it, there are a some more comments in there too to explain how it works*

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
│   └── wb
├── renv                    # renv environment files
└── src                     # source code
    ├── eurostat
    ├── imf
    ├── wb
    └── utils               # utility functions
├── README.md               # this file  
└── renv.lock               # renv lock file
```



## Data Sources

### IMF

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

### Eurostat

| Indicators               | Unit                                                         | Adjustment                                | Eurostat Dataset (LINKS ARE WITH PRESELECTION!)              | Code                          |
| ------------------------ | ------------------------------------------------------------ | ----------------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| Annual GDP components    | Chain Linked Volums (2010); Current Prices (millions of nat. curr) | None                                      | [NAMA_10_GDP](https://ec.europa.eu/eurostat/databrowser/view/NAMA_10_GDP__custom_15679333/default/table?lang=en) | {ISO}\_{CODE}\_{ADJ}\_ESTAT_Q |
| Quarterly GDP Components | Chain Linked Volums (2010); Current Prices (millions of nat. curr) | unadjusted; Seasonal; Seasonal + Calendar | [NAMQ_10_GDP](https://ec.europa.eu/eurostat/databrowser/view/namq_10_gdp__custom_20133126/default/table) | {ISO}\_{CODE}\_{ADJ}\_ESTAT_Q |
| Annual Unemployment      | % of pop in labour force (age 15-74)                         | None                                      | [UNE_RT_A](https://ec.europa.eu/eurostat/databrowser/view/une_rt_a__custom_15679523/default/table?lang=en) | {ISO}_URX_ESTAT               |
| Monthly Unemployment     | % of pop in labour force (total pop)                         | Seasonal                                  | [UNE_RT_M](https://ec.europa.eu/eurostat/databrowser/view/une_rt_m__custom_20133163/default/table) | {ISO}_URX_ESTAT_M             |
| Annual HICP              | All-items HICP, Annual Average                               | None                                      | [PRC_HICP_AIND](https://ec.europa.eu/eurostat/databrowser/view/prc_hicp_aind__custom_15679491/default/table?lang=en) | {ISO}_HIC_ESTAT               |
| Monthly HICP             | All-items HICP, 2015=100                                     | None                                      | [PRC_HICP_MIDX](https://ec.europa.eu/eurostat/databrowser/view/prc_hicp_midx__custom_15679516/default/table?lang=en) | {ISO}_HIC_ESTAT_M             |

Annual GDP components are (CLV code / Curr Pr code)

- Gross domestic product at market prices (YER / YCN)
- Final consumption expenditure of general government (GCR / GCN)
- Household and NPISH final consumption expenditure (PCR / PCN)
- Gross fixed capital formation (ITR / ITN)
- Exports of goods and services (XTR / XTN)
- Imports of goods and services (MTR / MTN)



### World Bank

Indicators taken from the World Bank [WDI Viewer](https://data.worldbank.org/indicator?tab=all)

| Title                                                        | WEFM Code | WDI Code          |
| ------------------------------------------------------------ | --------- | ----------------- |
| Interest payments (current LCU)                              | GGEI      | GC.XPN.INTP.CN    |
| GNI per capita, Atlas method (current US$)                   | GNICAP    | NY.GNP.PCAP.CD    |
| Gini index                                                   | GINI      | SI.POV.GINI       |
| Survey mean consumption or income per capita, total population (2021 PPP $ per day) | YBAR      | SI.SPR.PCAP       |
| Poverty headcount ratio at $3.00 a day (2021 PPP) (% of population) | HEAD      | SI.POV.DDAY       |
| PPP conversion factor, GDP (LCU per international $)         | /         | PA.NUS.PPP        |
| GDP, PPP (current international $)                           | /         | NY.GDP.MKTP.PP.CD |
| GDP, PPP (constant 2021 international $)                     | /         | NY.GDP.MKTP.PP.KD |

