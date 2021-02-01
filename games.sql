/*В базе данных games хранится информация о компьютерных играх. Можно получать информацию и сортировать игры по жанрам,
 платформам, создателям, датам релиза и т.д. Также пользователи могут регистрировать аккаунты на сайте и добавлять игры себе в коллекицю. 
 Есть информация о создателях игр, они также могут иметь свои аккаунты. На основании пользовательских лайков составляются рейтинги игр.
 В качестве развития можно реализовать покупку игр на этом же сайте.
 Содержание файла:
 Создание структуры БД (12 стр.)
 Наполнение БД тестовыми данными (162 стр.)
 Скрипты характерных выборок (362 стр.)
 Представления (384 стр.)
 Хранимые процедуры (414 стр.) */

-- СОЗДАНИЕ СТРУКТУРЫ БД 

DROP DATABASE IF EXISTS games;
CREATE DATABASE games;
USE games;


DROP TABLE IF EXISTS country;
CREATE TABLE country (
	id SERIAL PRIMARY KEY, 
    name VARCHAR(255) COMMENT 'Название'
) COMMENT 'Страны';


DROP TABLE IF EXISTS developer;
CREATE TABLE developer (
	id SERIAL PRIMARY KEY, 
    name VARCHAR(255) COMMENT 'Название',
    country BIGINT UNSIGNED DEFAULT NULL COMMENT 'Страна',
    date_added DATETIME DEFAULT NOW() COMMENT 'Дата добавления на сайт', 
    
	FOREIGN KEY (country) REFERENCES country(id)
) COMMENT 'Компании разработчики';


DROP TABLE IF EXISTS all_games;
CREATE TABLE all_games (
	id SERIAL PRIMARY KEY, 
    name VARCHAR(255) COMMENT 'Название',
    description TEXT COMMENT 'Описание',
    developer BIGINT UNSIGNED DEFAULT NULL COMMENT 'Разработчик',
	release_date DATETIME DEFAULT NOW() COMMENT 'Дата выхода',
	date_added DATETIME DEFAULT NOW() COMMENT 'Дата добавления на сайт',
	
	FOREIGN KEY (developer) REFERENCES developer(id),
	INDEX developer_games(name, developer)
) COMMENT 'Игры';
	

DROP TABLE IF EXISTS platform;
CREATE TABLE platform(
	id SERIAL,
    name VARCHAR(255) COMMENT 'Название', 
    date_added DATETIME DEFAULT NOW() COMMENT 'Дата добавления на сайт'
) COMMENT 'Платформы';


DROP TABLE IF EXISTS genre;
CREATE TABLE genre(
	id SERIAL,
    name VARCHAR(255) COMMENT 'Название', 
    date_added DATETIME DEFAULT NOW() COMMENT 'Дата добавления на сайт'
) COMMENT 'Жанры';


DROP TABLE IF EXISTS games_platform;
CREATE TABLE games_platform (
	game_id BIGINT UNSIGNED NOT NULL,
	platform_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (game_id, platform_id),
	
	CONSTRAINT delete_game FOREIGN KEY (game_id) 
        REFERENCES all_games(id) ON DELETE CASCADE, -- каскадное удаление связи при удалении игры
    CONSTRAINT delete_platform FOREIGN KEY (platform_id) 
        REFERENCES platform(id) ON DELETE CASCADE  -- каскадное удаление связи при удалении платформы
)COMMENT='Таблица связи игр и платформ';


DROP TABLE IF EXISTS games_genre;
CREATE TABLE games_genre (
	game_id BIGINT UNSIGNED NOT NULL,
	genre_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (game_id, genre_id),
	
	CONSTRAINT delete_game2 FOREIGN KEY (game_id) 
        REFERENCES all_games(id) ON DELETE CASCADE, -- каскадное удаление связи при удалении игры
    CONSTRAINT delete_genre FOREIGN KEY (genre_id) 
        REFERENCES genre(id) ON DELETE CASCADE  -- каскадное удаление связи при удалении жанра
)COMMENT='Таблица связи игр и жанров';


DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, 
    login VARCHAR(255) UNIQUE COMMENT 'Логин',
    name VARCHAR(255) COMMENT 'Имя Фамилия',
    email VARCHAR(120) UNIQUE,
 	password_hash VARCHAR(100),
	phone BIGINT UNSIGNED UNIQUE, 
	birthday DATE,
	country BIGINT UNSIGNED DEFAULT NULL,
	date_added DATETIME DEFAULT NOW() COMMENT 'Дата регистрации на сайте',
	
	
	FOREIGN KEY (country) REFERENCES country(id)
) COMMENT 'Пользователи';


DROP TABLE IF EXISTS users_games;
CREATE TABLE users_games(
	user_id BIGINT UNSIGNED NOT NULL,
	game_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, game_id), 
    
    CONSTRAINT delete_user FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE, -- каскадное удаление связи при удалении пользователя
    CONSTRAINT delete_game3 FOREIGN KEY (game_id) 
        REFERENCES all_games(id) ON DELETE CASCADE -- каскадное удаление связи при удалении игры
) COMMENT 'Игры пользователя';


DROP TABLE IF EXISTS creator;
CREATE TABLE creator (
	id SERIAL PRIMARY KEY, 
    name VARCHAR(255) COMMENT 'Имя Фамилия',
    profession VARCHAR(255) COMMENT 'Род деятельности',
	user_id BIGINT UNSIGNED COMMENT 'Пользователь на этом сайте',
	country BIGINT UNSIGNED DEFAULT NULL,
	
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (country) REFERENCES country(id)
) COMMENT 'Создатели';


DROP TABLE IF EXISTS creator_games;
CREATE TABLE creator_games (
	game_id BIGINT UNSIGNED NOT NULL,
	creator_id BIGINT UNSIGNED NOT NULL,
	PRIMARY KEY (game_id, creator_id),
	
	CONSTRAINT delete_game4 FOREIGN KEY (game_id) 
        REFERENCES all_games(id) ON DELETE CASCADE, -- каскадное удаление связи при удалении игры
    CONSTRAINT delete_creator FOREIGN KEY (creator_id) 
        REFERENCES creator(id) ON DELETE CASCADE  -- каскадное удаление связи при удалении платформы
)COMMENT='Таблица связи игр и создателей';


DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (game_id) REFERENCES all_games(id)
) COMMENT 'Лайки пользователей';


-- НАПОЛНЕНИЕ БД ДАННЫМИ


INSERT INTO country(name) VALUES
	('Соединенные Штаты Америки'),
	('Великобритания'),
	('Польша'),
	('Дания'),
	('Канада'),
	('Болгария'),
	('Австрия'),
	('Россия'),
	('Германия'),
	('Франция');
  

INSERT INTO developer(name, country) VALUES
	('CI Games S.A', '3'),
	('Aspyr Media', '1'),
	('Rockstar North', '2'),
	('Rockstar Games', '1'),
	('Bethesda Game Studios', '1'),
	('Ubisoft Montreal', '5'),
	('IO Interactive', '4'),
	('Warner Bros. Interactive', '1'),
	('Feral Interactive', '2'),
	('THQ Nordic', '7');


