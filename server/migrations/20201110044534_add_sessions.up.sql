CREATE TABLE sessions (
  uuid UUID PRIMARY KEY,
  user_uuid UUID NOT NULL REFERENCES users (uuid) ON DELETE CASCADE,
  user_agent VARCHAR (256),
  ip VARCHAR (39),
  expires TIMESTAMP NOT NULL
);

CREATE INDEX user_sessions
  ON sessions (user_uuid);
