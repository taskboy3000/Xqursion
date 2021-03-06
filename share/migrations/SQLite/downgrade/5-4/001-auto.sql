-- Convert schema '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/5/001-auto.yml' to '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE dependencies (
  id char(64) NOT NULL,
  dependency_group_id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL
);

;
CREATE TABLE dependency_groups (
  id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  operation char(3) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL
);

;
CREATE TABLE journeys (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date NOT NULL,
  end_at date NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL
);

;
CREATE TABLE steps (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(4096) NOT NULL,
  sequence int NOT NULL,
  dependency_group_id char(64) NOT NULL,
  error_url varchar(4096) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL
);

;
CREATE TABLE users (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  role char(16) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL
);

;

COMMIT;

