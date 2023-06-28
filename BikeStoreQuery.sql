-- Joining multiple tables to generate relevant store, customer and product data

Select 
	ord.order_id,
	CONCAT(cus.first_name,' ', cus.last_name) AS 'customers',
	cus.city,
	cus.state,
	ord.order_date,
	SUM(ite.quantity) AS 'total_units',
	SUM(ite.quantity *ite.list_price) AS 'revenue',
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name, ' ', sta.last_name) AS 'sales_rep'
From sales.orders ord
Join sales.customers cus
ON ord.customer_id = cus.customer_id
Join sales.order_items ite
ON ord.order_id = ite.order_id
Join production.products pro
ON ite.product_id = pro.product_id
Join production.categories cat
ON pro.category_id = cat.category_id
Join sales.stores sto
ON sto.store_id = ord.store_id
Join sales.staffs sta
ON sta.staff_id = ord.staff_id
Group by
	ord.order_id,
	CONCAT(cus.first_name,' ', cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	pro.product_name,
	cat.category_name,
	sto.store_name,
	CONCAT(sta.first_name, ' ', sta.last_name)