CREATE DATABASE cinema_manager;

-- Поки не передбачав ніяких users з різними role, бо ще не знаю, як це робити
-- й зосередився на предметній області

CREATE TABLE IF NOT EXISTS actors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(50) NOT NULL CHECK (LENGTH(first_name) >= 2),
  last_name VARCHAR(50) NOT NULL CHECK (LENGTH(last_name) >= 2),
  birth_date DATE CHECK (birth_date <= CURRENT_DATE),
  country VARCHAR(50) CHECK (LENGTH(country) >= 2),
  -- не робив country та birth_date обов'язковими
  photo TEXT,
  biography VARCHAR(2000)
);

INSERT INTO actors (first_name, last_name, birth_date, country, photo, biography)
VALUES 
    (
      'Matthew', 
      'McConaughey', 
      '1969-11-04', 
      'USA', 
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqfu-8n0ljUW4HAw5VtBpUkxB09VQ3SjoG4i3rDdk1WQsCfl8PMftbeakmk-hrYbDyA9YrFQ5lm7s0QVxg_VxAk9mvx9HXA_7iXsMqFww&s=10',
      'Academy Award-winning American actor'
    ),
    (
      'Anne', 
      'Hathaway', 
      '1982-11-12', 
      'USA', 
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Anne_Hathaway-_Press_conference_for_the_film_%22The_Devil_Wears_Prada_2%22_-_55194764955_%28cropped%29.jpg/960px-Anne_Hathaway-_Press_conference_for_the_film_%22The_Devil_Wears_Prada_2%22_-_55194764955_%28cropped%29.jpg',
      'American actress and Academy Award winner'
    ),
    (
      'Jessica',
      'Chastain',
      '1977-03-24',
      'USA', 
      'https://upload.wikimedia.org/wikipedia/commons/1/11/Jessica_Chastain-64631_%28cropped%29.jpg',
      'American actress and producer'
    ),
    (
      'Joaquin',
      'Phoenix',
      '1974-10-28',
      'USA', 
      'https://upload.wikimedia.org/wikipedia/commons/d/dc/Joaquin_Phoenix-64908_%28cropped%29.jpg',
      'American actor known for intense dramatic roles'
    ),
    (
      'Cillian',
      'Murphy',
      '1976-05-25',
      'Ireland', 
      'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Cillian_Murphy-2014.jpg/250px-Cillian_Murphy-2014.jpg',
      'Irish actor known for Oppenheimer and Peaky Blinders'
    ),
    (
      'Emily',
      'Blunt',
      '1983-02-23',
      'United Kingdom', 
      'https://upload.wikimedia.org/wikipedia/commons/4/45/Emily_Blunt_at_WWD_Style_Awards_2026-02.jpg',
      'British actress'
    );

CREATE TABLE IF NOT EXISTS directors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name VARCHAR(50) NOT NULL CHECK (LENGTH(first_name) >= 2),
  last_name VARCHAR(50) NOT NULL CHECK (LENGTH(last_name) >= 2),
  birth_date DATE CHECK (birth_date <= CURRENT_DATE),
  country VARCHAR(50) CHECK (LENGTH(country) >= 2),
  -- не робив country та birth_date обов'язковими
  photo TEXT,
  biography VARCHAR(2000)
);

INSERT INTO directors (first_name, last_name, birth_date, country, photo, biography)
VALUES 
    (
      'Christopher',
      'Nolan',
      '1970-07-30',
      'United Kingdom', 
      'https://upload.wikimedia.org/wikipedia/commons/9/95/Christopher_Nolan_Cannes_2018.jpg',
      'British-American film director, producer and screenwriter. Known for large-scale science fiction and psychological thrillers'
    ),
    (
      'Todd',
      'Phillips',
      '1970-12-20',
      'USA', 
      'https://upload.wikimedia.org/wikipedia/commons/0/0b/Todd_Phillips-64847.jpg',
      'American film director, producer and screenwriter. Best known for Joker and The Hangover trilogy'
    );

CREATE TABLE IF NOT EXISTS studios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  studio_name VARCHAR(50) NOT NULL CHECK (LENGTH(studio_name) >= 2),
  founded SMALLINT CHECK (founded <= EXTRACT(YEAR FROM CURRENT_DATE)),
  country VARCHAR(50) CHECK (LENGTH(country) >= 2),
  -- не робив country та founded обов'язковими
  logo TEXT,
  description VARCHAR(2000)
);

