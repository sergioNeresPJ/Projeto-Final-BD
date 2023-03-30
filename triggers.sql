CREATE FUNCTION verifica_data_func()
RETURNS TRIGGER AS $$
BEGIN
	IF(new.data_contrato < CURRENT_DATE) THEN
		RAISE EXCEPTION 'Data Invalida pois é posterior a data atual';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER data_funcionario
BEFORE INSERT ON funcionario
FOR EACH ROW
EXECUTE PROCEDURE verifica_data_func();


CREATE FUNCTION verifica_data_compra()
RETURNS TRIGGER AS $$
BEGIN
	IF(new.data_compra < CURRENT_DATE) THEN
		RAISE EXCEPTION 'Data Invalida pois é posterior a data atual';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER data_bebida
BEFORE INSERT ON bebida
FOR EACH ROW
EXECUTE PROCEDURE verifica_data_compra();

CREATE TRIGGER data_igrediente
BEFORE INSERT ON ingrediente
FOR EACH ROW
EXECUTE PROCEDURE verifica_data_compra();

CREATE FUNCTION update_qtd_igrediente()
RETURNS TRIGGER AS $$
DECLARE
	quant int;
	string varchar(100);
BEGIN
	SELECT quantidade FROM igrediente where nome like new.nome_igrediente into quant;
	IF(quant < new.quantidade) THEN
		string := 'Impossivel preparar prato pois só ha '|| quant || ' de '||new.nome_igrediente||' em estoque';
		RAISE EXCEPTION '%', string;
	ELSE
		UPDATE igrediente i SET i.quantidade = i.quantidade - new.quantidade where i.nome like new.nome_igrediente;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_igrediente
BEFORE INSERT OR UPDATE ON igrediente_prato
FOR EACH ROW
EXECUTE PROCEDURE update_qtd_igrediente();