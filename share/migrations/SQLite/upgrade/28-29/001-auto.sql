-- Convert schema '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/28/001-auto.yml' to '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/29/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE steps ADD COLUMN qrcode_filename varchar(255);

;

COMMIT;

