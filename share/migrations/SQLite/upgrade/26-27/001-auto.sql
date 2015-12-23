-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/26/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/27/001-auto.yml':;

;
BEGIN;

;
CREATE UNIQUE INDEX unique_email ON users (email);

;
CREATE UNIQUE INDEX unique_username ON users (username);

;

COMMIT;