INSERT INTO all_games(name, description, developer, release_date) VALUES
	('Enemy Front', 'На фоне ультрареалистичных декораций различных захватывающих мест Европы вы почувствуете себя в роли американского военкора Роберта Хокинза.', '1', '2014-05-01'),
	('Borderlands 2', 'Borderlands номер два — такая же, как и первая, только лучше. К сожалению для остального человечества, «лучше» еще не значит, что она хороша.', '2', '2012-09-18'),
	('Grand Theft Auto V', '«Взросление — это не про меня, я тачки угоняю и людей убиваю», — в сердцах выпаливает один из главных героев игры, чернокожий бандит Франклин.', '3', '2013-09-17'),
	('Red Dead Redemption 2', 'Америка, 1899 год. Артур Морган и другие подручные Датча ван дер Линде вынуждены пуститься в бега.', '4', '2018-10-26'),
	('Fallout 4', 'Каждый миг вы сражаетесь за выживание, каждое решение может стать последним. Но именно от вас зависит судьба пустошей. Добро пожаловать домой.', '5', '2015-11-09'),
	('The Elder Scrolls V: Skyrim', 'Снег на мониторе и за окном. Skyrim повезло не только со стильной датой релиза «11-11-11», но и с погодой, по крайней мере, в подмосковных краях. ', '5', '2011-11-11'),
	('Fallout 3', 'Ролевые игры, выпущенные Interplay на рубеже тысячелетий, по праву вошли в «золотой фонд» этого благородного жанра. ', '5', '2018-10-28'),
	('Assassin`s Creed II', 'Создавая продолжение популярной игры, современный разработчик осторожен и методичен, как наемный убийца, выбирающий удачный момент для атаки. ', '6', '2009-11-17'),
	('Hitman 2', 'Путешествуйте по миру и выслеживайте свои цели в экзотических местах. От залитых солнцем улиц до темных и опасных тропических лесов, нигде нельзя спрятаться от Агента 47.', '7', '2018-11-13'),
	('Mortal Kombat X', 'Сочетая в себе кинематографическую подачу беспрецедентного качества и обновленную игровую механику, Mortal Kombat X являет миру самую брутальную из всех Смертельных битв', '8', '2015-04-07');


INSERT INTO platform(name) VALUES
	('PC'),
	('PlayStation'),
	('Xbox 360'),
	('Xbox One'),
	('PlayStation 4'),
	('macOS'),
	('Nintendo Switch'),
	('IOS'),
	('Android'),
	('PlayStation 3');


INSERT INTO genre(name) VALUES
	('Экшены'),
	('Шутеры'),
	('Ролевые'),
	('Стратегии'),
	('Головоломки'),
	('Гонки'),
	('Спорт'),
	('Симуляторы'),
	('Приключения'),
	('Файтинги');


INSERT INTO games_platform VALUES
	('1', '1'),
	('1', '2'),
	('1', '3'),
	('2', '1'),
	('2', '2'),
	('2', '3'),
	('2', '4'),
	('2', '5'),
	('2', '6'),
	('3', '1'),
	('3', '2'),
	('3', '5'),
	('4', '1'),
	('4', '2'),
	('5', '1'),
	('5', '2'),
	('5', '3'),
	('6', '7'),
	('7', '1'),
	('7', '5'),
	('8', '5'),
	('8', '6'),
	('9', '1'),
	('9', '2'),
	('10', '1'),
	('10', '9');


INSERT INTO games_genre VALUES
	('1', '1'),
	('1', '2'),
	('2', '1'),
	('2', '2'),
	('2', '3'),
	('3', '1'),
	('4', '1'),
	('4', '9'),
	('5', '1'),
	('5', '3'),
	('6', '1'),
	('6', '3'),
	('8', '1'),
	('9', '1'),
	('9', '2'),
	('10', '1'),
	('10', '10');


