# Midnight Riders Member Portal

The Midnight Riders Member Portal is a membership database for current Riders. It allows Riders
to update and manage their information, and play the games that used to be housed elsewhere, attached
to their Rider identity. In development, there's PayPal integration so that Riders can renew memberships
and this database can be used as the Database of Record for riders information and communications,
instead of Google Drive.

----

## Models

[`Ability`](#markdown-header-ability)
[`Club`](#markdown-header-club)
[`Match`](#markdown-header-match)
[`Membership`](#markdown-header-membership)
[`MotM`](#markdown-header-motm)
[`PickEm`](#markdown-header-pickem)
[`Player`](#markdown-header-player)
[`RevGuess`](#markdown-header-revguess)
[`User`](#markdown-header-user)

### Ability

Setup for [CanCanCan](https://github.com/CanCanCommunity/cancancan), `Permission`-based permissions.

### Club

The model for clubs or teams. Has many `Matches`, `Players`. Has `home_matches` and `away_matches`
which are both incarnations of `Match`. The `.matches` method returns all `Matches` that include
the club as either home or away.

**Attributes:**

    id                     :integer          not null, primary key
    name                   :string(255)
    conference             :string(255)
    primary_color          :integer
    secondary_color        :integer
    accent_color           :integer
    abbrv                  :string(255)
    created_at             :datetime
    updated_at             :datetime
    crest_file_name        :string(255)
    crest_content_type     :string(255)
    crest_file_size        :integer
    crest_updated_at       :datetime

### Match

The model for matches or games. Has many `MotMs`, `RevGuesses`, `PickEms`. Has a `home_team`,
and an `away_team`. Both are `Club` instances. Same model, same table. `uid` is pulled from
the calendar import (see `matches_controller#import`).

**Attributes:**

    id                      :integer          not null, primary key
    home_team_id            :integer
    away_team_id            :integer
    kickoff                 :datetime
    location                :string(255)
    home_goals              :integer
    away_goals              :integer
    created_at              :datetime
    updated_at              :datetime
    uid                     :string(255)

### Membership

**Under development.** One `Membership` per `User`, per year.

**Attributes:**

    id                      :integer          not null, primary key
    user_id                 :integer
    year                    :integer
    info                    :hstore
    privileges              :json
    type                    :string
    created_at              :datetime
    updated_at              :datetime

### MotM

Man of the Match model. Up to three picks - no duplicates, only `Players` who are `active?`.
Only voteable between 45 minutes and two weeks after kickoff. 

**Attributes:**

    id                     :integer          not null, primary key
    user_id                :integer
    match_id               :integer
    first_id               :integer
    second_id              :integer
    third_id               :integer
    created_at             :datetime
    updated_at             :datetime

### PickEm

Pick 'Em model. Users can pick either team, or a draw, for every `Match`. One point for correct
picks. Only voteable up until kickoff, of course. One pick per user per match.

**Attributes:**

    id                     :integer          not null, primary key
    match_id               :integer
    user_id                :integer
    result                 :integer
    created_at             :datetime
    updated_at             :datetime

### Player

Just what it says. Belongs to `Club`.

**Attributes:**

    id                     :integer          not null, primary key
    first_name             :string(255)
    last_name              :string(255)
    club_id                :integer
    position               :string(255)
    created_at             :datetime
    updated_at             :datetime
    number                 :integer
    active                 :boolean          default(TRUE)

### RevGuess

Score predictions for Revs games. One per user per `Match`.

**Attributes:**

    id                     :integer          not null, primary key
    match_id               :integer
    user_id                :integer
    home_goals             :integer
    away_goals             :integer
    comment                :string(255)
    created_at             :datetime
    updated_at             :datetime

### User

[Devise](https://github.com/plataformatec/devise)-based model for users.

**Attributes:**

    id                     :integer          not null, primary key
    last_name              :string(255)
    first_name             :string(255)
    address                :string(255)
    city                   :string(255)
    state                  :string(255)
    postal_code            :string(255)
    phone                  :integer
    email                  :string(255)      default(""), not null
    username               :string(255)      default(""), not null
    member_since           :integer
    created_at             :datetime
    updated_at             :datetime
    encrypted_password     :string(255)      default(""), not null
    reset_password_token   :string(255)
    reset_password_sent_at :datetime
    remember_created_at    :datetime
    sign_in_count          :integer          default(0), not null
    current_sign_in_at     :datetime
    last_sign_in_at        :datetime
    current_sign_in_ip     :string(255)
    last_sign_in_ip        :string(255)