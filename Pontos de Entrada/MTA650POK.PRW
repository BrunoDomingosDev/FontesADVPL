#Include 'Totvs.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} 
Validações na geração da OP por Pedido de venda
@author  Bruno Domingos
@version version
/*/
//-------------------------------------------------------------------

User Function MTA650POK()
Local cAlias := PARAMIXB[1]
Local cMarca := PARAMIXB[2]
Local aArea  := (cAlias)->(GetArea()) //Guarda a area corrente
Local lRet 
 
dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(1))
If (cAlias)->(dbSeek(xFilial(cAlias)))
    While !Eof() .And. SC6->C6_FILIAL == xFilial(cAlias)
        If SC6->C6_OK = cMarca
            MsgInfo('O Item '+SC6->C6_ITEM+' do pedido de Vendas ' +SC6->C6_NUM+ ' foi marcado para gerar Ordem de Produção!!!')

            DbSelectArea("SC5")
            DBSetOrder(1)
            DBSeek(SC6->C6_FILIAL + SC6->C6_NUM)

            If Empty(C5_LIBEROK).And.Empty(C5_NOTA).And.Empty(C5_BLQ).And.C5_XSTATUS=="06"
            lRet := .T.

            FwAlertInfo(SC5->C5_NUM + " " + SC6->C6_NUM )
            Else
            lRet := .F.
            FwAlertInfo("O Pedido " + SC5->C5_NUM + " não está pronto para gerar OP, por gentileza verifique os pedidos de venda com o status verde")
            Endif

        EndIf
        (cAlias)->(dbSkip())
    EndDo
EndIf
(cAlias)->(dbCloseArea())
 
RestArea(aArea) //Restaura a area guardada
Return(lRet)

Static Function lValid()
