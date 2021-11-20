--TRIGGERS

--O que são Triggers?
--O termo trigger (gatilho em inglês) define uma estrutura do banco de dados que funciona, como o nome sugere, 
--como uma função que é disparada mediante alguma ação.
--Geralmente essas ações que disparam os triggers são alterações nas tabelas por meio de operações de inserção, 
--exclusão e atualização de dados (insert, delete e update).

--Um gatilho está intimamente relacionado a uma tabela, sempre que uma dessas ações 
--é efetuada sobre essa tabela, é possível dispará-lo para executar alguma tarefa.

--Neste artigo veremos como trabalhar com triggers no SQL Server, através de um exemplo que simula uma 
--situação real, para facilitar o entendimento.





--Triggers no SQL Server
--No SQL Server, utilizamos instruções DML (Data Manipulation Language) para criar, alterar ou excluir um trigger.

--A sintaxe para criação de um trigger é a seguinte:



--CREATE TRIGGER [NOME DO TRIGGER]
--ON [NOME DA TABELA]
--[FOR/AFTER/INSTEAD OF] [INSERT/UPDATE/DELETE]
--AS
    --CORPO DO TRIGGER






--Os parâmetros são:

---	NOME DO TRIGGER: nome que identificará o gatilho como objeto do banco de dados. Deve seguir as regras básicas de nomenclatura de objetos.

---	NOME DA TABELA: tabela à qual o gatilho estará ligado, para ser disparado mediante ações de insert, update ou delete.

---	FOR/AFTER/INSTEAD OF: uma dessas opções deve ser escolhida para definir o momento em que o trigger será disparado. 
--	FOR é o valor padrão e faz com o que o gatilho seja disparado junto da ação. AFTER faz com que o disparo se dê somente após a ação 
--	que o gerou ser concluída. INSTEAD OF faz com que o trigger seja executado no lugar da ação que o gerou.

---	INSERT/UPDATE/DELETE: uma ou várias dessas opções (separadas por vírgula) devem ser indicadas para informar ao banco qual é a ação que disparará o gatilho. 
--	Por exemplo, se o trigger deve ser disparado após toda inserção, deve-se utilizar AFTER INSERT.


--	O entendimento de toda essa sintaxe, bem como do funcionamento dos triggers será facilitado quando desenvolvermos um exemplo próximo de um cenário real, 
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


--Por lógica, o saldo final do caixa começa igual ao saldo inicial.

--Criemos então o primeiro trigger sobre a tabela de vendas, que reduzirá o saldo final do caixa na data da venda quando uma venda for inserida.



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



--Nesse trigger utilizamos uma tabela temporária chamada INSERTED. Essa tabela existe somente dentro do trigger e possui apenas uma linha, 
--contendo os dados do registro que acabou de ser incluído. Assim, fazemos um select sobre essa tabela e passamos o valores de suas colunas para duas variáveis internas,
--@VALOR e @DATA, que são utilizadas posteriormente para realizar o update na tabela de caixa.

--O que fazemos é atualizar o saldo final da tabela caixa, somando o valor da venda cadastrada, no registro cuja data seja igual à data da venda (lógica de negócio simples).

--Como sabemos que o saldo final da tabela caixa encontra-se com o valor 100,00, podemos testar o trigger inserindo um registro na tabela vendas. 
--Vamos então executar a seguinte instrução SQL e observar seu resultado.


INSERT INTO VENDAS
VALUES (CONVERT(DATETIME, CONVERT(VARCHAR, GETDATE(), 103)), 1, 10)



--Inserimos uma venda com a data atual, o código 1 e o valor 10,00. Seguindo a lógica definida, o saldo final do caixa agora deverá ser 110,00.

--Podemos conferir isso executando um select sobre a tabela CAIXA e observando o resultado, conforme ilustra a Figura 1.



--Agora precisamos criar um trigger para a instrução de delete, que devolverá o valor ao caixa quando uma venda for excluída.


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



--Dessa vez utilizamos a tabela temporária DELETED, 
--que funciona da mesma forma que a INSERTED já citada, porém com os dados do registro que está sendo excluído, em operações de delete e update.


--Podemos agora excluir o registro da tabela VENDAS e verificar como o saldo do caixa é atualizado (deve voltar ao valor 100,00, devido ao cancelamento da venda de 10,00).



DELETE FROM VENDAS WHERE CODIGO = 1
GO


--Listando os registros da tabela CAIXA podemos ver que o saldo final foi atualizado, tendo sido subtraído dele o valor 10,00, conforme esperado (Figura 2).


--Vemos então que ambos os triggers estão funcionando como esperado, sendo disparados com as operações de insert e delete da tabela de vendas.


--Conclusão
-----------------
--Com este exemplo bastante simples é possível perceber um ponto muito importante da utilização de triggers para automatização de certas ações. 
--Por exemplo, o programador responsável por esta parte do sistema poderia optar, antes de ler este artigo, 
--por atualizar a tabela de caixa manualmente após cada operação na tabela vendas, utilizando sua linguagem de programação de preferência. 
--Agora, ele apenas precisará se preocupar com o registro e cancelamento da venda, pois a atualização da tabela de caixa será feita automaticamente pelo próprio banco de dados.

--Com isso, o sistema em si, ou seja, o aplicativo, tende a ficar mais leve, pois parte da responsabilidade de execução de algumas tarefas 
--foi transferida para o servidor de banco de dados.

--Apesar de breve, este artigo buscou apresentar os principais pontos sobre o uso de triggers no SQL Server, 
--apresentando um exemplo prático bastante próximo a uma situação real, com o objetivo de facilitar o entendimento.