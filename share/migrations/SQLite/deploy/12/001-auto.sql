-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Dec  3 12:13:04 2015
-- 

;
BEGIN TRANSACTION;
--
-- Table: dependencies
--
CREATE TABLE dependencies (
  id char(64) NOT NULL,
  dependency_group_id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);
--
-- Table: dependency_groups
--
CREATE TABLE dependency_groups (
  id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  title varchar(255),
  operation char(3) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);
--
-- Table: users
--
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
--
-- Table: journeys
--
CREATE TABLE journeys (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date,
  end_at date,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX journeys_idx_user_id ON journeys (user_id);
--
-- Table: steps
--
CREATE TABLE steps (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(4096) NOT NULL,
  dependency_group_id char(64) NOT NULL,
  error_url varchar(4096) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (journey_id) REFERENCES journeys(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX steps_idx_journey_id ON steps (journey_id);
COMMIT;
