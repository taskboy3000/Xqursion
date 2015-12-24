-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/27/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/28/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE users ADD COLUMN last_login_at datetime;

;

COMMIT;

