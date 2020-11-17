BEGIN;
ALTER TABLE memberships REMOVE COLUMN purchase_uuid;
DROP TABLE IF EXISTS purchases;
DROP TYPE IF EXISTS purchase_type;
COMMIT;
