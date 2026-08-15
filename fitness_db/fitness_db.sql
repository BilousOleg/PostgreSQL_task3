CREATE DATABASE fitness

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(64) NOT NULL CHECK(first_name <> ''),
  last_name VARCHAR(64) NOT NULL CHECK(last_name <> ''),
  email VARCHAR(64) NOT NULL UNIQUE CHECK (email ~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$'),
  -- співставлення з регулярним виразом без урахування регістру
  registation_date DATE NOT NULL CHECK (registation_date <= CURRENT_DATE)
);

INSERT INTO users (first_name, last_name, email, registation_date)
VALUES
    ('Олександр', 'Коваленко', 'oleksandr.kovalenko@example.com', '2025-01-15'),
    ('Анна', 'Шевченко', 'anna.shevchenko@example.com', '2025-02-03'),
    ('Максим', 'Бондар', 'maksym.bondar@example.com', '2025-03-20'),
    ('Марія', 'Данилюк', 'maria.danyliuk@example.com', '2025-04-11'),
    ('Ігор', 'Мельник', 'ihor.melnyk@example.com', '2025-05-07'),
    ('Валерія', 'Хрипко', 'valeriia.khrypko@example.com', '2025-06-18'),
    ('Андрій', 'Ткаченко', 'andrii.tkachenko@example.com', '2025-07-02'),
    ('Софія', 'Романенко', 'sofia.romanenko@example.com', '2025-08-14'),
    ('Дмитро', 'Лисенко', 'dmytro.lysenko@example.com', '2025-09-25'),
    ('Іван', 'Іваненко', 'ivan.ivanenko@example.com', '2025-10-09');

CREATE TABLE IF NOT EXISTS trainers (
  id SERIAL PRIMARY KEY,
  trainer_name VARCHAR(64) NOT NULL CHECK(trainer_name <> ''),
  specialty VARCHAR(128) NOT NULL CHECK (specialty <> ''),
  experience_since DATE NOT NULL CHECK (experience_since <= CURRENT_DATE)
);

INSERT INTO trainers (trainer_name, specialty, experience_since)
VALUES
    ('Олена Петренко', 'Йога та розтяжка', '2018-03-12'),
    ('Артем Савченко', 'Силові тренування', '2016-09-01'),
    ('Наталія Коваль', 'Кардіо та функціональні тренування', '2019-05-20'),
    ('Сергій Бондаренко', 'Функціональний тренінг', '2017-11-15'),
    ('Катерина Мельник', 'Йога та розтяжка', '2020-02-10');

CREATE TYPE training_category AS ENUM ('йога', 'силові', 'кардіо', 'розтяжка', 'функціональні');

CREATE TABLE IF NOT EXISTS trainings (
  id SERIAL PRIMARY KEY,
  trainer_id INTEGER REFERENCES trainers(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  training_name VARCHAR(128) NOT NULL CHECK (training_name <> ''),
  training_type training_category NOT NULL,
  duration SMALLINT NOT NULL CHECK (duration > 0),
  -- duration - кількість хвилин
  price NUMERIC(7, 2) NOT NULL CHECK (price >= 0)
);

INSERT INTO trainings (trainer_id, training_name, training_type, duration, price)
VALUES
    (1, 'Ранкова йога', 'йога', 45, 150.00),
    (1, 'Глибока розтяжка', 'розтяжка', 40, 130.00),
    (2, 'Силове тренування для початківців', 'силові', 60, 250.00),
    (2, 'Силовий комплекс', 'силові', 75, 300.00),
    (3, 'Кардіо 30 хвилин', 'кардіо', 30, 120.00),
    (3, 'Інтенсивне кардіо', 'кардіо', 50, 220.00),
    (4, 'Функціональне тренування', 'функціональні', 60, 280.00),
    (4, 'Функціональний комплекс', 'функціональні', 45, 230.00),
    (5, 'Йога для початківців', 'йога', 60, 180.00),
    (5, 'Розслаблююча розтяжка', 'розтяжка', 35, 110.00),
    (2, 'Силова витривалість', 'силові', 55, 260.00),
    (3, 'Кардіо HIIT', 'кардіо', 35, 200.00);

CREATE TABLE IF NOT EXISTS subscriptions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  duration_months SMALLINT NOT NULL CHECK (duration_months > 0),
  price_per_month NUMERIC (7, 2) NOT NULL CHECK (price_per_month >= 0),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL CHECK (end_date > start_date)
);

INSERT INTO subscriptions (user_id, duration_months, price_per_month, start_date, end_date)
VALUES
    (1, 1, 500.00, CURRENT_DATE, CURRENT_DATE + 14),
    (2, 12, 350.00, '2026-01-15', '2027-01-15'),
    (3, 3, 450.00, CURRENT_DATE, CURRENT_DATE + 21),
    (4, 1, 500.00, '2026-02-20', '2026-03-20'),
    (5, 6, 400.00, '2026-03-01', '2026-09-01'),
    (6, 12, 350.00, '2026-03-10', '2027-03-10'),
    (7, 1, 500.00, '2026-04-05', '2026-05-05'),
    (8, 3, 450.00, '2026-05-01', '2026-08-01'),
    (9, 6, 400.00, '2026-06-01', '2026-12-01'),
    (10, 1, 500.00, '2026-07-01', '2026-08-01');

CREATE TYPE access_type AS ENUM ('subscription', 'single_purchase');

