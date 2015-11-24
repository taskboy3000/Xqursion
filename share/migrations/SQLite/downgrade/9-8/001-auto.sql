-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/9/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/8/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE journeys_temp_alter (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date NOT NULL,
  end_at date NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
INSERT INTO journeys_temp_alter( id, name, user_id, start_at, end_at, created_at, updated_at) SELECT id, name, user_id, start_at, end_at, created_at, updated_at FROM journeys;

;
DROP TABLE journeys;

;
CREATE TABLE journeys (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date NOT NULL,
  end_at date NOT NULL,
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX journeys_idx_user_id04 ON journeys (user_id);

;
INSERT INTO journeys SELECT id, name, user_id, start_at, end_at, created_at, updated_at FROM journeys_temp_alter;

;
DROP TABLE journeys_temp_alter;

;

COMMIT;

