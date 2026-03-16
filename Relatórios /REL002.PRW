#Include "Totvs.ch"
#Include "PRTOPDEF.ch"
#Include "RPTdef.ch"
#Include "TopConn.ch"
#Include "FWPrintSetup.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc}
Relatório de Orçamento Customizado
@author  Bruno Domingos
@since   10/06/2025
@version 1.0
/*/
//-------------------------------------------------------------------

// Variáveis Ultilizadas no Fonte inteiro

//Pads
Static nPadLeft   := 0                                                                     //Alinhamento a Esquerda
Static nPadRight  := 1                                                                     //Alinhamento a Direita
Static nPadCenter := 2                                                                     //Alinhamento Centralizado

//Posições iniciais de Colunas do Relatório
Static nPosCod    := 0000                                                                  //Posição Inicial da Coluna de Código do Produto
Static nPosDesc   := 0000                                                                  //Posição Inicial da Coluna de Descrição
Static nPosUnid   := 0000                                                                  //Posição Inicial da Coluna de Unidade de Medida
Static nPosQuan   := 0000                                                                  //Posição Inicial da Coluna de Quantidade
Static nPosVUni   := 0000                                                                  //Posição Inicial da Coluna de Valor Unitario
Static nPosVTot   := 0000                                                                  //Posição Inicial da Coluna de Valor Total
Static nPosBIcm   := 0000                                                                  //Posição Inicial da Coluna de Base Calculo ICMS
Static nPosVIcm   := 0000                                                                  //Posição Inicial da Coluna de Valor ICMS
Static nPosVIPI   := 0000                                                                  //Posição Inicial da Coluna de Valor Ipi
Static nPosAIcm   := 0000                                                                  //Posição Inicial da Coluna de Aliquota ICMS
Static nPosAIpi   := 0000                                                                  //Posição Inicial da Coluna de Aliquota IPI
Static nPosSTUn   := 0000                                                                  //Posição Inicial da Coluna de Valor Unitário ST
Static nPosSTVl   := 0000                                                                  //Posição Inicial da Coluna de Valor Unitário + ST
Static nPosSTBa   := 0000                                                                  //Posição Inicial da Coluna de Base do ST
Static nPosSTTo   := 0000                                                                  //Posição Inicial da Coluna de Valor Total ST
Static nTamFundo  := 15                                                                    //Altura de fundo dos blocos com título

//Fontes
Static cNomeFont  := "Arial"                                                               //Nome da Fonte Padrão
Static oFontDet   := Nil                                                                   //Fonte utilizada na impressão dos itens
Static oFontDetN  := Nil                                                                   //Fonte utilizada no cabeçalho dos itens
Static oFontRod   := Nil                                                                   //Fonte utilizada no rodapé da página
Static oFontTit   := Nil                                                                   //Fonte utilizada no Título das seções
Static oFontCab   := Nil                                                                   //Fonte utilizada na impressão dos textos dentro das seções
Static oFontCabN  := Nil                                                                   //Fonte negrita utilizada na impressão dos textos dentro das seções

//Cores
Static nCorVerdeCl  := RGB(000, 102, 000)                                                  //Cor Azul usada nos Títulos
Static nCorCinza  := RGB(040, 040, 040)                                                    //Cor Cinza usada nos textos
Static nCorPreto  := RGB(000, 000, 000)
Static nCorVerdeEsc := RGB(000, 051, 000)                                                  //Cor Verde Escuro usada nos textos
Static nCorBranco := RGB(255, 255, 255)                                                   //Cor Branca usada nos textos

//Mascaras
Static cMaskPad   := "@E 99,999,999,999.99"                                                       //Máscara padrão de valor
Static cMaskTel   := "@R (99) 99999999"                                                    //Máscara de telefone / fax
Static cMaskCNPJ  := "@R 99.999.999/9999-99"                                               //Máscara de CNPJ
Static cMaskCEP   := "@R 99999-999"                                                        //Máscara de CEP
Static cMaskIE    := "@R 999.999.999.999"
Static cMaskCPF   := "@R 999.999.999-99"                                                   //Máscara de CPF
Static cMaskQtd   := PesqPict("SCK", "CK_QTDVEN")                                          //Máscara de quantidade
Static cMaskPrc   := PesqPict("SCK", "CK_PRCVEN")                                          //Máscara de preço
Static cMaskVlr   := PesqPict("SCK", "CK_VALOR")                                           //Máscara de valor
Static cMaskFrete := PesqPict("SCJ", "CJ_FRETE")                                           //Máscara de frete


//Variáveis diversas
Static cEmpEmail  := Alltrim(SuperGetMV("MV_X_EMAIL", .F., "fw@fwdobrasil.com.br"))        //Parâmetro com o e-Mail da empresa
Static cEmpSite   := Alltrim(SuperGetMV("MV_X_HPAGE", .F., "http://www.fwdobrasil.com.br"))   //Parâmetro com o site da empresa


//-------------------------------------------------------------------
/*/{Protheus.doc} rOrcVen
Relatório de Orçamento
@author  Bruno Domingos
@since   03/06/2025
@version 1.0
/*/
//-------------------------------------------------------------------

User Function RORCVEN()

	Local aArea     := FWGetArea()
	Local aAreaC5   := SCJ->(FWGetArea())
	Local aPergs    := {}
	Local aRetorn   := {}
	Local oProcess  := Nil

	//Variáveis usadas nas outras funcoes
	Private cLogoEmp := "\system\lgmid.png"
	Private cPedDe   := SCJ->CJ_NUM
	Private cPedAte  := SCJ->CJ_NUM
	Private cLayout  := "1"
	Private cTipoBar := "2."
	Private cZeraPag := "1"

	//Perguntas para o Parambox
	aAdd(aPergs, {1, "Orçamento De",  cPedDe, "", ".T.", "SCJ", ".T.", 80, .F.})
	aAdd(aPergs, {1, "Orçamento Até", cPedAte, "", ".T.", "SCJ", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Layout",                         Val(cLayout),  {"1=Dados com IPI"}  ,                                                   100, ".T.", .F.})
	aAdd(aPergs, {2, "Código de Barras",               Val(cTipoBar), {"1=Número do orçamento", "2=Filial + Número do orçamento", "3=Sem Código de Barras"}, 100, ".T.", .F.})
	aAdd(aPergs, {2, "Zera a Página", Val(cZeraPag), {"1=Sim",              "2=Não"},                                                 100, ".T.", .F.})

	cZeraPag := 1///
	cLayout  := 1///

	//Se a pergunta for confirmada chama o Parambox
	If ParamBox(aPergs, "Informe os parâmetros", @aRetorn, , , , , , , , .F., .F.)
		cPedDe   :=            aRetorn[1]
		cPedAt   :=            aRetorn[2]
		cLayout  := cValToChar(aRetorn[3])
		cTipoBar := cValToChar(aRetorn[4])
		cZeraPag := cValToChar(aRetorn[5])


		fMudaLayout() //Muda o Layout do Relatório

		//Processa o Relatório
		oProcess := MsNewProcess():New({|| fMontaRel(@oProcess) }, "Impressão do Orçamento de Venda", ,.F.)
		oProcess:Activate()
	EndIf

	FWRestArea(aArea)
	FWRestArea(aAreaC5)
Return


/*----------------------------------------------------------------------------------/
@Func fMontaRel
@author  Bruno Domingos
@since   03/06/2025
/*----------------------------------------------------------------------------------*/

