@EndUserText.label: 'Managed Scenario for PO ITems'
@AccessControl.authorizationCheck: #CHECK
define view entity ZC_RISHI_POITEMS_M as projection on ZI_RISHI_POITEMS_M {
    key po_document,
    key po_item,
    item_desc,
    vendor,
    price,
    currency,
    quantity,
    unit,
    change_date_time,
    /* Associations */
    _Header : redirected to parent ZC_RISHI_POINFO_Projection 
}
