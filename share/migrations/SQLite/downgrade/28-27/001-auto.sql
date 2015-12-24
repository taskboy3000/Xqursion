-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/28/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/27/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE users_temp_alter (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  role char(16) NOT NULL,
  reset_token char(64),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO users_temp_alter( id, username, email, password_hash, role, reset_token, created_at, updated_at) SELECT id, username, email, password_hash, role, reset_token, created_at, updated_at FROM users;

;
DROP TABLE users;

;
CREATE TABLE users (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  role char(16) NOT NULL,
  reset_token char(64),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
CREATE UNIQUE INDEX unique_email02 ON users (email);

;
CREATE UNIQUE INDEX unique_username02 ON users (username);

;
INSERT INTO users SELECT id, username, email, password_hash, role, reset_token, created_at, updated_at FROM users_temp_alter;

;
DROP TABLE users_temp_alter;

;

COMMIT;

