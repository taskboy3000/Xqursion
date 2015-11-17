-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Nov 17 13:02:00 2015
-- 

;
BEGIN TRANSACTION;
--
-- Table: users
--
CREATE TABLE users (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);
COMMIT;
