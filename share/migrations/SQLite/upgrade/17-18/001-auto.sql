-- Convert schema '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/17/001-auto.yml' to '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/18/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE export_jobs (
  id char(64) NOT NULL,
  journey_id char(64) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
CREATE TABLE work_queue (
  id char(64) NOT NULL,
  model varchar(128) NOT NULL,
  model_id char(64) NOT NULL,
  status char(1) NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id)
);

;
ALTER TABLE journeys ADD COLUMN export_url varchar(255);

;

COMMIT;

