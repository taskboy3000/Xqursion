-- Convert schema '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/4/001-auto.yml' to '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE users_temp_alter (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO users_temp_alter( id, username, email, password_hash, created_at, updated_at) SELECT id, username, email, password_hash, created_at, updated_at FROM users;

;
DROP TABLE users;

;
CREATE TABLE users (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO users SELECT id, username, email, password_hash, created_at, updated_at FROM users_temp_alter;

;
DROP TABLE users_temp_alter;

;
DROP TABLE dependencies;

;
DROP TABLE dependency_groups;

;
DROP TABLE journeys;

;
DROP TABLE steps;

;

COMMIT;

