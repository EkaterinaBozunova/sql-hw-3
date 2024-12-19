
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
WHERE string_to_array(lower(name), ' ') && ARRAY['мой', 'my'];

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
WHERE ar.id NOT IN (
    SELECT aa.artist_id
    FROM music.artist_to_album aa
    JOIN music.album al ON aa.album_id = al.id
    WHERE al.year = 2020
);

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
GROUP BY a.id, aa.artist_id  -- Группируем по ID альбома и ID исполнителя
HAVING COUNT(DISTINCT ga.genre_id) > 1

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