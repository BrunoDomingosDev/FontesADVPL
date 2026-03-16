#Include "Totvs.ch"
#Include "RwMake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA416PV
description
PE para levar dados do orc para PV
@author  Bruno
@since   25/04/2025
@version version
/*/
//-------------------------------------------------------------------

User Function MTA416PV()
    Local aArea := GetArea()
    
    Local NX :=0                                                         
    Local aAreaSCK := GetArea("SCK")


    //Faz a correlacao de campos entre o orcamento e o pedido de venda
       // M->C5_XTRANSP  := SCJ->CJ_XTRANSP
        M->C5_VEND1    := SCJ->CJ_XCODREP
        M->C5_VEND2    := SCJ->CJ_XCODVEN
        M->C5_XNVENDE  := SCJ->CJ_XNOMREP
        M->C5_XNOMCLI  := SCJ->CJ_XNOMCLI
        M->C5_XOBSGER  := SCJ->CJ_XOBS
        M->C5_XPEDCLI  := SCJ->CJ_XPEDCLI
        M->C5_FECENT   := SCJ->CJ_XENTREG

    //Traz o C5_XSTATUS do orcamento para o pedido de venda COMO "Aguardando Analise"
        M->C5_XSTATUS  := "5" //Aguardando Analise

        //percorre o aCols
         For nX :=1 TO len(_aCols)      
             nPosqdlib := aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_QTDLIB" } )                                      
             nPosXocli := aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_XOBSCLI" } )
             nPosOrc   := aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_NUMORC" } )
             nPosDtProg:= aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_XPINTUR" } ) 
             nPosNCM   := aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_XTENSAO" } )
             nPosXobs  := aScan( aHeadC6, { |x| Alltrim(x[2])=="C6_XOBSOP" } ) //CK_XOBSOP             

             SCK->(DbSelectArea("SCK"))

             SCK->(DbSetOrder(1))

             If SCK->(DbSeek(xfilial("SCK") + _aCols[NX][nPosOrc] )) .And. nPosDtProg > 0 .And. nPosNCM > 0
                 _aCols[NX][nPosDtProg] := SCK->CK_XPINTUR	
                 _aCols[NX][nPosNCM]    := SCK->CK_XTENSAO			
                 _aCols[NX][nPosXobs]   := SCK->CK_XOBS
                 _aCols[NX][nPosXocli]  := SCK->CK_XOBSCLI
             EndIF
             _aCols[NX][nPosqdlib] :=0
         Next

     RestArea(aAreaSCK)

     aColsC6:=_aCols

    RestArea(aArea)
Return
