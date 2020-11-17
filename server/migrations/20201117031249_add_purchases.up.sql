BEGIN;

CREATE TYPE purchase_type AS ENUM (
  'cash',
  'stripe'
);

CREATE TABLE purchases (
  uuid UUID PRIMARY KEY,
  user_uuid UUID NOT NULL REFERENCES users (uuid),
  "type" purchase_type NOT NULL,
  amount DECIMAL(6, 2) NOT NULL,
  ts TIMESTAMP NOT NULL DEFAULT NOW(),
  transaction_id VARCHAR(256),
  meta JSONB DEFAULT '{}'
);

ALTER TABLE memberships
  ADD COLUMN purchase_uuid UUID NOT NULL REFERENCES purchases (uuid);

COMMIT;
