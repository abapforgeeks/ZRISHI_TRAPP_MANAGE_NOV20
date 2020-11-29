@AbapCatalog.sqlViewName: 'ZIPOITEM_M'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Managed Scenario for PO ITems'
define view ZI_RISHI_POITEMS_M as select from zrishi_poitems
 association to parent ZI_RISHI_POINFO_M  as _Header on $projection.po_document = _Header.po_doc
 {
    key po_document ,
    key po_item ,
    item_desc ,
    vendor ,
    price ,
    currency,
    quantity,
    unit ,
    change_date_time,
    _Header
}
