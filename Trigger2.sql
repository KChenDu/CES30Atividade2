CREATE TRIGGER OKL.OKL_trigger_atualiza_estoque
ON OKL.OKL_ITEM_PEDIDO
AFTER INSERT
AS
DECLARE
	@inserted_prod INT,
    @inserted_qtd INT,
	@stock INT;
BEGIN
	SET @inserted_prod = (SELECT COD_PRODUTO FROM inserted i);
    SET @inserted_qtd = (SELECT QTD_VENDIDA FROM inserted i);
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
END;

-- Verificar trigger
SELECT * FROM sys.triggers
WHERE name LIKE 'OKL_%';

-- Visualizar tabelas
SELECT * FROM OKL.OKL_ITEM_PEDIDO;
SELECT * FROM OKL.OKL_PRODUTO;
SELECT * FROM OKL.OKL_VENDEDOR;

-- Testa trigger insert(instancia errada)
INSERT INTO OKL.OKL_ITEM_PEDIDO
VALUES (10, 0, 2, 500, 500.0, 1);

-- Testa trigger insert(instancia correta)
INSERT INTO OKL.OKL_ITEM_PEDIDO
VALUES (10, 0, 2, 2, 500.0, 1);

SELECT * FROM OKL.OKL_PRODUTO;

--DELETA ITEM_PEDIDO
DELETE
FROM OKL.OKL_ITEM_PEDIDO
WHERE NUMERO_ITEM = 10

--DROPS UTILS
DROP TRIGGER OKL.OKL_trigger_atualiza_estoque