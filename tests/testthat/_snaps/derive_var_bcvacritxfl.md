# derive_var_bcvacritxfl Test 1: Criterion flags derived correctly

    Code
      actual_output1 <- derive_var_bcvacritxfl(dataset = expected_output1 %>% select(
        -starts_with("CRIT")), crit_var = exprs(CHG), bcva_ranges = list(c(0, 5)),
      bcva_uplims = list(-3, 10), bcva_lowlims = list(8), additional_text = "")
    Message
      `derive_var_bcvacritxfl()` was deprecated in admiralophtha 1.4.0.
      i Please use `admiral::derive_vars_crit_flag()` instead.
      i See admiralophtha's guidance on creating BCVA criterion flags here: https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags
      x This message will turn into a warning with release of admiralophtha 1.5.0.

# derive_var_bcvacritxfl Test 2: Correct appending in CRITx of additional text

    Code
      actual_output2 <- derive_var_bcvacritxfl(dataset = expected_output2 %>% select(
        -starts_with("CRIT")), crit_var = exprs(AVAL), bcva_ranges = list(c(4, 7)),
      additional_text = " (transformed)")
    Message
      `derive_var_bcvacritxfl()` was deprecated in admiralophtha 1.4.0.
      i Please use `admiral::derive_vars_crit_flag()` instead.
      i See admiralophtha's guidance on creating BCVA criterion flags here: https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags
      x This message will turn into a warning with release of admiralophtha 1.5.0.

# derive_var_bcvacritxfl Test 3: Correct CRITx index when critxfl_index not supplied

    Code
      actual_output3 <- derive_var_bcvacritxfl(dataset = expected_output3 %>% select(
        -starts_with("CRIT2")), crit_var = exprs(AVAL), bcva_lowlims = list(c(5)))
    Message
      `derive_var_bcvacritxfl()` was deprecated in admiralophtha 1.4.0.
      i Please use `admiral::derive_vars_crit_flag()` instead.
      i See admiralophtha's guidance on creating BCVA criterion flags here: https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags
      x This message will turn into a warning with release of admiralophtha 1.5.0.

# derive_var_bcvacritxfl Test 4: Correct CRITx index when critxfl_index is supplied

    Code
      actual_output4 <- derive_var_bcvacritxfl(dataset = expected_output4 %>% select(
        -starts_with("CRIT2")), crit_var = exprs(AVAL), bcva_uplims = list(c(1)),
      critxfl_index = 12)
    Message
      `derive_var_bcvacritxfl()` was deprecated in admiralophtha 1.4.0.
      i Please use `admiral::derive_vars_crit_flag()` instead.
      i See admiralophtha's guidance on creating BCVA criterion flags here: https://pharmaverse.github.io/admiralophtha/articles/adbcva.html#critflags
      x This message will turn into a warning with release of admiralophtha 1.5.0.

