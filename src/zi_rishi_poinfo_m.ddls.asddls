@AbapCatalog.sqlViewName: 'ZIPOINFO_M'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Managed'
define root view ZI_RISHI_POINFO_M as select from zrishi_poinfo
composition[0..*] of ZI_RISHI_POITEMS_M as _Items

 {
    key po_doc ,
    po_description ,
    postatus ,
    popriority ,
    compcode ,
    total_poprice,
    curkey ,
    createby ,
    created_on,
    changed_on ,
    final_change ,
    _Items
}
