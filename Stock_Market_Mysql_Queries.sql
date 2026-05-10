create database Stock_Market_Analysis;
use Stock_Market_Analysis;

-- Dimentions Tables
select * from dim_exchange;
select * from dim_sector;
select * from dim_company;
select * from dim_trader;
select * from dim_portfolio;
select * from dim_calendar;

-- Fact Tables
select * from fact_daily_prices;
select * from fact_dividends;
select * from fact_splits;
select * from fact_orders;
select * from fact_trades;
select * from fact_positions_snapshot;
select * from fact_trades_pnl_kpi;
select * from stocks;


-- 1. Join trades with company name
select  ft.trade_id, c.company_id, ft.quantity, ft.price
from fact_trades ft
JOIN dim_company c
ON ft.company_id = c.company_id;


 -- 2. JOIN TRADER & PORTFOLIO
select distinct
t.trader_id, t.trader_name, p.portfolio_id, p.portfolio_name
from fact_trades ft
JOIN dim_trader t
ON ft.trader_id = t.trader_id
JOIN dim_portfolio p
ON ft.portfolio_id = p.portfolio_id;


-- 3. Portfolio count per trader
select 
t.trader_name,
count(distinct ft.portfolio_id ) AS total_portfolios
from fact_trades ft
JOIN dim_trader t
    ON ft.trader_id = t.trader_id
GROUP BY t.trader_name;


-- 4. Trades per portfolio
select
p.portfolio_name,
COUNT(ft.trade_id) AS Total_Trades
from fact_trades ft
JOIN dim_portfolio p
ON ft.portfolio_id = p.portfolio_id
GROUP BY p.portfolio_name;

-- 5. Trade value
select trade_id, quantity, price, 
(quantity * price) AS Trade_Value
from fact_trades;

-- 6. Total traded value per company
select
c.company_name,
SUM( ft.quantity * ft.price) AS Total_Trade_Value
from fact_trades ft
JOIN dim_company c
ON c.company_id = ft.company_id
group by c.company_name
order by Total_Trade_Value DESC;

-- 7. PnL per TRADE
SELECT
    sell_trade_id,
    trader_id,
    portfolio_id,
    realized_profit,
    return_pct,
    win_flag
FROM fact_trades_pnl_kpi;


-- 8. Total PnL per TRADER
SELECT
    t.trader_id,
    t.trader_name,
    SUM(p.realized_profit) AS total_pnl
FROM fact_trades_pnl_kpi p
JOIN dim_trader t
    ON p.trader_id = t.trader_id
GROUP BY t.trader_id, t.trader_name
ORDER BY total_pnl DESC;

-- 9. Total PnL per PORTFOLIO
select p.portfolio_id,  pf.portfolio_name, SUM(p.realized_profit) AS  portfolio_pnl
from fact_trades_pnl_kpi p
JOIN dim_portfolio pf
on p.portfolio_id = pf.portfolio_id
group by p.portfolio_id,  pf.portfolio_name
order by portfolio_pnl DESC;


-- 10. Win vs Loss per TRADER
select 
t.trader_name,
count(*) as Total_Trades,
SUM(CASE WHEN p.win_flag = 1 THEN 1 ELSE 0 END) AS Winning_trades,
SUM(CASE WHEN p.win_flag = 0 THEN 1 ELSE 0 END) AS losing_trades,
ROUND( SUM(CASE WHEN p.win_flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS win_rate_pct
FROM fact_trades_pnl_kpi p
JOIN dim_trader t
    ON p.trader_id = t.trader_id
GROUP BY t.trader_name
order by win_rate_pct;


-- 11. Portfolio Return %
select
pf.portfolio_name,
ROUND(AVG(p.return_pct), 2) AS Average_Return_Percentages
from fact_trades_pnl_kpi p
JOIN dim_portfolio pf
ON p.portfolio_id = pf.portfolio_id
group by pf.portfolio_name
order by Average_Return_Percentages;


-- 12. Daily Price Range
select
date, company_id,
(high - low) as Daily_Price_Range
from fact_daily_prices;


-- 13. Average Closing Price per Company
select
c.company_name,
round(avg(dp.close), 2) AS Average_Close
from fact_daily_prices dp
JOIN dim_company c
ON dp.company_id = c.company_id
Group By c.company_name
order by Average_Close DESC;


-- 14. Best Performing Stocks
select
c.company_name,
Round(Max(dp.close) - MIN(dp.open) / MIN(dp.open) * 100, 2) as Price_Growth_Percentages
from fact_daily_prices dp
JOIN dim_company c
ON dp.company_id = c.company_id
group by c.company_name
ORDER BY Price_Growth_Percentages DESC;



















