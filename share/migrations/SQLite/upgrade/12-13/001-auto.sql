-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/12/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/13/001-auto.yml':;

;
BEGIN;

;
CREATE INDEX dependencies_idx_dependency_group_id ON dependencies (dependency_group_id);

;

;
CREATE INDEX dependency_groups_idx_step_id ON dependency_groups (step_id);

;

;

COMMIT;

