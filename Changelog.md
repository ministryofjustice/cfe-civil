# Changelog

The date is when it was released/deployed to production - see [cfe-civil CI/CD](https://app.circleci.com/pipelines/github/ministryofjustice/cfe-civil).

Includes changes that are material to the client - refactors are ignored.

## 14th November 2023

* LEP-410 Renamed net_housing_costs and gross_housing_costs response fields to allowed_housing_costs and housing_costs
* The old field names remain in the v6 API and are deprecated

## 18th September 2023

* LEP-233 added support for new MTR percentage based thresholds after MTR go-live date

## 25th July 2023

* LEP-84 Feature: Added "other_incomes" to partner input structure

## 21st July 2023

* LEP-190 **Bug Fix** Child care expenses are included now if they have employment income, rather than on basis of "employed" boolean field. And deprecated "employed" boolean field.

## 18th July 2023

* LEP-83 Feature: Added "cash_transactions" to partner input structure

## 14th July 2023

* LEP-278 Feature: Return attribute "subject_matter_of_dispute" in the "properties" response

## 7th July 2023

* LEP-272: **Bug Fix** Childcare costs were incorrectly being included in disposable income in the case that a client or partner is receiving only statutory pay.

* LEP-226 Feature: Introduced v7 API with tighter API validation - additional properties in the input data are no longer accepted, for the remaining 30% of the intput schema. This will flag up when clients are out of line with the schema e.g. mistaken structure, or using no-longer valid keys

## 27th June 2023

* LEP-218 Feature: "employment_or_self_employment" input field split into "employment_details" and "self_employment_details" (Is a breaking change, but was agreed with CCQ)

## 23rd June 2023

* LEP-214 **Bug Fix** Properties missing from response if gross/disposable income test is ineligible

## 15th June 2023

* LEP-172 Feature: Remarks produced when partner data has variations (e.g. income variations) to match applicant remarks
* LEP-212 Feature: Support for 'annual' frequency in 'frequency' based employment inputs

## 14th June 2203

* LEP-207 **Bug Fix** Vehicles missing from response if gross/disposable income test is ineligible

## 31st May 2023

* LEP-165 Removal: Removal of all v5 endpoints in favour of single-shot v6 endpoint allowing subsequent removal of database tables
