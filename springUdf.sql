CREATE DATABASE tarefa_spring_udf
GO
USE tarefa_spring_udf
GO
CREATE TABLE produto(
codigo         INT           NOT NULL,
nome           VARCHAR(50)   NOT NULL,
valor_unitario DECIMAL(7,2)  NOT NULL,
qtd_estoque    INT           NOT NULL
PRIMARY KEY(codigo)
)

CREATE PROCEDURE sp_produto(@op CHAR(1), @codigo INT, 
		@nome VARCHAR(100), @valor_unitario DECIMAL(7,2), @qtd_estoque INT,
		@saida VARCHAR(MAX) OUTPUT)
AS
IF(UPPER(@op) = 'D' AND @codigo IS NOT NULL)
BEGIN
	DELETE produto WHERE codigo = @codigo
	SET @saida = 'Pessoa #ID ' + cast(@codigo AS VARCHAR(5)) + ' excluida'
END
ELSE
BEGIN
	IF(UPPER(@op) = 'D' AND @codigo IS NULL)
	BEGIN
		RAISERROR('#ID invalido', 16, 1)
	END
	ELSE
	BEGIN
		IF(UPPER(@op) = 'I')
		BEGIN
			INSERT INTO produto VALUES
			(@codigo, @nome, @valor_unitario, @qtd_estoque)
			SET @saida = 'Produto #ID' + CAST(@codigo AS VARCHAR(5)) + ' inserido com sucesso'
		END
		ELSE
		BEGIN
			IF(UPPER(@op) = 'U')
			BEGIN
				UPDATE produto
				SET nome = @nome, valor_unitario = @valor_unitario,
					qtd_estoque = @qtd_estoque
				WHERE codigo = @codigo

				SET @saida = 'Produto #ID ' + 
					CAST(@codigo AS VARCHAR(5))+' atualizado com sucesso' 
			END
			ELSE
			BEGIN
				RAISERROR('Operacao de codigo invalido', 16, 1)
			END
		END
	END
END

DECLARE @saida1 VARCHAR(MAX)
EXEC sp_produto 'u', 1, 'Caderno', 5.99, 10, @saida1 OUTPUT 
PRINT @saida1

DECLARE @saida2 VARCHAR(MAX)
EXEC sp_produto 'i', 2, 'Caneta', 1.99, 8, @saida2 OUTPUT  
PRINT @saida2

DECLARE @saida3 VARCHAR(MAX)
EXEC sp_produto 'i', 3, 'Lapis', 0.99, 3, @saida3 OUTPUT  
PRINT @saida3

DECLARE @saida4 VARCHAR(MAX)
EXEC sp_produto 'i', 4, 'Borracha', 3.99, 0, @saida4 OUTPUT  
PRINT @saida4

SELECT * FROM produto

CREATE FUNCTION fn_prod(@codigo INT)
RETURNS DECIMAL(7,2)
AS
BEGIN
	DECLARE @nome				varchar(100),
			@valor_unitario		DECIMAL(7,2),
			@qtd_estoque		INT

	SELECT @nome = nome, @valor_unitario = valor_unitario, @qtd_estoque = qtd_estoque FROM produto
		WHERE codigo = @codigo
	
	RETURN @qtd_estoque
END
 
SELECT dbo.fn_prod(2) AS qtd_estoque
 
CREATE FUNCTION fn_tabelaprod()
RETURNS @tabela TABLE (
codigo			INT,
nome			VARCHAR(100),
valor_unitario	DECIMAL(7,2),
qtd_estoque		INT,
condicao		VARCHAR(22)
)
AS
BEGIN
	INSERT INTO @tabela(codigo, nome, valor_unitario, qtd_estoque)
		SELECT codigo, nome, valor_unitario, qtd_estoque FROM produto
 
	UPDATE @tabela SET qtd_estoque = (SELECT dbo.fn_prod(codigo))
 
	UPDATE @tabela SET condicao = 'Sem estoque'
		WHERE qtd_estoque = 0
	UPDATE @tabela SET condicao = 'Estoque baixo'
		WHERE qtd_estoque > 1 AND qtd_estoque < 9
	UPDATE @tabela SET condicao = 'Em estoque'
		WHERE qtd_estoque >= 10

	RETURN 
END

SELECT * FROM fn_tabelaprod()