INSERT INTO users(login, name, email, password_hash, phone, birthday, country) VALUES
	('Cris_Velasco', 'Cris Velasco', 'Cris_Velasco@com', '6acd32e72d0d8a6a4b734652cd27dfc81fce94a5','89470209697', '1974-05-01','1'),
	('Dan_Houser', 'Dan Houser', 'Dan_Houser@com', '6acd32e72d0d8a6a4b734652cd27dfc81fce94a5','89470209698', '1973-01-05','2'),
	('Aaron_Garbut', 'Aaron Garbut', 'Aaron_Garbut@com', '6acd32e72d0d8a6a4b734652cd27dfc81fce94a5','89470209699', NULL,'2'),
	('Guy_Carver', 'Guy Carver', 'Guy_Carvert@com', '6acd32e72d0d8a6a4b734652cd27dfc81fce94a5','89470209799', NULL, NULL),
	('Filiberto_Marks', 'Filiberto Marks', 'emily.bins@example.com','c99adc067978eda298ce71a2cb86a8771d242eaf','89470209007', '2005-11-13', '3'),
	('Kristy_Hirthe', 'Kristy Hirthe', 'heller.deonte@example.org','6acd32e72d0d8a6a4b734652cd27dfc81fce94a5','89934206774', '2001-05-03', '4'),
	('Gerard_Kassulke', 'Gerard Kassulke', 'ashtyn.vandervort@example.net','09af8f54637160e97877c301943479ac53f81a47','89854748562', '1995-06-07', '5'),
	('Esther_Rippin', 'Esther Rippin', 'lonie32@example.net','fb3b8a882f7346d68944ea124de817934066b0d5','89715768580', '1990-11-11', '6'),
	('Claire_Murray', 'Claire Murray','odibbert@example.org','628ae8925e21a99e86dab595cc1bf0111345a87e','89087125215', '1973-07-06', '7'),
	('Lisette_Reichel','Lisette Reichel','ncollier@example.org','7f07152c0011e423f9913cedf25d5d2bed633f77','89072770445', '1987-05-04', '9'),
	('Valerie_Koepp','Valerie Koepp','patsy.green@example.org','52235793e605b81f3cfba35c8c3215d4a63729d8','89979459794', '1991-10-10', '8'),
	('Vincenzo_Vandervort', 'Vincenzo Vandervort','krajcik.lempi@example.com','713801f1551f37b418ac5ce02d1a','89479548037', '1998-12-12', '10'),
	('Emanuel_Jenkins', 'Emanuel Jenkins','tyra.tromp@example.net','75e7d9bc5ce53a56bf147ab0729d18d6f1221a1c','89461565765', '2002-01-01', '6'),
	('Holly_Crona', 'Holly Crona','unitzsche@example.org','5574169331765a55584fcf0407f4e11ba84ac760','89860621422', '2006-08-07', '3'); 


INSERT INTO users_games VALUES
	('1', '3'),
	('4', '5'),
	('4', '7'),
	('14', '1'),
	('5', '2'),
	('5', '3'),
	('7', '10'),
	('11', '5'),
	('11', '6'),
	('12', '6'),
	('3', '9');


INSERT INTO creator(name, profession, user_id, country) VALUES
	('Cris Velasco', 'композитор', '1', '1'),
	('Dan Houser', 'сценарист', '2', '2'),
	('Aaron Garbut', 'художник', '3', '2'),
	('Guy Carver', 'программист', '4', NULL),
	('Emil Pagliarulo', 'сценарист', NULL, '1'),
	('Jesper Kyd', 'композитор', NULL, '4'),
	('Peter McConnell ', 'композитор', NULL, '1'),
	('Rhianna Pratchett', 'сценарист', NULL, '2'),
	('Michael Unsworth', 'сценарист', NULL, NULL),
	('Marcin Przybyłowicz', 'композитор', NULL, '3'),
	('Viktor Antonov', 'художник', NULL, '6'),
	('John Carmack', 'режиссёр', NULL, '1'),
	('Travis Stout', 'сценарист', NULL, '1'),
	('Bruce Nesmith', 'дизайнер', NULL, '1'),
	('Ed Boon', 'программист', NULL, '1');


INSERT INTO creator_games VALUES
	('1', '1'),
	('1', '2'),
	('3', '3'),
	('3', '4'),
	('4', '5'),
	('4', '6'),
	('5', '5'),
	('5', '6'),
	('4', '7'),
	('5', '7'),
	('6', '8'),
	('6', '9');


INSERT INTO likes(user_id, game_id) VALUES 
	('1', '3'),
	('2', '3'),
	('3', '10'),
	('5', '2'),
	('7', '7'),
	('8', '3'),
	('14', '10'),
	('14', '3'),
	('14', '2'),
	('11', '4'),
	('8', '10'),
	('6', '10'),
	('6', '7'),
	('6', '3'),
	('6', '2');


