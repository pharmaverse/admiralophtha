# admiralophtha 1.0.0

## Updates to Templates

- Removed `analysis_value` argument in the calls to `derive_param_computed()` in ADBCVA template in line with the deprecation of this argument in the new version of `{admiral}`. Variable values for parameters of interest are now all populated through the `set_values_to` argument (#207). 

- Modified calls to `derive_summary_records()` in ADVFQ template in line with the updates to this function in the new version of the `{admiral}` package. The `filter` argument is now renamed to `filter_add`, the argument `dataset_add` is now always specified and the variable values are now all populated through the `set_values_to` argument (#204).

## Updates to Documentation

- Added release date for `{admiralophtha}` 1.0 to the front page (#203).

- Removed `analysis_value` argument in the calls to `derive_param_computed()` in ADBCVA vignette in line with the deprecation of this argument in the new version of `{admiral}`. Variable values for parameters of interest are now all populated through the `set_values_to` argument (#207). 

- Modified calls to `derive_summary_records()` in ADVFQ vignette in line with the updates to this function in the new version of the `{admiral}` package. The `filter` argument is now renamed to `filter_add`, the argument `dataset_add` is now always specified and the variable values are now all populated through the `set_values_to` argument (#204).

## Updates to Functions

- `derive_var_afeye()` was updated (#214):

  * A bug was removed where the function issued warnings when missing `xxLOC` values were present in the input dataset.
  * The argument `dataset_occ` was deprecated in favor of `dataset`, in line with `{admiral}` conventions.
  * The argument `lat_vals` was deprecated. Laterality values are now just expected to be "LEFT", "RIGHT" or "BILATERAL".

## Various

- Website now has button/links to Slack channel and GitHub Issues (#206).

- Test coverage is now improved to 100% (#217).

# admiralophtha 0.3.0

## Updates to Functions

- Added a new parameter `crit_var` to `derive_var_bcvacritxfl()` so that criterion flags can be derived with respect to any variable. Also removed arguments `paramcds` and `basetype` as their function can be achieved using `restrict_derivation()` from `{admiral}`. This also required renaming of argument `dataset_adbcva` to `dataset` (#119).

- Added `AFEYE` derivation and description to ADOE Vignette (#165).

## Updates to Templates

- Updated ADBCVA template's calls to use `restrict_derivation()` in calls to `derive_var_bcvacritxfl()` and also to showcase use of `crit_var` argument of `derive_var_bcvacritxfl()` (#119).

- Switched out all references to `admiral.test` for references to `pharmaversesdtm` in ADOE and ADBCVA templates, and updated code to refer to `oe_ophtha` accordingly (#184). 

- Switched out `derive_var_merged_cat()` for `derive_vars_merged()` in the function `derive_var_studyeye()` due to deprecation of the former in favor of the latter in `{admiral}`(#119).

- `OECAT` and `OESCAT` have been added to the lookup tables in the ADOE and ADBCVA templates (#189).

## Updates to Documentation

- Added a reference for the ETDRS to LogMAR conversion done by `convert_etdrs_to_logmar()` and `convert_logmar_to_etdrs()` (#136).

- `OECAT` and `OESCAT` have been added to the lookup tables in the ADOE and ADBCVA vignettes (#189).

- All function and variable names on the website are in backquotes (#173).

## Updates to Data

- Removed `admiralophtha_ex` and `admiralophtha_qs` from the package, as they now reside in `pharmaversesdtm`, where they are now names `ex_ophtha` and `qs_ophtha` respectively (#184).


# admiralophtha 0.2.0

## Updates to Functions

- Added new parameter `loc_vals` to function `derive_var_afeye()` to allow users to specify values of `xxLOC` for which `AFEYE` is derived (issue #163).
- Updated function `derive_var_afeye()` to resolve bug when `STUDYEYE` is 'Bilateral' (issue #134).
- Added new parameter `lat_vals` to function `derive_var_afeye()` to allow users to specify values of `xxLAT` for which `AFEYE` is derived, as well as issuing warnings when unexpected values are found (issue #174).

## Updates to Templates

- Updated ADOE to refer to `OESTRESU` for `AVALU` creation (issue #139).
- Updated ADOE and ADBCVA `PARAM` mapping to include units where applicable (issue #139).
- Updated ADOE, ADVFQ and ADBCVA for the unique intermediate dataset name to avoid overwriting, corrected the link for Visit and Period variables Vignette in ADVFQ (issue #128).
- Corrected values of `DTYPE`, `VISIT`, `VISITNUM`, `OEDY`, `OEDTC` for derived parameters in ADBCVA template (issue #137).
- Updated ADBCVA and ADOE templates to include `AFEYE` (issue #133).

## Updates to Site

- Added a "Report a bug" link to `{admiralophtha}` website (issue #127).
- Fixed bug where the search bar didn't work for some searches (issue #141).

# admiralophtha 0.1.0

## New Features

- Added a function to derive the variable `STUDYEYE` in ADSL (issue #9).
- Added a function to derive the variable `AFEYE` in Occurrence datasets (issue #10).
- Added a function to derive the criterion flags in ADBCVA (issue #49).
- Added a function to convert LogMAR scores to ETDRS scores (issue #50).
- Added a function to convert ETDRS scores to LogMAR scores (issue #50).
- Created ophthalmology-specific test data for the EX SDTM domain, stored in `{admiralophtha}` package and accessible by calling `data(admiralophtha_ex)` (issue #36).
- Created ophthalmology-specific test data for the SC and OE SDTM domains, stored in `{admiral}` package and accessible by calling `data(admiral_sc)` or `data(admiral_oe)` (issues #11 and #13).
- Updated AE and QS test datasets in `{admiral}` to include ophthalmology-specific variables and records, such as laterality variables in AE and VFQ records in QS (issues #12 and #52).
