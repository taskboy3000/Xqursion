-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/3/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/8/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE dependencies_temp_alter (
  id char(64) NOT NULL,
  dependency_group_id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO dependencies_temp_alter( id, dependency_group_id, step_id, created_at, updated_at) SELECT id, dependency_group_id, step_id, created_at, updated_at FROM dependencies;

;
DROP TABLE dependencies;

;
CREATE TABLE dependencies (
  id char(64) NOT NULL,
  dependency_group_id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO dependencies SELECT id, dependency_group_id, step_id, created_at, updated_at FROM dependencies_temp_alter;

;
DROP TABLE dependencies_temp_alter;

;
CREATE TEMPORARY TABLE dependency_groups_temp_alter (
  id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  operation char(3) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO dependency_groups_temp_alter( id, step_id, operation, created_at, updated_at) SELECT id, step_id, operation, created_at, updated_at FROM dependency_groups;

;
DROP TABLE dependency_groups;

;
CREATE TABLE dependency_groups (
  id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  operation char(3) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO dependency_groups SELECT id, step_id, operation, created_at, updated_at FROM dependency_groups_temp_alter;

;
DROP TABLE dependency_groups_temp_alter;

;
CREATE TEMPORARY TABLE journeys_temp_alter (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date NOT NULL,
  end_at date NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
INSERT INTO journeys_temp_alter( id, name, user_id, start_at, end_at, created_at, updated_at) SELECT id, name, user_id, start_at, end_at, created_at, updated_at FROM journeys;

;
DROP TABLE journeys;

;
CREATE TABLE journeys (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date NOT NULL,
  end_at date NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX journeys_idx_user_id02 ON journeys (user_id);

;
INSERT INTO journeys SELECT id, name, user_id, start_at, end_at, created_at, updated_at FROM journeys_temp_alter;

;
DROP TABLE journeys_temp_alter;

;
CREATE TEMPORARY TABLE steps_temp_alter (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(4096) NOT NULL,
  ordering int NOT NULL,
  dependency_group_id char(64) NOT NULL,
  error_url varchar(4096) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO steps_temp_alter( id, journey_id, title, url, dependency_group_id, error_url, created_at, updated_at) SELECT id, journey_id, title, url, dependency_group_id, error_url, created_at, updated_at FROM steps;

;
DROP TABLE steps;

;
CREATE TABLE steps (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(4096) NOT NULL,
  ordering int NOT NULL,
  dependency_group_id char(64) NOT NULL,
  error_url varchar(4096) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO steps SELECT id, journey_id, title, url, ordering, dependency_group_id, error_url, created_at, updated_at FROM steps_temp_alter;

;
DROP TABLE steps_temp_alter;

;
CREATE TEMPORARY TABLE users_temp_alter (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  role char(16) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO users_temp_alter( id, username, email, password_hash, role, created_at, updated_at) SELECT id, username, email, password_hash, role, created_at, updated_at FROM users;

;
DROP TABLE users;

;
CREATE TABLE users (
  id char(64) NOT NULL,
  username varchar(64) NOT NULL,
  email varchar(128) NOT NULL,
  password_hash varchar(128) NOT NULL,
  role char(16) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO users SELECT id, username, email, password_hash, role, created_at, updated_at FROM users_temp_alter;

;
DROP TABLE users_temp_alter;

;

COMMIT;

