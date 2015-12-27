-- Convert schema '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/29/001-auto.yml' to '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/28/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE steps_temp_alter (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(4096) NOT NULL,
  error_url varchar(4096),
  create_new_session char(1) NOT NULL DEFAULT '0',
  dependency_group_id char(64),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (journey_id) REFERENCES journeys(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
INSERT INTO steps_temp_alter( id, journey_id, title, url, error_url, create_new_session, dependency_group_id, created_at, updated_at) SELECT id, journey_id, title, url, error_url, create_new_session, dependency_group_id, created_at, updated_at FROM steps;

;
DROP TABLE steps;

;
CREATE TABLE steps (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  title varchar(255) NOT NULL,
  url varchar(4096) NOT NULL,
  error_url varchar(4096),
  create_new_session char(1) NOT NULL DEFAULT '0',
  dependency_group_id char(64),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (journey_id) REFERENCES journeys(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX steps_idx_journey_id02 ON steps (journey_id);

;
INSERT INTO steps SELECT id, journey_id, title, url, error_url, create_new_session, dependency_group_id, created_at, updated_at FROM steps_temp_alter;

;
DROP TABLE steps_temp_alter;

;

COMMIT;

