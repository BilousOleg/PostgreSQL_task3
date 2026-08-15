CREATE DATABASE hotel;

CREATE TABLE IF NOT EXISTS clients (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(64) NOT NULL CHECK (first_name <> ''),
  last_name VARCHAR(64) NOT NULL CHECK (last_name <> ''),
  birthday DATE NOT NULL CHECK(birthday <= CURRENT_DATE)
);

INSERT INTO clients (first_name, last_name, birthday)
VALUES
    ('Олександр', 'Коваленко', '1998-03-14'),
    ('Анна', 'Шевченко', '2001-11-08'),
    ('Максим', 'Бондар', '1995-07-21'),
    ('Марія', 'Данилюк', '2003-01-30'),
    ('Іван', 'Іваненко', '1990-05-17'),
    ('Валерія', 'Хрипко', '1999-07-29'),
    ('Андрій', 'Ткаченко', '1987-09-12'),
    ('Софія', 'Романюк', '2000-12-05'),
    ('Дмитро', 'Левченко', '1990-05-17'),
    ('Наталія', 'Петренко', '1997-08-16'),
    ('Микола', 'Сирний', '1985-02-11'),
    ('Юлія', 'Мороз', '1996-06-25');

CREATE TYPE room_category AS ENUM ('standard', 'comfort', 'deluxe', 'suite');

CREATE TABLE IF NOT EXISTS rooms (
  id SERIAL PRIMARY KEY,
  room_number SMALLINT NOT NULL UNIQUE CHECK(room_number > 0),
  category room_category NOT NULL,
  capacity SMALLINT NOT NULL CHECK (capacity > 0),
  daily_cost NUMERIC(10, 2) NOT NULL CHECK (daily_cost > 0)
);

INSERT INTO rooms (room_number, category, capacity, daily_cost)
VALUES
    (201, 'standard', 1, 800.00),
    (102, 'standard', 2, 1000.00),
    (103, 'standard', 2, 1100.00),
    (104, 'comfort', 2, 1400.00),
    (105, 'comfort', 3, 1700.00),
    (101, 'comfort', 2, 1500.00),
    (202, 'deluxe', 2, 2200.00),
    (203, 'deluxe', 3, 2600.00),
    (204, 'deluxe', 4, 3000.00),
    (301, 'suite', 2, 3500.00),
    (302, 'suite', 4, 5000.00),
    (303, 'suite', 5, 6000.00),
    (304, 'suite', 4, 5000.00);

