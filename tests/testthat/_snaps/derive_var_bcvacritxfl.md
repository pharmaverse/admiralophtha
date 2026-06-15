# derive_var_bcvacritxfl_util Test 1: Correct deprecation message for derive_var_bcvacritxfl_util

    Code
      derive_var_bcvacritxfl_util(dataset = iris, crit_var = exprs(AVAL))
    Condition
      Error:
      ! `derive_var_bcvacritxfl_util()` was deprecated in admiralophtha 1.5.0 and is now defunct.
      i Please use `admiral::derive_vars_crit_flag()` instead.
      i See admiralophtha's guidance on creating BCVA criterion flags here: https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags

# derive_var_bcvacritxfl Test 2: Correct deprecation message for derive_var_bcvacritxfl

    Code
      derive_var_bcvacritxfl(dataset = iris, crit_var = exprs(AVAL), bcva_uplims = list(
        c(1)), critxfl_index = 12)
    Condition
      Error:
      ! `derive_var_bcvacritxfl()` was deprecated in admiralophtha 1.5.0 and is now defunct.
      i Please use `admiral::derive_vars_crit_flag()` instead.
      i See admiralophtha's guidance on creating BCVA criterion flags here: https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags

