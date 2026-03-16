#Include "Totvs.ch"
#Include "PRTOPDEF.ch"
#Include "RPTdef.ch"
#Include "TopConn.ch"


//-------------------------------------------------------------------
/*/{Protheus.doc}
Relatório de Op com Estrtutura
@author  Bruno Domingos
@since   25/07/2025
@version 1.0
/*/
//-------------------------------------------------------------------

//Pads
Static nPadLeft   := 0                                                                     //Alinhamento a Esquerda
Static nPadRight  := 1                                                                     //Alinhamento a Direita
Static nPadCenter := 2                                                                     //Alinhamento Centralizado

Static nTamFundo  := 15                                                                    //Altura de fundo dos blocos com tÃ­tulo

//Fontes
Static cNomeFont  := "Arial"                                                               //Nome da Fonte PadrÃ£o
Static oFontDet   := Nil                                                                   //Fonte utilizada na impressÃ£o dos itens
Static oFontDetN  := Nil                                                                   //Fonte utilizada no cabeÃ§alho dos itens
Static oFontRod   := Nil                                                                   //Fonte utilizada no rodapÃ© da pÃ¡gina
Static oFontTit   := Nil                                                                   //Fonte utilizada no TÃ­tulo das seÃ§Ãµes
Static oFontCab   := Nil                                                                   //Fonte utilizada na impressÃ£o dos textos dentro das seÃ§Ãµes
Static oFontCabN  := Nil                                                                   //Fonte negrita utilizada na impressÃ£o dos textos dentro das seÃ§Ãµes

//Cores
Static nCorVerdeCl  := RGB(000, 102, 000)                                                  //Cor Azul usada nos TÃ­tulos
Static nCorCinza  := RGB(040, 040, 040)                                                    //Cor Cinza usada nos textos
Static nCorPreto  := RGB(000, 000, 000)
Static nCorVerdeEsc := RGB(000, 050, 000)                                                  //Cor Verde Escuro usada nos textos
Static nCorBranco := RGB(255, 255, 255)

//Mascaras
Static cMaskPad   := "@E 99,999,999,999.99"                                                       //MÃ¡scara padrÃ£o de valor
Static cMaskTel   := "@R (99) 99999999"                                                    //MÃ¡scara de telefone / fax
Static cMaskCNPJ  := "@R 99.999.999/9999-99"                                               //MÃ¡scara de CNPJ
Static cMaskCEP   := "@R 99999-999"                                                        //MÃ¡scara de CEP
Static cMaskIE    := "@R 999.999.999.999"
Static cMaskCPF   := "@R 999.999.999-99"                                                   //MÃ¡scara de CPF
Static cMaskQtd   := PesqPict("SC2", "C2_QUANT")                                          //MÃ¡scara de quantidade
Static cLinCa

//VariÃ¡veis diversas
Static cEmpEmail  := Alltrim(SuperGetMV("MV_X_EMAIL", .F., "fw@fwdobrasil.com.br"))        //ParÃ¢metro com o e-Mail da empresa
Static cEmpSite   := Alltrim(SuperGetMV("MV_X_HPAGE", .F., "http://www.fwdobrasil.com.br"))   //ParÃ¢metro com o site da empresa

User Function rOpEst()

    Local aArea     := FWGetArea()
    Local aAreaC2   := SC2->(FWGetArea())
    Local aPergs    := {}
    Local aRetorn   := {}
    Local oProcess  := Nil
    Local cInterBkp := __cInternet
    __cInternet := "AUTOMATICO"

    //VariÃ¡veis usadas nas outras funcoes
    Private cLogoEmp := "\system\lgmid.png"
    Private cOp   := SC2->C2_NUM
    Private cZeraPag := "1"
    Private cLayout := "1" //1-Sim 2-Não

    //Perguntas para o Parambox
    aAdd(aPergs, {1, "Op",  cOp, "", ".T.", "SC2", ".T.", 80, .T.})
    aAdd(aPergs, {2, "Quebra Página",               cLayout, {"1=Sim", "2=Não"}, 100, ".T.", .T.})
    cZeraPag := 1///

    //Se a pergunta for confirmada chama o Parambox
    If ParamBox(aPergs, "Informe os parâmetros", @aRetorn, , , , , , , , .F., .F.)
        cOp   :=            aRetorn[1]
        cLayout :=          aRetorn[2]

        //Processa o Relatório
        oProcess := MsNewProcess():New({|| fMontaRel(@oProcess) }, "Impressão da Ordem de Produção com Estrutura", ,.F.)
        oProcess:Activate()
    EndIf

    __cInternet := cInterBkp
    FWRestArea(aArea)
    FWRestArea(aAreaC2)
