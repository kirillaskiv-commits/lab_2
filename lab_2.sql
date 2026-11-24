-- 1.1. Список таблиц
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 1.2. Столбцы и типы данных
SELECT table_name, ordinal_position, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- 1.3. Первичные и внешние ключи
SELECT
    tc.table_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
   AND tc.table_schema = ccu.table_schema
WHERE tc.table_schema = 'public'
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY tc.table_name, tc.constraint_type, kcu.column_name;

-- 2.1. Все пользователи
SELECT *
FROM users;

-- 2.2. Имя, логин и адрес электронной почты
SELECT name, username, email
FROM users;

-- 2.3. Активные пользователи
SELECT *
FROM users
WHERE isactive = TRUE;

-- 2.4. Пользователи с начальным уровнем B1
SELECT *
FROM users
WHERE initiallevel = 'B1';

-- 2.5. Пользователи, зарегистрированные после указанной даты
SELECT *
FROM users
WHERE createdat >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
ORDER BY createdat;

-- 3.1. Все слова
SELECT *
FROM words;

-- 3.2. Английское слово, перевод и часть речи
SELECT texten, textl AS translation, partofspeech
FROM words;

-- 3.3. Слова уровня B1
SELECT texten, textl, partofspeech, difficultylevel
FROM words
WHERE difficultylevel = 'B1';

-- 3.4. Слова, содержащие "ing"
SELECT *
FROM words
WHERE texten ILIKE '%ing%';

-- 3.5. Слова в алфавитном порядке
SELECT texten, textl, difficultylevel
FROM words
ORDER BY texten ASC;

-- 3.6. Количество слов каждого уровня сложности
SELECT difficultylevel, COUNT(*) AS word_count
FROM words
GROUP BY difficultylevel
ORDER BY difficultylevel;

-- 3.7. Количество слов каждой части речи
SELECT partofspeech, COUNT(*) AS word_count
FROM words
GROUP BY partofspeech
ORDER BY word_count DESC;

-- 4.1. Средний показатель успешности
SELECT AVG(successrate) AS average_success_rate
FROM userwordprogress;

-- 4.2. Максимальный и минимальный показатель успешности
SELECT MAX(successrate) AS max_success_rate,
       MIN(successrate) AS min_success_rate
FROM userwordprogress;

-- 4.3. Среднее количество повторений слова
SELECT AVG(reviewcount) AS average_review_count
FROM userwordprogress;

-- 4.4. Количество изученных слов
SELECT COUNT(*) AS known_words
FROM userwordprogress
WHERE isknown = TRUE;

-- 4.5. Количество ещё не освоенных слов
SELECT COUNT(*) AS unknown_words
FROM userwordprogress
WHERE isknown = FALSE;

-- 4.6. Слова с самой высокой успешностью
SELECT u.username, w.texten, w.textl AS translation,
       p.successrate, p.reviewcount
FROM userwordprogress p
JOIN users u ON u.id = p.userid
JOIN words w ON w.id = p.wordid
ORDER BY p.successrate DESC NULLS LAST
LIMIT 10;

-- 4.7. Слова с наибольшим количеством повторений
SELECT u.username, w.texten, w.textl AS translation,
       p.reviewcount, p.successrate
FROM userwordprogress p
JOIN users u ON u.id = p.userid
JOIN words w ON w.id = p.wordid
ORDER BY p.reviewcount DESC NULLS LAST
LIMIT 10;


-- 5.1. Общее количество попыток повторения
SELECT COUNT(*) AS total_attempts
FROM wordreviews;

-- 5.2. Количество правильных и неправильных ответов
SELECT
    COUNT(*) FILTER (WHERE iscorrect = TRUE) AS correct_answers,
    COUNT(*) FILTER (WHERE iscorrect = FALSE) AS incorrect_answers
FROM wordreviews;

-- 5.3. Среднее время ответа в миллисекундах
SELECT AVG(responsetimems) AS average_response_time_ms
FROM wordreviews;

-- 5.4. Среднее время правильного ответа
SELECT AVG(responsetimems) AS average_correct_time_ms
FROM wordreviews
WHERE iscorrect = TRUE;

-- 5.5. Среднее время неправильного ответа
SELECT AVG(responsetimems) AS average_incorrect_time_ms
FROM wordreviews
WHERE iscorrect = FALSE;

-- 5.6. Доля правильных ответов, %
SELECT ROUND(
    100.0 * COUNT(*) FILTER (WHERE iscorrect = TRUE)
    / NULLIF(COUNT(*), 0), 2
) AS correct_answer_percent
FROM wordreviews;

-- 5.7. Количество повторений по каждому пользователю
SELECT u.id, u.username, COUNT(wr.id) AS review_count
FROM users u
LEFT JOIN wordreviews wr ON wr.userid = u.id
GROUP BY u.id, u.username
ORDER BY review_count DESC;

