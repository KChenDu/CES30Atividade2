--DROP ALL
DROP TABLE OKL.OKL_ITEM_PEDIDO;
DROP TABLE OKL.OKL_PRODUTO;
DROP TABLE OKL.OKL_VENDEDOR;
DROP TABLE OKL.OKL_PEDIDO;
DROP TABLE OKL.OKL_CLIENTE;

--CREATE TABLES
CREATE TABLE OKL.OKL_CLIENTE
(CPF CHAR(11) PRIMARY KEY,
NOME VARCHAR(64),
ENDERECO VARCHAR(128),
FONE_CLIENTE CHAR(11));

CREATE TABLE OKL.OKL_VENDEDOR
(COD_VENDEDOR INT PRIMARY KEY,
NOME_VENDEDOR VARCHAR(64));

CREATE TABLE OKL.OKL_PEDIDO(
    NUMERO_PEDIDO INT PRIMARY KEY,
    CPF CHAR(11),
    DATA_PEDIDO DATE,
    DATA_ENTREGA DATE,
    FOREIGN KEY (CPF) REFERENCES OKL.OKL_CLIENTE(CPF)
);

CREATE TABLE OKL.OKL_ITEM_PEDIDO
(NUMERO_ITEM INT PRIMARY KEY,
NUMERO_PEDIDO INT,
COD_PRODUTO INT,
QTD_VENDIDA INT,
VALOR_VENDA REAL,
COD_VENDEDOR INT,
FOREIGN KEY(NUMERO_PEDIDO) REFERENCES OKL.OKL_PEDIDO(NUMERO_PEDIDO),
FOREIGN KEY(COD_VENDEDOR) REFERENCES OKL.OKL_VENDEDOR(COD_VENDEDOR));

CREATE TABLE OKL.OKL_PRODUTO(
    COD_PRODUTO INT PRIMARY KEY,
    DESCRICAO_PRODUTO VARCHAR(128),
    PRECO_BASE REAL,
    QTD_ESTOQUE INT,
);

ALTER TABLE OKL.OKL_ITEM_PEDIDO
ADD CONSTRAINT ITEM_PRODUTO_PRODUTO_FK FOREIGN KEY(COD_PRODUTO) REFERENCES OKL.OKL_PRODUTO(COD_PRODUTO);

--Populate all
INSERT
INTO OKL.OKL_PRODUTO
VALUES
(0, 'Um prod espetacular', 2.0, 200),
(1, 'Um prod excelente', 3.0, 200),
(2, 'Um prod louco', 99.0, 200),
(3, 'Um prod bom', 128.0, 10),
(4, 'Um prod sensacional', 300000000.0, 1);

INSERT INTO OKL.OKL_CLIENTE
VALUES
    ('95693152618', 'Bruna Isabelle Daiane Caldeira', 'Rua OP-IX', '95985783637'),
    ('50539992607', 'André Juan Araújo', 'Travessa Benjamin Constant', '79981253309'),
    ('48564804808', 'Diego Matheus Barbosa', 'Rua Severino Francisco dos Santos', '83998001344'),
    ('78379403932', 'Marlene Rayssa Gomes', 'Rua Ademar José Demate Filho', '47988993243'),
    ('43032367646', 'Elaine Letícia Alessandra da Cunha', 'Rua José de Assis Régis', '83992678421');

INSERT INTO OKL.OKL_VENDEDOR
VALUES
    (0, 'Edson Marcelo Pietro das Neves'),
    (1, 'Flávia Liz da Luz'),
    (2, 'Antonio Alexandre Theo Castro'),
    (3, 'Raquel Vitória Novaes'),
    (4, 'Benício Caio Nascimento');

-- Triggers
COMMIT;
GO;
CREATE TRIGGER OKL.OKL_trigger_qtd_prod
ON OKL.OKL_PRODUTO
AFTER INSERT, UPDATE
AS
DECLARE
    @inserted_qtd INT;
BEGIN
    --SET @inserted_qtd = (SELECT i.QTD_ESTOQUE FROM inserted i)
	DECLARE iterator CURSOR
	FOR SELECT i.QTD_ESTOQUE FROM inserted i;
	-- Abrir o cursor
	OPEN iterator;
	FETCH NEXT FROM iterator INTO @inserted_qtd;

	WHILE @@FETCH_STATUS = 0
	BEGIN
	IF @inserted_qtd < 0
    BEGIN
        ROLLBACK;
        RAISERROR (N'Quantidade  %d menor que 0 (zero) não permitida.', -- Message text
        14, -- Severity
        1, -- State
        @inserted_qtd);
    END;
	FETCH NEXT FROM iterator INTO @inserted_qtd;
	END;
	CLOSE iterator;
	DEALLOCATE iterator;
END;

COMMIT;
GO;

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

COMMIT;
GO;

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

COMMIT;
GO;

CREATE TRIGGER OKL.OKL_trigger_preco_base
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
        SET @valor_venda = (
            SELECT VALOR_VENDA FROM OKL.OKL_ITEM_PEDIDO
            WHERE COD_PRODUTO = @cod_produto
        );
        IF @valor_venda < @inserted_preco_base
        BEGIN
            SET @char_valor_venda = CONVERT(varchar(10), @valor_venda);
            SET @char_preco_base = CONVERT(varchar(10), @inserted_preco_base); 
            ROLLBACK;
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

COMMIT;
GO;