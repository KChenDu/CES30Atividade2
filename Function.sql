SELECT * FROM OKL.OKL_ITEM_PEDIDO;
SELECT * FROM OKL.OKL_PRODUTO;
SELECT * FROM OKL.OKL_CLIENTE;
SELECT * FROM OKL.OKL_VENDEDOR;
SELECT * FROM OKL.OKL_PEDIDO;

INSERT
INTO OKL.OKL_PEDIDO
VALUES
(53, 43032367646, NULL, NULL),
(78, 50539992607, NULL, NULL);

UPDATE OKL.OKL_PRODUTO
SET QTD_ESTOQUE = 1
WHERE COD_PRODUTO = 4;

INSERT
INTO OKL.OKL_ITEM_PEDIDO
VALUES
(44, 53, 4, 1, 300000001, 2);
INSERT
INTO OKL.OKL_ITEM_PEDIDO
VALUES
(97, 78, 2, 13, 101, 1);