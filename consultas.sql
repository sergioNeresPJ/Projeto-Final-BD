-- Consulta 1
SELECT * FROM item_cardapio WHERE preco > 35;

-- Consulta 2
SELECT avg(salario) AS "media salarial" FROM funcionario;

-- Consulta 3
SELECT * FROM pedido_item p
INNER JOIN ingrediente_prato i ON p.nome_item = i.nome_item
WHERE nome_ingrediente = 'Ovo';

-- Consulta 4
SELECT avg(preco) AS "media de preco das entradas" FROM item_cardapio 
INNER JOIN prato ON nome = nome_item WHERE tipo_prato = 'entrada';

-- Consulta 5
SELECT nome_ingrediente, count(*) quant FROM ingrediente_prato
GROUP BY nome_ingrediente
LIMIT 1;

-- Consulta 6