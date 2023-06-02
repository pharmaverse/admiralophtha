# admiralophtha 0.2.0

## Updates to Functions

- Updated function `derive_var_afeye()` to resolve bug when `STUDYEYE` is 'Bilateral' (issue #134).

## Updates to Templates

- Updated `ADOE` to refer to `OESTRESU` for `AVALU` creation (issue #139).
- Updated `ADOE` and `ADBCVA` `PARAM` mapping to include units where applicable (issue #139).
- Updated `ADOE`, `ADVFQ` and `ADBCVA` for the unique intermediate dataset name to avoid overwriting, corrected the link for Visit and Period variables Vignette in `ADVFQ`. (issue #128) 
- Corrected values of `DTYPE`, `VISIT`, `VISITNUM`, `OEDY`, `OEDTC` for derived parameters in `ADBCVA` template (issue #137).

## Updates to Site

- Added a "Report a bug" link to `{admiralophtha}` website (issue #127).
- Fixed bug where the search bar didn't work for some searches (issue #141).

# admiralophtha 0.1.0

## New Features

- Added a function to derive the variable `STUDYEYE` in `ADSL` (issue #9).
- Added a function to derive the variable `AFEYE` in Occurrence datasets (issue #10).
- Added a function to derive the criterion flags in `ADBCVA` (issue #49).
- Added a function to convert LogMAR scores to ETDRS scores (issue #50).
- Added a function to convert ETDRS scores to LogMAR scores (issue #50).
- Created ophthalmology-specific test data for the `EX` SDTM domain, stored in `{admiralophtha}` package and accessible by calling `data(admiralophtha_ex)` (issue #36).
- Created ophthalmology-specific test data for the `SC` and `OE` SDTM domains, stored in `{admiral}` package and accessible by calling `data(admiral_sc)` or `data(admiral_oe)` (issues #11 and #13).
- Updated `AE` and `QS` test datasets in `{admiral}` to include ophthalmology-specific variables and records, such as laterality variables in `AE` and VFQ records in `QS` (issues #12 and #52).