-- 6.1. Все тексты
SELECT *
FROM texts;

-- 6.2. Название текста и язык
SELECT title, language
FROM texts;

-- 6.3. Количество текстов каждого пользователя
SELECT u.id, u.username, COUNT(t.id) AS text_count
FROM users u
LEFT JOIN texts t ON t.userid = u.id
GROUP BY u.id, u.username
ORDER BY text_count DESC;

-- 6.4. Количество текстов по языкам
SELECT language, COUNT(*) AS text_count
FROM texts
GROUP BY language
ORDER BY text_count DESC;

-- 6.5. Тексты, созданные после указанной даты
SELECT *
FROM texts
WHERE createdat >= TIMESTAMPTZ '2025-01-01 00:00:00+00'
ORDER BY createdat;

-- 6.6. Пользователь, название текста, язык и дата создания
SELECT u.name, u.username, t.title, t.language, t.createdat
FROM texts t
JOIN users u ON u.id = t.userid
ORDER BY t.createdat DESC;

-- 7.1. Среднее словарное покрытие
SELECT AVG(coveragepercent) AS average_coverage_percent
FROM textvocabularystats;

-- 7.2. Текст с максимальным словарным покрытием
SELECT t.title, s.coveragepercent
FROM textvocabularystats s
JOIN texts t ON t.id = s.textid
ORDER BY s.coveragepercent DESC NULLS LAST
LIMIT 1;

-- 7.3. Текст с минимальным словарным покрытием
SELECT t.title, s.coveragepercent
FROM textvocabularystats s
JOIN texts t ON t.id = s.textid
ORDER BY s.coveragepercent ASC NULLS LAST
LIMIT 1;

-- 7.4. Количество известных и неизвестных слов в каждом тексте
SELECT t.title, s.totalwords, s.knownwords, s.unknownwords
FROM textvocabularystats s
JOIN texts t ON t.id = s.textid
ORDER BY t.title;

-- 7.5. Название текста и его словарное покрытие
SELECT t.title, s.coveragepercent
FROM texts t
JOIN textvocabularystats s ON s.textid = t.id
ORDER BY s.coveragepercent DESC NULLS LAST;

-- 8.1. Список экзаменов
SELECT *
FROM exams;

-- 8.2. Результаты экзаменов и пользователи
SELECT u.username, e.difficultylevel, e.size, e.takenat,
       er.score, er.estimatedlevel
FROM examresults er
JOIN users u ON u.id = er.userid
JOIN exams e ON e.id = er.examid
ORDER BY e.takenat DESC;

-- 8.3. Средний результат экзаменов
SELECT AVG(score) AS average_exam_score
FROM examresults;

-- 8.4. Максимальный и минимальный результат
SELECT MAX(score) AS max_score, MIN(score) AS min_score
FROM examresults;

-- 8.5. Количество экзаменов каждого уровня сложности
SELECT difficultylevel, COUNT(*) AS exam_count
FROM exams
GROUP BY difficultylevel
ORDER BY difficultylevel;

-- 8.6. Количество результатов по уровню сложности экзамена
SELECT e.difficultylevel, COUNT(er.id) AS result_count
FROM exams e
LEFT JOIN examresults er ON er.examid = e.id
GROUP BY e.difficultylevel
ORDER BY e.difficultylevel;

-- 8.7. Пользователи с результатом выше 80
SELECT u.username, er.score, er.estimatedlevel
FROM examresults er
JOIN users u ON u.id = er.userid
WHERE er.score > 80
ORDER BY er.score DESC;


-- 9. КОМПЛЕКСНЫЙ ЗАПРОС
SELECT
    u.id,
    u.username,
    COUNT(DISTINCT p.wordid) AS studied_word_count,
    ROUND(AVG(p.successrate)::numeric, 2) AS average_success_rate,
    COUNT(DISTINCT p.wordid) FILTER (WHERE p.isknown = TRUE) AS known_word_count
FROM users u
LEFT JOIN userwordprogress p ON p.userid = u.id
LEFT JOIN words w ON w.id = p.wordid
GROUP BY u.id, u.username
ORDER BY known_word_count DESC, average_success_rate DESC NULLS LAST;

-- 10. СОБСТВЕННЫЙ АНАЛИТИЧЕСКИЙ ЗАПРОС
SELECT
    u.username,
    w.texten,
    w.textl AS translation,
    p.successrate,
    p.reviewcount,
    p.isknown
FROM userwordprogress p
JOIN users u ON u.id = p.userid
JOIN words w ON w.id = p.wordid
WHERE p.successrate IS NOT NULL
ORDER BY p.successrate ASC, p.reviewcount DESC
LIMIT 20;
