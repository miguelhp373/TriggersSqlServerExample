--TRIGGERS

--O que s�o Triggers?
--O termo trigger (gatilho em ingl�s) define uma estrutura do banco de dados que funciona, como o nome sugere, 
--como uma fun��o que � disparada mediante alguma a��o.
--Geralmente essas a��es que disparam os triggers s�o altera��es nas tabelas por meio de opera��es de inser��o, 
--exclus�o e atualiza��o de dados (insert, delete e update).

--Um gatilho est� intimamente relacionado a uma tabela, sempre que uma dessas a��es 
--� efetuada sobre essa tabela, � poss�vel dispar�-lo para executar alguma tarefa.

--Neste artigo veremos como trabalhar com triggers no SQL Server, atrav�s de um exemplo que simula uma 
--situa��o real, para facilitar o entendimento.





--Triggers no SQL Server
--No SQL Server, utilizamos instru��es DML (Data Manipulation Language) para criar, alterar ou excluir um trigger.

--A sintaxe para cria��o de um trigger � a seguinte:



--CREATE TRIGGER [NOME DO TRIGGER]
--ON [NOME DA TABELA]
--[FOR/AFTER/INSTEAD OF] [INSERT/UPDATE/DELETE]
--AS
    --CORPO DO TRIGGER






--Os par�metros s�o:

---	NOME DO TRIGGER: nome que identificar� o gatilho como objeto do banco de dados. Deve seguir as regras b�sicas de nomenclatura de objetos.

---	NOME DA TABELA: tabela � qual o gatilho estar� ligado, para ser disparado mediante a��es de insert, update ou delete.

---	FOR/AFTER/INSTEAD OF: uma dessas op��es deve ser escolhida para definir o momento em que o trigger ser� disparado. 
--	FOR � o valor padr�o e faz com o que o gatilho seja disparado junto da a��o. AFTER faz com que o disparo se d� somente ap�s a a��o 
--	que o gerou ser conclu�da. INSTEAD OF faz com que o trigger seja executado no lugar da a��o que o gerou.

---	INSERT/UPDATE/DELETE: uma ou v�rias dessas op��es (separadas por v�rgula) devem ser indicadas para informar ao banco qual � a a��o que disparar� o gatilho. 
--	Por exemplo, se o trigger deve ser disparado ap�s toda inser��o, deve-se utilizar AFTER INSERT.


--	O entendimento de toda essa sintaxe, bem como do funcionamento dos triggers ser� facilitado quando desenvolvermos um exemplo pr�ximo de um cen�rio real, 
--	conforme faremos a seguir.




CREATE TABLE CAIXA
(
    DATA            DATETIME,
    SALDO_INICIAL   DECIMAL(10,2),
    SALDO_FINAL     DECIMAL(10,2)
)
GO

INSERT INTO CAIXA
VALUES (CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 103)), 100, 100)
GO

CREATE TABLE VENDAS
(
    DATA    DATETIME,
    CODIGO  INT,
    VALOR   DECIMAL(10,2)
)
GO


--Por l�gica, o saldo final do caixa come�a igual ao saldo inicial.

--Criemos ent�o o primeiro trigger sobre a tabela de vendas, que reduzir� o saldo final do caixa na data da venda quando uma venda for inserida.



CREATE TRIGGER TGR_VENDAS_AI
ON VENDAS
FOR INSERT
AS
BEGIN
    DECLARE
    @VALOR  DECIMAL(10,2),
    @DATA   DATETIME

    SELECT @DATA = DATA, @VALOR = VALOR FROM INSERTED

    UPDATE CAIXA SET SALDO_FINAL = SALDO_FINAL + @VALOR
    WHERE DATA = @DATA
END
GO



--Nesse trigger utilizamos uma tabela tempor�ria chamada INSERTED. Essa tabela existe somente dentro do trigger e possui apenas uma linha, 
--contendo os dados do registro que acabou de ser inclu�do. Assim, fazemos um select sobre essa tabela e passamos o valores de suas colunas para duas vari�veis internas,
--@VALOR e @DATA, que s�o utilizadas posteriormente para realizar o update na tabela de caixa.

--O que fazemos � atualizar o saldo final da tabela caixa, somando o valor da venda cadastrada, no registro cuja data seja igual � data da venda (l�gica de neg�cio simples).

--Como sabemos que o saldo final da tabela caixa encontra-se com o valor 100,00, podemos testar o trigger inserindo um registro na tabela vendas. 
--Vamos ent�o executar a seguinte instru��o SQL e observar seu resultado.


INSERT INTO VENDAS
VALUES (CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 103)), 1, 10)



--Inserimos uma venda com a data atual, o c�digo 1 e o valor 10,00. Seguindo a l�gica definida, o saldo final do caixa agora dever� ser 110,00.

--Podemos conferir isso executando um select sobre a tabela CAIXA e observando o resultado, conforme ilustra a Figura 1.



--Agora precisamos criar um trigger para a instru��o de delete, que devolver� o valor ao caixa quando uma venda for exclu�da.


CREATE TRIGGER TGR_VENDAS_AD
ON VENDAS
FOR DELETE
AS
BEGIN
    DECLARE
    @VALOR  DECIMAL(10,2),
    @DATA   DATETIME

    SELECT @DATA = DATA, @VALOR = VALOR FROM DELETED

    UPDATE CAIXA SET SALDO_FINAL = SALDO_FINAL - @VALOR
    WHERE DATA = @DATA
END
GO



--Dessa vez utilizamos a tabela tempor�ria DELETED, 
--que funciona da mesma forma que a INSERTED j� citada, por�m com os dados do registro que est� sendo exclu�do, em opera��es de delete e update.


--Podemos agora excluir o registro da tabela VENDAS e verificar como o saldo do caixa � atualizado (deve voltar ao valor 100,00, devido ao cancelamento da venda de 10,00).



DELETE FROM VENDAS WHERE CODIGO = 1
GO


--Listando os registros da tabela CAIXA podemos ver que o saldo final foi atualizado, tendo sido subtra�do dele o valor 10,00, conforme esperado (Figura 2).


--Vemos ent�o que ambos os triggers est�o funcionando como esperado, sendo disparados com as opera��es de insert e delete da tabela de vendas.


--Conclus�o
-----------------
--Com este exemplo bastante simples � poss�vel perceber um ponto muito importante da utiliza��o de triggers para automatiza��o de certas a��es. 
--Por exemplo, o programador respons�vel por esta parte do sistema poderia optar, antes de ler este artigo, 
--por atualizar a tabela de caixa manualmente ap�s cada opera��o na tabela vendas, utilizando sua linguagem de programa��o de prefer�ncia. 
--Agora, ele apenas precisar� se preocupar com o registro e cancelamento da venda, pois a atualiza��o da tabela de caixa ser� feita automaticamente pelo pr�prio banco de dados.

--Com isso, o sistema em si, ou seja, o aplicativo, tende a ficar mais leve, pois parte da responsabilidade de execu��o de algumas tarefas 
--foi transferida para o servidor de banco de dados.

--Apesar de breve, este artigo buscou apresentar os principais pontos sobre o uso de triggers no SQL Server, 
--apresentando um exemplo pr�tico bastante pr�ximo a uma situa��o real, com o objetivo de facilitar o entendimento.