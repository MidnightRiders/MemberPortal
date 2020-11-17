BEGIN;

CREATE TYPE conference AS ENUM (
    'Eastern',
    'Western'
);

CREATE TABLE clubs (
    uuid UUID PRIMARY KEY,
    "name" VARCHAR (64) UNIQUE NOT NULL,
    abbreviation VARCHAR(4) UNIQUE NOT NULL,
    primary_color CHAR (6) NOT NULL,
    secondary_color CHAR (6) NOT NULL,
    accent_color CHAR (6) NOT NULL,
    conference conference NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX club_conference
    ON clubs (conference);

CREATE TYPE membership_type AS ENUM (
    'Individual',
    'Family'
);

CREATE TYPE membership_role AS ENUM (
    'Executive Board',
    'At-Large Board'
);

CREATE TABLE users (
    uuid UUID PRIMARY KEY,
    username VARCHAR (24) UNIQUE NOT NULL,
    password_digest CHAR (60),
    pepper CHAR(128),
    email VARCHAR (128) UNIQUE NOT NULL,
    first_name VARCHAR (64) NOT NULL,
    last_name VARCHAR (64) NOT NULL,
    address1 VARCHAR (128),
    address2 VARCHAR (128),
    city VARCHAR (64),
    province VARCHAR (64),
    postal_code VARCHAR (16),
    country VARCHAR (64),
    membership_number SERIAL UNIQUE NOT NULL
);

CREATE TABLE memberships (
    uuid UUID PRIMARY KEY,
    user_uuid UUID REFERENCES users (uuid),
    year SMALLINT NOT NULL,
    "type" membership_type NOT NULL,
    "role" membership_role
);

CREATE INDEX membership_user
    ON memberships (user_uuid);

CREATE INDEX membership_role
    ON memberships ("role");

CREATE INDEX membership_type
    ON memberships ("type");

CREATE INDEX user_membership_year
    ON memberships (user_uuid, year);

CREATE TABLE admins (
    uuid UUID PRIMARY KEY,
    user_uuid UUID NOT NULL REFERENCES users (uuid),
    beginning TIMESTAMP NOT NULL DEFAULT NOW(),
    ending TIMESTAMP
);

CREATE INDEX admin_users
    ON admins (user_uuid);

CREATE TYPE player_position AS ENUM (
  'Goalkeeper',
  'Defender',
  'Midfielder',
  'Attacker'
);

CREATE TABLE players (
    uuid UUID PRIMARY KEY,
    club_uuid UUID NOT NULL REFERENCES clubs (uuid),
    first_name VARCHAR (64) NOT NULL,
    last_name VARCHAR (64) NOT NULL,
    "position" player_position NOT NULL,
    active BOOLEAN NOT NULL
);

CREATE INDEX player_club
    ON players (club_uuid);

CREATE TYPE match_status AS ENUM (
  'Upcoming',
  'Delayed',
  'Postponed',
  'Started',
  'Finished'
);

CREATE TABLE matches (
    uuid UUID PRIMARY KEY,
    kickoff TIMESTAMP NOT NULL,
    home_club_uuid UUID NOT NULL REFERENCES clubs (uuid),
    away_club_uuid UUID NOT NULL REFERENCES clubs (uuid),
    home_goals SMALLINT,
    away_goals SMALLINT,
    "status" match_status NOT NULL DEFAULT 'Upcoming'
);

CREATE INDEX match_home_club
    ON matches (home_club_uuid);

CREATE INDEX match_away_club
    ON matches (away_club_uuid);

CREATE TABLE rev_guesses (
    uuid UUID PRIMARY KEY,
    user_uuid UUID NOT NULL REFERENCES users (uuid) ON DELETE CASCADE,
    match_uuid UUID NOT NULL REFERENCES matches (uuid) ON DELETE CASCADE,
    home_goals SMALLINT NOT NULL,
    away_goals SMALLINT NOT NULL,
    comment VARCHAR (255) NOT NULL
);

CREATE INDEX rev_guess_user
    ON rev_guesses (user_uuid);

CREATE INDEX rev_guess_match
    ON rev_guesses (match_uuid);

CREATE UNIQUE INDEX rev_guess_per_user
    ON rev_guesses (user_uuid, match_uuid);

CREATE TABLE man_of_the_match_votes (
    uuid UUID PRIMARY KEY,
    user_uuid UUID NOT NULL REFERENCES users (uuid) ON DELETE CASCADE,
    match_uuid UUID NOT NULL REFERENCES matches (uuid) ON DELETE CASCADE,
    first_pick_uuid UUID NOT NULL REFERENCES players (uuid) ON DELETE SET NULL,
    second_pick_uuid UUID REFERENCES players (uuid) ON DELETE SET NULL,
    third_pick_uuid UUID REFERENCES players (uuid) ON DELETE SET NULL
);

CREATE INDEX motm_user
    ON man_of_the_match_votes (user_uuid);

CREATE INDEX motm_match
    ON man_of_the_match_votes (match_uuid);

CREATE INDEX motm_first_pick
    ON man_of_the_match_votes (first_pick_uuid);

CREATE INDEX motm_second_pick
    ON man_of_the_match_votes (second_pick_uuid);

CREATE INDEX motm_third_pick
    ON man_of_the_match_votes (third_pick_uuid);

CREATE UNIQUE INDEX motm_per_user
    ON man_of_the_match_votes (user_uuid, match_uuid);

COMMIT;
