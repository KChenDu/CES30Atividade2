CREATE PROCEDURE OKL.populate AS
BEGIN
    INSERT
    INTO OKL.OKL_PEDIDO
    VALUES
    (0, '95693152618', Null, Null), -- VIP
    (1, '50539992607', Null, Null), -- VIP
    (2, '48564804808', Null, Null),
    (3, '78379403932', Null, Null),
    (4, '78379403932', Null, Null);

    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (0, 0,  0, 6,    3.0,         1);
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (1, 0,  1, 10,   5.0,         3);
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (2, 0,  2, 73,   150.0,       3);
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (3, 1,  3, 2,    200.50,      0);
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (4, 1,  4, 1,    600000000.0, 4);
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (5, 3,  0, 270,  5.0,         1); -- Compra mais que o estoque
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (6, 3,  1, 293,  7.0,         4); -- Compra mais que o estoque
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (7, 4,  2, 250,  123.0,       0); -- Compra mais que o estoque
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (8, 4,  3, 20,   177.0,       2); -- Compra mais que o estoque
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (9, 4,  4, 3,    400000000.0, 1); -- Compra mais que o estoque
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (10, 1, 0, 4,    1.0,         4); -- Valor venda menor que preço base
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (11, 2, 1, 7,    2.99,        0); -- Valor venda menor que preço base
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (12, 2, 2, 34,   80.0,        1); -- Valor venda menor que preço base
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (13, 2, 3, 1,    100.0,       3); -- Valor venda menor que preço base
    INSERT INTO OKL.OKL_ITEM_PEDIDO VALUES (14, 3, 4, 1,    999.0,       4); -- Valor venda menor que preço base
END;

BEGIN EXEC OKL.populate end;

--Visualizar Tableas
SELECT * FROM OKL.OKL_CLIENTE;
SELECT * FROM OKL.OKL_PEDIDO;
SELECT * FROM OKL.OKL_ITEM_PEDIDO;

SELECT ip.COD_PRODUTO, VALOR_VENDA, PRECO_BASE
FROM OKL.OKL_ITEM_PEDIDO ip
INNER JOIN OKL.OKL_PRODUTO p
ON p.COD_PRODUTO = ip.COD_PRODUTO;