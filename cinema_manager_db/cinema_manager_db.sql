CREATE DATABASE cinema_manager;

-- Поки не передбачав ніяких users з різними role, бо ще не знаю, як це робити
-- й зосередився на предметній області

CREATE TABLE IF NOT EXISTS countries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  country_name VARCHAR(128) NOT NULL UNIQUE CHECK (LENGTH(country_name) >= 2)
  -- Може бути й PRIMARY KEY, але залишив стандартний id
);

INSERT INTO countries (country_name)
VALUES
    ('USA'),
    ('United Kingdom'),
    ('Ireland'),
    ('Canada');

-- Таблиця персон для акторів та режисерів, адже одна і та ж персона може бути і актором, і режисером
CREATE TABLE IF NOT EXISTS persons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(50) NOT NULL CHECK (LENGTH(first_name) >= 2),
  last_name VARCHAR(50) NOT NULL CHECK (LENGTH(last_name) >= 2),
  birth_date DATE,
  country_id UUID REFERENCES countries(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  -- не робив country та birth_date обов'язковими
  photo TEXT,
  biography VARCHAR(2000)
);

INSERT INTO persons (first_name, last_name, birth_date, country_id, photo, biography)
VALUES
    (
      'Matthew',
      'McConaughey',
      '1969-11-04',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqfu-8n0ljUW4HAw5VtBpUkxB09VQ3SjoG4i3rDdk1WQsCfl8PMftbeakmk-hrYbDyA9YrFQ5lm7s0QVxg_VxAk9mvx9HXA_7iXsMqFww&s=10',
      'Academy Award-winning American actor.'
    ),
    (
      'Anne',
      'Hathaway',
      '1982-11-12',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Anne_Hathaway-_Press_conference_for_the_film_%22The_Devil_Wears_Prada_2%22_-_55194764955_%28cropped%29.jpg/960px-Anne_Hathaway-_Press_conference_for_the_film_%22The_Devil_Wears_Prada_2%22_-_55194764955_%28cropped%29.jpg',
      'American actress and Academy Award winner.'
    ),
    (
      'Jessica',
      'Chastain',
      '1977-03-24',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/1/11/Jessica_Chastain-64631_%28cropped%29.jpg',
      'American actress and producer.'
    ),
    (
      'Joaquin',
      'Phoenix',
      '1974-10-28',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/d/dc/Joaquin_Phoenix-64908_%28cropped%29.jpg',
      'American actor known for intense dramatic roles.'
    ),
    (
      'Cillian',
      'Murphy',
      '1976-05-25',
      (SELECT id FROM countries WHERE country_name = 'Ireland'),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Cillian_Murphy-2014.jpg/250px-Cillian_Murphy-2014.jpg',
      'Irish actor known for Oppenheimer and Peaky Blinders.'
    ),
    (
      'Emily',
      'Blunt',
      '1983-02-23',
      (SELECT id FROM countries WHERE country_name = 'United Kingdom'),
      'https://upload.wikimedia.org/wikipedia/commons/4/45/Emily_Blunt_at_WWD_Style_Awards_2026-02.jpg',
      'British actress.'
    ),
    (
      'Keanu',
      'Reeves',
      '1964-09-02',
      (SELECT id FROM countries WHERE country_name = 'Canada'),
      'https://upload.wikimedia.org/wikipedia/commons/b/b4/Keanu_Reeves_at_TIFF_2025_02_%28Cropped%29.jpg',
      'Canadian actor best known for The Matrix and John Wick.'
    ),
    (
      'Laurence',
      'Fishburne',
      '1961-07-30',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Laurence_Fishburne_at_53rd_Saturn_Awards_2026.jpg/960px-Laurence_Fishburne_at_53rd_Saturn_Awards_2026.jpg',
      'American actor and producer.'
    ),
    (
      'Leonardo',
      'DiCaprio',
      '1974-11-11',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2d/LeoPTABFI191125-28_%28cropped%29.jpg/250px-LeoPTABFI191125-28_%28cropped%29.jpg',
      'Academy Award-winning American actor and producer.'
    ),
    (
      'Joseph',
      'Gordon-Levitt',
      '1981-02-17',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/0/01/Joseph_Gordon_Levitt_Sundance_Film_Festival_2026_%28cropped%29.jpg',
      'American actor and filmmaker.'
    ),
    (
      'Christopher',
      'Nolan',
      '1970-07-30',
      (SELECT id FROM countries WHERE country_name = 'United Kingdom'),
      'https://upload.wikimedia.org/wikipedia/commons/9/95/Christopher_Nolan_Cannes_2018.jpg',
      'British-American film director, producer and screenwriter. Known for large-scale science fiction and psychological thrillers.'
    ),
    (
      'Todd',
      'Phillips',
      '1970-12-20',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/0/0b/Todd_Phillips-64847.jpg',
      'American film director, producer and screenwriter. Best known for Joker and The Hangover trilogy.'
    ),
    (
      'Lana',
      'Wachowski',
      '1965-06-21',
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://upload.wikimedia.org/wikipedia/commons/5/55/Lana_Wachowski-2787_%283x4_cropped%29.jpg',
      'American filmmaker best known for creating The Matrix franchise.'
    );

