-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/11/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/12/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE dependency_groups ADD COLUMN title varchar(255);

;

COMMIT;