Return

Static Function fMontaRel(oProcess)

    //VariÃ¡veis usada no controle das rÃ©guas
    Local nTotIte       := 0
    Local nItAtu        := 0
    Local nTotPed       := 0
    Local nPedAtu       := 0
    //Consultas SQL
    Local cQryPed       := ""
    Local cQryIte       := ""
    //Valores de Impostos

    //VariÃ¡veis do Relatório
    Local nLinCab       := 025
    Local nLinCabOrig := nLinCab
    Local cNomeRel      := "opestrutura_"+"_"+dToS(Date())+"_"+StrTran(Time(), ":", "-")
    Local nPos          := 0
    Local cEmailCompleto := ""
    Local cEmail        := ""
    Local aMsg  := Array(7)
    Local nQueb := 200
    Local nQueb2 := 75
    Local cObsop := ""
    Local aObsop := {"", "", "", ""}
    Local cMsg  := ""
    Local aMsgop := {}
    Local aMsgop2 := {}
    Local nAtual   := 1
    Local cAtual    := ""
    Local cRestante := ""
    Local nQuebras  := 0
    Local nI := 0
    Local nUltPos := 0
    Private oPrintPvt
    Private nLinAux       := 0
    Private cHoraEx     := Time()
    Private cDataEx     := Date()
    Private nPagAtu     := 1

    Private nLinCab       := 040
    Private nLinCabOrig := nLinCab
    Private cPedCli := ""

    Private aDuplicatas := {}
    oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
    oFontTit   := TFont():New(cNomeFont, 12, -20, , .T.)
    oFontCab   := TFont():New(cNomeFont, , -12, , .F.)
    oFontCabN  := TFont():New(cNomeFont, , -12, , .T.)
    oFontOrc   := TFont():New(cNomeFont, , -10, , .F.)
    oFontDet   := TFont():New(cNomeFont, , -8, , .F.)
    oFontDetN  := TFont():New(cNomeFont, , -8, , .T.)
    oFontCau   := TFont():New(cNomeFont, , -10, , .T.)
    oFontCas   := TFont():New(cNomeFont, , -12, , .T.)
    //Linhas e colunas
    Private nLinAtu     := 0
    Private nLTamLin    := 010
    Private nLinFin     := 780
    Private nLinIni     := 000
    Private nColIni     := 000
    Private nColFin     := 559
    Private nColMeio    := (nColFin-nColIni)/2
    Private nEspLin     := 015
    Private nLinRod     := nLinFin + 10


    // 	Private nLinAtu     := 0
    // Private nLTamLin    := 010
    // Private nLinFin     := 780
    // Private nColIni     := 000
    // Private nColFin     := 563
    // Private nColMeio    := (nColFin-nColIni)/2
    // Private nEspLin     := 015
    // Private nLinRod:= nLinFin + 10

    //Totalizadores
    Private nTotFrete   := 0
    Private nValorTot   := 0
    Private nTotalST    := 0
    Private nTotVal     := 0
    Private nTotICM		:= 0
    Private cFretePed   := ""
    Private nTotIPI     := 0
    Private cFilial		:= FWxFilial("SC2")
    Private cMaskQtd := PesqPict("SC2", "C2_QUANT") //MÃ¡scara de quantidade
    Private cSequen  := SC2->C2_SEQUEN
    Private cItem    := SC2->C2_ITEM

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
    SB1->(DbGoTop())
    DbSelectArea("SC2")

    //Criando o objeto de impressÃ£o
    oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
    oPrintPvt:cPathPDF := GetTempPath()
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)

    fImpProd()

    //		fImpRod()
    //Gera o pdf para visualização
    oPrintPvt:Preview()

    If Empty(cOp)
        MsgStop("Não há estrutura!", "Atenção")
    EndIf

    SC2->(DbCloseArea())