-- Функція перевірки дати народження
CREATE OR REPLACE FUNCTION check_birth_date()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.birth_date > CURRENT_DATE THEN
    RAISE EXCEPTION 'Birth date cannot be in the past';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Тригер на додавання усіх даних/оновлення із застосуванням дати народження
CREATE TRIGGER birth_date_check
BEFORE INSERT OR UPDATE OF birth_date
ON persons
FOR EACH ROW
EXECUTE FUNCTION check_birth_date();

CREATE TABLE IF NOT EXISTS actors (
  person_id UUID PRIMARY KEY REFERENCES persons(id) ON UPDATE CASCADE ON DELETE CASCADE
  -- Тут PRIMARY KEY, адже у актора МАЄ БУТИ (NOT NULL) УНІКАЛЬНА (UNIQUE) персона
);

INSERT INTO actors (person_id)
  SELECT id
  FROM persons
  WHERE (first_name, last_name) IN (
    ('Matthew', 'McConaughey'),
    ('Anne', 'Hathaway'),
    ('Jessica', 'Chastain'),
    ('Joaquin', 'Phoenix'),
    ('Cillian', 'Murphy'),
    ('Emily', 'Blunt'),
    ('Keanu', 'Reeves'),
    ('Laurence', 'Fishburne'),
    ('Leonardo', 'DiCaprio'),
    ('Joseph', 'Gordon-Levitt')
);

CREATE TABLE IF NOT EXISTS directors (
  person_id UUID PRIMARY KEY REFERENCES persons(id) ON UPDATE CASCADE ON DELETE CASCADE
  -- Тут PRIMARY KEY, адже у директора МАЄ БУТИ (NOT NULL) УНІКАЛЬНА (UNIQUE) персона
);

INSERT INTO directors (person_id)
  SELECT id
  FROM persons
  WHERE (first_name, last_name) IN (
    ('Christopher', 'Nolan'),
    ('Todd', 'Phillips'),
    ('Lana', 'Wachowski')
  );

CREATE TABLE IF NOT EXISTS studios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  studio_name VARCHAR(50) NOT NULL CHECK (LENGTH(studio_name) >= 2),
  founded SMALLINT CHECK (founded <= EXTRACT(YEAR FROM CURRENT_DATE)),
  country_id UUID REFERENCES countries(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  -- не робив country та founded обов'язковими
  logo TEXT,
  description VARCHAR(2000)
);

INSERT INTO studios (studio_name, founded, country_id, logo, description)
VALUES
    (
      'Warner Bros. Pictures',
      1923,
      (SELECT id FROM countries WHERE country_name = 'USA'), 
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKjUsWV5bfTnNebkW8x-TWwAQK7dNtRlhzOe6_021VSQ&s=10',
      'American movie production studio'
    ),
    (
      'DC Films',
      2016,
      (SELECT id FROM countries WHERE country_name = 'USA'), 
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPkOI-5VPQTphP8ywCHIE7HiT1gzDtz-SjNZrHyDhR8A&s',
      'American movie production studio, another one'
    ),
    (
      'Universal Pictures',
      1912,
      (SELECT id FROM countries WHERE country_name = 'USA'),
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCDjUYCMWCJvYgNi5GPXrAo-iX3n5VnbG7vIEZFwSl3Q&s',
      'Another american studio'
    );

CREATE TABLE IF NOT EXISTS genres (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  genre_name VARCHAR(50) NOT NULL UNIQUE CHECK (LENGTH(genre_name) >= 2)
  -- Може бути й PRIMARY KEY, але залишив стандартний id
);

INSERT INTO genres (genre_name)
VALUES
    ('Action'),
    ('Adventure'),
    ('Biography'),
    ('Comedy'),
    ('Crime'),
    ('Drama'),
    ('Fantasy'),
    ('Horror'),
    ('Romance'),
    ('Science Fiction'),
    ('Thriller');

