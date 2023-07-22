#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
 
/*/{Protheus.doc} User Function MyMata410
    Fonte utilizado para testes e treinamentos. 
    Este documento é de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avaliação, preencha todos os blocos de comentários de 
    acordo com a descrição inserida.

    @type  Function
    @author gabriel.antonio@totvs.com.br
    /*/

User Function MyMata410(cOper)
    
    Local cDoc       := ""                                                                 // Número do Pedido de Vendas
    Local cA1Cod     := "000001"                                                           // Código do Cliente
    Local cA1Loja    := "01"                                                               // Loja do Cliente
    Local cB1Cod     := "000000000000000000000000000061"                                   // Código do Produto
    Local cF4TES     := "501"                                                              // Código do TES
    Local cE4Codigo  := "001"                                                              // Código da Condição de Pagamento
    Local aAGGCC     := {"FAT000001", "FAT000002", "FAT000003", "FAT000004", "FAT000005"}  // Códigos dos Centros de Custo
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
    A função "MyMATA410" recebe um parâmetro "cOper" e tem como objetivo realizar diferentes operações relacionadas a um pedido de venda, dependendo do valoir passado para o parâmetro.
    ---- São declaradas variáveis locais que serão usadas ao longo da função, cada uma delas com seu respectivo valor inicial. Algumas variáveis tem valor literal como:
    "cA1Cod" -> código do cliente
    "cA1Loja" -> loja do cliente
    "cB1Cod" -> código do produto
    "cF4TES" -> código do TES
    "cE4Codigo" -> código da condição de pagamento
    "aAGGCC -> um array de códigos de centros de custo
    ---- São criadas variáveis "CMsgLog" e "LogErro" para armazenar mensagens de log e possíveis erros que possam ocorrer durante a execução da função. As variáveis "cFilAGG", "cFilSA1", "cFilSB1", "cFilSE4", "cFilSF4" armazenam informações de filiais de diferentes tabelas.
    ---- São declaradas variáveis numéricas que serão usadas para controle e tamanho de strings e arrays como "nTmAGGItPd" (tamanho do campo AGG_ITEMPD), "nTmAGGItem" (tamanho do campo AGG_ITEM), "nOpcX" (opção para escolher a operação realizada), "nX", "nY" e "nCount" (variáveis de controle para laços).
    ---- São declaradas várias variáveis do tipo array (aCabec, aItens, aLinha, aRatAGG, aItemRat, aAuxRat, aErroAuto) que serão utilizadas para armazenar informações relacionadas ao pedido de vendas e centros de custo.
    ---- São delcaradas duas variáveis private (lMsErroAuto e lAutoErrNoFile) que serão utilizadas para controlar erros e tratamentos específicos.
    ---- Caso o parâmetro cOper não seja passado na chamada da função, a variável cOper será atribuída o valor 1 por padrão.
    */
    //****************************************************************
    
    PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"
    //****************************************************************
    /* 
    A função "PREPARE ENVIRONMENT" é utilizada para preparar o ambiente e configurar algumas informações importantes antes de iniciar a utilização  do módulo do sistema.
    ---- EMPRESA: Especifica o código da empresa a ser utilizada no ambiente.
    ---- FILIAL: Especifica o código da filial a ser utilizada no ambiente.
    ---- MODULO: Especifica o módulo Protheus que será utilizado, no caso indica o módulo de Faturamento.
    ---- TABLES: Especifica as tabelas que será uitlizadas no ambiente.
    Essa função é essencial para garantir que o ambiente esteja configurado corretamente e pronto para ser utilizado pelo módulo Faturamento. Sem a chamada dessa função, algumas operações podem não funcionar corretamente devido à falta de configurações necessárias ou à ausência das tabelas requeridas. 
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
    Esse bloco de código configura a ordem de acesso às tabelas "SA1", "SB1", "SE4" e "SF4" e armazena os códigos de filial relacionados a cada tabela em variáveis correspondentes.
    ---- A funçãoi "dbSetOrder(1) indica que os registros serão acessados pela primeira chave da tabela. Isso significa que a primeira chave definida na estrutura da tabela determinará a sequência em que os resgistros serão acessados.
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
        cMsgLog += "Cadastrar a Condição de Pagamento: " + cE4Codigo + CRLF
        lOk     := .F.
    EndIf
    
    If SA1->(! MsSeek(cFilSA1 + cA1Cod + cA1Loja))
        cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja + CRLF
        lOk     := .F.
    EndIf
    
    //****************************************************************
    /* 
    Ese bloco de código verifica se determinados registros existem nas tabelas do sistema e, caso não existam, atualiza uma variável de controle para indicar que algo está faltando e adiciona uma mensagem informativa em uma variável de log.
    ---- A função "MsSeek" é usada para fazer a busca na tabela. Então, caso não exista o registro identificado no parâmetro da função, uma mensagem é adicionada na variável "cMsgLog" informando o que deve ser cadastrado. Além disso, a variável de controle "lOk" é atualizado para falso, indicando que algo está faltando.
    ---- Após essa sequência de verificações, a variável "1Ok" será verdadeira se todos os registros forem encontrados nas suas respectivas tabelas.
    ---- Essa estrutura é comum em rotinas de validação ou preparação de dados antes de executar operações mais compleas. É uma maneira de garantir que os dados necessários estejam disponíveis e prontos para serem utilizados nas próximas operações.
    */
    //****************************************************************

    If lOk
    
        cDoc := GetSxeNum("SC5", "C5_NUM")
        //****************************************************************
        /*
        Essa função é usada para obter o próximo número disponível na sequência da tabela "SC5" e campo "C5_NUM". Esse número pode ser utilizado para criar um novo registro no módulo de Pedidos de Vendas, garantindo que o número de pedido seja único e sequencial.
        ---- A funcionalidade de "GetSxeNum" é acessar o Protheus SXE (Sistema de Expansão) para obter o próximo número disponível na sequência da tabela e campo especificados no parâmetro. Nessa caso o nome da tabela é "SC5" e o nome do campo "C5_NUM". 
        ---- Após a execução dessa linha, "cDoc" conterá o novo número disponível para ser utilizado no próximo pedido criado.
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
            Esse bloco de código prepara as estruturas de dados necessárias para criar um novo Pedido de Vendas e realizar o rateio dos itens, se necessário. É uma parte importante da função "MyMATA410", pois define os detalhes do pedido e prepara as informações necessárias para que a função "MATA410" possa executar a operação de inclusão do pedido no sistema.
            ---- If cOper == 1: Este é um bloco condicional que verifica se o valor da variável cOper é igual a 1. Se cOper for igual a 1, significa que o código está criando um novo Pedido de Vendas.
            ---- aCabec := {}: Cria um array vazio chamado aCabec, que será utilizado para armazenar informações do cabeçalho do Pedido de Vendas.
            ---- aItens := {}: Cria um array vazio chamado aItens, que será utilizado para armazenar informações dos itens do Pedido de Vendas.
            ---- aLinha := {}: Cria um array vazio chamado aLinha, que será utilizado temporariamente para armazenar informações de cada item do Pedido de Vendas antes de ser adicionado ao array aItens.
            ---- aRatAGG := {}: Cria um array vazio chamado aRatAGG, que será utilizado para armazenar informações relacionadas ao rateio dos itens do Pedido de Vendas.
            ---- aItemRat := {}: Cria um array vazio chamado aItemRat, que será utilizado para armazenar informações de rateio de cada item do Pedido de Vendas.
            ---- aAuxRat := {}: Cria um array vazio chamado aAuxRat, que será utilizado temporariamente para armazenar informações de rateio antes de ser adicionado ao array aItemRat.
            ---- aadd(aCabec, {...}): Adiciona informações do cabeçalho do Pedido de Vendas ao array aCabec. As informações são adicionadas como subarrays contendo pares chave-valor, onde a chave é o nome do campo na tabela do sistema e o valor é o valor a ser atribuído a esse campo.
            ---- If cPaisLoc == "PTG" ... Endif: Este bloco condicional verifica se o valor da variável cPaisLoc é igual a "PTG". Caso verdadeiro, adiciona uma informação adicional no cabeçalho do Pedido de Vendas.
            ---- For nX := 1 To 02 ... Next nX: Este é um loop For que itera duas vezes, criando um bloco de código repetitivo para cada item do Pedido de Vendas. Ele preenche o array aItens com informações dos itens do pedido e o array aItemRat com informações de rateio para cada item.
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
            Esse bloco de código automatiza a inclusão de um novo Pedido de Vendas usando a função "MATA410". Se a inclusão for bem-sucedida, uma mensagem de sucesso é exibida com o número do documento do Pedido de Vendas. Caso ocorra algum erro durante a inclusão, uma mensagem de erro é exibida e os detalhes de erro são recuperados da função "GetAutoGRLog()" e formatados antes de serem exibidos na tela.
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
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            

            */
            //****************************************************************
            
            nOpcX := 4
            MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )}, aCabec, aItens, nOpcX, .F., aItemRat)
            If !lMsErroAuto
                ConOut("Alterado com sucesso! " + cDoc)
            Else
                ConOut("Erro na alteração!")
                aErroAuto := GetAutoGRLog()
                For nCount := 1 To Len(aErroAuto)
                    cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "
                    ConOut(cLogErro)
                Next nCount
            EndIf

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            

            */
            //****************************************************************


        ElseIf cOper == 3 

            
            ConOut(PadC("Teste de exclusão",80))
            
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
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            

            */
            //****************************************************************
            
            MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 5)
            If !lMsErroAuto
                ConOut("Excluído com sucesso! " + cDoc)
            Else
                ConOut("Erro na exclusão!")
            EndIf

            //****************************************************************
            /* Com o seu conhecimento, descreva o bloco de código lido até aqui:
            

            */
            //****************************************************************
            
        EndIf
    Else
            
        ConOut(cMsgLog)
    
    EndIf
    
    ConOut("Fim: " + Time())
    
    RESET ENVIRONMENT
Return(.T.)
