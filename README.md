<!-- Please do not edit the README.md file as it is auto-generated after PR merges. Only edit the README.Rmd file -->

<!-- The purpose of this is to enable dynamic links using dyn_link function above to access devel/main admiral homepage respectively -->

<!-- To test this in your feature branch use code: rmarkdown::render("README.Rmd", output_format ="md_document") -->

# Admiral Extension for Ophthalmology <img src="man/figures/logo.png" align="right" width="200" style="margin-left:50px;"/>

<!-- badges: start -->

[<img src="http://pharmaverse.org/shields/admiralophtha.svg">](https://pharmaverse.org)
[![CRAN
status](https://www.r-pkg.org/badges/version/admiralophtha)](https://CRAN.R-project.org/package=admiralophtha)
[![Test
Coverage](https://raw.githubusercontent.com/pharmaverse/admiralophtha/badges/main/test-coverage.svg)](https://github.com/pharmaverse/admiralophtha/actions/workflows/code-coverage.yml)

<!-- badges: end -->

## Installation

To install the latest development version of the package directly from
GitHub use the following code:

```
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}
remotes::install_github("pharmaverse/admiraloptha", ref = "devel")
```

## Scope

* Build a toolbox of re-usable functions and utilities to create
  Ophthalmology-specific ADaM datasets in R in a modular manner.
* All functions are created based upon the ADaM Implementation Guide
  and aim to facilitate the programming of ADaM dataset standards.

## Expectations

`{admiralophtha}` is expected to complement `{admiral}` and provide
functions to help with the creation of the endpoints required for
ophthalmology ADaMs.

## References and Documentation

* Please refer to the [{admiral} References and
  Documentation](https://pharmaverse.github.io/admiral/index.html#references-and-documentation).

## R Versions

Here’s a summary of our strategy for this package related to R versions:

* R versions for developers and users will follow the same as
  `{admiral}` core package.
* For development the `devel` branch of `{admiral}` core is used as a
  dependency. For releasing a new `{admiralophtha}` version it must
  run using the latest released `{admiral}` core version, i.e., `main`
  branch of `{admiral}` core.

## Contact

We use the following for support and communications between user and
developer community:

* [Slack](https://app.slack.com/client/T028PB489D3/C02M8KN8269) - for
  informal discussions, Q\&A and building our user community. If you
  don’t have access, use this
  [link](https://join.slack.com/t/pharmaverse/shared_invite/zt-yv5atkr4-Np2ytJ6W_QKz_4Olo7Jo9A)
  to join the pharmaverse Slack workspace
* [GitHub
  Issues](https://github.com/pharmaverse/admiralophtha/issues) - for
  direct feedback, enhancement requests or raising bugs

## Release Schedule

To be decided
