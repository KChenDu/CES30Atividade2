INSERT
INTO OKL.OKL_PRODUTO
VALUES
(0, 'Um prod espetacular', 2.0, 64),
(1, 'Um prod excelente', 3.0, 100),
(2, 'Um prod louco', 99.0, 200),
(3, 'Um prod bom', 128.0, 3),
(4, 'Um prod sensacional', 300000000.0, 0);

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

GO;

CREATE PROCEDURE OKL.populate AS
BEGIN
	INSERT
	INTO OKL.OKL_PEDIDO
	VALUES
	(0, '95693152618', Null, Null),
	(1, '50539992607', Null, Null),
	(2, '48564804808', Null, Null),
	(3, '78379403932', Null, Null),
	(4, '78379403932', Null, Null);
	INSERT
	INTO OKL.OKL_ITEM_PEDIDO
	VALUES
	(0, 0, 0, 6, 3.0, 1),
	(1, 0, 1, 10, 5.0, 3),
	(2, 0, 2, 73, 150.0, 3),
	(3, 1, 3, 2, 200.50, 0),
	(4, 1, 4, 0, 600000000.0, 4),
	(5, 3, 0, 60, 5.0, 1), -- Compra mais que o estoque
	(6, 3, 1, 93, 7.0, 4), -- Compra mais que o estoque
	(7, 4, 2, 150, 123.0, 0), -- Compra mais que o estoque
	(8, 4, 3, 2, 177.0, 2), -- Compra mais que o estoque
	(9, 4, 4, 1, 400000000.0, 1), -- Compra mais que o estoque
	(10, 1, 0, 4, 1.0, 4), -- Valor venda menor que preço base
	(11, 2, 1, 7, 2.99, 0), -- Valor venda menor que preço base
	(12, 2, 2, 34, 80.0, 1), -- Valor venda menor que preço base
	(13, 2, 3, 1, 100.0, 3), -- Valor venda menor que preço base
	(14, 3, 4, 0, 999.0, 4); -- Valor venda menor que preço base
END;


--Visualizar Tableas
SELECT * FROM OKL.OKL_CLIENTE;
SELECT * FROM OKL.OKL_PEDIDO;