#Include 'Protheus.ch'
#Include 'RestFul.ch'
#Include "Totvs.ch"
#Include "RwMake.ch"
#Include "FwMvcDef.ch"
#include "fileio.ch"

/*/{Protheus.doc} Webservice myAPI
    Fonte utilizado para testes e treinamentos. 
    Este documento � de propriedade da TOTVS. Todos os direitos reservados.

    IMPORTANTE: Para avalia��o, preencha todos os blocos de coment�rios de 
    acordo com a descri��o inserida.

    @type  Webservice
    @author gabriel.antonio@totvs.com.br 
    /*/ 

WSRESTFUL myAPI DESCRIPTION "Lancamentos (AKD)"

	WSMETHOD POST DESCRIPTION "Inclui lancamentos" WSSYNTAX ""
    //****************************************************************
    /* 
    Nesse bloco de c�digo estamos declarando uma classe RESTfull chamada "myAPI" que disponibiliza o m�todo POST para que os clientes possam realizar a inclus�o de lan�amentos na tabela "AKD" do sistema.
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
    Esse bloco de c�digo � o in�cio da implementa��o do m�todo POST da classe "myAPI" e define vari�veis e objetos necess�rios para processar as requisi��es recebidas, incluindo a obten��o do conte�do da requisi��o JSON, a prepara��o de vari�veis de controle e a exibi��o de mensagens informativas no console.
    A fun��o  "fStrDatHor" � respons�vel por exibir mensagens no console, informando eventos no fluxo do c�digo.
    */
    //****************************************************************

	::SetContentType("application/json")
    //****************************************************************
    /* 
    Esse bloco de c�digo est� configurando o cabe�alho da resposta para indicar que o conte�do retornado ser� um objeto JSON. Essa configura��o � importante para que o cliente saiba como interpretar os dados recebidos e possa process�-lo adequadamente.
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
        Nesse bloco de c�digo estamos realizando as prepara��es necess�rias para processar o conte�do JSON recebido na requisi��o POST. Primeiro, verificamos se o conte�do � uma string n�o vazia e, em seguida, convertemos essa string para um objeto JSON manipul�vel. 
        Selecionamos as �reas de trabalho das tabelas do banco de dados envolvidas nas opera��es para garantir que as opera��es sejam realizadas na tabela correta.
        */
        //****************************************************************

        For nFor := 1 to Len(oAKD:AAKD)	
        
            AADD( aAKDRet, JsonObject():new() )
            _nX := len(aAKDRet)
            aAKDRet[_nX][ 'Indice' ]   := cValToChar(nFor)

            //****************************************************************
            /* 
            Essa estrutura de loop � usada para processar os lan�amentos cont�beis recebidos na requisi��o POST. Ela percorre cada lan�amento cont�bil presente no array "oAKD:AAKD", adicionando um objeto JSON vazio para representar cada lan�amento no array "aAKDRet". Cada objeto JSON do array "aAKDRet" cont�m um campo "Indice" que indica o n�mero sequencial do lan�amento.
            Obs.: _nX n�o foi declarada no in�cio do programa e pode provocar erro.
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
                Esse bloco de c�digo representa uma sequ�ncia de verifoca��es e valida��es dos campos do lan�amento cont�bil. Caso alguma dessas verifica��es nao seja atendida, uma mensagem de erro � armazenada no array "aAKDRet" para informar ao cliente que h� problemas com os dados de lan�amento. Essas mensagens de erro ser�o retornadas ao cliente na resposta da requisi��o POST, fornecendo informa��es espec�ficas sobre os campos que precisam ser corrigidos ou preenchidos corretamente.
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
                Esse bloco de c�digo tem como finalidade obter um n�mero de lote dispon�vel e �nico para o lan�amento cont�bil atual. Ele busca o pr�ximo n�mero de lote dispon�vel da tabela "AKD" e, caso esse n�mero j� esteja sendo usado, ele obt�m um novo n�mero de lote at� encontrar um que esteja livre. Uma vez que um n�mero de lote v�lido � encontrado, ele � atribu�do � vari�vel "_clote" para ser utilizado posteriormente no processamento do lan�amento cont�bil. Isso garante que cada lan�amento tenha um n�mero de lote exclusivo e evita poss�veis conflitos de duplica��o.
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
                Esse bloco de c�digo � respons�vel por processar o lan�amento cont�bil validado e inserir as informa��es na tabela "AKD" do sistema. Ele registra as informa��es necess�rias para o lan�amento, como filial, n�mero de lote, data, conta, hist�rico, valor, centro de custo, tipo de saldo e classe. Ap�s realizar o processo de inser��o, ele informa na estrutura "aAKDRet" se o lan�amento foi importado com sucesso ou se ocorreu algum problema ao grav�-lo no banco de dados.
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
        Esse bloco de c�digo � respons�vel por finalizar a transa��o de banco de dados ap�s o processamento dos lan�amentos cont�beis, bem como lidar com poss�veis erros de requisi��o relacionados � estrutura JSON enviada. Ele assegura que as opera��es no banco de dados sejam tratadas de forma consistente e, em caso de erro, retorna uma mensagem adequada ao cliente para que ele possa entender o motivo da falha na requisi��o.
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
    Esse bloco de c�digo prepara a resposta da API ap�s o processamento dos lan�amentos cont�beis. Ele cria um objeto JSON "oAKDRet", preenche-o com os dados processados e registra logs relevantes para fins de depura��o. Em seguida, define esse objeto JSON como a resposta da API, que ser� enviada de volta ao cliente que realizou a chamada. Caso ocorra algum erro durante o processamento, a vari�vel "lRet" ser� definida como falso e uma mensagem de erro adequada ser� registrada e enviada na resposta JSON.
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
    Esse bloco de c�digo encerra o processamento do m�todo POST da API, restaura as �reas do banco de dados relacionadas �s tabelas "AKD" e outras n�o especificadas, registra um log indicando que o m�todo POST foi finalizado e retorna o status do processamento (verdadeiro ou falso) para ser usado no contexto geral da execu��o da API. A fun��o "fStrDatHor" � usada para registrar logs ao longo do c�digo para fins de depura��o e rastreamento de atividades
    */
    //****************************************************************
Return