Static Function fMontaRel(oProc)

	//Variáveis usada no controle das réguas
	Local nTotIte       := 0
	Local nItAtu        := 0
	Local nTotPed       := 0
	Local nPedAtu       := 0
	//Consultas SQL
	Local cQryPed       := ""
	Local cQryIte       := ""
	//Valores de Impostos

	//Variáveis do Relatório
	Local cCliCgc      := ""
	Local nLinCab       := 025
	Local nLinCabOrig := nLinCab
	Local cNomeRel      := "orcamento_"+"_"+dToS(Date())+"_"+StrTran(Time(), ":", "-")
	Local nPos          := 0
	Local cEmailCompleto := ""
	Local cEmail        := ""
	Local aMsg  := Array(7)
	Local nQueb := 36
	Local nQueb2 := 75
	Local cObsop := ""
	Local aObsop := {"", "", "", ""}
	Local cMsg  := ""
	Local aMsgop := {}
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
	Private nBasICM       := 0
	Private nValICM       := 0
	Private nValIPI       := 0
	Private nAlqICM       := 0
	Private nAlqIPI       := 0
	Private nValSol       := 0
	Private nBasSol       := 0
	Private nPrcUniSol    := 0
	Private nTotSol       := 0
	Private nAliqISS      := 0
	Private nLinCab       := 025
	Private nLinCabOrig := nLinCab

	Private aDuplicatas := {}
	oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
	oFontTit   := TFont():New(cNomeFont, 12, -20, , .T.)
	oFontCab   := TFont():New(cNomeFont, , -12, , .F.)
	oFontCabN  := TFont():New(cNomeFont, , -10, , .T.)
	oFontOrc   := TFont():New(cNomeFont, , -10, , .F.)
	oFontDet   := TFont():New(cNomeFont, , -12, , .F.)
	oFontDetN  := TFont():New(cNomeFont, , -12, , .T.)
	oFontCau   := TFont():New(cNomeFont, , -14, , .T.)
	oFontCas   := TFont():New(cNomeFont, , -12, , .T.)
	oFontDetC  := TFont():New(cNomeFont, , -08, , .F.)
	oFontDetNC := TFont():New(cNomeFont, , -08, , .T.)
	//Linhas e colunas
	Private nLinAtu     := 0
	Private nLTamLin    := 010
	Private nLinFin     := 780
	Private nColIni     := 000
	Private nColFin     := 563
	Private nColMeio    := (nColFin-nColIni)/2
	Private nEspLin     := 015
	Private nLinRod:= nLinFin + 10

	//Totalizadores
	Private nTotFrete   := 0
	Private nValorTot   := 0
	Private nTotalST    := 0
	Private nTotVal     := 0
	Private nValICM		:= 0
	Private nTotICM		:= 0
	Private cFretePed   := ""
	Private nTotIPI     := 0

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(DbGoTop())
	DbSelectArea("SCJ")

	//Criando o objeto de impressão
	oPrintPvt := FWMSPrinter():New(cNomeRel, IMP_PDF, .F., /*cStartPath*/, .T., , @oPrintPvt, , , , , .T.)
	oPrintPvt:cPathPDF := GetTempPath()
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetPortrait()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)

	//Selecionando os pedidos
	cQryPed := " SELECT "                                        + CRLF
	cQryPed += "    CJ_FILIAL, "                                 + CRLF
	cQryPed += "    CJ_NUM, "                                    + CRLF
	cQryPed += "    CJ_EMISSAO, "                                + CRLF
	cQryPed += "    CJ_CLIENTE, "                                + CRLF
	cQryPed += "    CJ_LOJA, "                                   + CRLF
	cQryPed += "    NVL(A1_NREDUZ, '') AS A1_NREDUZ, "           + CRLF
	cQryPed += "    NVL(A1_PESSOA, '') AS A1_PESSOA, "           + CRLF
	cQryPed += "    NVL(A1_NOME, '') AS A1_NOME, "               + CRLF
	cQryPed += "    NVL(A1_END, '') AS A1_END, "                 + CRLF
	cQryPed += "    NVL(A1_BAIRRO, '') AS A1_BAIRRO, "           + CRLF
	cQryPed += "    NVL(A1_MUN, '') AS A1_MUN, "                 + CRLF
	cQryPed += "    NVL(A1_EST, '') AS A1_EST, "                 + CRLF
	cQryPed += "    NVL(A1_CEP, '') AS A1_CEP, "                 + CRLF
	cQryPed += "    NVL(A1_CGC, '') AS A1_CGC, "                 + CRLF
	cQryPed += "    NVL(A1_PESSOA, '') AS A1_PESSOA, "           + CRLF
	cQryPed += "    NVL(A1_EMAIL, '') AS A1_EMAIL, "             + CRLF
	cQryPed += "    NVL(A1_DDD, '') AS A1_DDD, "                 + CRLF
	cQryPed += "    NVL(A1_TEL, '') AS A1_TEL, "                 + CRLF
	cQryPed += "    CJ_CONDPAG, "                                + CRLF
	cQryPed += "    NVL(A3_NOME, '') AS A3_NOME, "               + CRLF
	cQryPed += "    NVL(A3_TEL, '') AS A3_TEL, "                 + CRLF
	cQryPed += "    NVL(A3_DDDTEL, '') AS A3_DDD, "              + CRLF
	cQryPed += "    NVL(E4_DESCRI, '') AS E4_DESCRI, "           + CRLF
	cQryPed += "    CJ_XCODVEN, "                                + CRLF
	//	cQryPed += "    CJ_XDTENTR, "                                + CRLF
	cQryPed += "    CJ_XNOMREP, "                                + CRLF
	cQryPed += "    CJ_TPFRETE, "                                + CRLF
	cQryPed += "    NVL(A3_EMAIL, '') AS A3_EMAIL, "             + CRLF
	cQryPed += "    CJ_FRETE, "                                  + CRLF
	cQryPed += "    CJ_XOBS, "                                   + CRLF
	cQryPed += "    CJ_VALIDA, "                                 + CRLF
	cQryPed += "    CJ_XCONT1, "                                 + CRLF
	cQryPed += "    CJ_XCNOME1, "                                + CRLF
	cQryPed += "    CJ_XCMAILC, "                                + CRLF
	cQryPed += "    CJ_XCDDD1, "                                 + CRLF
	cQryPed += "    CJ_XCTEL1, "                                 + CRLF
	cQryPed += "    CJ_XCCELUL, "                                + CRLF
	cQryPed += "    SCJ.R_E_C_N_O_ AS C5REC "                    + CRLF
	cQryPed += " FROM "                                          + CRLF
	cQryPed += "    "+RetSQLName("SCJ")+" SCJ "                  + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA1")+" SA1 ON ( "   + CRLF
	cQryPed += "        A1_FILIAL   = '"+FWxFilial("SA1")+"' "   + CRLF
	cQryPed += "        AND A1_COD  = SCJ.CJ_CLIENTE "           + CRLF
	cQryPed += "        AND A1_LOJA = SCJ.CJ_LOJA "              + CRLF
	cQryPed += "        AND SA1.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SE4")+" SE4 ON ( "   + CRLF
	cQryPed += "        E4_FILIAL     = '"+FWxFilial("SE4")+"' " + CRLF
	cQryPed += "        AND E4_CODIGO = SCJ.CJ_CONDPAG "         + CRLF
	cQryPed += "        AND SE4.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += "    LEFT JOIN "+RetSQLName("SA3")+" SA3 ON ( "   + CRLF
	cQryPed += "        A3_FILIAL     = '"+FWxFilial("SA3")+"' " + CRLF
	cQryPed += "        AND A3_COD = SCJ.CJ_XCODVEN "            + CRLF
	cQryPed += "        AND SA3.D_E_L_E_T_ = ' ' "               + CRLF
	cQryPed += "    ) "                                          + CRLF
	cQryPed += " WHERE "                                         + CRLF
	cQryPed += "    CJ_FILIAL   = '"+FWxFilial("SCJ")+"' "       + CRLF
	cQryPed += "    AND CJ_NUM >= '"+cPedDe+"' "                 + CRLF
	cQryPed += "    AND CJ_NUM <= '"+cPedAt+"' "                 + CRLF
	cQryPed += "    AND SCJ.D_E_L_E_T_ = ' ' "                   + CRLF
	TCQuery cQryPed New Alias "QRY_PED"
	TCSetField("QRY_PED", "CJ_EMISSAO", "D")
	Count To nTotPed
	oProc:SetRegua1(nTotPed)

	//Somente se houver pedidos
	If nTotPed != 0

		//Enquanto houver pedidos
		QRY_PED->(DbGoTop())
		While ! QRY_PED->(EoF())
			If cZeraPag == "1"
				nPagAtu := 1
			EndIf
			nPedAtu++
			oProc:IncRegua1("Processando o orçamento "+cValToChar(nPedAtu)+" de "+cValToChar(nTotPed)+"...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")

			//Imprime o cabeçalho
			fImpCab()

			//Inicializa os calculos de impostos
			nItAtu   := 0
			nTotIte  := 0
			nTotalST := 0
			nTotIPI  := 0
			SCJ->(DbGoTo(QRY_PED->C5REC))
			MaFisIni(SCJ->CJ_CLIENTE,;                   // 01 - Codigo Cliente/Fornecedor
				SCJ->CJ_LOJA,;                        // 02 - Loja do Cliente/Fornecedor
				Iif(SCJ->CJ_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
				SCJ->CJ_TIPO,;                           // 04 - Tipo da NF
				SCJ->CJ_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
				MaFisRelImp("MT100", {"SF2", "SD2"}),;   // 06 - Relacao de Impostos que suportados no arquivo
				,;                                       // 07 - Tipo de complemento
				,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
				"SB1",;                                  // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
				"MATA461")                               // 10 - Nome da rotina que esta utilizando a funcao

			//Seleciona agora os itens do pedido
			cQryIte := " SELECT "                                                                                   + CRLF
			cQryIte += "    CK_PRODUTO, "                                                                           + CRLF
			cQryIte += "    NVL(CK_DESCRI, '') AS B1_DESC, "                                                        + CRLF
			cQryIte += "    NVL(B1_POSIPI, '') AS B1_POSIPI, "                                                      + CRLF
			cQryIte += "    NVL(CK_UM, '') AS B1_UM, "                                                              + CRLF
			cQryIte += "    CK_ITEM, "                                                                              + CRLF
			cQryIte += "    CK_UM, "                                                                                + CRLF
			cQryIte += "    NVL(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CK_XOBSCLI, 4000, 1)), '') AS CK_XOBS, "   + CRLF
			cQryIte += "    CK_ENTREG, "                                                                            + CRLF
			cQryIte += "    CK_TES, "                                                                               + CRLF
			cQryIte += "    CK_QTDVEN, "                                                                            + CRLF
			cQryIte += "    CK_PRCVEN, "                                                                            + CRLF
			cQryIte += "    CK_VALDESC, "                                                                           + CRLF
			cQryIte += "    CK_VALOR "                                                                              + CRLF
			cQryIte += " FROM "                                                                                     + CRLF
			cQryIte += "    "+RetSQLName("SCK")+" SCK "                                                             + CRLF
			cQryIte += "    LEFT JOIN "+RetSQLName("SB1")+" SB1 ON ( "                                              + CRLF
			cQryIte += "        B1_FILIAL = '"+FWxFilial("SB1")+"' "                                                + CRLF
			cQryIte += "        AND B1_COD = SCK.CK_PRODUTO "                                                       + CRLF
			cQryIte += "        AND SB1.D_E_L_E_T_ = ' ' "                                                          + CRLF
			cQryIte += "    ) "                                                                                     + CRLF
			cQryIte += " WHERE "                                                                                    + CRLF
			cQryIte += "    CK_FILIAL = '"+FWxFilial("SCK")+"' "                                                    + CRLF
			cQryIte += "    AND CK_NUM = '"+QRY_PED->CJ_NUM+"' "                                                    + CRLF
			cQryIte += "    AND SCK.D_E_L_E_T_ = ' ' "                                                              + CRLF
			cQryIte += " ORDER BY "                                                                                 + CRLF
			cQryIte += "    CK_ITEM "                                                                               + CRLF
			TCQuery cQryIte New Alias "QRY_ITE"
			TCSetField("QRY_ITE", "CK_ENTREG", "D")
			Count To nTotIte
			nValorTot := 0
			oProc:SetRegua2(nTotIte)

			//Enquanto houver itens
			QRY_ITE->(DbGoTop())
			While ! QRY_ITE->(EoF())
				nItAtu++
				oProc:IncRegua2("Calculando impostos - item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")

				//Pega os tratamentos de impostos
				SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->CK_PRODUTO))
				MaFisAdd(QRY_ITE->CK_PRODUTO,;    // 01 - Codigo do Produto                    ( Obrigatorio )
					QRY_ITE->CK_TES,;             // 02 - Codigo do TES                        ( Opcional )
					QRY_ITE->CK_QTDVEN,;          // 03 - Quantidade                           ( Obrigatorio )
					QRY_ITE->CK_PRCVEN,;          // 04 - Preco Unitario                       ( Obrigatorio )
					0,;         // 05 - Desconto
					0,;           // 06 - Numero da NF Original                ( Devolucao/Benef )
					0,;         // 07 - Serie da NF Original                 ( Devolucao/Benef )
					0,;                           // 08 - RecNo da NF Original no arq SD1/SD2
					0,;                           // 09 - Valor do Frete do Item               ( Opcional )
					0,;                           // 10 - Valor da Despesa do item             ( Opcional )
					0,;                           // 11 - Valor do Seguro do item              ( Opcional )
					0,;                           // 12 - Valor do Frete Autonomo              ( Opcional )
					QRY_ITE->CK_VALOR,;           // 13 - Valor da Mercadoria                  ( Obrigatorio )
					0,;                           // 14 - Valor da Embalagem                   ( Opcional )
					SB1->(RecNo()),;              // 15 - RecNo do SB1
					0)                            // 16 - RecNo do SF4

				nQtdPeso := QRY_ITE->CK_QTDVEN*SB1->B1_PESO
				MaFisLoad("IT_VALMERC", QRY_ITE->CK_VALOR, nItAtu)
				MaFisAlt("IT_PESO", nQtdPeso, nItAtu)

				QRY_ITE->(DbSkip())
			EndDo

			//    Altera dados da Nota
			//    MaFisAlt("NF_FRETE", SCK->CK_FRETE)
			//     MaFisAlt("NF_SEGURO", SCK->CK_SEGURO)
			//     MaFisAlt("NF_DESPESA", SCK->CK_DESPESA)
			//     MaFisAlt("NF_AUTONOMO", SCK->CK_FRETAUT)
			//     If SCK->CK_DESCONT > 0
			//     	MaFisAlt("NF_DESCONTO", Min(MaFisRet(, "NF_VALMERC")-0.01, SCK->CK_DESCONT+MaFisRet(, "NF_DESCONTO")) )
			//     EndIf

			//     If SCK->CK_PDESCAB > 0
			//     	MaFisAlt("NF_DESCONTO", A410Arred(MaFisRet(, "NF_VALMERC")*SCK->CK_PDESCAB/100, "CK_VALOR") + MaFisRet(, "NF_DESCONTO"))
			//     EndIf

			nLinAux := nLinAtu + 70

			// 	oPrintPvt:SayAlign(nLinAux, nColIni, "It.", oFontDetN, 020, nTamFundo, nCorPreto, nPadLeft, )
			// 	oPrintPvt:SayAlign(nLinAux, nColIni + 015, "Cód. Produto", oFontDetN, 150, nTamFundo, nCorPreto, nPadLeft, )
			// 	oPrintPvt:SayAlign(nLinAux, nColIni + 105, "Descrição", oFontDetN, 200, nTamFundo, nCorPreto, nPadLeft, )
			// 	oPrintPvt:SayAlign(nLinAux, nColIni + 372, "NCM", oFontDetN, 050, nTamFundo, nCorPreto, nPadLeft, )
			// 	oPrintPvt:SayAlign(nLinAux, nColIni + 422 , "Qtde.", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
			// 	oPrintPvt:SayAlign(nLinAux, nColIni + 461 , "Vl. Unitário",  oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
			// 	oPrintPvt:SayAlign(nLinAux, nColIni + 520 , "Vl. Total", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

			//Enquanto houver itens
			oProc:IncRegua2("...")
			oProc:SetRegua2(nTotIte)
			nItAtu := 0


			oProc:IncRegua2("Imprimindo item "+cValToChar(nItAtu)+" de "+cValToChar(nTotIte)+"...")

			//Pega os tratamentos de impostos
			SB1->(DbSeek(FWxFilial("SB1")+QRY_ITE->CK_PRODUTO))

			//Pega os valores
			nBasICM    := MaFisRet(nItAtu, "IT_BASEICM")
			nValICM    := MaFisRet(nItAtu, "IT_VALICM")
			nValIPI    := MaFisRet(nItAtu, "IT_VALIPI")
			nAlqICM    := MaFisRet(nItAtu, "IT_ALIQICM")
			nAlqIPI    := MaFisRet(nItAtu, "IT_ALIQIPI")
			nValSol    := (MaFisRet(nItAtu, "IT_VALSOL") / QRY_ITE->CK_QTDVEN)
			nBasSol    := MaFisRet(nItAtu, "IT_BASESOL")
			nPrcUniSol := QRY_ITE->CK_PRCVEN + nValSol
			nTotSol    := nPrcUniSol * QRY_ITE->CK_QTDVEN
			nTotalST   += MaFisRet(nItAtu, "IT_VALSOL")
			nAliqISS   := MaFisRet(nItAtu, "IT_ALIQISS")
			nTotIPI    += nValIPI

			//////////////COMECA OS PRINTS
			// IMPRESSAO DOS ITENS DO PEDIDO
			// Cabeçalho
			oPrintPvt:SayAlign(nLinAux - 12, nColIni, "It.", oFontDetN, 020, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux - 12, nColIni + 015, "Cód. Produto", oFontDetN, 150, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux - 12, nColIni + 105, "Descrição", oFontDetN, 200, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux - 12, nColIni + 345, "NCM", oFontDetN, 050, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux - 12, nColIni + 398 , "Qtde.", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux - 12, nColIni + 443 , "Vl. Unitário",  oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux - 12, nColIni + 517 , "Vl. Total", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )


			//nLinAux += 80

			If nLinAux + 40 >= nLinFin
				fImpRod()
				fImpCab()

			EndIf


			oPrintPvt:SayAlign(nLinAux, nColIni, QRY_ITE->CK_ITEM, oFontDet, 020, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux, nColIni + 015, QRY_ITE->CK_PRODUTO, oFontDet, 250, nTamFundo, nCorPreto, nPadLeft, )

			//Imprime a descrição do produto
			//Se atingir o fim da página, quebra


			cMsg  := Alltrim(QRY_ITE->B1_DESC)
			//Quebrando a mensagem
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

			//oPrintPvt:SayAlign(nLinAux, nColIni + 105, aMsg[1], oFontDet, 300, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux, nColIni + 336, AllTrim(QRY_ITE->B1_POSIPI), oFontDet, 050, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux, nColIni + 386 , AllTrim(Transform(QRY_ITE->CK_QTDVEN, cMaskQtd)) + " " + QRY_ITE->B1_UM, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux, nColIni + 440 , "R$ " + AllTrim(Transform(QRY_ITE->CK_PRCVEN, cMaskPrc)), oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
			oPrintPvt:SayAlign(nLinAux, nColIni + 505 , "R$ " + AllTrim(Transform(QRY_ITE->CK_VALOR, cMaskVlr)), oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )


			nLinAux += 10
			For nAtual := 1 To Len(aMsg)
				If !Empty(aMsg[nAtual])
					oPrintPvt:Say(nLinAux, nColIni + 105, aMsg[nAtual], oFontDet, , nCorPreto)
					nLinAux += 10
				EndIf
			Next

			nLinAux += 5

			aMsgop := u_zMemoToA(AllTrim(QRY_ITE->CK_XOBS), 44, , .T.)

			nUltPos := 0
			For nI := Len(aMsgop) To 1 Step -1
				If !Empty(aMsgop[nI])
					nUltPos := nI
					Exit
				EndIf
			Next
			// Loop de impressão com verificação da última linha
			// Loop de impressão com quebra segura
			For nAtual := 1 To Len(aMsgop)
				If !Empty(aMsgop[nAtual])

					// Se a linha seguinte ultrapassar a área útil da página, quebra antes de imprimir
					If nLinAux + 10 >= nLinRod
						fImpRod()
						fImpCab()
					EndIf

					oPrintPvt:Say(nLinAux, nColIni + 105, AllTrim(aMsgop[nAtual]), oFontDet, , nCorCinza)
					nLinAux += 10
				EndIf
			Next


			nLinAux+=20

			//Se por acaso atingiu o limite da página, finaliza, e começa uma nova página
			If nLinAux + 120 >= nLinRod
				fImpRod()
				fImpCab()
			EndIf

			nValorTot += QRY_ITE->CK_VALOR
			QRY_ITE->(DbSkip())
		EndDo

		nTotFrete := MaFisRet(, "NF_FRETE")
		nTotVal := MaFisRet(, "NF_TOTAL")
		nTotICM := MaFisRet(1,"NF_BASEICM")
		nValIcm := MaFisRet(1,"NF_VALICM" )
		//fMontDupl()
		QRY_ITE->(DbCloseArea())
		MaFisEnd()

		//Imprime o total do pedido
		fImpTot()

		//Se tiver mensagem da observação
		If !Empty(QRY_PED->CJ_XOBS)
			fMsgObs()
		EndIf

		fImpDad()

		// //Se deverá ser impresso as duplicatas
		// If cImpDupl == "1"
		//  fImpDupl()
		// EndIf

		//Imprime o rodapé
		fImpRod()

		QRY_PED->(DbSkip())

		fAnx1()

		//Gera o pdf para visualização
		oPrintPvt:Preview()
	EndIf

	If nTotPed == 0
		MsgStop("Não há orçamentos!", "Atenção")
	EndIf

	QRY_PED->(DbCloseArea())