CREATE TABLE IF NOT EXISTS completions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    training_id INTEGER NOT NULL REFERENCES trainings(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    completion_date DATE NOT NULL,
    access_type access_type NOT NULL
);

INSERT INTO completions (user_id, training_id, completion_date, access_type)
VALUES
    (1, 1, CURRENT_DATE, 'subscription'),
    (1, 3, CURRENT_DATE, 'subscription'),
    (2, 5, CURRENT_DATE - 2, 'subscription'),
    (2, 9, CURRENT_DATE - 3, 'subscription'),
    (3, 3, CURRENT_DATE - 4, 'subscription'),
    (3, 7, CURRENT_DATE - 5, 'subscription'),
    (4, 1, '2026-02-25', 'subscription'),
    (4, 10, CURRENT_DATE - 14, 'single_purchase'),
    (5, 4, '2026-03-12', 'subscription'),
    (5, 6, '2026-04-01', 'subscription'),
    (6, 9, '2026-03-15', 'subscription'),
    (6, 11, '2026-04-10', 'subscription'),
    (7, 2, '2026-04-10', 'subscription'),
    (7, 8, '2026-04-20', 'single_purchase'),
    (8, 5, '2026-05-10', 'subscription'),
    (8, 12, '2026-05-15', 'subscription'),
    (9, 7, '2026-06-05', 'subscription'),
    (9, 3, '2026-06-12', 'single_purchase'),
    (10, 1, '2026-07-05', 'subscription'),
    (10, 6, '2026-07-15', 'single_purchase');

DROP TABLE completions;
DROP TABLE subscriptions;
DROP TABLE trainings;
DROP TABLE trainers;
DROP TABLE users;

-- 1 Список тренувань конкретного користувача

SELECT DISTINCT t.training_name, t.training_type, t.duration
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
                    INNER JOIN users AS u ON u.id = c.user_id
WHERE u.id = 1; -- Обираю певного користувача за його id

-- 2 Перелік тренувань, пройдених сьогодні

SELECT DISTINCT t.training_name, t.training_type, t.duration
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
WHERE c.completion_date = CURRENT_DATE;

-- 3 Перелік тренувань за тиждень

-- Якщо тиждень - це проміжок в 7 днів
SELECT DISTINCT t.training_name, t.training_type, t.duration
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
WHERE c.completion_date >= CURRENT_DATE - 6;

-- Якщо мається на увазі саме поточний тиждень
SELECT DISTINCT t.training_name, t.training_type, t.duration
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
WHERE c.completion_date >= DATE_TRUNC('week', CURRENT_DATE)::DATE
  AND c.completion_date < (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week')::DATE;

-- 4 Загальний дохід за день

-- Якщо враховувати тільки купування окремих тренувань
SELECT COALESCE(SUM(t.price), 0) AS total_income
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
WHERE c.completion_date = CURRENT_DATE
  AND c.access_type = 'single_purchase';

-- Якщо також врахувати підписки
SELECT
    COALESCE((
        SELECT SUM(t.price)
        FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
        WHERE c.completion_date = CURRENT_DATE
          AND c.access_type = 'single_purchase'
    ), 0)
    +
    COALESCE((
        SELECT SUM(s.duration_months * s.price_per_month)
        FROM subscriptions AS s
        WHERE s.start_date = CURRENT_DATE
    ), 0) AS total_income;

-- 5 Дохід за місяць

-- Якщо враховувати тільки купування окремих тренувань
SELECT COALESCE(SUM(t.price), 0) AS total_income
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
WHERE c.completion_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE
  AND c.completion_date < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE
  AND c.access_type = 'single_purchase';

-- Якщо також врахувати підписки
SELECT
    COALESCE((
        SELECT SUM(t.price)
        FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
        WHERE c.completion_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE
          AND c.completion_date < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE
          AND c.access_type = 'single_purchase'
    ), 0)
    +
    COALESCE((
        SELECT SUM(s.duration_months * s.price_per_month)
        FROM subscriptions AS s
        WHERE s.start_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE
          AND s.start_date < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE
    ), 0) AS total_income;

-- 6 Список активних користувачів за місяць

SELECT DISTINCT u.first_name, u.last_name
FROM users AS u INNER JOIN completions AS c ON u.id = c.user_id
WHERE c.completion_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE
  AND c.completion_date < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE;

-- 7 Топ 5 найпопулярніших тренувань

-- Якщо враховувати популярність як кількість ПРОХОДЖЕНЬ тренувань
SELECT t.training_name, COUNT(c.id) AS completion_count
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
GROUP BY t.id, t.training_name
ORDER BY completion_count DESC
LIMIT 5;

-- Якщо враховувати популярність як кількість унікальних користувачів, що пройшли тренування
SELECT t.training_name, COUNT(DISTINCT c.user_id) AS user_count
FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
GROUP BY t.id, t.training_name
ORDER BY user_count DESC
LIMIT 5;

-- 8 Прибуток платформи за місяць (3%)

SELECT
    COALESCE((
        SELECT SUM(t.price)
        FROM trainings AS t INNER JOIN completions AS c ON t.id = c.training_id
        WHERE c.completion_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE
          AND c.completion_date < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE
          AND c.access_type = 'single_purchase'
    ), 0)
    +
    COALESCE((
        SELECT SUM(s.duration_months * s.price_per_month)
        FROM subscriptions AS s
        WHERE s.start_date >= DATE_TRUNC('month', CURRENT_DATE)::DATE
          AND s.start_date < (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month')::DATE
    ), 0) * 0.03 AS platform_income;