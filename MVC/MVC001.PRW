#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTitulo := "Motivos de Cancelamento"
Static cALiasMVC  := "ZZM"

//-------------------------------------------------------------------
/*/{Protheus.doc} zMVC01
Monta a tela da tabela ZZM (Cadastro de motivos de cancelamento de orçamento)
@author  Bruno Domingos
@since   22/07//2025
@version 1.0
/*/
//-------------------------------------------------------------------

User Function zMVC02()

    Local aArea := GetArea()
    Local oBrowse
    Private aRotina := {}

    //Definicao do Menu
    
    aRotina  :=  MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cALiasMVC)
    oBrowse:SetDescription(cTitulo)
    oBrowse:DisableDetails()
    oBrowse:AddLegend( "ZZM->ZZM_ATIVO == 'S'", "GREEN",    "Cadastro Ativo" )
    oBrowse:AddLegend( "ZZM->ZZM_ATIVO == 'N'", "RED",    "Cadastro Inativo" )

    oBrowse:Activate()

    RestArea(aArea)
Return Nil

Static Function MenuDef()

    Local aRotina   :=  {}

    ADD OPTION aRotina TITLE "Pesquisar" ACTION "PesqBrw" OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.zMVC02" OPERATION MODEL_OPERATION_VIEW ACCESS 0
    ADD OPTION aRotina TITLE "Incluir" ACTION "VIEWDEF.zMVC02"    OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotina TITLE "Alterar" ACTION "VIEWDEF.zMVC02" OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.zMVC02" OPERATION MODEL_OPERATION_DELETE ACCESS 0

Return aRotina

Static Function ModelDef()

    Local oStruct   := FWFormStruct(1, cALiasMVC)
    Local oModel
    Local bPre  := Nil
    Local bPos  := Nil
    Local bCommit   := Nil
    Local bCancel   := Nil

    oModel  :=  MPFormModel():New("zMVC02M", bPre, bPos, bCommit, bCancel)
    oModel:AddFields("ZZMMASTER", /*cOwner*/, oStruct)
    oModel:SetDescription(cTitulo)
    oModel:GetModel("ZZMMASTER"):SetDescription( "Dados de - " + cTitulo)
    oModel:SetPrimaryKey({})
Return oModel


User Function z03Model()
Return ModelDef()


Static Function ViewDef()
    Local oModel    :=  FWLoadModel("zMVC02")
    Local oStruct   :=  FWFormStruct(2, cALiasMVC)
    Local oView

    oView   := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_ZZM", oStruct, "ZZMMASTER")
    oView:CreateHorizontalBox("TELA" ,  100)
    oView:SetOwnerView("VIEW_ZZM", "TELA")

Return oView
