-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/25/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/26/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE users ADD COLUMN reset_token char(64);

;

COMMIT;