-- СКРИПТЫ ХАРАКТЕРНЫХ ВЫБОРОК (включающие группировки, JOIN'ы, вложенные таблицы)

-- Игры пользователя

select all_games.id AS game_id, all_games.name
from all_games
LEFT JOIN users_games
ON all_games.id = users_games.game_id
where users_games.user_id = '1';

-- Популярные игры, которых нет у пользователя

select all_games.id
from all_games
LEFT JOIN likes  
ON all_games.id = likes.game_id
LEFT JOIN users_games
ON all_games.id != users_games.game_id
where users_games.user_id = '5'	 
GROUP BY all_games.id
ORDER BY count(*) desc
LIMIT 3;

-- ПРЕДСТАВЛЕНИЯ

-- Сортировка по популярности игр (по рейтингу среди пользователей), можно определять ТОП игр

CREATE or replace VIEW range_games
AS
	select all_games.name, count(*) AS 'count_likes'
	from all_games
	LEFT JOIN likes  
	ON all_games.id = likes.game_id
	GROUP BY all_games.name
	ORDER BY count(*) desc;

select *
from range_games
LIMIT 5; 

-- Все игры для платформы

CREATE or replace VIEW games_for_platform
AS
	select all_games.id AS game_id, all_games.name AS name, games_platform.platform_id  AS platform_id 
	from all_games
	LEFT JOIN games_platform
	ON all_games.id = games_platform.game_id;

select game_id, name, platform_id
from games_for_platform
where platform_id = '6';

-- ХРАНИМЫЕ ПРОЦЕДУРЫ/ТРИГГЕРЫ

-- Рекомендуемые игры

DROP PROCEDURE IF EXISTS recommended_games;

DELIMITER //

CREATE PROCEDURE recommended_games(for_user_id BIGINT UNSIGNED)
	BEGIN
		# Игры тех жанров, которые уже есть у пользователя 
		select games_genre.game_id
		FROM games_genre
		right join (select games_genre.genre_id  AS genre_id, users_games.game_id AS game_id
				from games_genre
				left join users_games
				ON games_genre.game_id = users_games.game_id
				where users_games.user_id = for_user_id) AS like_genre	
		ON games_genre.genre_id = like_genre.genre_id and games_genre.game_id != like_genre.game_id
		
			union	
			
		# Покупают пользователи, у которых есть такие же игры
		select users_games.game_id
		from users_games
		right join (select ug.user_id AS user_id, ug.game_id AS user_game
			from users_games ug
			LEFT join users_games ug2
			ON ug.game_id = ug2.game_id
			where ug2.user_id = for_user_id) as users_rec   
		ON users_games.user_id = users_rec.user_id and users_games.user_id != for_user_id
		WHERE users_rec.user_game != users_games.game_id
		GROUP BY users_games.game_id
		
		order by rand()
		limit 5;
END//

DELIMITER ;

CALL recommended_games(5);


-- Добавление нового пользователя
DROP PROCEDURE IF EXISTS add_user;

DELIMITER //

CREATE PROCEDURE add_user(login varchar(255), name varchar(255), email varchar(120), password_hash varchar(100), phone BIGINT UNSIGNED, birthday DATE, country BIGINT UNSIGNED, profession varchar(255), OUT tran_result varchar(200))
BEGIN
    DECLARE `_rollback` BOOL DEFAULT 0;
   	DECLARE code varchar(100);
   	DECLARE error_string varchar(100);
   DECLARE last_user_id int;

   DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
   begin
    	SET `_rollback` = 1;
	GET stacked DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    	set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
    end;
		        
    START TRANSACTION;
		INSERT INTO users (login, name, email, password_hash, phone, birthday, country)
		  VALUES (login, name, email, password_hash, phone, birthday, country);
		if profession IS NOT NULL then
				INSERT INTO creator (name, profession, user_id, country)
		  		VALUES (name, profession, last_insert_id(), country); 
		END IF;
	
	    IF `_rollback` THEN
	       ROLLBACK;
	    ELSE
		set tran_result := 'ok';
	       COMMIT;
	    END IF;
END//

DELIMITER ;

-- Пользователь являющийся создателем игр
call add_user('user_creator', 'user creator', 'creator@email', 'fhfhfjf', '89399888787', '1990-12-12', '1', 'художник', @tran_result);
select @tran_result;

-- Обычный пользователь
call add_user('test_user', 'test user', 'user@email', 'fhfhааfjf', '899998498787', '1990-11-12', '2', NULL, @tran_result);

select @tran_result;
