-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/19/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/20/001-auto.yml':;

;
BEGIN;

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

COMMIT;

