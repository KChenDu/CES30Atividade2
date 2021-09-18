CREATE TRIGGER OKL.OKL_trigger_valor_venda
ON OKL.OKL_ITEM_PEDIDO
AFTER INSERT, UPDATE
AS
DECLARE
    @cod_produto INT,
    @inserted_valor_venda REAL,
    @preco_base REAL,
    @char_valor_venda VARCHAR(10),
    @char_preco_base VARCHAR(10);
BEGIN
    -- SET @inserted_valor_venda = (SELECT i.VALOR_VENDA FROM inserted i);
    DECLARE iterator_valor_venda CURSOR
	FOR SELECT i.VALOR_VENDA, i.COD_PRODUTO FROM inserted i;
    -- Abrir o cursor
	OPEN iterator_valor_venda;
	FETCH NEXT FROM iterator_valor_venda INTO @inserted_valor_venda, @cod_produto;

    WHILE @@FETCH_STATUS = 0
	BEGIN
        SET @preco_base = (
            SELECT PRECO_BASE FROM OKL.OKL_PRODUTO
            WHERE COD_PRODUTO = @cod_produto
        );
        IF @inserted_valor_venda < @preco_base
        BEGIN
            ROLLBACK;
            SET @char_valor_venda = CONVERT(varchar(10), @inserted_valor_venda); 
            SET @char_preco_base = CONVERT(varchar(10), @preco_base);
            RAISERROR (N'Valor de venda %s menor que preço base %s não permitido.', -- Message text
                14, -- Severity
                1, -- State
                @char_valor_venda,
                @char_preco_base
            );
        END;
    	FETCH NEXT FROM iterator_valor_venda INTO @inserted_valor_venda, @cod_produto;
    END;
    
	CLOSE iterator_valor_venda;
	DEALLOCATE iterator_valor_venda;
END;
GO;

ALTER TRIGGER OKL.OKL_trigger_preco_base
ON OKL.OKL_PRODUTO
AFTER UPDATE
AS
DECLARE
    @cod_produto INT,
    @inserted_preco_base REAL,
    @valor_venda REAL,
    @char_preco_base VARCHAR(10),
    @char_valor_venda VARCHAR(10);
BEGIN
    -- SET @inserted_preco_base = (SELECT i.PRECO_BASE FROM inserted i);
    DECLARE iterator_preco_base CURSOR
	FOR SELECT i.PRECO_BASE, i.COD_PRODUTO FROM inserted i;
    -- Abrir o cursor
	OPEN iterator_preco_base;
	FETCH NEXT FROM iterator_preco_base INTO @inserted_preco_base, @cod_produto;

    WHILE @@FETCH_STATUS = 0
	BEGIN
        IF NOT (@inserted_preco_base < ALL (
                SELECT VALOR_VENDA FROM OKL.OKL_ITEM_PEDIDO
                WHERE COD_PRODUTO = @cod_produto)
            )

        BEGIN
            ROLLBACK;
            SET @char_preco_base = CONVERT(varchar(10), @inserted_preco_base);
            SET @char_valor_venda = CONVERT(varchar(10), @valor_venda);
            RAISERROR (N'Valor de venda %s menor que preço base %s não permitido.', -- Message text
                14, -- Severity
                1, -- State
                @char_valor_venda,
                @char_preco_base
            );
        END;
    	FETCH NEXT FROM iterator_preco_base INTO @inserted_preco_base, @cod_produto;
    END;
	CLOSE iterator_preco_base;
	DEALLOCATE iterator_preco_base;
END;
GO;

-- Verificar trigger
SELECT name FROM sys.triggers
WHERE name LIKE 'OKL_%';

-- Testa trigger insert ITEM_PEDIDO (inválido)
INSERT INTO OKL.OKL_PEDIDO(NUMERO_PEDIDO, CPF)
VALUES (0, '43032367646');
SELECT NUMERO_PEDIDO, CPF FROM OKL.OKL_PEDIDO;

INSERT INTO OKL.OKL_ITEM_PEDIDO(NUMERO_ITEM, COD_PRODUTO, VALOR_VENDA)
VALUES (1, 1, 1.0);

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

-- Testa trigger insert ITEM_PEDIDO (válido)
INSERT INTO OKL.OKL_ITEM_PEDIDO(NUMERO_ITEM, COD_PRODUTO, VALOR_VENDA)
VALUES (1, 1, 4.0);

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

-- Testa trigger update ITEM_PEDIDO (inválido)
UPDATE OKL.OKL_ITEM_PEDIDO
SET VALOR_VENDA = 1.0
WHERE NUMERO_ITEM = 1;

-- Testa trigger update ITEM_PEDIDO (válido)
UPDATE OKL.OKL_ITEM_PEDIDO
SET VALOR_VENDA = 5.0
WHERE NUMERO_ITEM = 1;

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

-- Testa trigger update PRODUTO (inválido)
UPDATE OKL.OKL_PRODUTO
SET PRECO_BASE = 6.0
WHERE COD_PRODUTO = 1;

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

-- Testa trigger update PRODUTO (válido)
UPDATE OKL.OKL_PRODUTO
SET PRECO_BASE = 1.0
WHERE COD_PRODUTO = 1
UPDATE OKL.OKL_PRODUTO
SET PRECO_BASE = 0.5
WHERE COD_PRODUTO = 2
;

UPDATE OKL.OKL_PRODUTO
SET QTD_ESTOQUE = 100
WHERE COD_PRODUTO = 1
UPDATE OKL.OKL_PRODUTO
SET QTD_ESTOQUE = 300
WHERE COD_PRODUTO = 2
;

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

SELECT * FROM OKL.OKL_PRODUTO

