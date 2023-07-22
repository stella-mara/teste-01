#Include 'Protheus.ch'
#Include 'RestFul.ch'
#Include "Totvs.ch"
#Include "RwMake.ch"
#Include "FwMvcDef.ch"
#include "fileio.ch"

/*/{Protheus.doc} Webservice myAPI
    Fonte utilizado para testes e treinamentos. 
    Este documento é de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avaliação, preencha todos os blocos de comentários de 
    acordo com a descrição inserida.

    @type  Webservice
    @author gabriel.antonio@totvs.com.br 
    /*/ 

WSRESTFUL myAPI DESCRIPTION "Lancamentos (AKD)"

	WSMETHOD POST DESCRIPTION "Inclui lancamentos" WSSYNTAX ""
    //****************************************************************
    /* 
    Nesse bloco de código estamos declarando uma classe RESTfull chamada "myAPI" que disponibiliza o método POST para que os clientes possam realizar a inclusão de lançamentos na tabela "AKD" do sistema.
    */
    //****************************************************************
END WSRESTFUL 

WSMETHOD POST WSSERVICE myAPI
	Local cJSON         := ::GetContent()
	Local oAKD          := JsonObject():New()
	Local oAKDRet
	Local aArea         := GetArea()
	Local aAreaAKD      := AKD->(GetArea())
	Local cMsgAux       := ""
	Local lRet          := .T.
	Local cChavePesq    := ""
	Local nFor          := 0
    Local _clote        := ""
    Local _cID          := 0
    Local aAKDRet       := {} 

	fStrDatHor("Metodo POST requisitado")
    //****************************************************************
    /* 
    Esse bloco de código é o início da implementação do método POST da classe "myAPI" e define variáveis e objetos necessários para processar as requisições recebidas, incluindo a obtenção do conteúdo da requisição JSON, a preparação de variáveis de controle e a exibição de mensagens informativas no console.
    A função  "fStrDatHor" é responsável por exibir mensagens no console, informando eventos no fluxo do código.
    */
    //****************************************************************

	::SetContentType("application/json")
    //****************************************************************
    /* 
    Esse bloco de código está configurando o cabeçalho da resposta para indicar que o conteúdo retornado será um objeto JSON. Essa configuração é importante para que o cliente saiba como interpretar os dados recebidos e possa processá-lo adequadamente.
    */
    //****************************************************************

	If ValType(cJSON) == "C" .AND. !Empty(cJSON)      

		oAKD:fromJson(cJSON)
 
        DbSelectArea("AK5")
        AK5->(DbSetOrder(1))

        DbSelectArea("AL2")
        AL2->(DbSetOrder(1))

        DbSelectArea("CTT")
        CTT->(DbSetOrder(1))

        DbSelectArea("CTD")
        CTD->(DbSetOrder(1))

        DbSelectArea("CTH")
        CTH->(DbSetOrder(1))

        DbSelectArea("AK6")
        AK6->(DbSetOrder(1))

        DbSelectARea("AKD")
        AKD->(DbSetOrder(1))

        //****************************************************************
        /* 
        Nesse bloco de código estamos realizando as preparações necessárias para processar o conteúdo JSON recebido na requisição POST. Primeiro, verificamos se o conteúdo é uma string não vazia e, em seguida, convertemos essa string para um objeto JSON manipulável. 
        Selecionamos as áreas de trabalho das tabelas do banco de dados envolvidas nas operações para garantir que as operações sejam realizadas na tabela correta.
        */
        //****************************************************************

        For nFor := 1 to Len(oAKD:AAKD)	
        
            AADD( aAKDRet, JsonObject():new() )
            _nX := len(aAKDRet)
            aAKDRet[_nX][ 'Indice' ]   := cValToChar(nFor)

            //****************************************************************
            /* 
            Essa estrutura de loop é usada para processar os lançamentos contábeis recebidos na requisição POST. Ela percorre cada lançamento contábil presente no array "oAKD:AAKD", adicionando um objeto JSON vazio para representar cada lançamento no array "aAKDRet". Cada objeto JSON do array "aAKDRet" contém um campo "Indice" que indica o número sequencial do lançamento.
            Obs.: _nX não foi declarada no início do programa e pode provocar erro.
            */
            //****************************************************************

            BEGIN SEQUENCE 
 
                _cFilial := oAKD:AAKD[nFor]:AKD_FILIAL
                If Empty(_cFilial)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor do campo AKD_FILIAL nao informado."
                    Break
                EndIf

                cChavePesq := "01"+_cFilial
                If SM0->(msSeek(cChavePesq))
                    U_fGoEmp("01",_cFilial)
                Else
                    aAKDRet[_nX][ 'mensagem' ] := "Filial nao encontrada com a chave " + cChavePesq
                    Break
                EndIf

                cData := oAKD:AAKD[nFor]:AKD_DATA
                If Empty(cData)
                    aAKDRet[_nX][ 'mensagem' ] := "O campo AKD_DATA e obrigatorio e deve estar no formato DD/MM/AAAA."
                    Break
                EndIf

                cHist := oAKD:AAKD[nFor]:AKD_HIST
                If Empty(cHist)
                    aAKDRet[_nX][ 'mensagem' ] := "O campo AKD_HIST e obrigatorio."
                    Break
                EndIf

                nValor := oAKD:AAKD[nFor]:AKD_VALOR1
                If Empty(nValor)
                    aAKDRet[_nX][ 'mensagem' ] := "O campo AKD_VALOR1 e obrigatorio e deve estar no formato float."
                    Break
                EndIf

                cTipo := oAKD:AAKD[nFor]:AKD_TIPO
                If !cTipo $ "1|2|3" .Or. Empty(cTipo)
                    aAKDRet[_nX][ 'mensagem' ] := "Valores aceitos para o campo AKD_TIPO: 1, 2 ou 3."
                    Break
                EndIf

                cConta := padr(oAKD:AAKD[nFor]:AKD_CO,TamSX3("AKD_CO")[1])
                If !AK5->(msSeek(xFilial("AK5")+cConta)) .Or. Empty(cConta)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cConta) + " do campo AKD_CO vazio ou nao encontrado na tabela AK5. "
                    Break
                EndIf

                If AK5->AK5_MSBLQL == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cConta) + " do campo AKD_CO bloqueado na tabela AK5."
                    Break
                EndIf

                cTpSld := padr(oAKD:AAKD[nFor]:AKD_TPSALD,TamSX3("AKD_TPSALD")[1])
                If !AL2->(msSeek(xFilial("AL2")+cTpSld)) .Or. Empty(cTpSld)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cTpSld) + " do campo AKD_TPSALD vazio ou nao encontrado na tabela AL2. "
                    Break
                EndIf

                cCC := padr(oAKD:AAKD[nFor]:AKD_CC,TamSX3("AKD_CC")[1])
                If !CTT->(msSeek(xFilial("CTT")+cCC)) .Or. Empty(cCC)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCC) + " do campo AKD_CC vazio ou nao encontrado na tabela CTT."
                    Break
                EndIf

                If CTT->CTT_BLOQ == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCC) + " do campo AKD_CC bloqueado na tabela CTT."
                    Break
                EndIf

                cITCTB := padr(oAKD:AAKD[nFor]:AKD_ITCTB,TamSX3("AKD_ITCTB")[1]) 
                If !CTD->(msSeek(xFilial("CTD")+cITCTB)) .and. !Empty(cITCTB)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cITCTB) + " do campo AKD_ITCTB nao encontrado na tabela CTD."
                    Break
                EndIf

                If CTD->CTD_BLOQ == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cITCTB) + " do campo AKD_ITCTB bloqueado na tabela CTD."
                    Break
                EndIf

                cCLVLR := padr(oAKD:AAKD[nFor]:AKD_CLVLR,TamSX3("AKD_CLVLR")[1])
                If !CTH->(msSeek(xFilial("CTH")+cCLVLR)) .and. !Empty(cCLVLR)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCLVLR) + " do campo AKD_CLVLR vazio ou nao encontrado na tabela CTH."
                    Break
                EndIf

                If CTH->CTH_BLOQ == "1"
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cCLVLR) + " do campo AKD_CLVLR bloqueado na tabela CTH."
                    Break
                EndIf

                cClasse := padr(oAKD:AAKD[nFor]:AKD_CLASSE,TamSX3("AKD_CLASSE")[1])
                If !AK6->(msSeek(xFilial("AK6")+cClasse)) .and. !Empty(cClasse)
                    aAKDRet[_nX][ 'mensagem' ] := "Valor " + alltrim(cClasse) + " do campo AKD_CLASSE vazio ou nao encontrado na tabela AK6."
                    Break
                EndIf
                
                //****************************************************************
                /*
                Esse bloco de código representa uma sequência de verifocações e validações dos campos do lançamento contábil. Caso alguma dessas verificações nao seja atendida, uma mensagem de erro é armazenada no array "aAKDRet" para informar ao cliente que há problemas com os dados de lançamento. Essas mensagens de erro serão retornadas ao cliente na resposta da requisição POST, fornecendo informações específicas sobre os campos que precisam ser corrigidos ou preenchidos corretamente.
                */
                //****************************************************************
                
                If Empty(_clote)
                    _clote := GETSXENUM("AKD","AKD_LOTE","AKD" + _cFilial)
                    ConfirmSx8()
                    While .T.
                        If AKD->(msSeek(_cFilial + _clote))
                            _clote := GETSXENUM("AKD","AKD_LOTE","AKD" + _cFilial)
                            ConfirmSx8()
                        Else
                            Exit
                        EndIf
                    EndDo
                EndIf

                //****************************************************************
                /* 
                Esse bloco de código tem como finalidade obter um número de lote disponível e único para o lançamento contábil atual. Ele busca o próximo número de lote disponível da tabela "AKD" e, caso esse número já esteja sendo usado, ele obtém um novo número de lote até encontrar um que esteja livre. Uma vez que um número de lote válido é encontrado, ele é atribuído à variável "_clote" para ser utilizado posteriormente no processamento do lançamento contábil. Isso garante que cada lançamento tenha um número de lote exclusivo e evita possíveis conflitos de duplicação.
                */
                //****************************************************************

                _cID++
                Begin Transaction
                If RecLock("AKD",.T.)
                    AKD->AKD_FILIAL := _cFilial
                    AKD->AKD_FILORI := _cFilial
                    AKD->AKD_LOTE   := _clote
                    AKD->AKD_ID     := strZero(_cID,4)
                    AKD->AKD_DATA   := CTOD(cData)
                    AKD->AKD_CO     := cConta
                    AKD->AKD_TPSALD := cTpSld
                    AKD->AKD_HIST   := cHist
                    AKD->AKD_COSUP  := Substr(cConta,1,5)
                    AKD->AKD_VALOR1 := nValor
                    AKD->AKD_CC     := cCC
                    AKD->AKD_ITCTB  := cITCTB
                    AKD->AKD_CLVLR  := cCLVLR
                    AKD->AKD_STATUS := "1"
                    AKD->AKD_CLASSE := cClasse
                    AKD->AKD_TIPO   := cTipo
                    AKD->(MsUnLock())

                    aAKDRet[_nX][ 'mensagem' ] := "Lancamento Importado com sucesso."
                    aAKDRet[_nX][ 'lote' ]     := alltrim(_clote)
                Else
                    aAKDRet[_nX][ 'mensagem' ] := "Nao foi possivel gravar o lancamento."
                    aAKDRet[_nX][ 'lote' ]     := alltrim(_clote)
                EndIf

                //****************************************************************
                /* 
                Esse bloco de código é responsável por processar o lançamento contábil validado e inserir as informações na tabela "AKD" do sistema. Ele registra as informações necessárias para o lançamento, como filial, número de lote, data, conta, histórico, valor, centro de custo, tipo de saldo e classe. Após realizar o processo de inserção, ele informa na estrutura "aAKDRet" se o lançamento foi importado com sucesso ou se ocorreu algum problema ao gravá-lo no banco de dados.
                */
                //****************************************************************


                End Transaction
            END SEQUENCE
        Next nFor
	Else
		cMsgAux := "JSON nao foi especificado corretamente no corpo da requisicao, verifique."
		SetRestFault(12, cMsgAux)
        //****************************************************************
        /* 
        Esse bloco de código é responsável por finalizar a transação de banco de dados após o processamento dos lançamentos contábeis, bem como lidar com possíveis erros de requisição relacionados à estrutura JSON enviada. Ele assegura que as operações no banco de dados sejam tratadas de forma consistente e, em caso de erro, retorna uma mensagem adequada ao cliente para que ele possa entender o motivo da falha na requisição.
        */
        //****************************************************************

		fStrDatHor(cMsgAux)
		lRet := .F.
	EndIf

	fStrDatHor("Preparando retorno")
    oAKDRet := JsonObject():New()
    oAKDRet[ '_classname' ] := "myAPI"
    oAKDRet[ 'AAKD' ]       := aAKDRet

    ::SetResponse(oAKDRet)

    //****************************************************************
    /*
    Esse bloco de código prepara a resposta da API após o processamento dos lançamentos contábeis. Ele cria um objeto JSON "oAKDRet", preenche-o com os dados processados e registra logs relevantes para fins de depuração. Em seguida, define esse objeto JSON como a resposta da API, que será enviada de volta ao cliente que realizou a chamada. Caso ocorra algum erro durante o processamento, a variável "lRet" será definida como falso e uma mensagem de erro adequada será registrada e enviada na resposta JSON.
    */
    //****************************************************************

	RestArea(aAreaAKD)
	RestArea(aArea)
	fStrDatHor("Metodo POST finalizado")
Return(lRet)

Static Function fStrDatHor(cMsg)
	ConOut(DToC(Date())+"-"+Time()+" (myAPI) -> " + cValToChar(cMsg))

    //****************************************************************
    /* 
    Esse bloco de código encerra o processamento do método POST da API, restaura as áreas do banco de dados relacionadas às tabelas "AKD" e outras não especificadas, registra um log indicando que o método POST foi finalizado e retorna o status do processamento (verdadeiro ou falso) para ser usado no contexto geral da execução da API. A função "fStrDatHor" é usada para registrar logs ao longo do código para fins de depuração e rastreamento de atividades
    */
    //****************************************************************
Return