CREATE TABLE IF NOT EXISTS movies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(100) NOT NULL CHECK (LENGTH(title) >= 2),
  release_year SMALLINT NOT NULL,
    CHECK (release_year BETWEEN 1895 AND EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT),
  poster TEXT,
  trailer TEXT,
  description VARCHAR(2000)
);

INSERT INTO movies (
    title,
    release_year,
    poster,
    trailer,
    description
)
VALUES
    (
      'Interstellar',
      2014,
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRN6MBU9VxzNxqU0gzzOsgDR0Mpxn4_6BDHIzD-Xc8YaQ&s=10',
      'https://www.youtube.com/watch?v=zSWdZVtXT7E',
      'A team of astronauts travels through a wormhole in search of a new home for humanity'
    ),
    (
      'Joker',
      2019,
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPOXFFZpg7J8ka6L6mvKWbczd0RSi6cewOp5cssjDsAg&s',
      'https://www.youtube.com/watch?v=zAGVQLHvwOY',
      'Arthur Fleck slowly descends into madness and becomes the Joker'
    ),
    (
      'Oppenheimer',
      2023,
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3gsJAEwsM9Y3lIK2f6M24jtsae8ljoF2kFvC03Qn7Tw&s',
      'https://www.youtube.com/watch?v=uYPbbksJxIg',
      'The story of physicist J. Robert Oppenheimer and the Manhattan Project.'
    );

