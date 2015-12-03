-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/12/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/11/001-auto.yml':;

;
BEGIN;

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

COMMIT;

