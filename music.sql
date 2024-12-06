-- Создание базы данных
CREATE DATABASE music_db;

-- Создание схемы
CREATE SCHEMA music;

-- Создание таблиц в схеме music
CREATE TABLE music.genre (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL
);

CREATE TABLE music.artist (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE music.album (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  year INT CHECK (year > 0)
);

CREATE TABLE music.track (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  album_id INT REFERENCES music.album(id),
  duration INT
);

CREATE TABLE music.collection (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  issue_year INT CHECK (issue_year > 0)
);

CREATE TABLE music.genre_to_artist (
  genre_id INT REFERENCES music.genre(id),
  artist_id INT REFERENCES music.artist(id)
);

CREATE TABLE music.artist_to_album (
  artist_id INT REFERENCES music.artist(id),
  album_id INT REFERENCES music.album(id)
);

CREATE TABLE music.track_to_collection (
  track_id INT REFERENCES music.track(id),
  collection_id INT REFERENCES music.collection(id)
);

-- Заполнение таблицы жанров
INSERT INTO music.genre (title) VALUES
('Pop'),
('Rock'),
('Hip-Hop');

-- Заполнение таблицы исполнителей
INSERT INTO music.artist (name) VALUES
('Artist One'),
('Artist Two'),
('Artist Three'),
('Artist');

-- Заполнение таблицы альбомов
INSERT INTO music.album (title, year) VALUES
('Album One', 2019),
('Album Two', 2020),
('Album Three', 2018);

-- Заполнение таблицы треков, с длительностью в секундах
INSERT INTO music.track (name, album_id, duration) VALUES
('Track One', 1, 210),
('My best track', 1, 240),
('Track Three', 2, 180),
('Track Four', 2, 300),
('Мой самый душевный трек', 3, 150),
('Track Six', 3, 420); 

-- Заполнение таблицы сборников
INSERT INTO music.collection (name, issue_year) VALUES
('Collection One', 2019),
('Collection Two', 2020),
('Collection Three', 2018),
('Collection Four', 2021);

-- Связывание исполнителей с жанрами
INSERT INTO music.genre_to_artist (genre_id, artist_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

-- Связывание исполнителей с альбомами
INSERT INTO music.artist_to_album (artist_id, album_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 1);

-- Связывание треков со сборниками
INSERT INTO music.track_to_collection (track_id, collection_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 1),
(6, 2);

-- 1. Название и продолжительность самого длительного трека
SELECT name, duration 
FROM music.track 
ORDER BY duration DESC 
LIMIT 1;

-- 2. Название треков, продолжительность которых не менее 3,5 минут
SELECT name 
FROM music.track 
WHERE duration >= 210;

-- 3. Названия сборников, вышедших в период с 2018 по 2020 год включительно
SELECT name 
FROM music.collection 
WHERE issue_year BETWEEN 2018 AND 2020;

-- 4. Исполнители, чьё имя состоит из одного слова
SELECT name 
FROM music.artist 
WHERE name NOT LIKE '% %';

-- 5. Название треков, которые содержат слово «мой» или «my»
SELECT name 
FROM music.track 
WHERE name ILIKE '%мой%' OR name ILIKE '%my%';

-- 1. Количество исполнителей в каждом жанре
SELECT g.title, COUNT(ga.artist_id) AS artist_count
FROM music.genre g
LEFT JOIN music.genre_to_artist ga ON g.id = ga.genre_id
GROUP BY g.title;

-- 2. Количество треков, вошедших в альбомы 2019–2020 годов
SELECT COUNT(t.id) AS track_count
FROM music.track t
JOIN music.album a ON t.album_id = a.id
WHERE a.year BETWEEN 2019 AND 2020;

-- 3. Средняя продолжительность треков по каждому альбому
SELECT a.title, AVG(t.duration) AS average_duration
FROM music.album a
JOIN music.track t ON a.id = t.album_id
GROUP BY a.title;

-- 4. Все исполнители, которые не выпустили альбомы в 2020 году
SELECT DISTINCT ar.name
FROM music.artist ar
LEFT JOIN music.artist_to_album aa ON ar.id = aa.artist_id
LEFT JOIN music.album al ON aa.album_id = al.id AND al.year = 2020
WHERE al.id IS NULL;

-- 5. Названия сборников, в которых присутствует конкретный исполнитель (например, Artist One)
SELECT DISTINCT c.name
FROM music.collection c
JOIN music.track_to_collection tc ON c.id = tc.collection_id
JOIN music.track t ON tc.track_id = t.id
JOIN music.artist_to_album aa ON t.album_id = aa.album_id
JOIN music.artist ar ON aa.artist_id = ar.id
WHERE ar.name = 'Artist One';

-- 1. Названия альбомов, в которых присутствуют исполнители более чем одного жанра
SELECT a.title
FROM music.album a
JOIN music.artist_to_album aa ON a.id = aa.album_id
JOIN music.genre_to_artist ga ON aa.artist_id = ga.artist_id
GROUP BY a.title
HAVING COUNT(DISTINCT ga.genre_id) > 1;

-- 2. Наименования треков, которые не входят в сборники
SELECT t.name
FROM music.track t
LEFT JOIN music.track_to_collection tc ON t.id = tc.track_id
WHERE tc.collection_id IS NULL;

-- 3. Исполнитель или исполнители, написавшие самый короткий по продолжительности трек
SELECT ar.name
FROM music.artist ar
JOIN music.artist_to_album aa ON ar.id = aa.artist_id
JOIN music.album a ON aa.album_id = a.id
JOIN music.track t ON a.id = t.album_id
WHERE t.duration = (SELECT MIN(duration) FROM music.track);

-- 4. Названия альбомов, содержащих наименьшее количество треков
SELECT a.title
FROM music.album a
JOIN music.track t ON a.id = t.album_id
GROUP BY a.title
HAVING COUNT(t.id) = (SELECT MIN(track_count)
                      FROM (SELECT COUNT(id) AS track_count
                            FROM music.track
                            GROUP BY album_id) AS subquery);