Return

Static Function fImpCab()
    Local cTexto      := ""
    // Local nLinCab     := 025
    // Local nLinCabOrig := nLinCab
    Local cCodBar     := ""
    Local nColMeiPed  := nColMeio+8+((nColMeio-nColIni)/2)
    Local cCGC        := ""
    Local cFretePed   := ""
    //Dados da FW
    Local cEmpresa    := AllTrim(SM0->M0_FULNAME)
    Local cEmpTel     := Alltrim(SM0->M0_TEL)
    Local cEmpCidade  := AllTrim(SM0->M0_CIDENT)+" / "+SM0->M0_ESTENT
    Local cEmpCnpj    := Alltrim(Transform(SM0->M0_CGC, cMaskCNPJ))
    Local cEmpCep     := Alltrim(Transform(SM0->M0_CEPENT, cMaskCEP))
    Local cEmpEnd     := AllTrim(SM0->M0_ENDCOB)
    Local cEmpBairro  := AllTrim(SM0->M0_BAIRCOB)
    Local cEmpIe      := AllTrim(Transform(SM0->M0_INSC, cMaskIE))
    Local cData       := ""
    Local cCLi        := ""
    Local cData       := ""

    Private nLinCab       := 025
    Private nLinCabOrig := nLinCab


    ///////////////COMECA OS PRINTS

    oPrintPvt:StartPage()

    //Código de barras
    nLinCab := nLinCabOrig

    //Tí­tulo
    nLinAtu := 35
    DbSelectArea("SC2")
    DbSetOrder(1)
    DbSeek(SC2->C2_FILIAL + cOp)

    cClient := AllTrim(SC2->C2_XNOMCLI)

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)


    oPrintPvt:SayAlign(nLinAtu, nColIni, "Estrutura de Ordem de Produção", oFontTit, nColFin-nColIni, nTamFundo, nCorVerdeEsc, nPadCenter, )

    nLinAtu += 20

    cData := AllTrim(QRY_OP->C2_DATPRF)

    If Len(cData) == 8
        cData := SubStr(cData, 7, 2) + "/" + SubStr(cData, 5, 2) + "/" + SubStr(cData, 1, 4)
    EndIf


    oPrintPvt:SayAlign(nLinAtu, nColIni, cEmpresa + " - OP: " + cOp + " - DT. DE ENTREGA: "+ AllToChar(cData), oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadCenter, )

    nLinAtu += 20

    oPrintPvt:SayAlign(nLinAtu, nColIni, "Cliente: " + cClient, oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadCenter)


    nLinAtu += 13

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)

    nLinAtu += 05
    DBCloseArea("SC2")
Return

Static Function fImpRod()

    oPrintPvt:EndPage()
return