Return

/*---------------------------------------------------------------------*
 | Func:  fImpCab                                                      |
 | Desc:  Função que imprime o cabeçalho                               |
*---------------------------------------------------------------------*/

Static Function fImpCab()
	Local cTexto      := ""
	// Local nLinCab     := 025
	// Local nLinCabOrig := nLinCab
	Local cCodBar     := ""
	Local nColMeiPed  := nColMeio+8+((nColMeio-nColIni)/2)
	Local lCNPJ       := (QRY_PED->A1_PESSOA != "F")
	Local cCliAux     := QRY_PED->CJ_CLIENTE+" "+QRY_PED->CJ_LOJA+" - "+QRY_PED->A1_NREDUZ
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
	Local cData1      := ""
	Private nLinCab       := 025
	Private nLinCabOrig := nLinCab

	///////////////COMECA OS PRINTS


	oPrintPvt:StartPage()
	// nLinAtu := 40
	// oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "Pedido de Venda", oFontTit, 250, 07, nCorAzul, nPadLeft, )
	oPrintPvt:SayBitmap(nLinAtu -16, nColIni, cLogoEmp, 100, 100)

	oPrintPvt:SayAlign(nLinAtu , nColIni + 127, "Emitente:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni + 163, cEmpresa, oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinAtu, nColFin -192, "Contato:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColFin -160, AllTrim(QRY_PED->A3_NOME) , oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinAtu += 10
	oPrintPvt:SayAlign(nLinAtu, nColIni + 127, "CNPJ:"      , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni + 151, cEmpCnpj, oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinAtu, nColFin -192, "Tel:"   , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColFin -177, Alltrim(QRY_PED->A3_DDD) + " " + AllTrim(QRY_PED->A3_TEL), oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	//   oPrintPvt:SayAlign(nLinAtu, nColIni + 200, "CEP:"      , oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	//   oPrintPvt:SayAlign(nLinAtu, nColIni + 260, cEmpCep, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinAtu += 10

	oPrintPvt:SayAlign(nLinAtu, nColIni+127, "Tel:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni + 143, cEmpTel, oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )


	oPrintPvt:SayAlign(nLinAtu, nColFin -192, "E-Mail:"   , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColFin -165, AllTrim(QRY_PED->A3_EMAIL), oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinAtu += 10


	oPrintPvt:SayAlign(nLinAtu, nColIni + 127, "Endereço:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni + 164, cEmpEnd + " - " + cEmpBairro, oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinAtu += 10

	// oPrintPvt:SayAlign(nLinAtu, nColIni + 147, "Vend. Interno:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAtu, nColIni + 68, AllTrim(QRY_PED->A3_NOME) + " - " +Alltrim(QRY_PED->A3_DDD) + " " + AllTrim(QRY_PED->A3_TEL) + " - " + AllTrim(QRY_PED->A3_EMAIL), oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinAtu, nColIni + 127, "CEP:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni + 146,   cEmpCep + " - " + cEmpCidade + " / SP " , oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinAtu += 10

	oPrintPvt:SayAlign(nLinAtu, nColIni + 127, "Email:"  , oFontDetNC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu, nColIni + 150,   "fw@fwdobrasil.com.br - www.fwdobrasil.com.br", oFontDetC, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )


	nLinAtu += 25
	oPrintPvt:SayAlign(nLinAtu,      nColIni, "PEDIDO DE VENDA", oFontTit, nColFin-nColIni, nTamFundo, nCorVerdeCl, nPadCenter, )
	oPrintPvt:SayAlign(nLinAtu + 20, nColIni - 25, "Número:",                      oFontCau, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )
	oPrintPvt:SayAlign(nLinAtu + 20, nColIni + 22, QRY_PED->CJ_NUM,           oFontCau, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )

	// oPrintPvt:SayAlign(nLinAtu + 35, nColIni - 25, "Pedido Cliente:",  oFontCas, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )
	// oPrintPvt:SayAlign(nLinAtu + 35, nColIni + 45, QRY_PED->C5_XPEDCLI, oFontCas, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )

	oPrintPvt:SayAlign(nLinAtu + 50, nColIni - 25, "Data de Emissão:",  oFontCas, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )
	oPrintPvt:SayAlign(nLinAtu + 50, nColIni + 42, Alltrim(AllToChar(QRY_PED->CJ_EMISSAO)), oFontCas, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )
	//	oPrintPvt:SayBitmap(nLinAtu - 30, nColIni, cLogoEmp, 100, 100)

	//Dados da Empresa
	nLinAtu += 50

	//If !Empty(QRY_ITE->C6_NUMORC)
	//	oPrintPvt:SayAlign(nLinCab + 50, nColIni -20, "Orçamento:",  oFontOrc, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )
	//	oPrintPvt:SayAlign(nLinCab + 50, nColIni + 20, QRY_ITE->C6_NUMORC, oFontOrc, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )
	//Endif

	//Alguns ajustes

	cEnd  := Alltrim(QRY_PED->A1_END) + " - " + AllTrim(QRY_PED->A1_BAIRRO) + ", " + Alltrim(QRY_PED->A1_MUN) + " / " + AllTrim(QRY_PED->A1_EST) + " CEP: " + Alltrim(QRY_PED->A1_CEP)
	cCont := Alltrim(QRY_PED->A1_DDD) + " " + Alltrim(QRY_PED->A1_TEL)

	Static cMaskCNPJ  := "@R 99.999.999/9999-99"                                               //Máscara de CNPJ
	Static cMaskCEP   := "@R 99999-999"                                                        //Máscara de CEP
	Static cMaskCPF   := "@R 999.999.999-99"                                                   //Máscara de CPF

	If QRY_PED->A1_PESSOA == "J"
		cCliCgc := Alltrim(Transform(QRY_PED->A1_CGC, cMaskCNPJ))
	Else
		cCliCgc := Alltrim(Transform(QRY_PED->A1_CGC, cMaskCPF))
	endif


	// Procura a posição do primeiro ponto e vírgula
	cEmailCompleto := AllTrim(QRY_PED->A1_EMAIL)
	nPos := At(";", cEmailCompleto)

	// Se encontrar, pega só até antes do ponto e vírgula; senão, retorna o valor completo
	cEmail := IIf(nPos > 0, SubStr(cEmailCompleto, 1, nPos - 1), cEmailCompleto)
	// DADOS DO CLIENTE

	//BOX e LInha
	nLinCab := nLinCabOrig + 190

	oPrintPvt:Line(nLinCab - 24, nColIni, nLinCab - 25, nColFin, nCorVerdeEsc, "-8")

	oPrintPvt:SayAlign(nLinCab - 22, nColIni, "Dados do Cliente",                      oFontCau, nColFin-nColIni, nTamFundo, nCorCinza, nPadCenter, )

	oPrintPvt:Box(nLinCab - 5, nColIni, nLinCab + 77, nColFin)

	nLinCab += nTamFundo - 5

	//Linha Separatório
	nLinCab += 6

	nLinAtu := nLinCab + 8
	oPrintPvt:SayAlign(nLinAtu - 22, nColIni + 5, "Cliente:"  , oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu - 22 , nColIni + 45, QRY_PED->A1_NOME, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinAtu - 07, nColIni + 5, "CNPJ/CPF:" , oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu - 07, nColIni + 57, cCliCgc, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinAtu + 7, nColIni + 5, "Endereço:" , oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu + 7, nColIni + 55, cEnd, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	IF !Empty(QRY_PED->CJ_XCTEL1) .AND. !Empty(QRY_PED->CJ_XCCELUL)
		cCont := Alltrim(QRY_PED->CJ_XCNOME1) + " - Tel: " + Alltrim(QRY_PED->CJ_XCDDD1) + " " + Alltrim(QRY_PED->CJ_XCTEL1) + " - Cel: " + Alltrim(QRY_PED->CJ_XCDDD1) + " " + Alltrim(QRY_PED->CJ_XCCELUL)
	ELSEIF Empty(QRY_PED->CJ_XCCELUL)
		cCont := Alltrim(QRY_PED->CJ_XCNOME1) + " - Tel: " + Alltrim(QRY_PED->CJ_XCDDD1) + " " + Alltrim(QRY_PED->CJ_XCTEL1)
	ELSEIF Empty(QRY_PED->CJ_XCTEL1)
		cCont := Alltrim(QRY_PED->CJ_XCNOME1) + " - Cel: " + Alltrim(QRY_PED->CJ_XCDDD1) + " " + Alltrim(QRY_PED->CJ_XCCELUL)
	endif

	cEmail := Alltrim(QRY_PED->CJ_XCMAILC)
	oPrintPvt:SayAlign(nLinAtu + 20, nColIni + 5, "Contato:", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu + 20, nColIni + 50, cCont, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinAtu + 34, nColIni + 5, "E-mail:", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinAtu + 34, nColIni + 38, cEmail, oFontDet, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinAux := nLinAtu + 70

	// oPrintPvt:SayAlign(nLinAux, nColIni, "It.", oFontDetN, 020, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux, nColIni + 015, "Cód. Produto", oFontDetN, 150, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux, nColIni + 105, "Descrição", oFontDetN, 200, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux, nColIni + 372, "NCM", oFontDetN, 050, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux, nColIni + 422 , "Qtde.", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux, nColIni + 461 , "Vl. Unitário",  oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux, nColIni + 520 , "Vl. Total", oFontDetN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )


	////////////////////////termina os prints

	//Atualizando a linha inicial do relatório
	nLinAux += 15
Return

/*---------------------------------------------------------------------*
 | Func:  fImpRod                                                      |
 | Desc:  Função que imprime o rodapé                                  |
*---------------------------------------------------------------------*/

Static Function fImpRod()

	Local cTexto := ""




	//Linha Separatória
	oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin)
	nLinRod += 3

	//Dados da Esquerda
	cTexto := "Orçamento: "+QRY_PED->CJ_NUM+"    |    "+dToC(dDataBase)+"     "+cHoraEx+"     "+cUserName
	oPrintPvt:SayAlign(nLinRod, nColIni,    cTexto, oFontRod, 250, 07, , nPadLeft, )

	//Direita
	cTexto := "Página "+cValToChar(nPagAtu)
	oPrintPvt:SayAlign(nLinRod, nColFin-40, cTexto, oFontRod, 040, 07, , nPadRight, )

	//Finalizando a página e somando mais um
	oPrintPvt:EndPage()
	nPagAtu++
Return

/*---------------------------------------------------------------------*
 | Func:  fMudaLayout                                                  |
 | Desc:  Função que muda as variáveis das colunas do layout           |
*---------------------------------------------------------------------*/

Static Function fMudaLayout()
	oFontRod   := TFont():New(cNomeFont, , -06, , .F.)
	oFontTit   := TFont():New(cNomeFont, 12, -16, , .T.)
	oFontCab   := TFont():New(cNomeFont, , -10, , .F.)
	oFontCabN  := TFont():New(cNomeFont, , -10, , .T.)
	oFontCau   := TFont():New(cNomeFont, , -14, , .F.)
	oFontOrc   := TFont():New(cNomeFont, , -8, , .F.)
	oFontDet   := TFont():New(cNomeFont, , -12, , .F.)
	oFontDetN  := TFont():New(cNomeFont, , -12, , .T.)

	nPosCod  := 0010 //Código do Produto
	nPosDesc := 0050 //Descrição
	nPosUnid := 0250 //Unidade de Medida
	nPosQuan := 0280 //Quantidade
	nPosVUni := 0310 //Valor Unitario
	nPosVTot := 0340 //Valor Total
	nPosBIcm := 0400 //Base Calculo ICMS
	nPosVIcm := 0430 //Valor ICMS
	nPosVIPI := 0460 //Valor Ipi
	nPosAIcm := 0490 //Aliquota ICMS
	nPosAIpi := 0520 //Aliquota IPI

	oFontDet   := TFont():New(cNomeFont, , -12, , .F.)
	oFontDetN  := TFont():New(cNomeFont, , -12, , .T.)
	oFontOrc   := TFont():New(cNomeFont, , -8, , .F.)

Return

/*---------------------------------------------------------------------*
 | Func:  fImpTot                                                      |
 | Desc:  Função para imprimir os totais                               |
*---------------------------------------------------------------------*/
Static Function fImpTot()
	nLinAux += 4
	Local nLinCab       := 025
	Local nLinCabOrig := nLinCab

	//Se atingir o fim da página, quebra
	If nLinAux + 50 >= nLinFin
		fImpRod()
		fImpCab()
		nLinAtu := nLinCab + 8

	EndIf

	//Cria o grupo de Total
	oPrintPvt:Box(nLinAux, nColIni, nLinAux + 070, nColFin)
	oPrintPvt:Line(nLinAux+nTamFundo, nColIni, nLinAux+nTamFundo, nColFin)
	nLinAux += nTamFundo - 5
	oPrintPvt:SayAlign(nLinAux-10, nColIni+5, "Totais:",                                         oFontDetN,  060, nTamFundo, nCorCinza, nPadLeft, )
	nLinAux += 5
	oPrintPvt:SayAlign(nLinAux, nColIni+0005, "Base ICMS: ",                                oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAux, nColIni+0110, "R$ " + Alltrim(Transform(nTotIcm, cMaskPad)),         oFontCabN, 080, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinAux, nColMeio+005, "Aliq. ICMS:",                                      oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAux+1, nColMeio+005,  Alltrim(Transform(nAlqICM, cMaskVlr)) + "%",  oFontCabN, 080, 07, , nPadRight, )
	nLinAux += 12
	oPrintPvt:SayAlign(nLinAux, nColIni+0005, "Valor ICMS: ",                    oFontCab,  150, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAux, nColIni+00110, "R$ " + Alltrim(Transform(nValICM, cMaskPad)),            oFontCabN, 080, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinAux, nColMeio+005, "Valor do IPI:",                                      oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAux +1, nColMeio+005,  "R$ " + Alltrim(Transform(nTotIPI, cMaskVlr)),  oFontCabN, 080, 07, , nPadRight, )
	//oPrintPvt:SayAlign(nLinAux, nColMeio+005, "Peso.Bru:",                                       oFontCab,  080, 07, , nPadLeft, )
	//oPrintPvt:SayAlign(nLinAux + 3, nColMeio+005, Alltrim(Transform(QRY_PED->C5_PBRUTO, cMaskPBru)), oFontCabN, 080, 07, , nPadRight, )
	nLinAux += 12
	oPrintPvt:SayAlign(nLinAux , nColIni+0005, "Valor Total dos Produtos: ",                      oFontCab,  150, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAux , nColIni+00110, "R$ " + Alltrim(Transform(nValorTot, cMaskVlr)),           oFontCabN, 080, 07, , nPadRight, )
	oPrintPvt:SayAlign(nLinAux , nColMeio+005, "Aliq. ISS:",                                      oFontCab,  080, 07, , nPadLeft, )
	oPrintPvt:SayAlign(nLinAux +1, nColMeio+005,  Alltrim(Transform(nAliqISS, cMaskVlr)) + "%",  oFontCabN, 080, 07, , nPadRight, )
	// oPrintPvt:SayAlign(nLinAux, nColIni+0005, "Base ICMS: ",                    oFontCab,  150, 07, , nPadLeft, )
	// oPrintPvt:SayAlign(nLinAux + 3, nColIni+00110, Alltrim(Transform(nBasICM, cMaskPad)),            oFontCabN, 080, 07, , nPadRight, )
	//oPrintPvt:SayAlign(nLinAux, nColMeio+005, "Valor do IPI:",                                   oFontCab,  080, 07, , nPadLeft, )
	///oPrintPvt:SayAlign(nLinAux + 3, nColMeio+005, Alltrim(Transform(nTotIPI, cMaskVlr)),             oFontCabN, 080, 07, , nPadRight, )
	nLinAux += 12
	oPrintPvt:SayAlign(nLinAux, nColIni+0005, "Valor Total do Orçamento:",                         oFontCab,  150, 07, nCorVerdeEsc, nPadLeft, )
	oPrintPvt:SayAlign(nLinAux, nColIni+0110, "R$ " + Alltrim(Transform(nTotVal, cMaskVlr)),             oFontCabN, 080, 07, , nPadRight, )
	nLinAux += 12

return

/*|Func:  fMsgObs                                                       |
  | Desc:  Função para imprimir mensagem de observação                  |
*---------------------------------------------------------------------*/

Static Function fMsgObs()
	Local aMsg  := {"", "", ""}
	Local nQueb := 090
	Local cMsg  := Alltrim(QRY_PED->CJ_XOBS)
	nLinAux += 4

	//Se atingir o fim da página, quebra
	If nLinAux + 40 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf

	//Quebrando a mensagem
	If Len(cMsg) > nQueb
		aMsg[1] := SubStr(cMsg,    1, nQueb)
		aMsg[1] := SubStr(aMsg[1], 1, RAt(' ', aMsg[1]))

		//Pegando o restante e adicionando nas outras linhas
		cMsg := Alltrim(SubStr(cMsg, Len(aMsg[1])+1, Len(cMsg)))
		If Len(cMsg) > nQueb
			aMsg[2] := SubStr(cMsg,    1, nQueb)
			aMsg[2] := SubStr(aMsg[2], 1, RAt(' ', aMsg[2]))

			cMsg := Alltrim(SubStr(cMsg, Len(aMsg[2])+1, Len(cMsg)))
			aMsg[3] := cMsg
		Else
			aMsg[2] := cMsg
		EndIf
	Else
		aMsg[1] := cMsg
	EndIf

	//Cria o grupo de Observação
	nLinAux += 15

	oPrintPvt:Box(nLinAux, nColIni, nLinAux + 050, nColFin)
	oPrintPvt:Line(nLinAux+nTamFundo, nColIni, nLinAux+nTamFundo, nColFin)
	nLinAux += nTamFundo - 5
	oPrintPvt:SayAlign(nLinAux-10, nColIni+5, "Observações gerais:",                oFontDetN,  100, nTamFundo, nCorCinza, nPadLeft, )
	nLinAux += 06
	oPrintPvt:SayAlign(nLinAux, nColIni+0005, aMsg[1],                      oFontDet,  1000, 07, , nPadLeft, )
	nLinAux += 10
	oPrintPvt:SayAlign(nLinAux, nColIni+0005, aMsg[2],                      oFontDet,  800, 07, , nPadLeft, )
	nLinAux += 10
	oPrintPvt:SayAlign(nLinAux, nColIni+0005, aMsg[3],                      oFontDet,  800, 07, , nPadLeft, )
	nLinAux += 20
Return



/*---------------------------------------------------------------------*
 | Func:  fImpDad                                                      |
 | Desc:  Função que imprime as duplicatas do pedido                   |
*---------------------------------------------------------------------*/


Static Function fImpDad()

	//Se atingir o fim da página, quebra
	If nLinAux + 40 >= nLinFin
		fImpRod()
		fImpCab()
	EndIf



	nLinAux += 17


	oPrintPvt:Line(nLinAux +nTamFundo, nColIni, nLinAux+nTamFundo, nColFin)

	oPrintPvt:SayAlign(nLinAux, nColIni+5, "Representante",                                         oFontDetN,  300, nTamFundo, nCorCinza, nPadLeft, )
	oPrintPvt:SayAlign(nLinAux, nColIni+140, "Frete",                                         oFontDetN,  300, nTamFundo, nCorCinza, nPadLeft, )
	oPrintPvt:SayAlign(nLinAux, nColIni+300, "Data de Entrega",                                         oFontDetN,  300, nTamFundo, nCorCinza, nPadLeft, )
	oPrintPvt:SayAlign(nLinAux, nColIni+400, "Condição de Pagamento",                                         oFontDetN,  300, nTamFundo, nCorCinza, nPadLeft, )

	nLinAux += nTamFundo + 8

	oPrintPvt:SayAlign(nLinAux, nColIni+5, QRY_PED->CJ_XNOMREP, oFontDet, 300, nTamFundo, nCorPreto, nPadLeft, )

	If QRY_PED->CJ_TPFRETE == "C"
		cFretePed := "CIF"
	ElseIf QRY_PED->CJ_TPFRETE == "F"
		cFretePed := "FOB"
	ElseIf QRY_PED->CJ_TPFRETE == "T"
		cFretePed := "Terceiros"
	Else
		cFretePed := "Sem Frete"
	EndIf

	// Supondo que a data esteja em QRY_PED->E4_DESCRI
	// cData := AllTrim(QRY_PED->CJ_XDTENTR)

	cData := "AllTrim(QRY_PED->CJ_XDTENTR)"


	If Len(cData) == 8
		cData := SubStr(cData, 7, 2) + "/" + SubStr(cData, 5, 2) + "/" + SubStr(cData, 1, 4)
	EndIf

	oPrintPvt:SayAlign(nLinAux, nColIni+140, cFretePed, oFontDet, 300, nTamFundo, nCorPreto, nPadLeft, )

	If !Empty(cData)
		oPrintPvt:SayAlign(nLinAux, nColIni+300, cData, oFontDet, 300, nTamFundo, nCorPreto, nPadLeft, )
	Else
		oPrintPvt:SayAlign(nLinAux, nColIni+300, "A Combinar", oFontDet, 300, nTamFundo, nCorPreto, nPadLeft, )
	endif

	oPrintPvt:SayAlign(nLinAux, nColIni+400, QRY_PED->E4_DESCRI, oFontDet, 300, nTamFundo, nCorPreto, nPadLeft, )

	nLinAux += 10

return

Static Function fAnx1()

	local oFontTitu  := Nil
	local oFontTex   := Nil
	local oFontTexN   := Nil
	local nLinNov    := 0
	local nColInic    := 25
	local nRal1013  := RGB(237, 231, 207) //RAL 1013
	Local nRal6011	 := RGB(091, 111, 066) //RAL 6011
	Local nRal7021 := 	RGB(031, 043, 043) //RAL 7021
	Local nRal9001	 := RGB(255, 248, 232) //RAL 9001
	local nPretoCa	 := RGB(006, 010, 009) //Preto Cal
	Local n10b	 := RGB(042, 072, 098) //10B
	Local nAmarelo := RGB(232, 191, 003) //Amarelo
	local oBrush1 := TBrush():New( , nRal1013)
	local oBrush2 := TBrush():New( , nRal6011)
	local oBrush3 := TBrush():New( , nRal7021)
	local oBrush4 := TBrush():New( , nRal9001)
	local oBrush5 := TBrush():New( , nPretoCa)
	local oBrush6 := TBrush():New( , n10b)
	local oBrush7 := TBrush():New( , nAmarelo)
	Local cEmpresa    := AllTrim(SM0->M0_FULNAME)


	oFontTitu   := TFont():New(cNomeFont, , -14, , .T.)
	oFontTexN    := TFont():New(cNomeFont, , -10, , .T.)
	oFontTex    := TFont():New(cNomeFont, , -10, , .F.)

	oPrintPvt:StartPage()

	nLinNov := 40
	oPrintPvt:SayAlign(nLinNov, nColIni, "Termo de fornecimento dos produtos " + cEmpresa, oFontTitu, nColFin-nColIni, nTamFundo, nCorVerdeCl, nPadCenter, )

	nLinNov += 40
	oPrintPvt:SayAlign(nLinNov, nColInic, "1. Confirmação de medidas: ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "1.1 Trabalhamos com peças e equipamentos sob medida, caso haja necessidade de confirmação de medidas in loco, será estipulado uma data e ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "horário previamente agendado em comum acordo entre FW e cliente. Está visita poderá ser cobrada com um valor adicional ao pedido, sendo o dia ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "do técnico e deslocamento para essa confirmação! Consultar disponibilidade e cobranças adicionais de acordo com cada região;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "1.2 Se por algum motivo não for possível a confirmação de medidas na data agendada, sem aviso prévio de no mínimo 24 horas a 2° visita também será ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "cobrada;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "1.3 O prazo de entrega constante no orçamento/negociação contará após a confirmação de medidas e/ou aprovação do projeto.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15

	oPrintPvt:SayAlign(nLinNov, nColInic, "2. Garantia: ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "A empresa garante seus produtos quanto a defeitos de fabricação e/ou falhas de funcionamento, por um período de: ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20

	oPrintPvt:SayAlign(nLinNov, nColInic, "Equipamento e proteção telescópica;", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 30

	oPrintPvt:Box(nLinNov , nColInic, nLinNov + 105, nColFin - 25)
	oPrintPvt:Line( nLinNov + 40 , nColInic, nLinNov + 40, nColFin - 25)
	oPrintPvt:Line( nLinNov + 18 , nColInic, nLinNov + 18, nColFin - 25)
	oPrintPvt:Line( nLinNov + 61 , nColInic, nLinNov + 61, nColFin - 25)
	oPrintPvt:Line( nLinNov + 83 , nColInic, nLinNov + 83, nColFin - 25)
	oPrintPvt:Line( nLinNov,  nColInic + 200, nLinNov + 105, nColInic + 200)
	oPrintPvt:Line( nLinNov,  nColInic + 330, nLinNov + 105, nColInic + 330)


	oPrintPvt:SayAlign(nLinNov + 5, nColInic + 5, "Jornada de Trabalho", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 5, nColInic + 210, "Novos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 5, nColInic + 340, "Reformados", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 25, nColInic + 5, "1 Turno", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 25, nColInic + 210, "12 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 25, nColInic + 340, "6 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 45, nColInic + 5, "2 Turnos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 45, nColInic + 210, "8 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 45, nColInic + 340, "4 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 67, nColInic + 5, "3 Turnos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 67, nColInic + 210, "6 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 67, nColInic + 340, "3 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 87, nColInic + 5, "4 Turnos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 87, nColInic + 210, "3 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 87, nColInic + 340, "2 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 120

	oPrintPvt:SayAlign(nLinNov, nColInic, "Proteção Sanfonada: ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 30

	oPrintPvt:Box(nLinNov , nColInic, nLinNov + 105, nColFin - 25)
	oPrintPvt:Line( nLinNov + 40 , nColInic, nLinNov + 40, nColFin - 25)
	oPrintPvt:Line( nLinNov + 18 , nColInic, nLinNov + 18, nColFin - 25)
	oPrintPvt:Line( nLinNov + 61 , nColInic, nLinNov + 61, nColFin - 25)
	oPrintPvt:Line( nLinNov + 83 , nColInic, nLinNov + 83, nColFin - 25)
	oPrintPvt:Line( nLinNov,  nColInic + 200, nLinNov + 105, nColInic + 200)
	oPrintPvt:Line( nLinNov,  nColInic + 330, nLinNov + 105, nColInic + 330)


	oPrintPvt:SayAlign(nLinNov + 5, nColInic + 5, "Jornada de Trabalho", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 5, nColInic + 210, "Novos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 5, nColInic + 340, "Reformados", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 25, nColInic + 5, "1 Turno", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 25, nColInic + 210, "6 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 25, nColInic + 340, "3 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 45, nColInic + 5, "2 Turnos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 45, nColInic + 210, "4 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 45, nColInic + 340, "2 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 67, nColInic + 5, "3 Turnos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 67, nColInic + 210, "2 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 67, nColInic + 340, "1 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:SayAlign(nLinNov + 87, nColInic + 5, "4 Turnos", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 87, nColInic + 210, "1 meses", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 87, nColInic + 340, "-", oFontTex, 100, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 120

	oPrintPvt:SayAlign(nLinNov, nColInic, "2.1. O período de garantia será contado a partir da emissão da Nota Fiscal de entrega, excluindo garantia caso o material fique em estoque no cliente ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10

	oPrintPvt:SayAlign(nLinNov, nColInic, "sem utilização e não seja contestado durante o período especificado no Item 2;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "2.2. Em caso de Transportador de Cavacos, não caberá garantia quando os cavacos transportados forem divergentes dos tipos/dimensões informados ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "no ato de fechamento do pedido de compras;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "2.3. É de responsabilidade do cliente a conferência do produto a partir do momento do recebimento;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "2.4. A garantia fornecida pela FW, não compreende a reparação de defeitos, danos ou avarias, quando originárias de:", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "I. Instalação e/ou utilização inadequada;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "II. Suprimento inadequado de energia elétrica, quer por deficiência das instalações do cliente, quer por fornecimento da concessionária;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "III. Quedas, batidas e/ou choques;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "IV. Danos decorrentes de transporte;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "V. Inobservância das normas de manutenção;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "VI. Armazenagem inadequada;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic + 5, "VII. Assistências técnicas, desmontagens ou alterações realizadas sem autorização da FW.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20
	oPrintPvt:SayAlign(nLinNov, nColInic, "2.5 No caso de defeito, a empresa pode optar por retrabalho ou substituição do produto; ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "2.6 Os produtos da empresa são itens de alta complexidade e em nenhum caso ou circunstância a mesma poderá ser responsabilizada pelo ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "contratante por perda de produtividade ou danos causados direta ou indiretamente, reclamações de terceiros, lesões, paralisações, perdas ou ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "despesas, incluindo lucros cessantes provenientes de paralisações ou fornecimento;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, '2.7 Nossa garantia considera o produto "posto em nossa fábrica", ficando por conta do cliente o frete ida e volta para devido reparo caracterizado ', oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "como garantia;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15

	oPrintPvt:SayAlign(nLinNov, nColInic, "2.8 Após avaliação do produto não sendo caracterizado garantia será enviado orçamento com valores dos serviços a serem realizados; ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20
	oPrintPvt:SayAlign(nLinNov, nColInic, "3. Transporte: ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColInic, "3.1 Após emissão da nota fiscal, o produto ficará disponível para coleta em até 48 horas. Em caso do não cumprimento do prazo estipulado, iremos ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColInic, "enviar o produto até a transportadora indicada com o custo adicional por km rodado, com limite de até 100 km da FW.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:EndPage()

	/////////////////////////////////SEGUNDA PAGINA DO ANEXO

	oPrintPvt:StartPage()

	nLinNov := 80

	oPrintPvt:SayAlign(nLinNov, nColIni + 20, "4. Pintura: ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )
	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 20, "4.1 Padrão FW:", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20

	nColInic += 20
	nColIni  += 20

	oPrintPvt:Box(nLinNov , nColInic, nLinNov + 40, nColIni + 120)
	oPrintPvt:FillRect({nLinNov, nColInic, nLinNov + 40, nColIni + 120}, oBrush1)

	oPrintPvt:Box(nLinNov , nColInic +120, nLinNov + 40, nColIni + 240)
	oPrintPvt:FillRect({nLinNov , nColInic + 120, nLinNov + 40, nColIni + 240}, oBrush2)

	oPrintPvt:Box(nLinNov , nColInic +240, nLinNov + 40, nColIni + 360)
	oPrintPvt:FillRect({nLinNov , nColInic + 240, nLinNov + 40, nColIni + 360}, oBrush3)

	oPrintPvt:Box(nLinNov , nColInic +360, nLinNov + 40, nColIni + 480)
	oPrintPvt:FillRect({nLinNov + 1, nColInic + 361, nLinNov + 39, nColIni + 479}, oBrush4)

	oPrintPvt:SayAlign(nLinNov + 15, nColInic + 25, "RAL 1013", oFontTexN, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 15, nColInic + 145, "RAL 6011", oFontTexN, 100, nTamFundo, nCorBranco, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 15, nColInic + 265, "RAL 7021", oFontTexN, 100, nTamFundo, nCorBranco, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 15, nColInic + 385, "RAL 9001", oFontTexN, 100, nTamFundo, nCorPreto, nPadLeft, )


	nLinNov += 60

	oPrintPvt:Box(nLinNov, nColInic, nLinNov + 40, nColIni + 120)
	oPrintPvt:FillRect({nLinNov, nColInic, nLinNov + 40, nColIni + 120}, oBrush5)
	oPrintPvt:Box(nLinNov, nColInic +120, nLinNov + 40, nColIni + 240)
	oPrintPvt:FillRect({nLinNov, nColInic + 120, nLinNov + 40, nColIni + 240}, oBrush6)
	oPrintPvt:Box(nLinNov, nColInic +240, nLinNov + 40, nColIni + 360)
	oPrintPvt:FillRect({nLinNov, nColInic + 240, nLinNov + 40, nColIni + 360}, oBrush7)

	oPrintPvt:SayAlign(nLinNov + 15	, nColInic + 13, "PRETO CADILLAC", oFontTexN, 100, nTamFundo, nCorBranco, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 15	, nColInic + 145, "10B 3/4", oFontTexN, 100, nTamFundo, nCorBranco, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 10	, nColInic + 260, "AMARELO", oFontTexN, 100, nTamFundo, nCorPreto, nPadLeft, )
	oPrintPvt:SayAlign(nLinNov + 20	, nColInic + 255, "SEGURANÇA", oFontTexN, 100, nTamFundo, nCorPreto, nPadLeft, )
	nLinNov += 60
	oPrintPvt:SayAlign(nLinNov, nColIni, "4.2. Para pintura fora do padrão será considerada como cor especial, estas serão orçadas e inclusa no valor apresentando em nossa ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "proposta comercial.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20
	oPrintPvt:SayAlign(nLinNov, nColIni, "5. Reforma: ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.1 As peças enviadas para reforma ficarão em nossa empresa pelo prazo máximo de 30 dias após o envio do orçamento, aguardando definição. ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "Após esse período, estaremos enviando uma notificação solicitando a coleta e caso a mesma não seja realizada estaremos sucateando o material;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.2 Orçamento sujeito a alteração após a chegada das peças em nossa fábrica;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.3 Em caso de reforma de proteções telescópicas ou sanfonas são necessárias as informações de altura e largura entre os barramentos da máquina ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "por parte do cliente, essas informações são necessárias pois com o tempo e desgaste a proteção pode perder essas referências e no momento do ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "reparo poderá sair com divergências que colidam com o barramento. Caso essas informações não sejam fornecidas a peça fica sujeita a não garantia ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "neste especifico motivo;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.4 No momento da avaliação da peça se for identificado que não é possível reformar, enviaremos valores de peça nova;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.5 No caso de ser identificado problema na hora de testar o motoredutor, será apresentado valor de um item novo;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.6 Não faz parte deste escopo revisão da parte elétrica.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "5.7 Após a implementação do sistema de gestão ambiental (SGA) que busca reduzir os impactos das nossas atividades sobre o meio ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "ambiente, pedimos a colaboração dos nossos clientes em enviar as peças/equipamentos para reforma sem resíduos de óleo, graxa, ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "cavacos e/ou outros materiais de descarte especial.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20
	oPrintPvt:SayAlign(nLinNov, nColIni, "6. Montagem (Opcional) ", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "6.1 Caso haja necessidade de montagem, considerar os custos homem/hora abaixo:", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 5, "•	Custo hora de montagem dias úteis por técnico: R$ 180,00;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 5, "•	Custo hora de deslocamento dias úteis por técnico: R$ 56,00;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 5, "•	Custo hora – sábados / domingos / feriados por técnico: R$ 360,00;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 5, "•	Custo hora de deslocamento – sábados / domingos / feriados por técnico: R$ 112,00;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 5, "•	Km rodado – R$ 3,00;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni + 5, "•	Despesas de refeição, estádia e translado por conta da contratante.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "6.2 Após cada montagem, será elaborado um relatório com todas as horas utilizadas para montagem, bem como todas as despesas, com custo único a ", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "ser faturado para a contratante, com prévia autorização.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 20
	oPrintPvt:SayAlign(nLinNov, nColIni, "7. Outras Considerações:", oFontTexN, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "7.1 Caso sejam constatadas outras necessidades não informadas por parte do cliente, estas serão orçadas e apresentadas para aprovação e inclusão no", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "orçamento/pedido", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "7.2 As propostas têm validade de 30 dias a partir da data de emissão, após ultrapassar este prazo a proposta será atualizada;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "7.3 Faturamento mínimo de R$1.000,00;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "7.4 Em caso de o cliente solicitar cancelamento após 48 horas do pedido de compras, cabe a FW julgar o aceite ou não da solicitação. Sendo que em", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, 'caso de aceite, poderá ser aplicada multa de até 100% sobre o valor total do pedido para ressarcimento de todos os danos da "inadimplência" em', oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 10
	oPrintPvt:SayAlign(nLinNov, nColIni, "decorrência a fabricação e/ou serviços já iniciados e/ou prontos;", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	nLinNov += 15
	oPrintPvt:SayAlign(nLinNov, nColIni, "7.5 Em caso de pedido de montagem o serviço será realizado pela nossa subcontratada: FW SERVICE TECHNOLOGY LTDA - CNPJ 45.426.945/0001-08.", oFontTex, nColFin-nColIni, nTamFundo, nCorPreto, nPadLeft, )

	oPrintPvt:EndPage()

return
