# Even SUBJID numbers will have study eye assigned to Left;  odd to Right
sc$SCORRES <- if_else(as.integer(sc$SUBJID) %% 2 == 0, "Left Eye", "Right Eye")
sc$SCSTRESC <- if_else(as.integer(sc$SUBJID) %% 2 == 0, "OS", "OD")