Static Function fImpProd()
    Local cQryOP     := ""
    Local cOpAtual   := ""
    Local cItemAtual := ""
    Local nQuant     := ""
    Local nTotPed    := 0
    Local aMsg  := Array(7)
    Local nQueb := 100
    Local nQueb2 := 75
    Local cObsop := ""
    Local aObsop := {"", "", "", ""}
    Local cMsg  := ""
    Local aMsgop := {}
    Local aMsgop2 := {}
    Local nAtual   := 1
    Local cAtual    := ""
    Local cRestante := ""
    Local nQuebras  := 0
    Local nI := 0
    Local nUltPos := 0

    cQryOP := " SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, C2_DATPRF, "  + CRLF
    cQryOP += " SC2.C2_PRODUTO, SC2.C2_QUANT, SB1.B1_COD, SB1.B1_DESC, SC2.C2_UM "+ CRLF
    cQryOP += " FROM " + RetSQLName("SC2") + " SC2 "+ CRLF
    cQryOP += " LEFT JOIN " + RetSQLName("SB1") + " SB1 ON SC2.C2_PRODUTO = SB1.B1_COD "+ CRLF
    cQryOP += " WHERE SC2.C2_FILIAL = '" + FWxFilial("SC2") + "' " + CRLF
    cQryOP += " AND SC2.C2_NUM = '" + cOp + "' " + CRLF
    cQryOP += " AND SC2.D_E_L_E_T_ = ' ' "+ CRLF
    cQryOP += " ORDER BY SC2.C2_ITEM, SC2.C2_SEQUEN "

    TCQuery cQryOP New Alias "QRY_OP"
    QRY_OP->(DbGoTop())

    While !QRY_OP->(EoF())
        cOpAtual   := QRY_OP->C2_NUM
        cItemAtual := QRY_OP->C2_ITEM
        nQuant     := QRY_OP->C2_QUANT

        If AllTrim(QRY_OP->C2_SEQUEN) == "001"

            fImpCab()

            cMsg := "IT.: " + AllTrim(cItemAtual) + ;
                "  SEQ.: " + AllTrim(QRY_OP->C2_SEQUEN) + ;
                "  COD: " + AllTrim(QRY_OP->C2_PRODUTO) + ;
                "  - " + AllTrim(QRY_OP->B1_DESC) + ;
                " - QTD: " + AllTrim(Transform(nQuant, cMaskQtd)) + " " + QRY_OP->C2_UM

            cRestante := AllTrim(cMsg)
            nQuebras  := 7

            nLinAtu += 20
            For nI := 1 To nQuebras
                aMsg[nI] := "" // zera as posições
            Next

            For nI := 1 To nQuebras
                If Len(cRestante) > nQueb .And. nI < nQuebras
                    cParte := SubStr(cRestante, 1, nQueb)
                    nEspaco := RAt(" ", cParte)

                    If nEspaco > 0
                        cParte := SubStr(cRestante, 1, nEspaco)
                    Else
                        cParte := SubStr(cRestante, 1, nQueb)
                    EndIf

                    aMsg[nI] := AllTrim(cParte)
                    cRestante := AllTrim(SubStr(cRestante, Len(cParte) + 1))
                Else
                    aMsg[nI] := AllTrim(cRestante)
                    Exit
                EndIf
            Next

            nLinAtu -= 12

            For nAtual := 1 To Len(aMsg)
                If !Empty(aMsg[nAtual])
                    oPrintPvt:SayAlign(nLinAtu, nColIni,   aMsg[nAtual],oFontCabN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft)
                    nLinAtu += 13
                EndIf
            Next

            nLinAtu += 05
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)




            // // Impressão apenas dos filhos diretos
            fImpBr(QRY_OP->C2_PRODUTO, QRY_OP->C2_QUANT)

            // Impressão hierárquica
            fImpEstrutura(QRY_OP->C2_PRODUTO, QRY_OP->C2_QUANT)

            fImpRod()

        EndIf

        If nLinAtu + 40 >= nLinFin
            fImpRod()
            fImpCab()
            nLinAtu := nLinIni
        EndIf

        QRY_OP->(DbSkip())
    EndDo

    nLinAtu += 10
    QRY_OP->(DbCloseArea())
Return

