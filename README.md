# Stargazers App

[![CI](https://github.com/RRReDz/Stargazers/actions/workflows/CI.yml/badge.svg)](https://github.com/RRReDz/Stargazers/actions/workflows/CI.yml)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/bfd9a9f8e5d84d728266f2fe4ac42ea6)](https://www.codacy.com/gh/RRReDz/Stargazers/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=RRReDz/Stargazers&amp;utm_campaign=Badge_Grade)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/bfd9a9f8e5d84d728266f2fe4ac42ea6)](https://www.codacy.com/gh/RRReDz/Stargazers/dashboard?utm_source=github.com&utm_medium=referral&utm_content=RRReDz/Stargazers&utm_campaign=Badge_Coverage)

## BDD Specs

### Story: Customer requests to see the stargazers of the selected user's repository

### Narrative #1

> As an online customer
> I want the app to automatically load the stargazers of a repository
> So I can always check who starred that repository

#### Scenarios #2 (Acceptance criteria)

```English
Given the customer has connectivity
When the customer requests to see certain repository's stargazers
Then the app should display the latest repository's stargazers
  And replace the cache of that repository with the new stargazers
```

### Narrative #2

> As an offline customer
> I want the app to show the latest saved version of stargazers for a repository
> So I can always check who starred that repository

#### Scenarios #2 (Acceptance criteria)

```English
Given the customer doesn't have connectivity
And there’s a cached version of the repository's stargazers
When the customer requests to see the repository's stargazers
Then the app should display the latest repository's stargazers saved

Given the customer doesn't have connectivity
And the cache is empty
When the customer requests to see the repository's stargazers
Then the app should display an error message
```

# Use Cases

## Load Stargazers From Remote Use Case

#### Data
  - `URL` (for certain `Repository`)

#### Primary course (happy path)
  1. Execute "Load Stargazers" command with above data.
  2. System downloads data from the URL.
  3. System validates downloaded data.
  4. System creates stargazers from valid data.
  5. System delivers stargazers.

#### Invalid data – error course (sad path)
  1. System delivers invalid data error.

#### No connectivity – error course (sad path)
  1. System delivers connectivity error.

## Load Stargazers From Cache Use Case

#### Data
  - `Repository`

#### Primary course
  1. Execute "Load Stargazers" command with above data.
  2. System fetches stargazers data from cache.
  3. System creates stargazers from cached data.
  4. System delivers stargazers.

#### Error course (sad path)
  1. System delivers error.

#### Empty cache course (sad path)
  1. System delivers no stargazers.

## Cache Stargazers Use Case

#### Data
  - `Stargazer`s
  - `Repository`

#### Primary course (happy path)
  1. Execute "Save Stargazers" command with above data.
  2. System deletes old cache data for repository.
  3. System encodes stargazers for the repository as data.
  4. System saves new cache data.
  5. System delivers success message.

#### Deleting error course (sad path)
  1. System delivers error.

#### Saving error course (sad path)
  1. System delivers error.

## Flowchart

TODO

## Architecture

![Architecture image](./Documents/ark/image.png)

## Model Specs

### Stargazer

| Property      | Type                |
|---------------|---------------------|
| `id`          | `Int`               |
| `username`    | `String`            |
| `avatarURL`   | `URL`               |
| `detailURL`   | `URL`               |

### Repository

| Property      | Type                |
|---------------|---------------------|
| `name`        | `String`            |
| `owner`       | `String`            |

### Payload contract

https://docs.github.com/en/rest/reference/activity#list-stargazers
