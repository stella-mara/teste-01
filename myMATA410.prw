#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
 
/*/{Protheus.doc} User Function MyMata410
    Fonte utilizado para testes e treinamentos. 
    Este documento � de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avalia��o, preencha todos os blocos de coment�rios de 
    acordo com a descri��o inserida.

    @type  Function
    @author gabriel.antonio@totvs.com.br
    /*/

User Function MyMata410(cOper)
    
    Local cDoc       := ""                                                                 // N�mero do Pedido de Vendas
    Local cA1Cod     := "000001"                                                           // C�digo do Cliente
    Local cA1Loja    := "01"                                                               // Loja do Cliente
    Local cB1Cod     := "000000000000000000000000000061"                                   // C�digo do Produto
    Local cF4TES     := "501"                                                              // C�digo do TES
    Local cE4Codigo  := "001"                                                              // C�digo da Condi��o de Pagamento
    Local aAGGCC     := {"FAT000001", "FAT000002", "FAT000003", "FAT000004", "FAT000005"}  // C�digos dos Centros de Custo
    Local cMsgLog    := ""
    Local cLogErro   := ""
    Local cFilAGG    := ""
    Local cFilSA1    := ""
    Local cFilSB1    := ""
    Local cFilSE4    := ""
    Local cFilSF4    := ""
    Local nTmAGGItPd := TamSx3("AGG_ITEMPD")[1]
    Local nTmAGGItem := TamSx3("AGG_ITEM")[1]
    Local nOpcX      := 0
    Local nX         := 0
    Local nY         := 0
    Local nCount     := 0
    Local aCabec     := {}
    Local aItens     := {}
    Local aLinha     := {}
    Local aRatAGG    := {}
    Local aItemRat   := {}
    Local aAuxRat    := {}
    Local aErroAuto  := {}
    Local lOk        := .T.
    
    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.

    Default cOper := 1

    //****************************************************************
    /* 
    A fun��o "MyMATA410" recebe um par�metro "cOper" e tem como objetivo realizar diferentes opera��es relacionadas a um pedido de venda, dependendo do valoir passado para o par�metro.
    ---- S�o declaradas vari�veis locais que ser�o usadas ao longo da fun��o, cada uma delas com seu respectivo valor inicial. Algumas vari�veis tem valor literal como:
    "cA1Cod" -> c�digo do cliente
    "cA1Loja" -> loja do cliente
    "cB1Cod" -> c�digo do produto
    "cF4TES" -> c�digo do TES
    "cE4Codigo" -> c�digo da condi��o de pagamento
    "aAGGCC -> um array de c�digos de centros de custo
    ---- S�o criadas vari�veis "CMsgLog" e "LogErro" para armazenar mensagens de log e poss�veis erros que possam ocorrer durante a execu��o da fun��o. As vari�veis "cFilAGG", "cFilSA1", "cFilSB1", "cFilSE4", "cFilSF4" armazenam informa��es de filiais de diferentes tabelas.
    ---- S�o declaradas vari�veis num�ricas que ser�o usadas para controle e tamanho de strings e arrays como "nTmAGGItPd" (tamanho do campo AGG_ITEMPD), "nTmAGGItem" (tamanho do campo AGG_ITEM), "nOpcX" (op��o para escolher a opera��o realizada), "nX", "nY" e "nCount" (vari�veis de controle para la�os).
    ---- S�o declaradas v�rias vari�veis do tipo array (aCabec, aItens, aLinha, aRatAGG, aItemRat, aAuxRat, aErroAuto) que ser�o utilizadas para armazenar informa��es relacionadas ao pedido de vendas e centros de custo.
    ---- S�o delcaradas duas vari�veis private (lMsErroAuto e lAutoErrNoFile) que ser�o utilizadas para controlar erros e tratamentos espec�ficos.
    ---- Caso o par�metro cOper n�o seja passado na chamada da fun��o, a vari�vel cOper ser� atribu�da o valor 1 por padr�o.
    */
    //****************************************************************
    
    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
    //****************************************************************
    /* 
    A fun��o "PREPARE ENVIRONMENT" � utilizada para preparar o ambiente e configurar algumas informa��es importantes antes de iniciar a utiliza��o  do m�dulo do sistema.
    ---- EMPRESA: Especifica o c�digo da empresa a ser utilizada no ambiente.
    ---- FILIAL: Especifica o c�digo da filial a ser utilizada no ambiente.
    ---- MODULO: Especifica o m�dulo Protheus que ser� utilizado, no caso indica o m�dulo de Faturamento.
    ---- TABLES: Especifica as tabelas que ser� uitlizadas no ambiente.
    Essa fun��o � essencial para garantir que o ambiente esteja configurado corretamente e pronto para ser utilizado pelo m�dulo Faturamento. Sem a chamada dessa fun��o, algumas opera��es podem n�o funcionar corretamente devido � falta de configura��es necess�rias ou � aus�ncia das tabelas requeridas. 
    */
    //****************************************************************
    
    SA1->(dbSetOrder(1))
    SB1->(dbSetOrder(1))
    SE4->(dbSetOrder(1))
    SF4->(dbSetOrder(1))
    
    cFilAGG := xFilial("AGG")
    cFilSA1 := xFilial("SA1")
    cFilSB1 := xFilial("SB1")
    cFilSE4 := xFilial("SE4")
    cFilSF4 := xFilial("SF4")
    
    //****************************************************************
    /* 
    Esse bloco de c�digo configura a ordem de acesso �s tabelas "SA1", "SB1", "SE4" e "SF4" e armazena os c�digos de filial relacionados a cada tabela em vari�veis correspondentes.
    ---- A fun��oi "dbSetOrder(1) indica que os registros ser�o acessados pela primeira chave da tabela. Isso significa que a primeira chave definida na estrutura da tabela determinar� a sequ�ncia em que os resgistros ser�o acessados.
    */
    //****************************************************************

    If SB1->(! MsSeek(cFilSB1 + cB1Cod))
        cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
        lOk     := .F.
    EndIf
    
    If SF4->(! MsSeek(cFilSF4 + cF4TES))
        cMsgLog += "Cadastrar o TES: " + cF4TES + CRLF
        lOk     := .F.
    EndIf
    
    If SE4->(! MsSeek(cFilSE4 + cE4Codigo))
        cMsgLog += "Cadastrar a Condi��o de Pagamento: " + cE4Codigo + CRLF
        lOk     := .F.
    EndIf
    
    If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
        cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja + CRLF
        lOk     := .F.
    EndIf
    
    //****************************************************************
    /* 
    Ese bloco de c�digo verifica se determinados registros existem nas tabelas do sistema e, caso n�o existam, atualiza uma vari�vel de controle para indicar que algo est� faltando e adiciona uma mensagem informativa em uma vari�vel de log.
    ---- A fun��o "MsSeek" � usada para fazer a busca na tabela. Ent�o, caso n�o exista o registro identificado no par�metro da fun��o, uma mensagem � adicionada na vari�vel "cMsgLog" informando o que deve ser cadastrado. Al�m disso, a vari�vel de controle "lOk" � atualizado para falso, indicando que algo est� faltando.
    ---- Ap�s essa sequ�ncia de verifica��es, a vari�vel "1Ok" ser� verdadeira se todos os registros forem encontrados nas suas respectivas tabelas.
    ---- Essa estrutura � comum em rotinas de valida��o ou prepara��o de dados antes de executar opera��es mais compleas. � uma maneira de garantir que os dados necess�rios estejam dispon�veis e prontos para serem utilizados nas pr�ximas opera��es.
    */
    //****************************************************************

    If lOk
    
        cDoc := GetSxeNum("SC5", "C5_NUM")
        //****************************************************************
        /*
        Essa fun��o � usada para obter o pr�ximo n�mero dispon�vel na sequ�ncia da tabela "SC5" e campo "C5_NUM". Esse n�mero pode ser utilizado para criar um novo registro no m�dulo de Pedidos de Vendas, garantindo que o n�mero de pedido seja �nico e sequencial.
        ---- A funcionalidade de "GetSxeNum" � acessar o Protheus SXE (Sistema de Expans�o) para obter o pr�ximo n�mero dispon�vel na sequ�ncia da tabela e campo especificados no par�metro. Nessa caso o nome da tabela � "SC5" e o nome do campo "C5_NUM". 
        ---- Ap�s a execu��o dessa linha, "cDoc" conter� o novo n�mero dispon�vel para ser utilizado no pr�ximo pedido criado.
        */
        //****************************************************************
        
        If cOper == 1 

            aCabec   := {}
            aItens   := {}
            aLinha   := {}
            aRatAGG  := {}
            aItemRat := {}
            aAuxRat  := {}
            aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
            aadd(aCabec, {"C5_TIPO",    "N",       Nil})
            aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
            aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
            aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
            aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
            
            If cPaisLoc == "PTG"
                aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
            Endif
            
            For nX := 1 To 02 
                aLinha := {}
                aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
                aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
                aadd(aLinha,{"C6_QTDVEN",  1,             Nil})
                aadd(aLinha,{"C6_PRCVEN",  1000,          Nil})
                aadd(aLinha,{"C6_PRUNIT",  1000,          Nil})
                aadd(aLinha,{"C6_VALOR",   1000,          Nil})
                aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
                aadd(aLinha,{"C6_RATEIO",  "1",           Nil})
                aadd(aItens, aLinha) 

                aAuxRat     := {}
                For nY := 1 to 04
                    aRatAGG := {}
                    aAdd(aRatAGG, {"AGG_FILIAL",  cFilAGG,                Nil})
                    aAdd(aRatAGG, {"AGG_PEDIDO",  cDoc,                   Nil})
                    aAdd(aRatAGG, {"AGG_FORNECE", cA1Cod,                 Nil})
                    aAdd(aRatAGG, {"AGG_LOJA",    cA1Loja,                Nil})
                    aAdd(aRatAGG, {"AGG_ITEMPD",  StrZero(nX,nTmAGGItPd), Nil})
                    aAdd(aRatAGG, {"AGG_ITEM",    Strzero(nY,nTmAGGItem), Nil})
                    aAdd(aRatAGG, {"AGG_PERC",    25,                     Nil})
                    aAdd(aRatAGG, {"AGG_CC",      aAGGCC[nY],             Nil})
                    aAdd(aRatAGG, {"AGG_CONTA",   "",                     Nil})
                    aAdd(aRatAGG, {"AGG_ITEMCT",  "",                     Nil})
                    aAdd(aRatAGG, {"AGG_CLVL",    "",                     Nil})
                    aAdd(aAuxRat, aRatAGG)
                Next nY
                aAdd(aItemRat, {StrZero(nX,2), aAuxRat})
            
            Next nX

            //****************************************************************
            /*
            Esse bloco de c�digo prepara as estruturas de dados necess�rias para criar um novo Pedido de Vendas e realizar o rateio dos itens, se necess�rio. � uma parte importante da fun��o "MyMATA410", pois define os detalhes do pedido e prepara as informa��es necess�rias para que a fun��o "MATA410" possa executar a opera��o de inclus�o do pedido no sistema.
            ---- If cOper == 1: Este � um bloco condicional que verifica se o valor da vari�vel cOper � igual a 1. Se cOper for igual a 1, significa que o c�digo est� criando um novo Pedido de Vendas.
            ---- aCabec := {}: Cria um array vazio chamado aCabec, que ser� utilizado para armazenar informa��es do cabe�alho do Pedido de Vendas.
            ---- aItens := {}: Cria um array vazio chamado aItens, que ser� utilizado para armazenar informa��es dos itens do Pedido de Vendas.
            ---- aLinha := {}: Cria um array vazio chamado aLinha, que ser� utilizado temporariamente para armazenar informa��es de cada item do Pedido de Vendas antes de ser adicionado ao array aItens.
            ---- aRatAGG := {}: Cria um array vazio chamado aRatAGG, que ser� utilizado para armazenar informa��es relacionadas ao rateio dos itens do Pedido de Vendas.
            ---- aItemRat := {}: Cria um array vazio chamado aItemRat, que ser� utilizado para armazenar informa��es de rateio de cada item do Pedido de Vendas.
            ---- aAuxRat := {}: Cria um array vazio chamado aAuxRat, que ser� utilizado temporariamente para armazenar informa��es de rateio antes de ser adicionado ao array aItemRat.
            ---- aadd(aCabec, {...}): Adiciona informa��es do cabe�alho do Pedido de Vendas ao array aCabec. As informa��es s�o adicionadas como subarrays contendo pares chave-valor, onde a chave � o nome do campo na tabela do sistema e o valor � o valor a ser atribu�do a esse campo.
            ---- If cPaisLoc == "PTG" ... Endif: Este bloco condicional verifica se o valor da vari�vel cPaisLoc � igual a "PTG". Caso verdadeiro, adiciona uma informa��o adicional no cabe�alho do Pedido de Vendas.
            ---- For nX := 1 To 02 ... Next nX: Este � um loop For que itera duas vezes, criando um bloco de c�digo repetitivo para cada item do Pedido de Vendas. Ele preenche o array aItens com informa��es dos itens do pedido e o array aItemRat com informa��es de rateio para cada item.
            */
            //****************************************************************
            
            nOpcX := 3
            MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItens, nOpcX, .F., aItemRat)
            If !lMsErroAuto
                ConOut("Incluido com sucesso! " + cDoc)
            Else
                ConOut("Erro na inclusao!")
                aErroAuto := GetAutoGRLog()
                For nCount := 1 To Len(aErroAuto)
                    cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
                    ConOut(cLogErro)
                Next nCount
            EndIf
            //****************************************************************
            /* 
            Esse bloco de c�digo automatiza a inclus�o de um novo Pedido de Vendas usando a fun��o "MATA410". Se a inclus�o for bem-sucedida, uma mensagem de sucesso � exibida com o n�mero do documento do Pedido de Vendas. Caso ocorra algum erro durante a inclus�o, uma mensagem de erro � exibida e os detalhes de erro s�o recuperados da fun��o "GetAutoGRLog()" e formatados antes de serem exibidos na tela.
            */
            //****************************************************************



        ElseIf cOper == 2 

            aCabec         := {}
            aItens         := {}
            aLinha         := {}
            aRatAGG        := {}
            aItemRat       := {}
            aAuxRat        := {}
            lMsErroAuto    := .F.
            lAutoErrNoFile := .F.
            
            aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
            aadd(aCabec, {"C5_TIPO",    "N",       Nil})
            aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
            aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
            aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
            aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
            
            If cPaisLoc == "PTG"
                aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
            Endif
            
            For nX := 1 To 02
                 
                aLinha := {}
                aadd(aLinha,{"LINPOS",     "C6_ITEM",     StrZero(nX,2)})
                aadd(aLinha,{"AUTDELETA",  "N",           Nil})
                aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
                aadd(aLinha,{"C6_QTDVEN",  2,             Nil})
                aadd(aLinha,{"C6_PRCVEN",  2000,          Nil})
                aadd(aLinha,{"C6_PRUNIT",  2000,          Nil})
                aadd(aLinha,{"C6_VALOR",   4000,          Nil})
                aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
                aadd(aLinha,{"C6_RATEIO",  "1",           Nil})
                aadd(aItens, aLinha)
             
                aAuxRat     := {}
                For nY := 1 to 05
                    aRatAGG := {}
                    aAdd(aRatAGG, {"AGG_FILIAL",  cFilAGG,                Nil})
                    aAdd(aRatAGG, {"AGG_PEDIDO",  cDoc,                   Nil})
                    aAdd(aRatAGG, {"AGG_FORNECE", cA1Cod,                 Nil})
                    aAdd(aRatAGG, {"AGG_LOJA",    cA1Loja,                Nil})
                    aAdd(aRatAGG, {"AGG_ITEMPD",  StrZero(nX,nTmAGGItPd), Nil})
                    aAdd(aRatAGG, {"AGG_ITEM",    Strzero(nY,nTmAGGItem), Nil})
                    aAdd(aRatAGG, {"AGG_PERC",    20,                     Nil})
                    aAdd(aRatAGG, {"AGG_CC",      aAGGCC[nY],             Nil})
                    aAdd(aRatAGG, {"AGG_CONTA",   "",                     Nil})
                    aAdd(aRatAGG, {"AGG_ITEMCT",  "",                     Nil})
                    aAdd(aRatAGG, {"AGG_CLVL",    "",                     Nil})
                    aAdd(aAuxRat, aRatAGG)
                Next nY
                aAdd(aItemRat, {StrZero(nX,2), aAuxRat})
            Next nX

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            

            */
            //****************************************************************
            
            nOpcX := 4
            MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItens, nOpcX, .F., aItemRat)
            If !lMsErroAuto
                ConOut("Alterado com sucesso! " + cDoc)
            Else
                ConOut("Erro na altera��o!")
                aErroAuto := GetAutoGRLog()
                For nCount := 1 To Len(aErroAuto)
                    cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
                    ConOut(cLogErro)
                Next nCount
            EndIf

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            

            */
            //****************************************************************


        ElseIf cOper == 3 

            
            ConOut(PadC("Teste de exclus�o",80))
            
            aCabec         := {}
            aItens         := {}
            aLinha         := {}
            aRatAGG        := {}
            aItemRat       := {}
            aAuxRat        := {}
            lMsErroAuto    := .F.
            lAutoErrNoFile := .F.
            
            aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
            aadd(aCabec, {"C5_TIPO",    "N",       Nil})
            aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
            aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
            aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
            aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
            
            If cPaisLoc == "PTG"
                aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
            Endif
            
            For nX := 1 To 02
                //--- Informando os dados do item do Pedido de Venda
                aLinha := {}
                aadd(aLinha,{"C6_ITEM",    StrZero(nX,2), Nil})
                aadd(aLinha,{"C6_PRODUTO", cB1Cod,        Nil})
                aadd(aLinha,{"C6_QTDVEN",  2,             Nil})
                aadd(aLinha,{"C6_PRCVEN",  2000,          Nil})
                aadd(aLinha,{"C6_PRUNIT",  2000,          Nil})
                aadd(aLinha,{"C6_VALOR",   4000,          Nil})
                aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
                aadd(aLinha,{"C6_RATEIO",  "1",           Nil})
                aadd(aItens, aLinha)
            Next nX

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            

            */
            //****************************************************************
            
            MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
            If !lMsErroAuto
                ConOut("Exclu�do com sucesso! " + cDoc)
            Else
                ConOut("Erro na exclus�o!")
            EndIf

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de c�digo lido at� aqui:
            

            */
            //****************************************************************
            
        EndIf
    Else
            
        ConOut(cMsgLog)
    
    EndIf
    
    ConOut("Fim: " + Time())
    
    RESET ENVIRONMENT
Return(.T.)
