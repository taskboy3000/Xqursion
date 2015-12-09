-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/22/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/23/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE journey_log ADD COLUMN journey_id char(64);

;

COMMIT;

