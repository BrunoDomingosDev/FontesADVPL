#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PRTOPDEF.CH'
 
User Function M415CANC()

//Tela para informar o motivo de cancelamento
// Author Bruno Domingos
 
    Local aArea         := GetArea()    as array  //Armazena o ambiente ativo para restaurar ao fim do processo
    Local nOpcao        := PARAMIXB     as numeric
    Local cOrcamento    := SCJ->CJ_NUM   as character
     Local cMotivo := ""
    Local cCampo  := SCJ->CJ_XMOTCAN
    Local cNumOrc := SCJ->CJ_NUM
    Local cQuery   := ""
    Local nTotal    := 0
    Local nAtual    := 0
    Local aArea         := FWGetArea()
    Local xGetObj9 := ""
    Local nCorFundo     := RGB(238, 238, 238)
    Local nJanAltura    := 160
    Local nJanLargur    := 700
    Local cJanTitulo    := 'Informe o motivo de cancelamento'
    Local lDimPixels    := .T. 
    Local lCentraliz    := .T. 
    Local nObjLinha     := 0
    Local nObjColun     := 0
    Local nObjLargu     := 0
    Local nObjAltur     := 0
    
    Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -12)
    Private oDialogPvt 
    Private bBlocoIni   := {|| /*fSuaFuncao()*/ } //Aqui voce pode acionar funcoes customizadas que irao ser acionadas ao abrir a dialog 

// cMotivo := AllTrim(FWInputBox("Informe o motivo do cancelamento", "Motivo Cancelamento"))

    Private oSayObj8 
    Private cSayObj8    := 'Selecione:'  

    //objeto9 
    Private oGetObj9 
    Private xGetObj9    := Space(150) //Se o get for data para inicilizar use dToS(''), se for numerico inicie com 0  

    Private oBtnObj14 
    Private cBtnObj14    := 'Confirmar'  
    Private bBtnObj14    := {|| IIF(Empty(xGetObj9),Alert("Informe um motivo válido"),oDialogPvt:End())}  


       oDialogPvt := TDialog():New(0, 0, nJanAltura, nJanLargur, cJanTitulo, , , , , , nCorFundo, , , lDimPixels)
       //objeto8 - usando a classe TSay
        nObjLinha := 32
        nObjColun := 30
        nObjLargu := 100
        nObjAltur := 6
        oSayObj8  := TSay():New(nObjLinha, nObjColun, {|| cSayObj8}, oDialogPvt, /*cPicture*/, oFontPadrao, , , , lDimPixels, /*nClrText*/, /*nClrBack*/, nObjLargu, nObjAltur, , , , , , /*lHTML*/)

        //objeto9 - usando a classe TGet
        nObjLinha := 30
        nObjColun := 70
        nObjLargu := 250
        nObjAltur := 10
        oGetObj9  := TGet():New(nObjLinha, nObjColun, {|u| Iif(PCount() > 0 , xGetObj9 := u, xGetObj9)}, oDialogPvt, nObjLargu, nObjAltur, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontPadrao, , , lDimPixels, , , , , , , , , , , , , ,.T. )
        oGetObj9:cPlaceHold := 'Motivo do cancelamento...'   //Texto que sera exibido no campo antes de ter conteudo
        oGetObj9:cF3        := 'ZZM' //Codigo da consulta padrao / F3 que sera habilitada
        oGetObj9:bValid     := {|| ExistCpo("ZZM", xGetObj9, 3)}           //Funcao para validar o que foi digitado
        oGetObj9:lReadOnly  := .F.                         //Para permitir o usuario clicar mas nao editar o campo
        oGetObj9:lActive    := .T.                         //Para deixar o campo inativo e o usuario nao conseguir nem clicar

        nObjLinha := 53
        nObjColun := 144
        nObjLargu := (nJanAltura/2) - 2
        nObjAltur := 15
        oBtnObj14  := TButton():New(nObjLinha, nObjColun, cBtnObj14, oDialogPvt, bBtnObj14, nObjLargu, nObjAltur, , oFontPadrao, , lDimPixels)

    //Ativa e exibe a janela
    oDialogPvt:Activate(, , , lCentraliz, , , bBlocoIni)

    If !Empty(xGetObj9) // ou If cMotivo != NIL

        DbSelectArea("SCJ")
        DbSetOrder(1) // Índice deve ser Filial + Número do Pedido + Item
        DbSeek(cFilial + cOrcamento)

        RecLock("SCJ", .F.)
            SCJ->CJ_XMOTCAN := xGetObj9
             SCJ->CJ_STATUS  := "C"
        MsUnlock()

        SCJ->(DbSkip())
        SCJ->(DbCloseArea())
        nOpcao := 1

    Else
    
    nOpcao := 0
    
    EndIf

    RestArea(aArea) //Restaura o ambiente ativo no início da chamada

Return nOpcao


Static Function fValidVlr()
    Local aArea := FWGetArea()
    Local lRet := .F.
    If xGetObj13 > 0
        lRet := .T.
    Else
        lRet := .F.
        Alert("Falha na validação")
    EndIf
    FWRestArea(aArea)
Return lRet


