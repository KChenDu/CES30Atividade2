CREATE TRIGGER OKL.OKL_trigger1
ON OKL.OKL_PRODUTO
AFTER INSERT, UPDATE
AS
DECLARE
    @inserted_qtd INT;
BEGIN
    SET @inserted_qtd = (SELECT i.QTD_ESTOQUE FROM inserted i)
    IF @inserted_qtd < 0
    BEGIN
        ROLLBACK;
        RAISERROR (N'Quantidade  %d menor que 0 (zero) não permitida.', -- Message text
        14, -- Severity
        1, -- State
        @inserted_qtd);
    END;
END;

-- Verificar trigger
SELECT * FROM sys.triggers
WHERE name LIKE 'OKL_%';

-- Testa trigger insert
INSERT INTO OKL.OKL_PRODUTO
VALUES (6, 'Um prod estragado', 10.0, -2);

SELECT * FROM OKL.OKL_PRODUTO;

-- Testa trigger update
UPDATE OKL.OKL_PRODUTO
SET QTD_ESTOQUE = -10
WHERE COD_PRODUTO = 3;

SELECT * FROM OKL.OKL_PRODUTO;

