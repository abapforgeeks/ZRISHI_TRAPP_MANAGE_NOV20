@EndUserText.label: 'Projection on Purchase Info root view'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_RISHI_POINFO_Projection as projection on ZI_RISHI_POINFO_M {
    key po_doc,
    po_description,
    postatus,
    popriority,
    compcode,
    total_poprice,
    curkey,
    createby,
    created_on,
    changed_on,
    final_change,
    /* Associations */
    _Items: redirected to composition child ZC_RISHI_POITEMS_M
}
