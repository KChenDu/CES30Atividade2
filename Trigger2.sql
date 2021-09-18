--Criar o trigger
CREATE TRIGGER OKL.OKL_trigger_atualiza_estoque
ON OKL.OKL_ITEM_PEDIDO
AFTER INSERT
AS
DECLARE
	@inserted_prod INT,
    @inserted_qtd INT,
	@stock INT;
BEGIN
	DECLARE iterator_atualiza_estoque CURSOR
	FOR SELECT i.COD_PRODUTO, i.QTD_VENDIDA FROM inserted i;
	-- Abrir o cursor
	OPEN iterator_atualiza_estoque;
	FETCH NEXT FROM iterator_atualiza_estoque INTO @inserted_prod, @inserted_qtd;

	WHILE @@FETCH_STATUS = 0
	BEGIN
	SET @stock = (SELECT QTD_ESTOQUE FROM OKL.OKL_PRODUTO WHERE OKL.OKL_PRODUTO.COD_PRODUTO = @inserted_prod);
	IF @inserted_qtd > @stock
    BEGIN
		ROLLBACK;
        RAISERROR (N'Quantidade %d maior que quantidade de estoque %d.', -- Message text
        14, -- Severity
        1, -- State
        @inserted_qtd, @stock);
    END;
	ELSE
	BEGIN
        UPDATE OKL.OKL_PRODUTO
		SET QTD_ESTOQUE = @stock - @inserted_qtd
		WHERE COD_PRODUTO = @inserted_prod;
    END;
	FETCH NEXT FROM iterator_atualiza_estoque INTO @inserted_prod, @inserted_qtd;
	END;
	CLOSE iterator_atualiza_estoque;
	DEALLOCATE iterator_atualiza_estoque;
END;

--Verificar trigger
SELECT * FROM sys.triggers
WHERE name LIKE 'OKL_%';

--Visualizar tabelas
SELECT * FROM OKL.OKL_ITEM_PEDIDO;
SELECT * FROM OKL.OKL_PRODUTO;
SELECT * FROM OKL.OKL_VENDEDOR;

-- Testa trigger insert PEDIDO
INSERT INTO OKL.OKL_PEDIDO(NUMERO_PEDIDO, CPF)
VALUES (0, '43032367646');
SELECT NUMERO_PEDIDO, CPF FROM OKL.OKL_PEDIDO;

-- Testa trigger insert(instancia errada)
INSERT INTO OKL.OKL_ITEM_PEDIDO
VALUES(13, 0, 2, 500, 500.0, 1);
--(12, 0, 2, 5, 500.0, 1);

-- Testa trigger insert(instancia correta)
INSERT INTO OKL.OKL_ITEM_PEDIDO
VALUES(14, 0, 2, 2, 500.0, 1),
(15, 0, 2, 2, 500.0, 1);

SELECT * FROM OKL.OKL_PRODUTO;
SELECT * FROM OKL.OKL_PEDIDO;
SELECT * FROM OKL.OKL_ITEM_PEDIDO;

--DELETA ITEM_PEDIDO
DELETE
FROM OKL.OKL_ITEM_PEDIDO
WHERE NUMERO_ITEM = 10

--DROPS UTILS
DROP TRIGGER OKL.OKL_trigger_atualiza_estoque