CREATE TABLE IF NOT EXISTS bookings (
  id SERIAL PRIMARY KEY,
  client_id INTEGER NOT NULL REFERENCES clients (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  room_id INTEGER NOT NULL REFERENCES rooms (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  stay_period DATERANGE NOT NULL CHECK (NOT isempty(stay_period)),
  -- єдина проблема може виникнути з пересіченням діапазону дат, але я не знаю, як її уникнути
  rating NUMERIC(2, 1) CHECK (rating BETWEEN 0 AND 5)
);

INSERT INTO bookings (client_id, room_id, stay_period, rating)
VALUES
    (1, 1, daterange(CURRENT_DATE - 30, CURRENT_DATE - 25, '[)'), 4.5),
    (2, 2, daterange(CURRENT_DATE - 28, CURRENT_DATE - 23, '[)'), 5.0),
    (3, 4, daterange(CURRENT_DATE - 25, CURRENT_DATE - 20, '[)'), 1.8),
    (4, 5, daterange(CURRENT_DATE - 22, CURRENT_DATE - 15, '[)'), 2.9),
    (5, 6, daterange(CURRENT_DATE - 20, CURRENT_DATE - 14, '[)'), 4.7),
    (6, 7, daterange(CURRENT_DATE - 18, CURRENT_DATE - 12, '[)'), 3.4),
    (7, 8, daterange(CURRENT_DATE - 15, CURRENT_DATE - 10, '[)'), 4.0),
    (8, 9, daterange(CURRENT_DATE - 12, CURRENT_DATE - 7, '[)'), 0.9),
    (1, 1, daterange(CURRENT_DATE - 5, CURRENT_DATE - 2, '[)'), 4.8),
    (9, 3, daterange(CURRENT_DATE - 2, CURRENT_DATE + 3, '[)'), NULL),
    (10, 10, daterange(CURRENT_DATE - 1, CURRENT_DATE + 4, '[)'), NULL),
    (2, 3, daterange(CURRENT_DATE + 5, CURRENT_DATE + 10, '[)'), NULL),
    (3, 11, daterange(CURRENT_DATE + 7, CURRENT_DATE + 14, '[)'), NULL),
    (5, 9, daterange(CURRENT_DATE + 12, CURRENT_DATE + 18, '[)'), NULL),
    (6, 12, daterange(CURRENT_DATE + 15, CURRENT_DATE + 20, '[)'), NULL),
    (8, 5, daterange(CURRENT_DATE + 22, CURRENT_DATE + 27, '[)'), NULL);

DROP TABLE bookings CASCADE;
DROP TABLE rooms CASCADE;
DROP TABLE clients CASCADE;

-- 1 Відобразити імена та прізвища клієнтів та номери кімнат, які вони бронювали.

SELECT c.first_name || ' ' || c.last_name AS full_name, r.room_number
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
                  INNER JOIN rooms AS r ON r.id = b.room_id;

-- 2 Створити представлення по запиту 1.

CREATE VIEW booking_info AS
SELECT
    c.first_name,
    c.last_name,
    r.room_number
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
                  INNER JOIN rooms AS r ON r.id = b.room_id;
    
SELECT *
FROM booking_info;

-- 3 Відобразити оцінку клієнта Івана Іваненка для номера 101.

SELECT b.rating
FROM bookings AS b INNER JOIN clients AS c ON b.client_id = c.id
                   INNER JOIN rooms AS r ON b.room_id = r.id
WHERE c.first_name = 'Іван'
  AND c.last_name = 'Іваненко'
  AND r.room_number = 101;

-- 4 Відобразити клієнтів, які мають оцінку нижче 3.5.

SELECT c.first_name || ' ' || c.last_name AS full_name, b.rating
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
WHERE b.rating < 3.5;

-- 5 Відобразити клієнтів, які бронювали номер 101 та залишили оцінку.

SELECT c.first_name || ' ' || c.last_name AS full_name, b.rating
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
                  INNER JOIN rooms AS r ON r.id = b.room_id
WHERE r.room_number = 101
  AND b.rating IS NOT NULL;

-- 6 Відобразити середню оцінку та кількість бронювань для кожного клієнта.

SELECT c.first_name || ' ' || c.last_name AS full_name, AVG(b.rating)::numeric(2, 1) AS avg_rating, COUNT(b.id) AS booking_count
FROM bookings AS b RIGHT JOIN clients AS c ON b.client_id = c.id
GROUP BY c.id;

-- 7 Відобразити клієнтів, які мають середню оцінку вище 4.0.

SELECT c.first_name || ' ' || c.last_name AS full_name, AVG(b.rating)::numeric(2, 1) AS avg_rating
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
GROUP BY c.id
HAVING AVG(b.rating) > 4.0;

-- 8 Відобразити номери, які ще жодного разу не були заброньовані.

SELECT r.room_number
FROM rooms AS r LEFT JOIN bookings AS b ON r.id = b.room_id
WHERE b.id IS NULL;

-- 9 Отримати список клієнтів, у яких день народження збігається із
--   днем народження Івана Іваненка.

SELECT c.first_name || ' ' || c.last_name AS full_name
FROM clients AS c
WHERE c.birthday IN (
-- IN для того, щоб уникнути того, що Іванів Іваненків буде декілька
  SELECT c.birthday
  FROM clients AS c
  WHERE c.first_name = 'Іван'
    AND c.last_name = 'Іваненко'
);

-- 10 Відобразити клієнтів, які мають середню оцінку вищу, ніж Іван Іваненко.

SELECT c.first_name || ' ' || c.last_name AS full_name, AVG(b.rating) AS avg_rating
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
GROUP BY c.id
HAVING AVG(b.rating) > ANY(
-- ANY для того, щоб уникнути того, що Іванів Іваненків буде декілька
    SELECT AVG(b2.rating)
    FROM clients AS c2 INNER JOIN bookings AS b2 ON c2.id = b2.client_id
    WHERE c2.first_name = 'Іван'
      AND c2.last_name = 'Іваненко'
);

-- 11 Отримати список номерів, у яких вартість за добу більша, ніж у номера 101.

SELECT r.room_number
FROM rooms AS r
WHERE r.daily_cost > (
  SELECT r2.daily_cost
  FROM rooms AS r2
  WHERE r2.room_number = 101
);

-- 12 Отримати список клієнт | номер | оцінка, де оцінка має бути більшою 
--    за будь-яку оцінку Івана Іваненка.

SELECT c.first_name || ' ' || c.last_name AS full_name, r.room_number, b.rating
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
                  INNER JOIN rooms AS r ON r.id = b.room_id
WHERE b.rating IS NOT NULL AND b.rating > ANY(
  SELECT b2.rating
  FROM bookings AS b2 INNER JOIN clients AS c2 ON b2.client_id = c2.id
  WHERE b2.rating IS NOT NULL
    AND c2.first_name = 'Іван'
    AND c2.last_name = 'Іваненко'
);

-- 13 Вивести клієнт | номер | оцінка, щоб оцінка виводилася у вигляді 
--    "відмінно", "добре" або "задовільно".

SELECT c.first_name || ' ' || c.last_name AS full_name, r.room_number, CASE
  WHEN b.rating IS NULL THEN 'ще не оцінено'
  WHEN rating >= 4.5 THEN 'відмінно'
  WHEN rating >= 3.5 THEN 'добре'
  WHEN rating >= 3.0 THEN 'задовільно'
  ELSE 'незадовільно'
END AS rating_description
FROM clients AS c INNER JOIN bookings AS b ON c.id = b.client_id
                  INNER JOIN rooms AS r ON r.id = b.room_id
