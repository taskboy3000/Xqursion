-- Convert schema '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/13/001-auto.yml' to '/home/jjohnston/sites/Xqursion/share/migrations/_source/deploy/12/001-auto.yml':;

;
BEGIN;

;
DROP INDEX dependencies_fk_dependency_group_id;

;
DROP INDEX dependencies_idx_dependency_group_id;

;
DROP INDEX dependency_groups_fk_step_id;

;
DROP INDEX dependency_groups_idx_step_id;

;

COMMIT;

