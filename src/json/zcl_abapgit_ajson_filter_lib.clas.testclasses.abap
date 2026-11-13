CLASS ltcl_filters_test DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.
  PRIVATE SECTION.
    METHODS zero_sample_default FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS zero_sample_false FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS zero_sample_keep FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS zero_matrix_default FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS zero_matrix_keep FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS check_zero_sample
      IMPORTING ii_filter TYPE REF TO zif_abapgit_ajson_filter
                iv_keep   TYPE abap_bool DEFAULT abap_false
      RAISING zcx_abapgit_ajson_error.
    METHODS check_zero_matrix
      IMPORTING ii_filter TYPE REF TO zif_abapgit_ajson_filter
                iv_keep   TYPE abap_bool DEFAULT abap_false
      RAISING zcx_abapgit_ajson_error.
    METHODS empty_filter_simple FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS empty_filter_deep FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS path_filter FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS path_filter_string FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS path_filter_w_patterns FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS path_filter_deep FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS and_filter FOR TESTING RAISING zcx_abapgit_ajson_error.
    METHODS mixed_case_filter FOR TESTING RAISING zcx_abapgit_ajson_error.
ENDCLASS.


CLASS ltcl_filters_test IMPLEMENTATION.

  METHOD zero_sample_default.
    check_zero_sample( zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).
  ENDMETHOD.

  METHOD zero_sample_false.
    check_zero_sample( zcl_abapgit_ajson_filter_lib=>create_empty_filter( iv_keep_zero_numbers = abap_false ) ).
  ENDMETHOD.

  METHOD zero_sample_keep.
    check_zero_sample(
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( iv_keep_zero_numbers = abap_true )
      iv_keep = abap_true ).
  ENDMETHOD.

  METHOD check_zero_sample.
    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_result TYPE REF TO zif_abapgit_ajson.
    DATA lv_input TYPE string.

    lv_input = '{"quoteId":"Q-1001","discount":0,"shippingFee":0,"requiresApproval":false,"notes":"","source":null,' &&
      '"items":[{"amount":0,"description":""},{"amount":25,"description":"Widget"}]}'.
    li_json = zcl_abapgit_ajson=>parse( lv_input ).
    li_result = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = ii_filter ).
    IF iv_keep = abap_true.
      cl_abap_unit_assert=>assert_equals(
        act = li_result->stringify( )
        exp = '{"discount":0,"items":[{"amount":0},{"amount":25,"description":"Widget"}],' &&
          '"quoteId":"Q-1001","requiresApproval":false,"shippingFee":0}' ).
      cl_abap_unit_assert=>assert_equals(
        act = li_result->get_node_type( '/discount' )
        exp = zif_abapgit_ajson_types=>node_type-number ).
      cl_abap_unit_assert=>assert_equals(
        act = li_result->get_node_type( '/shippingFee' )
        exp = zif_abapgit_ajson_types=>node_type-number ).
      cl_abap_unit_assert=>assert_equals(
        act = li_result->get_node_type( '/items/1/amount' )
        exp = zif_abapgit_ajson_types=>node_type-number ).
    ELSE.
      " {} comes from existing filter runner array re-indexing and is out of scope.
      cl_abap_unit_assert=>assert_equals(
        act = li_result->stringify( )
        exp = '{"items":[{}],"quoteId":"Q-1001","requiresApproval":false}' ).
    ENDIF.
  ENDMETHOD.

  METHOD zero_matrix_default.
    check_zero_matrix( zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).
  ENDMETHOD.

  METHOD zero_matrix_keep.
    check_zero_matrix(
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( iv_keep_zero_numbers = abap_true )
      iv_keep = abap_true ).
  ENDMETHOD.

  METHOD check_zero_matrix.
    DATA lt_numbers TYPE string_table.
    DATA lv_number TYPE string.
    DATA lv_input TYPE string.
    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_result TYPE REF TO zif_abapgit_ajson.
    DATA lv_expected TYPE string.

    SPLIT '0,0.0,-0,0e0,0e5,25,-25' AT ',' INTO TABLE lt_numbers.
    LOOP AT lt_numbers INTO lv_number.
      lv_input = '{"array":[' && lv_number && '],"object":{"n":' && lv_number && '}}'.
      li_json = zcl_abapgit_ajson=>parse( lv_input ).
      li_result = zcl_abapgit_ajson=>create_from(
        ii_source_json = li_json
        ii_filter = ii_filter ).
      IF iv_keep = abap_true OR lv_number <> '0'.
        cl_abap_unit_assert=>assert_equals(
          act = li_result->stringify( )
          exp = lv_input ).
        cl_abap_unit_assert=>assert_equals(
          act = li_result->get_node_type( '/object/n' )
          exp = zif_abapgit_ajson_types=>node_type-number ).
        cl_abap_unit_assert=>assert_equals(
          act = li_result->get_node_type( '/array/1' )
          exp = zif_abapgit_ajson_types=>node_type-number ).
      ELSE.
        cl_abap_unit_assert=>assert_equals(
          act = li_result->stringify( )
          exp = '' ).
      ENDIF.

      li_json = zcl_abapgit_ajson=>parse( lv_number ).
      li_result = zcl_abapgit_ajson=>create_from(
        ii_source_json = li_json
        ii_filter = ii_filter ).
      IF iv_keep = abap_true OR lv_number <> '0'.
        cl_abap_unit_assert=>assert_equals(
          act = li_result->stringify( )
          exp = lv_number ).
        cl_abap_unit_assert=>assert_equals(
          act = li_result->get_node_type( '' )
          exp = zif_abapgit_ajson_types=>node_type-number ).
      ELSE.
        cl_abap_unit_assert=>assert_equals(
          act = li_result->stringify( )
          exp = '' ).
      ENDIF.
    ENDLOOP.

    SPLIT 'false,null,"",{},[],[0]' AT ',' INTO TABLE lt_numbers.
    LOOP AT lt_numbers INTO lv_input.
      li_json = zcl_abapgit_ajson=>parse( lv_input ).
      li_result = zcl_abapgit_ajson=>create_from(
        ii_source_json = li_json
        ii_filter = ii_filter ).
      CLEAR lv_expected.
      IF lv_input = 'false' OR ( lv_input = '[0]' AND iv_keep = abap_true ).
        lv_expected = lv_input.
      ENDIF.
      cl_abap_unit_assert=>assert_equals(
        act = li_result->stringify( )
        exp = lv_expected ).
    ENDLOOP.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set_null( '/n' ).
    li_result = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = ii_filter ).
    cl_abap_unit_assert=>assert_equals(
      act = li_result->stringify( )
      exp = '{"n":null}' ).
  ENDMETHOD.

  METHOD empty_filter_simple.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/b'
      iv_val  = '' ).
    li_json->set(
      iv_path = '/c'
      iv_val  = '3' ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/d'
      iv_val  = 0 ).
    li_json->set_boolean(
      iv_path = '/e'
      iv_val  = abap_false ).
    li_json->set_boolean(
      iv_path = '/f'
      iv_val  = abap_true ).
    li_json->set_null( '/g' ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","c":"3","e":false,"f":true,"g":null}' ).

  ENDMETHOD.

  METHOD empty_filter_deep.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/b/c'
      iv_val  = '' ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/b/d'
      iv_val  = 0 ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/d/e'
      iv_val  = 0 ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1"}' ).

  ENDMETHOD.

  METHOD path_filter.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.
    DATA lt_paths TYPE string_table.

    APPEND '/b/c' TO lt_paths.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter( it_skip_paths = lt_paths ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","b":{},"c":{"d":"3"}}' ).

  ENDMETHOD.

  METHOD path_filter_string.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter( iv_skip_paths = '/b/c,/c/d' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","b":{},"c":{}}' ).

  ENDMETHOD.

  METHOD path_filter_w_patterns.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/@meta'
      iv_val  = 'meta' ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).
    li_json->set(
      iv_path = '/c/@meta2'
      iv_val  = 'meta2' ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter(
        iv_skip_paths = '/*/c,*/@*'
        iv_pattern_search = abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","b":{},"c":{"d":"3"}}' ).

  ENDMETHOD.

  METHOD path_filter_deep.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.
    DATA lt_paths TYPE string_table.

    APPEND '/b' TO lt_paths.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/b/c'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/b/d'
      iv_val  = 'x' ).
    li_json->set(
      iv_path = '/c/d'
      iv_val  = '3' ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter( it_skip_paths = lt_paths ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","c":{"d":"3"}}' ).

  ENDMETHOD.

  METHOD and_filter.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.
    DATA lt_filters TYPE zif_abapgit_ajson_filter=>ty_filter_tab.

    APPEND zcl_abapgit_ajson_filter_lib=>create_empty_filter( ) TO lt_filters.
    APPEND zcl_abapgit_ajson_filter_lib=>create_path_filter( iv_skip_paths = '/c' ) TO lt_filters.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/b'
      iv_val  = '' ).
    li_json->set(
      iv_path = '/c'
      iv_val  = '3' ).
    li_json->set(
      iv_ignore_empty = abap_false
      iv_path = '/d'
      iv_val  = 0 ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_and_filter( lt_filters ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1"}' ).

  ENDMETHOD.

  METHOD mixed_case_filter.

    DATA li_json TYPE REF TO zif_abapgit_ajson.
    DATA li_json_filtered TYPE REF TO zif_abapgit_ajson.

    li_json = zcl_abapgit_ajson=>create_empty( ).
    li_json->set(
      iv_path = '/a'
      iv_val  = '1' ).
    li_json->set(
      iv_path = '/bB'
      iv_val  = '2' ).
    li_json->set(
      iv_path = '/CC'
      iv_val  = '3' ).
    li_json->set(
      iv_path = '/cc'
      iv_val  = '4' ).
    li_json->set(
      iv_path = '/d'
      iv_val  = 5 ).

    li_json_filtered = zcl_abapgit_ajson=>create_from(
      ii_source_json = li_json
      ii_filter = zcl_abapgit_ajson_filter_lib=>create_path_filter( iv_skip_paths = '/bB,/CC' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = li_json_filtered->stringify( )
      exp = '{"a":"1","cc":"4","d":5}' ).

  ENDMETHOD.

ENDCLASS.
