-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/11/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/10/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE steps ADD COLUMN ordering int NOT NULL;

;

COMMIT;

