-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/24/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/25/001-auto.yml':;

;
BEGIN;

;
CREATE INDEX journey_log_idx_step_id ON journey_log (step_id);

;

;
ALTER TABLE steps ADD COLUMN create_new_session char(1) NOT NULL DEFAULT '0';

;

COMMIT;

