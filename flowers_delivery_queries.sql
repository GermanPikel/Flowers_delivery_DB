-- Заказы и их текущие состояния
CREATE VIEW current_orders AS
SELECT 
	ls.name AS "Имя",
    ls.phone AS "Телефон для связи",
    s.name AS "Статус заказа",
    ls.step_begin AS "Время"
FROM step s
JOIN (
    SELECT 
        client.name AS name,
        client.phone AS phone,
        MAX(os.fk_step) AS last_step,
        MAX(os.step_begin) AS step_begin
    FROM client
    JOIN ordering o ON o.fk_client = client.id
    JOIN order_step os ON os.fk_ordering = o.id
    GROUP BY client.name, client.phone
) AS ls ON ls.last_step = s.id;

-- самые популярные букеты
CREATE VIEW most_popular_bouquets AS 
SELECT
    b.name AS "Название букета",
    SUM(oi.quantity) AS "Всего продано",
    SUM(oi.quantity * b.price) AS "Доход с продаж"
FROM order_item oi
JOIN bouquet b ON oi.fk_bouquet = b.id
GROUP BY b.name
ORDER BY "Доход с продаж" DESC;

-- Представление, чтобы смотреть сколько каких цветов осталось в разны городах на складах
-- Если в каком-то городе меньше 100 цветов, то уведомляем о дефиците цветов
CREATE VIEW city_flower_stock AS
SELECT 
	city.name||', '||w.street||', '||w.building AS "Город",
    f.name AS "Цветы",
    SUM(wa.quantity) AS "Количество",
    CASE WHEN SUM(wa.quantity) < 100 THEN 'Низкий остаток' ELSE 'Достаточно' END AS "Вердикт"
FROM warehouse_avialability wa
JOIN warehouse w ON wa.fk_warehouse = w.id
JOIN city ON w.fk_city = city.id
JOIN flower f ON wa.fk_flower = f.id
GROUP BY city.name, w.street,  w.building , f.name;

-- Клиент, потративший больше всех денег в своем городе в феврале 2025
CREATE MATERIALIZED VIEW february_most_valuable_clients AS
SELECT DISTINCT ON (city.id)
  city.name AS city_name,
  client.name AS client_name,
  SUM(b.price * oi.quantity) AS total_spent
FROM client
JOIN city ON city.id = client.fk_city
JOIN ordering o ON o.fk_client =client.id
JOIN order_item oi ON oi.fk_ordering = o.id
JOIN bouquet b ON b.id = oi.fk_bouquet
JOIN (
    SELECT DISTINCT o.id
    FROM ordering o
    JOIN order_step os ON os.fk_ordering = o.id
    WHERE os.step_begin >= '2025-02-01'::timestamp
      AND os.step_begin <  '2025-03-01'::timestamp
) as february_orders ON february_orders.id = o.id
GROUP BY city.id, city.name, client.id, client.name
ORDER BY 
	city.id, 
	SUM(b.price * oi.quantity) DESC;

-- Инфа о клиентах в целом
SELECT
    client.name AS "Клиент",
    COUNT(o.id) AS "Всего заказов",
    SUM(oi.quantity * b.price) AS "Всего потратил"
FROM client
JOIN ordering o ON o.fk_client = client.id
JOIN order_item oi ON oi.fk_ordering = o.id
JOIN bouquet b ON oi.fk_bouquet = b.id
GROUP BY client.name
ORDER BY "Всего потратил" DESC, "Всего заказов" DESC;


SELECT * FROM most_popular_bouquets;
SELECT * FROM february_most_valuable_clients;
SELECT * FROM current_orders;
SELECT * FROM city_flower_stock;