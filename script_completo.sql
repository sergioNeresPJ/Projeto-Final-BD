DROP SCHEMA public CASCADE;
CREATE SCHEMA public; 

CREATE TABLE funcionario(
    cpf varchar(11) primary key,
    nome varchar(50) not null,
    salario double precision check (salario > 0) not null,
    data_contrato date not null -- trigger
);

CREATE TABLE pedido(
    id serial primary key,
    total double precision check (total>=0) default 0,
    forma_pgto varchar(15) check (forma_pgto in ('dinheiro', 'pix', 'cartao')) not null
);

CREATE TABLE prepara_pedido(
    id_pedido int REFERENCES pedido(id) not null,
    cpf_funcionario varchar(11) references funcionario(cpf) not null,
    
    constraint pk_funcped primary key (id_pedido, cpf_funcionario)
);

CREATE TABLE item_cardapio(
    nome varchar(50) primary key,
    ativo boolean not null,
    preco double precision check (preco>0) not null
);

CREATE TABLE pedido_item(
    nome_item varchar(50) references item_cardapio(nome) not null,
    id_pedido int references pedido(id) not null,
    
    constraint pk_peditem primary key (nome_item,id_pedido)
);

CREATE TABLE prato(
    nome_item varchar(50) references item_cardapio(nome) not null,
    tipo_prato varchar(15) check (tipo_prato in ('entrada', 'principal', 'sobremesa')) not null,
    
    constraint pk_prato primary key (nome_item)
);

CREATE TABLE bebida(
    nome_item varchar(50) references item_cardapio(nome) not null,
    tipo_bebida varchar(10) check (tipo_bebida in ('cerveja', 'suco', 'refri', 'agua')) not null,
    volume_ml int check (volume_ml > 0),
    data_compra date -- trigger
);

CREATE TABLE ingrediente(
    nome varchar(50) primary key,
    vegano boolean not null,
    data_compra date not null, --trigger
    data_validade date not null,
    quantidade int not null
);

CREATE TABLE ingrediente_prato(
    nome_item varchar(50) references item_cardapio(nome) not null,
    nome_ingrediente varchar(50) references prato(nome_item) not null,
    quantidade int not null,
    unidade_medida varchar(10) not null,
    
    constraint pk_ingredprato primary key (nome_item, nome_ingrediente) 
);
CREATE FUNCTION verifica_data_func()
RETURNS TRIGGER AS $$
BEGIN
	IF(new.data_contrato > CURRENT_DATE) THEN
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
	IF(new.data_compra > CURRENT_DATE) THEN
		RAISE EXCEPTION 'Data Invalida pois é posterior a data atual';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER data_bebida
BEFORE INSERT ON bebida
FOR EACH ROW
EXECUTE PROCEDURE verifica_data_compra();

CREATE TRIGGER data_ingrediente
BEFORE INSERT ON ingrediente
FOR EACH ROW
EXECUTE PROCEDURE verifica_data_compra();

CREATE FUNCTION update_qtd_ingrediente()
RETURNS TRIGGER AS $$
DECLARE
	quant int;
	string varchar(100);
BEGIN
	SELECT quantidade FROM ingrediente where nome like new.nome_ingrediente into quant;
	IF(quant < new.quantidade) THEN
		string := 'Impossivel preparar prato pois só ha '|| quant || ' de '||new.nome_ingrediente||' em estoque';
		RAISE EXCEPTION '%', string;
	ELSE
		UPDATE ingrediente i SET quantidade = quantidade - new.quantidade where i.nome like new.nome_ingrediente;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_ingrediente
BEFORE INSERT OR UPDATE ON ingrediente_prato
FOR EACH ROW
EXECUTE PROCEDURE update_qtd_ingrediente();



CREATE FUNCTION atualiza_total_pedido()
RETURNS TRIGGER AS $$
DECLARE
	valor int;
BEGIN
	SELECT preco FROM item_cardapio WHERE new.nome_item = nome INTO valor;

	IF(TG_OP = 'INSERT') THEN
		UPDATE pedido SET total = total + valor where id = new.id_pedido;
	ELSIF (TG_OP = 'DELETE') THEN
		UPDATE pedido SET total = total - valor where id = new.id_pedido;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER total_pedido
AFTER DELETE OR INSERT ON pedido_item
FOR EACH ROW
EXECUTE PROCEDURE atualiza_total_pedido();

CREATE OR REPLACE FUNCTION verifica_item_ativo()
RETURNS TRIGGER AS $$
DECLARE
	temp boolean;
BEGIN
	SELECT ativo FROM item_cardapio WHERE nome = new.nome_item INTO temp;
	IF(temp != true) THEN
		RAISE EXCEPTION 'Impossivel adicionar esse item ao pedido pois ele não está ativo no cardápio';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insercao_pedido
BEFORE INSERT ON pedido_item
FOR EACH ROW
EXECUTE PROCEDURE verifica_item_ativo();