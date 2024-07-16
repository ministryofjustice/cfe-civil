[![CircleCI](https://circleci.com/gh/ministryofjustice/cfe-civil.svg?style=shield)](https://circleci.com/gh/ministryofjustice/cfe-civil/tree/main)
[![repo standards badge](https://img.shields.io/endpoint?style=flat&labelColor=grey&label=MoJ%20Repository%20Standards&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fendpoint%2Fcfe-civil&logo=github)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-report/cfe-civil)

# Check Financial Eligibility - Civil (CFE-Civil)

An API that does the "civil means test" calculations i.e. whether someone's financial position makes them eligible for legal aid, for civil cases.

## Scope

CFE-Civil is suitable for:

* All case types, including certificated, controlled, asylum & immigration
* SMOD - where assets are disputed between the parties
* Partner - where the client has a partner, whose finances are included in the assessment

Not (yet) suitable for:

* Special applicant groups:
  * Self Employed: Sole Trader applicants
  * Self Employed: Sub-contractor applicants
  * Self Employed: Applicants in a Business Partnership
  * Self Employed: Shareholders in PLC/Company Directors
  * Applicants under 18 in Family cases
  * Applicants under 18 in Non-Family cases
  * Police officer applicants
  * Prisoner applicants
  * Applicants living outside of the UK
  * Applicants in the HM Forces
  * Applicants who are Insolvent
  * Applicants who are Bankrupt
  * Applicants subject to a freezing order

## Unforking

This repo [CFE-Civil](https://github.com/ministryofjustice/cfe-civil) is a "merge" of CCQ's "fork" [CFE-Partner](https://github.com/ministryofjustice/check-financial-eligibility-partner/) and Civil Apply's original [CFE](https://github.com/ministryofjustice/check-financial-eligibility). We have moved CCQ over to using CFE-Civil now, and are currently working to ensure CFE-Civil is also compatible with Civil Apply, so that both are using CFE-Civil.

CFE-Civil has enhancements over the original CFE:

* partner functionality added - to include in the calculation the financial info about the client's partner
* v6 API ("one shot API") added

# API Usage

## API Documentation

API documentation is available as:

* as a Swagger page on the running service, at `<hostname>/api-docs/index.html`
* as a Swagger definition in this repo: swagger/v6/swagger.yaml

## API Versioning

The API version in the URL path:

* v6 API - path `/v6/assessments`

## API Changelog

### 2023-04-03 v6 "one shot API"

See design reasoning: [ADR12 One Shot API](https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4405395614/ADR12+One+shot+API)
### 2022-07-12 v5 (decommissioned)

This was the last release of the API by the Civil Apply team.

There were previous releases, but they have since been removed from the code base.

**TODO** When in future this API has endpoints to allow direct submission of monthly income and outgoings figures (rather than collections of transactions from which these figures are inferred), make clear in the documentation for those endpoints that for controlled work that the API client should only submit figures that are valid for the calendar month leading up to the submission date, not an average of the previous 3 months.

# System architecture

See more about the architecture, including Architecture Decision Records in the team Confluence: <https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4317577492/Technical+Architecture>

## Architecture diagrams

Architecture diagrams can be viewed here: <https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4377182543/Architecture+Diagrams>

## Data model

The database/ORM structure:

* [ORM diagram](https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4377182543/Architecture+Diagrams#ORM-diagram)
* [Database model](https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4377182543/Architecture+Diagrams#Database-model)

Mostly the database objects contain a record of the input data. There are also some that hold thresholds and some calculation outputs, but we're aiming to elimenate them - see [ADR05 Remove from database the calculation results and instead return them as objects from calculation functions](https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4377542797/ADR05+Remove+from+database+the+calculation+results+and+instead+return+them+as+objects+from+calculation+functions)

The (main) assessment is determined by using three (sub) assessments. Those three assessments, with their corresponding parent object are:

* gross income assessment - `GrossIncomeSummary`
* disposable income assessment - `DisposableIncomeSummary`
* capital assessment - `CapitalSummary`

(Previously these 'summary' objects held properties containing sub-totals and results of each (sub) assessment, but now they don't. Instead the sub-totals and results are simply passed to the output decorators.)

Attached to each summary object are the input data, represented as one or more sub-objects, representing the individual items/transactions: the `GrossIncomeSummary` has income of various types, `CapitalSummary` has capital items, and the `DisposableIncomeSummary` various outgoings.

Each of the three summary objects also has a number of "Eligibility" objects - one for each proceeding type specified on the assessment.  Each eligibility object contains the upper and lower thresholds for that proceeding type, and will eventually hold the result for that proceeding type.

# Development

## Setting the env vars

Developers need a `.env` file in the root folder of their clone of this repo.

For running locally it should contain the following values:

```sh
LEGAL_FRAMEWORK_API_HOST=https://legal-framework-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk
```

(There used to be an option `ALLOW_FUTURE_SUBMISSION_DATE`, but now specifying a submission_date in the future is always allowed.)

However for running the integration tests, you need a few more values, including secrets - see: [Environment variables for Integration tests (spreadsheets)](#environment-variables-for-integration-tests-spreadsheets)

## Developer Setup

1.  Ensure Ruby is installed - for example using rbenv - with the version specified in `.ruby-version`

2.  Install these system dependencies:

    ```sh
    brew install shared-mime-info
    brew install cmake
    brew install postgresql
    # run postgres now AND on every boot
    brew services start postgresql
    ```

3.  Run the setup script:

    ```sh
    bin/setup
    ```

    This will:

    * install or update Ruby gem dependencies
    * ensure your local PostgreSQL has the development and test databases created, and runs any outstanding migrations

## Guard

It's recommended for devs to run 'Guard' in the background, to ensure RSwag rebuilds the swagger docs, and other tasks, before committing. This is more efficient than waiting for the CI to catch issues.

    Run Guard through Bundler with
    ```sh
    bundle exec guard
    ```

    Show configuration options for each used plugin
    ```sh
    bundle exec guard show
    ```

## Running the API locally

Start rails server:

```sh
bin/rails server
```

Try this simple test, to ensure it's working:

```
$ curl http://127.0.0.1:3000/healthcheck
{"checks":{"database":true}}
```
## Swagger - API schema & documentation generation

Rswag is used for generating Swagger API schemas and documentation. The sections below describe how these can be modified and managed, using filenames from a recent version of the main "assessments" API as examples.

### Source files

* spec/swagger_helper.rb - config
* app/lib/swagger_docs.rb - components which are used across multiple versions
* spec/requests/swagger_docs/v7/full_assessment_spec.rb

### Generation

The schemas are generated using rswag's rake task:

```sh
rake rswag:specs:swaggerize
```

### Generated schema

The schema is used to validate requests to the API, and are displayed in the Swagger docs UI served at `/api-docs`.

* swagger/v7/swagger.yaml

### RSwag administration

New endpoints can be created with:
```sh
rails generate rspec:swagger MyController
```

Rswag setup: [Rswag readme](https://github.com/rswag/rswag/blob/master/README.md)

## Threshold configuration files

Files holding details of all thresholds values used in calculating eligibility are stored in `config/thresholds`.

The file `values.yml` details the start dates for each set of thresholds, and the name of the file from which they should be read.

### Test threshold data

Whilst developing a thresholds .yml file, intended for a future date, you should include in it: `test_only: true`. This causes it *not* to be activated unless `FUTURE_THRESHOLD_FILE` is set to the same .yml filename. This is a protection against the thresholds file being used for actual assessments, in normal environments, where `FUTURE_THRESHOLD_FILE` is not set by default.

## Tests

CFE-Civil has several kinds of tests:

* End to End (E2E) tests
* Integration tests defined in Spreadsheets and using RSpec
* Integration tests using Cucumber
* Unit tests - using RSpec

For the purpose of each type of test, see: [CFE-Civil Test pyramid](https://docs.google.com/drawings/d/1XADSXrS-wQ6GHWo8b5JLdnWEHjrR_OyX5xT2uB4_jI4/edit)

### End to End (E2E) tests

The E2E tests perform user journeys using CCQ's web interface, using both CCQ and CFE-Civil running together. This helps us spot real-world incompatibilities between CCQ's requests and what CFE-Civil accepts.

The test cases are defined in the CCQ repo: https://github.com/ministryofjustice/laa-estimate-financial-eligibility-for-legal-aid/tree/main/spec/end_to_end

E2E tests are run by the [CircleCI config](.circleci/config.yml) - see the `end2end_tests` workflow.
### RSpec tests

The RSpec test suite in </spec> includes "Integration tests (spreadsheets)" and "other RSpec tests", but not "Integration tests (cucumber)" or E2E tests.

#### Environment variables for Integration tests (spreadsheets)

Before you can run the spreadsheet integration tests you will need to set up a `.env` file in the root folder of your clone of this repo.

Obtain the `.env` file from 1Password - look in the folder `LAA-Eligibility-Platform`, under item `Environment variables to run CFE ISPEC (spreadsheet) tests`. If you don't have access, see: [Tech we use - 1Password](https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4323606529/Tech+we+use#1Password)

Environment variables:

| Name                         | Value examples & commentary                                                             |
|------------------------------|-----------------------------------------------------------------------------------------|
| GOOGLE_SHEETS_PRIVATE_KEY_ID | (secret)                                                                                |
| GOOGLE_SHEETS_PRIVATE_KEY    | (secret)                                                                                |
| GOOGLE_SHEETS_CLIENT_EMAIL   | (secret)                                                                                |
| GOOGLE_SHEETS_CLIENT_ID      | (secret)                                                                                |
| RUNNING_AS_GITHUB_WORKFLOW   | `TRUE` / `FALSE`                                                                        |
| LEGAL_FRAMEWORK_API_HOST     | `https://legal-framework-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk` |
| FUTURE_THRESHOLD_FILE        | `mtr-2026.yml` - activates the specified thresholds file, as of today's date, overriding the date specified in values.yml. The thresholds file is activated even if it contains: `test_only: True`, as is likely |

#### Running RSpec tests

The RSpec test suite in </spec> includes "Integration tests (spreadsheets)" and "other RSpec tests", but not "Integration tests (cucumber)" or E2E tests.

Run them with:

```sh
bundle exec rspec
```

`pry-rescue` allows you to run tests so that a `pry` prompt will be opened on test failure or unhandled exceptions, which can be helpful for debugging. It is a gem which is included in this repo. Run it with:

```sh
bundle exec rescue rspec
```

#### Common errors

Error:
```ruby
   An error occurred while loading ./spec/integration/policy_disregards_spec.rb.
   Failure/Error: require File.expand_path("../config/environment", __dir__)

   NoMethodError:
     undefined method `gsub' for nil:NilClass
```
Solution: fix your .env file. See: [Environment variables for Integration tests (spreadsheets)](#environment-variables-for-integration-tests-spreadsheets)

Error:
```ruby
   An error occurred while loading ./spec/validators/json_validator_spec.rb.
   Failure/Error: ActiveRecord::Migration.maintain_test_schema!

   ActiveRecord::NoDatabaseError:
     We could not find your database: cfe_civil_test. Which can be found in the database configuration file located at config/database.yml.
```
Solution: fix your database, which should have been created with `bin/setup` - see [Developer setup](developer-setup)

### Integration tests (spreadsheets)

A series of spreadsheets is used to provide use cases and their expected results, and are run as part of the normal `rspec` test suite, or can be run individually with more control using the script `bin/ispec` (see below).

The [Master CFE Integration Tests Spreadsheet](https://docs.google.com/spreadsheets/d/1lkRmiqi4KpoAIxzui3hTnHddsdWgN9VquEE_Cxjy9AM/edit#gid=651307264) lists all the other spreadsheets to be run, as well as contain skeleton worksheets for creating new tests scenarios.  Each spreadsheet can hold multiple worksheets, each of which is a test scenario.

You can run these tests, in the standard rspec way:

```sh
bundle exec rspec --pattern=spec/integration/test_runner_spec.rb -fd
```

Each worksheet is a test scenario, which is run as an rspec example.

For more fine control over the amount of verbosity, to run just one test case, or to force download the google spreadsheet,
use `bin/ispec`, the help text of which is given below.

```text
ispec - Run integration tests

options:
-h        Display this help text
-r        Force refresh of Google speadsheet to local storage
-v        Set verbosity level to 1 (default is 0: silent) - produce detailed expected and actual results
-vv       Set verbosity level to 2 - display all payloads, and actual and expected results
-w XXX    Only process worksheet named XXX
```

Each worksheet has an entry `Test Active` which can be either true or false.  If set to false, the worksheet will be skipped, unless it is
the named worksheet using the `-w` command line switch.

### Integration tests (cucumber)

We are [trialling the use of cucumber for integration tests](https://dsdmoj.atlassian.net/wiki/spaces/LE/pages/4229660824/Architectural+Design+Records#Cucumber-tests-trial-in-CFE-Partner), in particular to document features added for the "[CCQ](https://github.com/ministryofjustice/laa-estimate-financial-eligibility-for-legal-aid)" client. These cucumber tests are to be found in the `features` folder.

Run them with:

```sh
bundle exec cucumber
```

### Unit tests in RSpec

The aim is for these to be "unit test" style - i.e. numerous tests that cover the detail of the functionality - the bottom level of the [test pyramid](https://martinfowler.com/articles/practical-test-pyramid.html). See: [CFE-Civil Test pyramid](https://docs.google.com/drawings/d/1XADSXrS-wQ6GHWo8b5JLdnWEHjrR_OyX5xT2uB4_jI4/edit)

Run them with:

```sh
bundle exec rspec --exclude-pattern=spec/integration/test_runner_spec.rb
```

## Replaying live API interactions for debugging purposes

In the event that you need to investigate why a CFE result was produced on live, there is
a way to replay the API calls of the original application and debug the assessment process
on a local machine

1) Record the original api payloads and calls on the Apply system
   Run the rake task `rake cfe:record_payloads`.  This will print to the screen a YAML
   representation of the calls to the API with the actual payloads

2) Copy and paste that output to the file `tmp/api_payloads.yml` in this repo

3) Start a CFE server locally on port 4000, and add breakpoints at the required places

4) Run the rake task `rake replay`: this will read the `tmp/api_payloads.yml` file and
   replay the original API calls and payloads enabling you to re-create the conditions.

## Re-running request logs through the local environment

1) Set environment variables pointing to staging or production database
   (to get the request_logs that will be rerun), as in:
   https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4415946946/Database+access

2) Make sure the local database has had rake db:seed run on it, otherwise most requests will error

3) RAILS_ENV=remote_database SECRET_KEY_BASE=anything rake rerun:requests

This currently takes around 5 minutes to run with 7500 requests from staging
The output format of the diffs is 4 fields:

a) +/-/~ addition, removal, change
b) fieldname
c) old value (only for change and removal)
d) new value (only for change and addition)

# Deployment

This app is deployed on Cloud Platform by CircleCI, using the Helm chart in deploy/helm.

[CircleCI pipeline for cfe-civil](https://app.circleci.com/pipelines/github/ministryofjustice/cfe-civil)

## Kubernetes secrets

Secrets are sourced from 1Password and deployed into an environment/namespace by manually running `kubectl create secret` commands. See: https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4356833911/Secrets

Within the `kube-secrets` k8s secret, the following keys are available:

* notifications-api-key
* sentry-dsn
* secret-key-base
* postgresql-postgres-password (for UAT only, as this environment has a pod running Postgres instead of an RDS instance)
