CREATE TRIGGER OKL.OKL_trigger_valor_venda
ON OKL.OKL_ITEM_PEDIDO
AFTER INSERT, UPDATE
AS
DECLARE
    @inserted_valor_venda REAL,
    @preco_base REAL,
    @char_valor_venda VARCHAR(10),
    @char_preco_base VARCHAR(10);
BEGIN
    SET @inserted_valor_venda = (SELECT i.VALOR_VENDA FROM inserted i);
    SET @preco_base = (
        SELECT PRECO_BASE FROM OKL.OKL_PRODUTO
        WHERE COD_PRODUTO = (SELECT i.COD_PRODUTO FROM inserted i)
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
END;
GO;

CREATE TRIGGER OKL.OKL_trigger_preco_base
ON OKL.OKL_PRODUTO
AFTER UPDATE
AS
DECLARE
    @inserted_preco_base REAL,
    @valor_venda REAL,
    @char_preco_base VARCHAR(10),
    @char_valor_venda VARCHAR(10);
BEGIN
    SET @inserted_preco_base = (SELECT i.PRECO_BASE FROM inserted i);
    SET @valor_venda = (
        SELECT VALOR_VENDA FROM OKL.OKL_ITEM_PEDIDO
        WHERE COD_PRODUTO = (SELECT i.COD_PRODUTO FROM inserted i)
        );
    IF @valor_venda < @inserted_preco_base
    BEGIN
        ROLLBACK;
        SET @char_valor_venda = CONVERT(varchar(10), @valor_venda);
        SET @char_preco_base = CONVERT(varchar(10), @inserted_preco_base); 
        RAISERROR (N'Valor de venda %s menor que preço base %s não permitido.', -- Message text
        14, -- Severity
        1, -- State
        @char_valor_venda,
        @char_preco_base
        );
    END;
END;
GO;

-- Verificar trigger
SELECT * FROM sys.triggers
WHERE name LIKE 'OKL_%';

-- Testa trigger insert ITEM_PEDIDO
INSERT INTO OKL.OKL_PEDIDO(NUMERO_PEDIDO, CPF)
VALUES (0, 43032367646);
SELECT NUMERO_PEDIDO, CPF FROM OKL.OKL_PEDIDO;

INSERT INTO OKL.OKL_ITEM_PEDIDO(NUMERO_ITEM, COD_PRODUTO, VALOR_VENDA)
VALUES (1, 1, 1.0);

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

-- Testa trigger update ITEM_PEDIDO
SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

UPDATE OKL.OKL_ITEM_PEDIDO
SET VALOR_VENDA = 90
WHERE COD_PRODUTO = 2;

-- Testa trigger update PRODUTO
SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;

UPDATE OKL.OKL_PRODUTO
SET PRECO_BASE = 600
WHERE COD_PRODUTO = 2;
