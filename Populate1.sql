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

-- Verifica adições:
SELECT * FROM OKL.OKL_PRODUTO;
SELECT * FROM OKL.OKL_CLIENTE;
SELECT * FROM OKL.OKL_VENDEDOR;