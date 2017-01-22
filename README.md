![CircleCI](https://circleci.com/gh/MidnightRiders/MemberPortal.svg?style=shield)
[![Code Climate](https://codeclimate.com/github/MidnightRiders/MemberPortal/badges/gpa.svg)](https://codeclimate.com/github/MidnightRiders/MemberPortal)
[![Test Coverage](https://codeclimate.com/github/MidnightRiders/MemberPortal/badges/coverage.svg)](https://codeclimate.com/github/MidnightRiders/MemberPortal/coverage)

# Midnight Riders Member Portal

The Midnight Riders Member Portal is a membership database for current Riders. It allows Riders
to update and manage their information, and play the games that used to be housed elsewhere, attached
to their Rider identity. In development, there's PayPal integration so that Riders can renew memberships
and this database can be used as the Database of Record for riders information and communications,
instead of Google Drive.

----

## Configuration

### Environment Variables
This project uses [dotenv-rails](https://github.com/bkeepers/dotenv) to obscure sensitive env variables.
A `.env` file is needed to run the application. The full `.env` file for development looks like below:

```bash
SECRET_KEY_BASE=[RAILS SECRET KEY BASE]
STRIPE_PUBLIC_KEY=[STRIPE PUBLIC KEY]
STRIPE_SECRET_KEY=[STRIPE SECRET KEY]
S3_BUCKET_NAME=[NAME OF AMAZON BUCKET]
AWS_ACCESS_KEY_ID=[AWS ACCESS KEY]
AWS_SECRET_ACCESS_KEY=[AWS SECRET KEY]
```

The Stripe and AWS credentials are unnecessary for a large portion of the project, and all you'll really
need is the `SECRET_KEY_BASE`, which can be generated for your local environment with `rake secret`.

Access to the development credentials for Stripe and AWS can be obtained as needed by contacting
Midnight Riders Web Chair [@bensaufley](https://github.com/bensaufley) at
[webczar@midnightriders.com](mailto:webczar@midnightriders.com).

### Dependencies
**`postgresql`** is used for the database. I've used [Postgres.app](https://postgresapp.com/documentation/install.html)
for Mac, which is pretty plug-and-play. You'll need a `root` user with broad privileges.

**`qmake`** is required for the `capybara-webkit` gem. It can be installed in macOS using Homebrew with
`brew install qt5 --with-qtwebkit` (note: **this can take several hours** so be prepared to set it
and leave it for a while). You may need to link with `brew link --force qt5` after installation completes.

**`phantomjs`** is also required to run spec, and can also be installed using Homebrew:
`brew install phantomjs`.

Other dependencies are outlined in the Gemfile.

----

## Contributing

This repo is open to contribution by anyone interested in lending a hand. Simply fork the repo and, when ready,
submit a Pull Request. Make sure RSpec passes before submitting, and any new functionality is covered by tests. In your PR, explain
your changes and post screenshots if there's anything relevant to show.

Linter configurations will become a part of this project soon, but in the meantime, please adhere to the _de facto_
conventions of the repo and mimick the styles you see. For example: single quotes except for interpolation, JSON-style hashes, etc.

----

## Models

[`Ability`](#ability)
[`Club`](#club)
[`Match`](#match)
[`Membership`](#membership)
[`MotM`](#motm)
[`PickEm`](#pickem)
[`Player`](#player)
[`RevGuess`](#revguess)
[`User`](#user)

### Ability

Setup for [CanCanCan](https://github.com/CanCanCommunity/cancancan), `Permission`-based permissions.

### Club

The model for clubs or teams. Has many `Matches`, `Players`. Has `home_matches` and `away_matches`
which are both incarnations of `Match`. The `.matches` method returns all `Matches` that include
the club as either home or away.

**Attributes:**

Name                      | Type               | Attributes
------------------------- | ------------------ | ---------------------------
**`id`**                  | `integer`          | `not null, primary key`
**`name`**                | `string(255)`      |
**`conference`**          | `string(255)`      |
**`primary_color`**       | `integer`          |
**`secondary_color`**     | `integer`          |
**`accent_color`**        | `integer`          |
**`abbrv`**               | `string(255)`      |
**`created_at`**          | `datetime`         |
**`updated_at`**          | `datetime`         |
**`crest_file_name`**     | `string(255)`      |
**`crest_content_type`**  | `string(255)`      |
**`crest_file_size`**     | `integer`          |
**`crest_updated_at`**    | `datetime`         |

### Match

The model for matches or games. Has many `MotMs`, `RevGuesses`, `PickEms`. Has a `home_team`,
and an `away_team`. Both are `Club` instances. Same model, same table. `uid` is pulled from
the calendar import (see `matches_controller#import`).

**Attributes:**

Name                | Type               | Attributes
------------------- | ------------------ | ---------------------------
**`id`**            | `integer`          | `not null, primary key`
**`home_team_id`**  | `integer`          |
**`away_team_id`**  | `integer`          |
**`kickoff`**       | `datetime`         |
**`location`**      | `string(255)`      |
**`home_goals`**    | `integer`          |
**`away_goals`**    | `integer`          |
**`created_at`**    | `datetime`         |
**`updated_at`**    | `datetime`         |
**`uid`**           | `string(255)`      |
**`season`**        | `integer`          |

### Membership

One `Membership` per `User`, per year. Single-table inheritance for `type`s:
`Individual`, `Family`, `Relative`. `Family` `has_many :relatives`; `Relative`
`belongs_to` `Family` (through `family_id`)

**Attributes:**

Name              | Type               | Attributes
----------------- | ------------------ | ---------------------------
**`id`**          | `integer`          | `not null, primary key`
**`user_id`**     | `integer`          |
**`year`**        | `integer`          |
**`info`**        | `hstore`           |
**`created_at`**  | `datetime`         |
**`updated_at`**  | `datetime`         |
**`privileges`**  | `json`             |
**`type`**        | `string(255)`      | For STI
**`family_id`**   | `integer`          | Only for `Relative` subclass
**`refunded`**    | `text`             | Can be true, nil, or contain comment or Stripe code

### MotM

Man of the Match model. Up to three picks - no duplicates, only `Players` who are `active?`.
Only voteable between 45 minutes and two weeks after kickoff. 

**Attributes:**

Name              | Type               | Attributes
----------------- | ------------------ | ---------------------------
**`id`**          | `integer`          | `not null, primary key`
**`user_id`**     | `integer`          |
**`match_id`**    | `integer`          |
**`first_id`**    | `integer`          |
**`second_id`**   | `integer`          |
**`third_id`**    | `integer`          |
**`created_at`**  | `datetime`         |
**`updated_at`**  | `datetime`         |
 
### PickEm

Pick 'Em model. Users can pick either team, or a draw, for every `Match`. One point for correct
picks. Only voteable up until kickoff, of course. One pick per user per match.

**Attributes:**

Name              | Type               | Attributes
----------------- | ------------------ | ---------------------------
**`id`**          | `integer`          | `not null, primary key`
**`match_id`**    | `integer`          |
**`user_id`**     | `integer`          |
**`result`**      | `integer`          |
**`created_at`**  | `datetime`         |
**`updated_at`**  | `datetime`         |
**`correct`**     | `boolean`          |

### Player

Just what it says. Belongs to `Club`.

**Attributes:**

Name              | Type               | Attributes
----------------- | ------------------ | ---------------------------
**`id`**          | `integer`          | `not null, primary key`
**`first_name`**  | `string(255)`      |
**`last_name`**   | `string(255)`      |
**`club_id`**     | `integer`          |
**`position`**    | `string(255)`      |
**`created_at`**  | `datetime`         |
**`updated_at`**  | `datetime`         |
**`number`**      | `integer`          |
**`active`**      | `boolean`          | `default(TRUE)`

### RevGuess

Score predictions for Revs games. One per user per `Match`.

**Attributes:**

Name              | Type               | Attributes
----------------- | ------------------ | ---------------------------
**`id`**          | `integer`          | `not null, primary key`
**`match_id`**    | `integer`          |
**`user_id`**     | `integer`          |
**`home_goals`**  | `integer`          |
**`away_goals`**  | `integer`          |
**`comment`**     | `string(255)`      |
**`created_at`**  | `datetime`         |
**`updated_at`**  | `datetime`         |
**`score`**       | `integer`          |

### User

[Devise](https://github.com/plataformatec/devise)-based model for users.

**Attributes:**

Name                          | Type               | Attributes
----------------------------- | ------------------ | ---------------------------
**`id`**                      | `integer`          | `not null, primary key`
**`last_name`**               | `string(255)`      |
**`first_name`**              | `string(255)`      |
**`address`**                 | `string(255)`      |
**`city`**                    | `string(255)`      |
**`state`**                   | `string(255)`      |
**`postal_code`**             | `string(255)`      |
**`phone`**                   | `integer`          |
**`email`**                   | `string(255)`      | `default(""), not null`
**`username`**                | `string(255)`      | `default(""), not null`
**`member_since`**            | `integer`          |
**`created_at`**              | `datetime`         |
**`updated_at`**              | `datetime`         |
**`encrypted_password`**      | `string(255)`      | `default(""), not null`
**`reset_password_token`**    | `string(255)`      |
**`reset_password_sent_at`**  | `datetime`         |
**`remember_created_at`**     | `datetime`         |
**`sign_in_count`**           | `integer`          | `default(0), not null`
**`current_sign_in_at`**      | `datetime`         |
**`last_sign_in_at`**         | `datetime`         |
**`current_sign_in_ip`**      | `string(255)`      |
**`last_sign_in_ip`**         | `string(255)`      |
**`stripe_customer_token`**   | `string(255)`      |
**`country`**                 | `string(255)`      |
