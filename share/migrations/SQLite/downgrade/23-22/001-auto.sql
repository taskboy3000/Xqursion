-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/23/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/22/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE journey_log_temp_alter (
  id char(64) NOT NULL,
  session_id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO journey_log_temp_alter( id, session_id, step_id, created_at, updated_at) SELECT id, session_id, step_id, created_at, updated_at FROM journey_log;

;
DROP TABLE journey_log;

;
CREATE TABLE journey_log (
  id char(64) NOT NULL,
  session_id char(64) NOT NULL,
  step_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
INSERT INTO journey_log SELECT id, session_id, step_id, created_at, updated_at FROM journey_log_temp_alter;

;
DROP TABLE journey_log_temp_alter;

;

COMMIT;

