-- Consulta 1 (Qual a média salarial dos funcionários do restaurante?)
SELECT avg(salario) AS "media salarial" FROM funcionario;

-- Consulta 2 (Listar todos os identificadores dos pedidos que possuem itens com o ingrediente ovo)
SELECT p.id_pedido, i.nome_item FROM pedido_item p
INNER JOIN ingrediente_prato i ON p.nome_item = i.nome_item
WHERE nome_ingrediente = 'Ovo';

-- Consulta 3 (Qual a média do preço das entradas?)
SELECT avg(preco) AS "media de preco das entradas" FROM item_cardapio 
INNER JOIN prato ON nome = nome_item WHERE tipo_prato = 'entrada';

-- Consulta 4 (Qual(is) o(s) ingrediente(s) que é(são) mais utilizado(s) para compor os pratos?)
SELECT nome_ingrediente, max(quant)
FROM ( 
    -- Seleciona todos os ingredientes que aparecem nos pratos e a quantidade respectiva.
    SELECT nome_ingrediente, count(*) as quant 
    FROM ingrediente_prato 
    GROUP BY nome_ingrediente
) t1
WHERE quant = ( -- Filtra para exibir apenas os ingredientes que aparecem a quantidade maxima. 
    -- Conta qual o ingrediente que mais aparece.
    SELECT count(*) as quant 
    FROM ingrediente_prato 
    GROUP BY nome_ingrediente
    ORDER BY quant desc
    limit 1
) 
GROUP BY nome_ingrediente;

-- Consulta 5 (Listar o nome dos funcionários que prepararam o pedido mais caro)
SELECT nome FROM funcionario 
INNER JOIN prepara_pedido ON cpf = cpf_funcionario
INNER JOIN pedido ON id = id_pedido
WHERE total = (SELECT max(total) FROM pedido)

-- Consulta 6 (Qual o tipo de prato mais vendido no restaurante?)
SELECT tipo_prato FROM pedido_item
NATURAL JOIN prato
GROUP BY tipo_prato
HAVING COUNT(*) = (
	SELECT MAX(qtd) FROM ( -- Pega a quantidade mais pedida.
		-- Seleciona a quantidade que cada tipo_prato foi pedido.
		SELECT count(*) qtd FROM pedido_item 
		NATURAL JOIN prato
		GROUP BY tipo_prato
) as QTD_TIPOS);