Static Function fImpEstrutura(cProduto, nQuantPai)
    Local cQryEst     := ""
    Local cProdPai    := AllTrim(cProduto)
    Local cProdF      := ""
    Local cFilial     := FWxFilial("SG1")
    Local cAliasEst   := GetNextAlias()
    Local nQuantComp  := 0
    Local nQuantTotal := 0
    LOcal cInterBkp := __cInternet
    Local lRet := .T.
    Local aMsg  := Array(7)
    Local nQueb := 150
    Local nQueb2 := 75
    Local cObsop := ""
    Local aObsop := {"", "", "", ""}
    Local cMsg  := ""
    Local aMsgop := {}
    Local aMsgop2 := {}
    Local nAtual   := 1
    Local cAtual    := ""
    Local cRestante := ""
    Local nQuebras  := 0
    Local nI := 0
    Local nUltPos := 0
    Local cItemAtual := ""

    cQryEst := " SELECT SG1.G1_COD, SG1.G1_COMP, SG1.G1_QUANT, SG1.G1_XUN, SB1.B1_DESC " + CRLF
    cQryEst += " FROM " + RetSQLName("SG1") + " SG1 " + CRLF
    cQryEst += " LEFT JOIN " + RetSQLName("SB1") + " SB1 ON SG1.G1_COMP = SB1.B1_COD " + CRLF
    cQryEst += " WHERE SG1.G1_FILIAL = '" + cFilial + "' " + CRLF
    cQryEst += " AND SG1.G1_COD = '" + cProdPai + "' " + CRLF
    cQryEst += " AND SG1.D_E_L_E_T_ = ' ' "

    TCQuery cQryEst New Alias (cAliasEst)
    (cAliasEst)->(DbGoTop())

    __cInternet := "AUTOMATICO"
    While !(cAliasEst)->(EoF())

        cProdF       := AllTrim((cAliasEst)->G1_COMP)
        nQuantComp   := (cAliasEst)->G1_QUANT
        nQuantTotal  := nQuantComp * nQuantPai

        // nLinAtu += 20
        // oPrintPvt:SayAlign(nLinAtu, nColIni, ;
        //      " COMP: " + cProdF + ;
        //      " QTD: " + AllTrim(Transform(nQuantTotal, cMaskQtd)) + " " + ;
        //      AllTrim((cAliasEst)->G1_XUN) + ;
        //      " - " + AllTrim((cAliasEst)->B1_DESC), ;
        //      oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft)

        // Quebra de página, se necessário
        If nLinAtu + 40 >= nLinFin
            fImpCab()
            fImpRod()
            nLinAtu := 110
        EndIf

        // Verifica se o componente tem subestrutura
        If fExis(cFilial, cProdF)

            If cLayout == "1"
                fImpCab()
            endIf
            // Espaço antes do novo grupo

            cMsg:= "SUB-ESTRUTURA DE: " + AllTrim(cProdF) +;
                "  QTD: " + AllTrim(Transform(nQuantTotal, cMaskQtd)) + " " + ;
                AllTrim((cAliasEst)->G1_XUN) + ;
                " - " + AllTrim((cAliasEst)->B1_DESC)

            cRestante := AllTrim(cMsg)
            nQuebras  := 7

            nLinAtu += 20
            For nI := 1 To nQuebras
                aMsg[nI] := "" // zera as posições
            Next

            For nI := 1 To nQuebras
                If Len(cRestante) > nQueb .And. nI < nQuebras
                    cParte := SubStr(cRestante, 1, nQueb)
                    nEspaco := RAt(" ", cParte)

                    If nEspaco > 0
                        cParte := SubStr(cRestante, 1, nEspaco)
                    Else
                        cParte := SubStr(cRestante, 1, nQueb)
                    EndIf

                    aMsg[nI] := AllTrim(cParte)
                    cRestante := AllTrim(SubStr(cRestante, Len(cParte) + 1))
                Else
                    aMsg[nI] := AllTrim(cRestante)
                    Exit
                EndIf
            Next


            IF nLinAtu + 40 >= nLinFin
                fImpRod()
                fImpCab()
                nLinAtu := nLinIni + 100
            EndIF



            nLinAtu -= 12

            For nAtual := 1 To Len(aMsg)
                If !Empty(aMsg[nAtual])

                    oPrintPvt:SayAlign(nLinAtu, nColIni, aMsg[nAtual],oFontCabN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft)
                    nLinAtu += 13
                EndIf
            Next

            nLinAtu += 05
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
            oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)

            // oPrintPvt:SayAlign(nLinAtu, nColIni, ;
            //     "IT.: " + AllTrim(cItemAtual) + ;
            //     "  SEQ.: " + AllTrim(QRY_OP->C2_SEQUEN) + ;
            //     "  COD: " + AllTrim(QRY_OP->C2_PRODUTO) + ;
            //     "  - " + AllTrim(QRY_OP->B1_DESC) + ;
            //     "  QTD: " + AllTrim(Transform(nQuant, cMaskQtd)) + " " + QRY_OP->C2_UM, ;
            //     oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft)


            fImpBr(cProdF, nQuantTotal)

            fImpEstrutura(cProdF, nQuantTotal)
            fImpRod()
        else
            Alert("Não há subestrutura para o componente: " + cProdF, "Atenção")
        endIf


        (cAliasEst)->(DbSkip())
    EndDo
    (cAliasEst)->(DbCloseArea())
Return





