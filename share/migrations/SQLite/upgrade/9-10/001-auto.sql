-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/9/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/10/001-auto.yml':;

;
BEGIN;

;
CREATE INDEX steps_idx_journey_id ON steps (journey_id);

;

;

COMMIT;

