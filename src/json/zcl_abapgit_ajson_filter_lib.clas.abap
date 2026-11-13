CLASS zcl_abapgit_ajson_filter_lib DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS create_empty_filter
      IMPORTING
        !iv_keep_zero_numbers TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ri_filter)      TYPE REF TO zif_abapgit_ajson_filter
      RAISING
        zcx_abapgit_ajson_error .
    CLASS-METHODS create_path_filter
      IMPORTING
        !it_skip_paths     TYPE string_table OPTIONAL
        !iv_skip_paths     TYPE string OPTIONAL
        !iv_pattern_search TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ri_filter)   TYPE REF TO zif_abapgit_ajson_filter
      RAISING
        zcx_abapgit_ajson_error .
    CLASS-METHODS create_and_filter
      IMPORTING
        !it_filters      TYPE zif_abapgit_ajson_filter=>ty_filter_tab
      RETURNING
        VALUE(ri_filter) TYPE REF TO zif_abapgit_ajson_filter
      RAISING
        zcx_abapgit_ajson_error .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abapgit_ajson_filter_lib IMPLEMENTATION.


  METHOD create_and_filter.
    CREATE OBJECT ri_filter TYPE lcl_and_filter
      EXPORTING
        it_filters = it_filters.
  ENDMETHOD.


  METHOD create_empty_filter.
    CREATE OBJECT ri_filter TYPE lcl_empty_filter
      EXPORTING
        iv_keep_zero_numbers = iv_keep_zero_numbers.
  ENDMETHOD.


  METHOD create_path_filter.
    CREATE OBJECT ri_filter TYPE lcl_paths_filter
      EXPORTING
        iv_pattern_search = iv_pattern_search
        it_skip_paths = it_skip_paths
        iv_skip_paths = iv_skip_paths.
  ENDMETHOD.
ENDCLASS.
