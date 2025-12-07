-- БД для сервиса по доставке цветов

CREATE TABLE IF NOT EXISTS flower (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price INT NOT NULL
);

CREATE TABLE city (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS bouquet_type (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS bouquet (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price INT NOT NULL,
  fk_type INT REFERENCES bouquet_type(id) ON DELETE SET NULL,
  description TEXT
);
 
CREATE TABLE IF NOT EXISTS bouquet_structure (
  id SERIAL PRIMARY KEY,
  fk_bouquet INT NOT NULL REFERENCES bouquet(id) ON DELETE CASCADE,
  fk_flower INT NOT NULL REFERENCES flower(id) ON DELETE RESTRICT,
  quantity INT NOT NULL CONSTRAINT positive_quantity CHECK (quantity > 0)
);
 
CREATE TABLE IF NOT EXISTS client (
  id SERIAL PRIMARY KEY,
  phone BIGINT NOT NULL,
  email VARCHAR(50) NOT NULL,
  fk_city INT REFERENCES city(id) ON DELETE SET NULL,
  name TEXT,
  date_of_birth DATE
);

CREATE TABLE IF NOT EXISTS warehouse (
  id SERIAL PRIMARY KEY,
  fk_city INT DEFAULT NULL REFERENCES city(id) ON DELETE SET NULL,
  street VARCHAR(120) NOT NULL,
  building VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS warehouse_avialability (
  id SERIAL PRIMARY KEY,
  fk_warehouse INT NOT NULL REFERENCES warehouse(id) ON DELETE CASCADE,
  fk_flower INT NOT NULL REFERENCES flower(id) ON DELETE CASCADE,
  quantity INT NOT NULL CONSTRAINT positive_quantity CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS step (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ordering (
  id SERIAL PRIMARY KEY,
  fk_client INT NOT NULL REFERENCES client(id) ON DELETE CASCADE,
  comment TEXT
);

CREATE TABLE IF NOT EXISTS order_step (
  id SERIAL PRIMARY KEY,
  fk_ordering INT NOT NULL REFERENCES ordering(id) ON DELETE CASCADE,
  fk_step INT DEFAULT NULL REFERENCES step(id) ON DELETE SET DEFAULT,
  step_begin TIMESTAMP NOT NULL,
  step_end TIMESTAMP,
  UNIQUE(fk_ordering, fk_step),
  CONSTRAINT step_period CHECK (step_end IS NULL OR step_end >= step_begin)
);

CREATE TABLE IF NOT EXISTS order_item (
  id SERIAL PRIMARY KEY,
  fk_ordering INT NOT NULL REFERENCES ordering(id) ON DELETE CASCADE,
  fk_bouquet INT NOT NULL REFERENCES bouquet(id) ON DELETE CASCADE,
  quantity INT NOT NULL CONSTRAINT positive_quantity CHECK (quantity > 0)
);


INSERT INTO flower (name, price)
VALUES
('Роза красная', 150),
('Роза белая', 160),
('Тюльпан жёлтый', 90),
('Тюльпан розовый', 100),
('Ромашка', 50),
('Пион', 200),
('Гортензия синяя', 250),
('Подсолнух', 80);

INSERT INTO city (name)
VALUES
('Москва'),
('Санкт-Петербург'),
('Казань'),
('Новосибирск'),
('Екатеринбург');

INSERT INTO bouquet_type (name)
VALUES
('Классический'),
('Премиум'),
('Свадебный'),
('Романтический');

INSERT INTO bouquet (name, price, fk_type, description)
VALUES
('Нежная любовь', 1200, 4, 'Романтический букет из роз и ромашек'),
('Солнечное настроение', 900, 1, 'Яркий микс подсолнухов и тюльпанов'),
('Белая мечта', 2500, 3, 'Свадебный букет из белых роз и гортензии'),
('Пионовый делюкс', 3200, 2, 'Премиальная композиция из пионов');

INSERT INTO bouquet_structure (fk_bouquet, fk_flower, quantity)
VALUES
(1, 1, 5),
(1, 5, 7),
(2, 8, 3),  
(2, 3, 5),
(3, 2, 7),
(3, 7, 2),
(4, 6, 10);

INSERT INTO client (phone, email, fk_city, name, date_of_birth)
VALUES
(79991234567, 'ivan@mail.ru', 1, 'Иван Петров', '1990-03-10'),
(79875553322, 'maria@mail.ru', 2, 'Мария Волкова', '1995-07-21'),
(79001230011, 'alex@mail.ru', 3, 'Алексей Смирнов', '1988-11-05'),
(88005553535, 'petya@mail.ru', 2, 'Петя Иванов', '2000-10-12'),
(78005507007, 'misha@mail.ru', 3, 'Михаил Зизюля', '2005-07-10');

INSERT INTO warehouse (fk_city, street, building)
VALUES
(1, 'ул. Ленина', '12'),
(2, 'Невский проспект', '105'),
(3, 'ул. Баумана', '7'),
(4, 'ул. Космонавтов', '13/4'),
(5, 'ул. Сталина', '15к1');

INSERT INTO warehouse_avialability (fk_warehouse, fk_flower, quantity) VALUES
(1, 1, 120),
(1, 5, 300),
(1, 3, 180),
(2, 2, 150),
(2, 8, 70),
(2, 4, 200),
(3, 6, 90),
(3, 7, 40),
(3, 1, 60);

INSERT INTO step (name)
VALUES
('Ожидает оплаты'),
('Оплата подтверждена'),
('Подготовка букета'),
('Ждет курьера'),
('В пути'),
('Доставлено');

INSERT INTO ordering (fk_client, comment)
VALUES
(1, 'Доставить после 18:00'),
(2, 'Оставить у охраны'),
(3, 'Позвонить перед доставкой'),
(4, 'Домофон - 119#'),
(5, 'Наденьте маску, я болею');

INSERT INTO order_item (fk_ordering, fk_bouquet, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1),
(3, 4, 1),
(3, 1, 1),
(4, 1, 2),
(5, 4, 1);


INSERT INTO order_step (fk_ordering, fk_step, step_begin, step_end)
VALUES
(1, 1, '2025-02-01 10:00', '2025-02-01 10:05'),
(1, 2, '2025-02-01 10:05', '2025-02-01 10:10'),
(1, 3, '2025-02-01 10:10', '2025-02-01 11:00'),
(1, 4, '2025-02-01 11:00', NULL),
(2, 1, '2025-02-02 09:00', '2025-02-02 09:02'),
(2, 2, '2025-02-02 09:02', '2025-02-02 09:10'),
(2, 3, '2025-02-02 09:10', NULL),
(3, 1, '2025-02-03 14:00', '2025-02-03 14:02'),
(3, 2, '2025-02-03 14:02', '2025-02-03 14:20'),
(3, 3, '2025-02-03 14:20', '2025-02-03 15:00'),
(3, 4, '2025-02-03 15:00', '2025-02-03 15:10'),
(3, 5, '2025-02-03 15:10', '2025-02-03 15:40'),
(3, 6, '2025-02-03 15:40', NULL),
(4, 1, '2025-03-07 12:00', NULL),
(5, 1, '2025-03-07 12:00', '2025-03-07 12:10'),
(5, 2, '2025-03-07 12:10', NULL);
