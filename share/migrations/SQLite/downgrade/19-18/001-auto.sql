-- Convert schema '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/19/001-auto.yml' to '/Users/jjohn/src/Xqursion/share/migrations/_source/deploy/18/001-auto.yml':;

;
BEGIN;

;
CREATE TEMPORARY TABLE journeys_temp_alter (
  id char(64) NOT NULL,
  name varchar(255) NOT NULL,
  user_id char(64) NOT NULL,
  start_at date,
  end_at date,
  export_url varchar(255),
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
  start_at date,
  end_at date,
  export_url varchar(255),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

;
CREATE INDEX journeys_idx_user_id04 ON journeys (user_id);

;
INSERT INTO journeys SELECT id, name, user_id, start_at, end_at, export_url, created_at, updated_at FROM journeys_temp_alter;

;
DROP TABLE journeys_temp_alter;

;

COMMIT;

