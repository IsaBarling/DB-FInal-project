CREATE TABLE users_old (
	id SERIAL PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия',
    email VARCHAR(120) UNIQUE
);

BEGIN;
INSERT INTO users_old (firstname, lastname, email)
SELECT firstname, lastname, email FROM users WHERE id = 3;
DELETE FROM users WHERE id = 3;
COMMIT;


/* 
Создайте  хранимую функцию hello , которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 ". — "Добрый вечер", с 00:00 до 6:00  — "Доброй ночи"
 */
CREATE FUNCTION hello()
RETURNS VARCHAR(50)
AS
BEGIN
  DECLARE current_hour INT;
  DECLARE message VARCHAR(50);
  
  SET current_hour = HOUR(NOW());
  
  IF current_hour >= 6 AND current_hour < 12 THEN
    SET message = 'Доброе утро';
  ELSEIF current_hour >= 12 AND current_hour < 18 THEN
    SET message = 'Добрый день';
  ELSEIF current_hour >= 18 AND current_hour < 24 THEN
    SET message = 'Добрый вечер';
  ELSE
    SET message = 'Доброй ночи';
  END IF;
  
  RETURN message;
END;

/* 
 Создайте таблицу logs . Пусть при каждом создании записи в таблицах users , communities и messages в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа.
 */
CREATE TABLE logs (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  created_at DATETIME NOT NULL,
  table_name VARCHAR(255) NOT NULL,
  primary_key_id INT NOT NULL
);

CREATE TRIGGER log_users_insert AFTER INSERT ON users
FOR EACH ROW
INSERT INTO logs (created_at, table_name, primary_key_id) VALUES (NOW(), 'users', NEW.id);

CREATE TRIGGER log_communities_insert AFTER INSERT ON communities
FOR EACH ROW
INSERT INTO logs (created_at, table_name, primary_key_id) VALUES (NOW(), 'communities', NEW.id);

CREATE TRIGGER log_messages_insert AFTER INSERT ON messages
FOR EACH ROW
INSERT INTO logs (created_at, table_name, primary_key_id) VALUES (NOW(), 'messages', NEW.id);


/* 
В улучшенной версии таблицы logs добавлен столбец message_time типа TIMESTAMP для хранения времени сообщений. 
В триггеры были внесены соответствующие изменения для добавления времени сообщений в таблицу 
logs при создании записей в таблице messages.
 */

CREATE TABLE logs (
  id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  table_name VARCHAR(255) NOT NULL,
  primary_key_id INT NOT NULL,
  message_time TIMESTAMP NOT NULL
);

CREATE TRIGGER log_users_insert AFTER INSERT ON users
FOR EACH ROW
INSERT INTO logs (table_name, primary_key_id, message_time) VALUES ('users', NEW.id, NOW());

CREATE TRIGGER log_communities_insert AFTER INSERT ON communities
FOR EACH ROW
INSERT INTO logs (table_name, primary_key_id, message_time) VALUES ('communities', NEW.id, NOW());

CREATE TRIGGER log_messages_insert AFTER INSERT ON messages
FOR EACH ROW
INSERT INTO logs (table_name, primary_key_id, message_time) VALUES ('messages', NEW.id, NEW.created_at);