CREATE TABLE IF NOT EXISTS movies_to_genres (
  genre_id UUID NOT NULL REFERENCES genres(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  movie_id UUID NOT NULL REFERENCES movies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  PRIMARY KEY (genre_id, movie_id)
);

-- Наочне додавання декількох жанрів для кожного фільму
INSERT INTO movies_to_genres (genre_id, movie_id)
VALUES
    (
      (SELECT id FROM genres WHERE genre_name = 'Adventure'),
      (SELECT id FROM movies WHERE title = 'Interstellar')
    ),
    (
      (SELECT id FROM genres WHERE genre_name = 'Drama'),
      (SELECT id FROM movies WHERE title = 'Interstellar')
    ),
    (
      (SELECT id FROM genres WHERE genre_name = 'Science Fiction'),
      (SELECT id FROM movies WHERE title = 'Interstellar')
    ),
    (
      (SELECT id FROM genres WHERE genre_name = 'Crime'),
      (SELECT id FROM movies WHERE title = 'Joker')
    ),
    (
      (SELECT id FROM genres WHERE genre_name = 'Drama'),
      (SELECT id FROM movies WHERE title = 'Joker')
    ),
    (
      (SELECT id FROM genres WHERE genre_name = 'Thriller'),
      (SELECT id FROM movies WHERE title = 'Joker')
    ),
    (
        (SELECT id FROM genres WHERE genre_name = 'Biography'),
        (SELECT id FROM movies WHERE title = 'Oppenheimer')
    ),
    (
      (SELECT id FROM genres WHERE genre_name = 'Drama'),
      (SELECT id FROM movies WHERE title = 'Oppenheimer')
    );

CREATE TABLE IF NOT EXISTS movies_to_actors (
  actor_id UUID NOT NULL REFERENCES actors(person_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  movie_id UUID NOT NULL REFERENCES movies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  character_name VARCHAR(100) NOT NULL,
  -- Ім'я персонажу актора В КОНКРЕТНОМУ фільмі, тому й у цій таблиці зв'язку фільмів з акторами
  PRIMARY KEY (actor_id, movie_id)
  -- Вирішив спробувати PRIMARY KEY без окремого id, адже, як на мене, він тут не потрібен.
  -- Також, зв'язка actor + movie повинна бути унікальною, адже один актор не може 
  -- двічі знятися в одному фільмі
);

INSERT INTO movies_to_actors (actor_id, movie_id, character_name)
VALUES
    (
      (
        SELECT a.person_id
        FROM actors AS a
        INNER JOIN persons AS p ON p.id = a.person_id
        WHERE p.first_name = 'Matthew'
          AND p.last_name = 'McConaughey'
      ),
      (SELECT id FROM movies WHERE title = 'Interstellar'),
      'Cooper'
    ),
    (
      (
        SELECT a.person_id
        FROM actors AS a
        INNER JOIN persons AS p ON p.id = a.person_id
        WHERE p.first_name = 'Anne'
          AND p.last_name = 'Hathaway'
      ),
      (SELECT id FROM movies WHERE title = 'Interstellar'),
      'Amelia Brand'
    ),
    (
      (
        SELECT a.person_id
        FROM actors AS a
        INNER JOIN persons AS p ON p.id = a.person_id
        WHERE p.first_name = 'Jessica'
          AND p.last_name = 'Chastain'
      ),
      (SELECT id FROM movies WHERE title = 'Interstellar'),
      'Murph'
    ),
    (
      (
        SELECT a.person_id
        FROM actors AS a
        INNER JOIN persons AS p ON p.id = a.person_id
        WHERE p.first_name = 'Joaquin'
          AND p.last_name = 'Phoenix'
      ),
      (SELECT id FROM movies WHERE title = 'Joker'),
      'Arthur Fleck'
    ),
    (
      (
        SELECT a.person_id
        FROM actors AS a
        INNER JOIN persons AS p ON p.id = a.person_id
        WHERE p.first_name = 'Cillian'
          AND p.last_name = 'Murphy'
      ),
      (SELECT id FROM movies WHERE title = 'Oppenheimer'),
      'J. Robert Oppenheimer'
    ),
    (
      (
        SELECT a.person_id
        FROM actors AS a
        INNER JOIN persons AS p ON p.id = a.person_id
        WHERE p.first_name = 'Emily'
          AND p.last_name = 'Blunt'
      ),
      (SELECT id FROM movies WHERE title = 'Oppenheimer'),
      'Kitty Oppenheimer'
    );

CREATE TABLE IF NOT EXISTS movies_to_directors (
  director_id UUID NOT NULL REFERENCES directors(person_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  movie_id UUID NOT NULL REFERENCES movies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  PRIMARY KEY (director_id, movie_id)
);

INSERT INTO movies_to_directors (director_id, movie_id)
VALUES
    (
      (
        SELECT d.person_id
        FROM directors AS d
        INNER JOIN persons AS p ON p.id = d.person_id
        WHERE p.first_name = 'Christopher'
          AND p.last_name = 'Nolan'
      ),
      (SELECT id FROM movies WHERE title = 'Interstellar')
    ),
    (
      (
        SELECT d.person_id
        FROM directors AS d
        INNER JOIN persons AS p ON p.id = d.person_id
        WHERE p.first_name = 'Todd'
          AND p.last_name = 'Phillips'
      ),
      (SELECT id FROM movies WHERE title = 'Joker')
    ),
    (
      (
        SELECT d.person_id
        FROM directors AS d
        INNER JOIN persons AS p ON p.id = d.person_id
        WHERE p.first_name = 'Christopher'
          AND p.last_name = 'Nolan'
      ),
      (SELECT id FROM movies WHERE title = 'Oppenheimer')
    );

CREATE TABLE IF NOT EXISTS movies_to_studios (
  studio_id UUID NOT NULL REFERENCES studios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  movie_id UUID NOT NULL REFERENCES movies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  PRIMARY KEY (studio_id, movie_id)
);

INSERT INTO movies_to_studios (
    studio_id,
    movie_id
)
VALUES
    (
      (SELECT id FROM studios WHERE studio_name = 'Warner Bros. Pictures'),
      (SELECT id FROM movies WHERE title = 'Interstellar')
    ),
    (
      (SELECT id FROM studios WHERE studio_name = 'DC Films'),
      (SELECT id FROM movies WHERE title = 'Joker')
    ),
    (
      (SELECT id FROM studios WHERE studio_name = 'Universal Pictures'),
      (SELECT id FROM movies WHERE title = 'Oppenheimer')
    );

-- Запит на отримання усіх акторів з причетними до них фільмами, директорами та студіями
SELECT 
  m.title,
  p_actor.first_name || ' ' || p_actor.last_name AS actor_name,
  p_director.first_name || ' ' || p_director.last_name AS director_name,
  s.studio_name
FROM movies AS m INNER JOIN movies_to_actors AS mta ON m.id = mta.movie_id
                 INNER JOIN actors AS a ON mta.actor_id = a.person_id
                 INNER JOIN persons AS p_actor ON a.person_id = p_actor.id
                 INNER JOIN movies_to_directors AS mtd ON m.id = mtd.movie_id
                 INNER JOIN directors AS d ON mtd.director_id = d.person_id
                 INNER JOIN persons AS p_director ON d.person_id = p_director.id
                 INNER JOIN movies_to_studios AS mts ON m.id = mts.movie_id
                 INNER JOIN studios AS s ON mts.studio_id = s.id;