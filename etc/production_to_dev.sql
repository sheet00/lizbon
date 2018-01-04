--
--
truncate table lizbon_development.trade_histories; 

insert 
into lizbon_development.trade_histories 
select
  * 
from
  lizbon_production.trade_histories; 

--
--
truncate table lizbon_development.currency_histories; 

insert 
into lizbon_development.currency_histories 
select
  * 
from
  lizbon_production.currency_histories; 

--
--
truncate table lizbon_development.wallets; 

insert 
into lizbon_development.wallets 
select
  * 
from
  lizbon_production.wallets; 

--
--
truncate table lizbon_development.wallet_histories; 

insert 
into lizbon_development.wallet_histories 
select
  * 
from
  lizbon_production.wallet_histories; 

--
--
truncate table lizbon_development.active_orders; 

insert 
into lizbon_development.active_orders 
select
  * 
from
  lizbon_production.active_orders; 

--
--
truncate table lizbon_development.bots; 

insert 
into lizbon_development.bots 
select
  * 
from
  lizbon_production.bots; 

--
--
truncate table lizbon_development.capitals; 

insert 
into lizbon_development.capitals 
select
  * 
from
  lizbon_production.capitals; 

--
--
truncate table lizbon_development.trade_settings; 

insert 
into lizbon_development.trade_settings 
select
  * 
from
  lizbon_production.trade_settings; 

--
--
truncate table lizbon_development.currency_averages; 

insert 
into lizbon_development.currency_averages 
select
  * 
from
  lizbon_production.currency_averages; 



--
--
truncate table lizbon_development.delayed_jobs; 

insert 
into lizbon_development.delayed_jobs 
select
  * 
from
  lizbon_production.delayed_jobs; 
