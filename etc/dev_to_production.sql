--
--
truncate table lizbon_production.active_orders; 

insert 
into lizbon_production.active_orders 
select
  * 
from
  lizbon_development.active_orders; 

--
--
truncate table lizbon_production.bots; 

insert 
into lizbon_production.bots 
select
  * 
from
  lizbon_development.bots; 

--
--
truncate table lizbon_production.currency_histories; 

insert 
into lizbon_production.currency_histories 
select
  * 
from
  lizbon_development.currency_histories; 

--
--
truncate table lizbon_production.currency_pairs; 

insert 
into lizbon_production.currency_pairs 
select
  * 
from
  lizbon_development.currency_pairs; 

--
--
truncate table lizbon_production.targets; 

insert 
into lizbon_production.targets 
select
  * 
from
  lizbon_development.targets; 

--
--
truncate table lizbon_production.trade_histories; 

insert 
into lizbon_production.trade_histories 
select
  * 
from
  lizbon_development.trade_histories; 

--
--
truncate table lizbon_production.trade_settings; 

insert 
into lizbon_production.trade_settings 
select
  * 
from
  lizbon_development.trade_settings; 

--
--
truncate table lizbon_production.wallet_histories; 

insert 
into lizbon_production.wallet_histories 
select
  * 
from
  lizbon_development.wallet_histories; 

--
--
truncate table lizbon_production.wallets; 

insert 
into lizbon_production.wallets( 
  currency_type
  , money
  , is_loscat
  , created_at
  , updated_at
) 
select
  currency_type
  , money
  , is_loscat
  , created_at
  , updated_at 
from
  lizbon_development.wallets; 