INSERT INTO studios (studio_name, founded, country, logo, description)
VALUES
    (
      'Warner Bros. Pictures',
      1923,
      'USA', 
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKjUsWV5bfTnNebkW8x-TWwAQK7dNtRlhzOe6_021VSQ&s=10',
      'American movie production studio'
    ),
    (
      'DC Films',
      2016,
      'USA', 
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPkOI-5VPQTphP8ywCHIE7HiT1gzDtz-SjNZrHyDhR8A&s',
      'American movie production studio, another one'
    );

-- Якщо врахувати, що жанри будуть зберігатись окремо, за своїми id
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
  genre_id UUID NOT NULL REFERENCES genres(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  release_year SMALLINT NOT NULL,
    CHECK (release_year BETWEEN 1895 AND EXTRACT(YEAR FROM CURRENT_DATE)::SMALLINT),
  poster TEXT,
  trailer TEXT,
  director_id UUID NOT NULL REFERENCES directors(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  studio_id UUID NOT NULL REFERENCES studios(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  description VARCHAR(2000)
);

INSERT INTO movies (
    title,
    genre_id,
    release_year,
    poster,
    trailer,
    director_id,
    studio_id,
    description
)
VALUES
    (
      'Interstellar',
      (SELECT id
      FROM genres
      WHERE genre_name = 'Science Fiction'),
      2014,
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRN6MBU9VxzNxqU0gzzOsgDR0Mpxn4_6BDHIzD-Xc8YaQ&s=10',
      'https://www.youtube.com/watch?v=zSWdZVtXT7E',
      (SELECT id
      FROM directors
      WHERE first_name = 'Christopher'
        AND last_name = 'Nolan'),
      (SELECT id
      FROM studios
      WHERE studio_name = 'Warner Bros. Pictures'),
      'A team of astronauts travels through a wormhole in search of a new home for humanity'
    ),
    (
      'Joker',
      (SELECT id
      FROM genres
      WHERE genre_name = 'Drama'),
      2019,
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPOXFFZpg7J8ka6L6mvKWbczd0RSi6cewOp5cssjDsAg&s',
      'https://www.youtube.com/watch?v=zAGVQLHvwOY',
      (SELECT id
      FROM directors
      WHERE first_name = 'Todd'
        AND last_name = 'Phillips'),
      (SELECT id
      FROM studios
      WHERE studio_name = 'DC Films'),
      'Arthur Fleck slowly descends into madness and becomes the Joker'
    );

CREATE TABLE IF NOT EXISTS movies_to_actors (
  actor_id UUID NOT NULL REFERENCES actors(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  movie_id UUID NOT NULL REFERENCES movies(id) ON UPDATE CASCADE ON DELETE RESTRICT,
  PRIMARY KEY (actor_id, movie_id)
  -- Вирішив спробувати PRIMARY KEY без окремого id, адже, як на мене, він тут не потрібен.
  -- Також, зв'язка actor + movie повинна бути унікальною, адже один актор не може 
  -- двічі знятися в одному фільмі
);

INSERT INTO movies_to_actors (movie_id, actor_id)
VALUES
    (
      (SELECT id
      FROM movies
      WHERE title = 'Interstellar'),
      (SELECT id
      FROM actors
      WHERE first_name = 'Matthew'
        AND last_name = 'McConaughey')
    ),
    (
      (SELECT id
      FROM movies
      WHERE title = 'Interstellar'),
      (SELECT id
      FROM actors
      WHERE first_name = 'Anne'
        AND last_name = 'Hathaway')
    ),
    (
      (SELECT id
      FROM movies
      WHERE title = 'Interstellar'),
      (SELECT id
      FROM actors
      WHERE first_name = 'Jessica'
        AND last_name = 'Chastain')
    ),
    (
      (SELECT id
      FROM movies
      WHERE title = 'Joker'),
      (SELECT id
      FROM actors
      WHERE first_name = 'Joaquin'
        AND last_name = 'Phoenix')
    );

-- Запит на отримання усіх акторів причетними до них фільмами, директорами та студіями
SELECT m.title, 
       a.first_name || ' ' || a.last_name AS actor_full_name, 
       d.first_name || ' ' || d.last_name AS director_full_name,
       s.studio_name
FROM movies AS m INNER JOIN movies_to_actors AS mta ON m.id = mta.movie_id
                 INNER JOIN actors AS a ON mta.actor_id = a.id
                 INNER JOIN directors AS d ON d.id = m.director_id
                 INNER JOIN studios AS s ON s.id = m.studio_id