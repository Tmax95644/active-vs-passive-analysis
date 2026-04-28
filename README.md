# Active vs Passive Fund Analysis

A data analysis project comparing the performance of the UK's most viewed 
active investment trusts against passive index trackers over a 3 year period 
(May 2023 — April 2026).

## Data Sources
- Active funds: AIC Top 20 most viewed investment trusts
- Passive benchmarks: FTSE 100, S&P 500, FTSE All World
- Price data: Yahoo Finance via yfinance
- Analysis period: 3 years monthly data

## Objectives & Key Findings

### 1. Did active beat passive?
No. The Active Fund Average returned 35.7% vs S&P 500's 70.6%.
A £1,000 equally split across all 18 active trusts returned £1,357 
vs £1,706 in the S&P 500 — passive wins by £349.

### 2. Which active funds outperformed?
- Beat S&P 500: 2 of 18 (11%)
- Beat FTSE All World: 3 of 18 (17%)
- Beat FTSE 100: 10 of 18 (56%)

### 3. Top performing funds (3yr return)
| Fund | Return |
|---|---|
| Scottish Mortgage | +108% |
| Temple Bar | +74% |
| S&P 500 | +71% |
| Monks Investment Trust | +58% |

### 4. Best risk-adjusted returns (Sharpe Ratio)
| Fund | Sharpe Ratio |
|---|---|
| FTSE All World | 9.38 |
| S&P 500 | 8.98 |
| FTSE 100 | 7.83 |
| Temple Bar (best active) | 6.69 |

### 5. Max Drawdown (worst losing streak)
| Fund | Max Drawdown |
|---|---|
| BlackRock World Mining | -26.2% |
| S&P 500 | -8.6% |
| FTSE 100 | -6.7% |

### 6. Consistency (months above starting value)
- Temple Bar, S&P 500, FTSE All World: never went negative
- International Public Partnerships: only positive 1 month of 36

## Tech Stack
- Python + yfinance — data collection
- pandas — data cleaning and transformation
- SQLite + SQL — analysis queries
- Power BI — dashboard visualisation

## Author
Toby Oliver | github.com/Tmax95644
