#' @keywords internal
#' @importFrom dplyr arrange bind_rows case_when desc ends_with filter full_join group_by
#' @importFrom dplyr if_else mutate mutate_at mutate_if n pull rename rename_at row_number
#' @importFrom dplyr select slice starts_with transmute ungroup vars n_distinct union distinct
#' @importFrom dplyr summarise_at summarise coalesce bind_cols na_if tibble
#' @importFrom magrittr %>%
#' @importFrom rlang := abort arg_match as_function as_string call2 caller_env
#' @importFrom rlang call_name current_env .data enexpr enquo eval_bare eval_tidy expr
#' @importFrom rlang expr_interp expr_label f_lhs f_rhs inform
#' @importFrom rlang is_bare_formula is_call is_character is_formula is_integerish
#' @importFrom rlang is_logical is_quosure is_quosures is_symbol new_formula
#' @importFrom rlang parse_expr parse_exprs quo quo_get_expr quo_is_call
#' @importFrom rlang quo_is_missing quo_is_null quo_is_symbol quos quo_squash quo_text
#' @importFrom rlang set_names sym syms type_of warn quo_set_env quo_get_env exprs
#' @importFrom utils capture.output str
#' @importFrom purrr map map2 map_chr map_lgl reduce walk keep map_if transpose
#' @importFrom purrr flatten every modify_at modify_if reduce compose
#' @importFrom stringr str_c str_detect str_extract str_remove str_remove_all
#' @importFrom stringr str_replace str_trim str_to_lower str_to_title str_to_upper str_glue
#' @importFrom lubridate as_datetime ceiling_date date days duration floor_date is.Date is.instant
#' @importFrom lubridate time_length %--% ymd ymd_hms weeks years hours minutes
#' @importFrom tidyr drop_na nest pivot_longer pivot_wider unnest
#' @importFrom tidyselect all_of contains vars_select
#' @importFrom hms as_hms
#' @importFrom lifecycle deprecate_warn deprecated deprecate_stop
#' @importFrom admiral derive_vars_merged restrict_derivation params derive_param_computed
#' @importFrom admiral derive_vars_cat get_admiral_option
#' @importFrom admiraldev assert_symbol assert_data_frame expect_dfs_equal assert_data_frame
#' @importFrom admiraldev assert_character_vector assert_character_scalar assert_integer_scalar
#' @importFrom admiraldev assert_numeric_vector assert_vars expr_c vars2chr deprecate_inform
"_PACKAGE"
