-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/15/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/16/001-auto.yml':;

;
BEGIN;

;
CREATE INDEX dependencies_idx_step_id ON dependencies (step_id);

;

;

COMMIT;

