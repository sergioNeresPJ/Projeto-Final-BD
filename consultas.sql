-- Consulta 1
SELECT * FROM item_cardapio WHERE preco > 35;

-- Consulta 2
SELECT avg(salario) AS "media salarial" FROM funcionario;

-- Consulta 3
SELECT p.id_pedido, i.nome_item FROM pedido_item p
INNER JOIN ingrediente_prato i ON p.nome_item = i.nome_item
WHERE nome_ingrediente = 'Ovo';

-- Consulta 4
SELECT nome_ingrediente, max(quant) 
FROM (
    SELECT nome_ingrediente, count(*) as quant 
    FROM ingrediente_prato 
    GROUP BY nome_ingrediente
) t1
WHERE quant = (
    SELECT count(*) as quant 
    FROM ingrediente_prato 
    GROUP BY nome_ingrediente
    ORDER BY quant desc
    limit 1
) 
GROUP BY nome_ingrediente;

-- Consulta 5
SELECT nome FROM funcionario 
INNER JOIN prepara_pedido ON cpf = cpf_funcionario
INNER JOIN pedido ON id = id_pedido
WHERE total = (SELECT max(total) FROM pedido);

-- Consulta 6
SELECT tipo_prato, count(*) quant FROM pedido_item NATURAL JOIN prato
GROUP BY tipo_prato
ORDER BY quant DESC
LIMIT 1;