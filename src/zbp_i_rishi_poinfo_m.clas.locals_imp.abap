CLASS lhc_purchaseitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculatePOTotal FOR DETERMINE ON MODIFY
      IMPORTING it_podocument FOR  PurchaseItem~calculatePOTotal.

ENDCLASS.

CLASS lhc_purchaseitem IMPLEMENTATION.

  METHOD calculatePOTotal.
    DATA(test) = abap_true.
    DATA lt_podoc TYPE TABLE FOR READ IMPORT  zi_rishi_poinfo_m\\PurchaseDocument.
    DATA lt_poitem TYPE TABLE FOR READ IMPORT zi_rishi_poinfo_m\\PurchaseDocument\_Items.
    DATA lt_final_price TYPE TABLE FOR UPDATE zi_rishi_poinfo_m\\PurchaseDocument.

    lt_podoc = VALUE #( FOR ls_header IN it_podocument ( po_doc = ls_header-po_document
                                                         %control-curkey = if_abap_behv=>mk-on
                                                       ) ).
    lt_poitem =   VALUE #( FOR ls_item IN it_podocument
                            ( po_doc = ls_item-po_document
                              %control-price = if_abap_behv=>mk-on
                              %control-quantity = if_abap_behv=>mk-on
                              %control-currency = if_abap_behv=>mk-on ) )   .

    READ ENTITIES OF zi_rishi_poinfo_m IN LOCAL MODE
    ENTITY PurchaseDocument
    FROM lt_podoc
    RESULT DATA(lt_po_data)
    ENTITY PurchaseDocument BY \_Items
    FROM lt_poitem
    RESULT DATA(lt_po_item).
    DATA lv_total_price TYPE p DECIMALS 2 LENGTH 5.

    LOOP AT lt_po_item ASSIGNING FIELD-SYMBOL(<lfs_po_item>) GROUP BY <lfs_po_item>-po_document.

      ASSIGN lt_po_data[ KEY entity COMPONENTS po_doc = <lfs_po_item>-po_document ]
      TO FIELD-SYMBOL(<Lfs_po_data>).
      IF sy-subrc EQ 0.
        CLEAR <lfs_po_data>-total_poprice.
      ENDIF.

      LOOP AT GROUP <lfs_po_item> INTO DATA(ls_item_data).

        lv_total_price += ls_item_data-price * ls_item_data-quantity.


      ENDLOOP.
      <lfs_po_data>-total_poprice = lv_total_price.
      CLEAR lv_total_price.


    ENDLOOP.

    lt_final_price = VALUE #( FOR ls_header_price IN lt_po_data
                                 ( po_doc = ls_header_price-po_doc
                                   curkey = ls_header_price-curkey
                                   total_poprice = ls_header_price-total_poprice
                                   %control-total_poprice = if_abap_behv=>mk-on ) ).

    MODIFY ENTITIES OF zi_rishi_poinfo_m IN LOCAL MODE
    ENTITY PurchaseDocument
    UPDATE FROM lt_final_price
    REPORTED DATA(lt_reported).



  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_RISHI_POINFO_M DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS copyPO FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~copyPO RESULT result.
    METHODS validatePO FOR VALIDATE ON SAVE
      IMPORTING keys FOR PurchaseDocument~validatePO.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR PurchaseDocument RESULT result.

ENDCLASS.

CLASS lhc_ZI_RISHI_POINFO_M IMPLEMENTATION.

  METHOD copyPO.

    SELECT MAX( po_doc ) FROM zrishi_poinfo INTO @DATA(lv_podocument).
    "Read the PO Document
    READ ENTITIES OF zi_rishi_poinfo_m IN LOCAL MODE ENTITY PurchaseDocument
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_po_data).
    "Modify the purchase Document with the maximum one
    LOOP AT lt_po_data ASSIGNING FIELD-SYMBOL(<lfs_podata>).
      lv_podocument = lv_podocument + 1.
      <lfs_podata>-po_doc =  condense( lv_podocument ).
    ENDLOOP.

    "Create new entry from lt_po_data.
    MODIFY  ENTITIES OF zi_rishi_poinfo_m IN LOCAL MODE ENTITY PurchaseDocument
    CREATE FIELDS ( po_doc po_description compcode created_on popriority postatus  )
    WITH CORRESPONDING #( lt_po_data ).

    "Send back the result
    result = VALUE #( FOR ls_create IN lt_po_data INDEX INTO lv_index
                        ( %cid_ref = keys[ lv_index ]-%cid_ref
                          %key = keys[ lv_index ]-po_doc
                          %param = CORRESPONDING #( ls_create ) ) ).

  ENDMETHOD.

  METHOD validatePO.
    "read current instance data
    READ ENTITIES OF zi_rishi_poinfo_m IN LOCAL MODE ENTITY PurchaseDocument
    FIELDS ( postatus ) WITH CORRESPONDING #( keys )
    RESULT  DATA(lt_po_docs).

    "eliminate duplicated statuses if any
    SORT lt_po_docs BY postatus.
    DELETE ADJACENT DUPLICATES FROM lt_po_docs COMPARING postatus.

    "fetch DB PO statuses
    SELECT status  FROM zrishi_postatus FOR ALL ENTRIES IN @lt_po_docs
    WHERE status = @lt_po_docs-postatus
    INTO TABLE @DATA(lt_podocs_db).


    "check PO Status and raise message.
    LOOP AT lt_po_docs ASSIGNING FIELD-SYMBOL(<lfs_podocs>).
      IF <lfs_podocs>-postatus IS INITIAL OR NOT line_exists( lt_podocs_db[ status = <lfs_podocs>-postatus ] ).
        APPEND VALUE #( po_doc = <lfs_podocs>-po_doc ) TO failed-purchasedocument.
        DATA(lo_message) = new_message( id = 'ZRISHI_MSG_V1'
                                        number = 001
                                        severity = if_abap_behv_message=>severity-error
                                        v1 = <lfs_podocs>-postatus  ).
        APPEND VALUE #( po_doc = <lfs_podocs>-po_doc
                        %msg = lo_message
                        ) TO reported-purchasedocument.
      ENDIF.

    ENDLOOP.





  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

ENDCLASS.