Static Function fImpBr(cProduto, nQuantPai)
    Local cQryEst     := ""
    Local cProdPai    := AllTrim(cProduto)
    Local cProdF      := ""
    Local cFilial     := FWxFilial("SG1")
    Local cAliasEst   := GetNextAlias()
    Local nQuantComp  := 0
    Local nQuantTotal := 0
    Local aMsg  := Array(7)
    Local nQueb := 150
    Local nQueb2 := 75
    Local cObsop := ""
    Local aObsop := {"", "", "", ""}
    Local cMsg  := ""
    Local aMsgop := {}
    Local aMsgop2 := {}
    Local nAtual   := 1
    Local cAtual    := ""
    Local cRestante := ""
    Local nQuebras  := 0
    Local nI := 0
    Local nUltPos := 0

    cQryEst := " SELECT SG1.G1_COD, SG1.G1_COMP, SG1.G1_QUANT, SG1.G1_XUN, SB1.B1_DESC " + CRLF
    cQryEst += " FROM " + RetSQLName("SG1") + " SG1 " + CRLF
    cQryEst += " LEFT JOIN " + RetSQLName("SB1") + " SB1 ON SG1.G1_COMP = SB1.B1_COD " + CRLF
    cQryEst += " WHERE SG1.G1_FILIAL = '" + cFilial + "' " + CRLF
    cQryEst += " AND SG1.G1_COD = '" + cProdPai + "' " + CRLF
    cQryEst += " AND SG1.D_E_L_E_T_ = ' ' "
    TCQuery cQryEst New Alias (cAliasEst)
    (cAliasEst)->(DbGoTop())
    While !(cAliasEst)->(EoF())


        cProdF := AllTrim((cAliasEst)->G1_COMP)
        nQuantComp   := (cAliasEst)->G1_QUANT
        nQuantTotal  := nQuantComp * nQuantPai

        //   nLinAtu += 05


        cMsg := " COD: " + cProdF +          ;
            " QTD: " + AllTrim(Transform(nQuantTotal, cMaskQtd)) + " " + Alltrim(nQuantTotal) + " " + G1_XUN +;
            " " + AllTrim((cAliasEst)->B1_DESC) ;

        cRestante := AllTrim(cMsg)
        nQuebras  := 7


        For nI := 1 To nQuebras
            aMsg[nI] := "" // zera as posições
        Next

        For nI := 1 To nQuebras
            If Len(cRestante) > nQueb .And. nI < nQuebras
                cParte := SubStr(cRestante, 1, nQueb)
                nEspaco := RAt(" ", cParte)

                If nEspaco > 0
                    cParte := SubStr(cRestante, 1, nEspaco)
                Else
                    cParte := SubStr(cRestante, 1, nQueb)
                EndIf

                aMsg[nI] := AllTrim(cParte)
                cRestante := AllTrim(SubStr(cRestante, Len(cParte) + 1))
            Else
                aMsg[nI] := AllTrim(cRestante)
                Exit
            EndIf
        Next


        For nAtual := 1 To Len(aMsg)

            If nLinAtu + 20 >= nLinFin
                fImpCab()
                fImpRod()
                nLinAtu := 100
            EndIf


            If !Empty(aMsg[nAtual])

                If nLinAtu + 20 >= nLinFin

                    fImpCab()
                    fImpRod()
                    nLinAtu := 0130
                EndIf

                oPrintPvt:SayAlign(nLinAtu, nColIni,aMsg[nAtual],oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft)
                nLinAtu += 07
            EndIf
        Next

        nLinAtu += 5

        oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
        oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin)
        If nLinAtu + 20 >= nLinFin

            fImpCab()
            fImpRod()
            nLinAtu := 040
        EndIf
        (cAliasEst)->(DbSkip())

    EndDo
    (cAliasEst)->(DbCloseArea())
Return

Static Function fExis(cFilialx, cProdx)

    Local lRet := .F.
    Local aArea := FWGetArea()

    DbSelectArea("SG1")
    DbSetOrder(1)

    If SG1->(MsSeek(cFilialx + cProdx))
        lRet := .T.
    Else
        lRet := .F.
        Alert("Não há subestrutura para o componente: " + cProdx, "Atenção")
    EndIf

    FWRestArea(aArea)
Return lRet
