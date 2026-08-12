DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'papel_gerente') THEN
        CREATE ROLE papel_gerente;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'papel_vendedor') THEN
        CREATE ROLE papel_vendedor;
    END IF;
END $$;
 
CREATE TABLE IF NOT EXISTS marcas (id_marca SERIAL PRIMARY KEY, nome_marca VARCHAR(50) NOT NULL UNIQUE);
CREATE TABLE IF NOT EXISTS status_veiculos (id_status SERIAL PRIMARY KEY, descricao VARCHAR(20) NOT NULL UNIQUE);
CREATE TABLE IF NOT EXISTS clientes (id_cliente SERIAL PRIMARY KEY, nome VARCHAR(100) NOT NULL, contato VARCHAR(50));
CREATE TABLE IF NOT EXISTS funcionarios (id_funcionario SERIAL PRIMARY KEY, nome VARCHAR(100) NOT NULL, id_gerente INTEGER REFERENCES funcionarios(id_funcionario));
CREATE TABLE IF NOT EXISTS carros (id_carro SERIAL PRIMARY KEY, modelo VARCHAR(50) NOT NULL, ano INTEGER, preco NUMERIC(10,2) CHECK (preco >= 0), id_marca INTEGER REFERENCES marcas(id_marca), id_status INTEGER REFERENCES status_veiculos(id_status));
CREATE TABLE IF NOT EXISTS vendas (id_venda SERIAL PRIMARY KEY, id_carro INTEGER NOT NULL REFERENCES carros(id_carro), id_cliente INTEGER NOT NULL REFERENCES clientes(id_cliente), data_venda DATE DEFAULT CURRENT_DATE, valor_final NUMERIC(10,2));
CREATE TABLE IF NOT EXISTS log_precos (id_log SERIAL PRIMARY KEY, id_carro INTEGER, valor_antigo NUMERIC(10,2), valor_novo NUMERIC(10,2), data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP, usuario_db VARCHAR(50));

INSERT INTO marcas (id_marca, nome_marca) VALUES (1,'Honda'), (2,'Toyota'), (3,'Ford'), (4,'Volkswagen'), (5,'Mercedes'), (6,'BMW'), (7,'Audi'), (8,'Fiat'), (9,'Chevrolet'), (10,'Porsche'), (11,'Land Rover'), (12,'Hyundai') ON CONFLICT DO NOTHING;
INSERT INTO status_veiculos (id_status, descricao) VALUES (1,'Disponível'), (2,'Vendido'), (3,'Reservado') ON CONFLICT DO NOTHING;

INSERT INTO clientes (nome, contato) VALUES ('Ricardo Silva', '11 98888-8888'), ('Juliana Costa', '21 97777-7777'), ('Carlos Souza', '31 96666-5555'), ('Fernanda Lima', '11 91111-2222'), ('Marcos Oliveira', '21 93333-4444'), ('Beatriz Santos', '31 95555-6666'), ('Paulo Mendes', '41 97777-8888'), ('Amanda Rocha', '11 92222-3333'), ('Bruno Ferreira', '21 94444-5555'), ('Camila Lima', '31 96666-7777') ON CONFLICT DO NOTHING;

INSERT INTO funcionarios (id_funcionario, nome, id_gerente) VALUES (1, 'Matheus Kopp', NULL), (2, 'Thiago Mendes', 1), (3, 'Beatriz Silva', 1) ON CONFLICT DO NOTHING;

INSERT INTO carros (id_carro, modelo, ano, preco, id_marca, id_status) VALUES 
(1,'Civic', 2022, 130000, 1, 2), (2,'Corolla', 2023, 145000, 2, 2), (3,'Mustang', 2021, 320000, 3, 2), (4,'Golf', 2020, 180000, 4, 2), (5,'C180', 2021, 185000, 5, 2), (6,'320i', 2023, 290000, 6, 2), (7,'A3', 2020, 145000, 7, 2), (8,'Uno', 2015, 35000, 8, 2), (9,'Onix', 2023, 85000, 9, 2), (10,'HB20', 2024, 92000, 12, 2),
(11,'911 Carrera', 2024, 950000, 10, 1), (12,'Range Rover', 2023, 380000, 11, 1), (13,'Creta', 2023, 140000, 12, 1), (14,'Sentra', 2024, 155000, 1, 1), (15,'GLA 200', 2023, 295000, 5, 1), (16,'Compass', 2022, 180000, 3, 1), (17,'Kicks', 2023, 115000, 1, 1), (18,'XC60', 2021, 350000, 6, 1), (19,'Cruze', 2022, 125000, 9, 1), (20,'Renegade', 2021, 105000, 3, 1) ON CONFLICT DO NOTHING;

INSERT INTO vendas (id_carro, id_cliente, valor_final) VALUES (1, 1, 128000), (2, 2, 145000), (3, 3, 320000), (4, 4, 178000), (5, 5, 185000), (6, 6, 285000), (7, 7, 140000), (8, 8, 32000), (9, 9, 83000), (10, 10, 90000) ON CONFLICT DO NOTHING;

CREATE OR REPLACE VIEW vw_relatorio_vendas AS
SELECT v.id_venda, c.modelo, cl.nome AS cliente, v.data_venda, v.valor_final
FROM vendas v
JOIN carros c ON v.id_carro = c.id_carro
JOIN clientes cl ON v.id_cliente = cl.id_cliente;
 
CREATE OR REPLACE FUNCTION fn_log_preco_carro() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN 
    IF OLD.preco <> NEW.preco THEN 
        INSERT INTO log_precos (id_carro, valor_antigo, valor_novo, usuario_db) VALUES (OLD.id_carro, OLD.preco, NEW.preco, CURRENT_USER); 
    END IF; RETURN NEW; 
END; $$;

CREATE OR REPLACE TRIGGER trg_auditoria_preco AFTER UPDATE ON carros FOR EACH ROW EXECUTE FUNCTION fn_log_preco_carro();

CREATE OR REPLACE PROCEDURE sp_registrar_venda_segura(p_id_carro INT, p_id_cliente INT, p_valor NUMERIC) LANGUAGE plpgsql AS $$
BEGIN 
    INSERT INTO vendas (id_carro, id_cliente, valor_final) VALUES (p_id_carro, p_id_cliente, p_valor);
    UPDATE carros SET id_status = 2 WHERE id_carro = p_id_carro;
EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Erro: %. Transação abortada.', SQLERRM; END; $$;

GRANT SELECT ON marcas, status_veiculos, carros, vw_relatorio_vendas TO papel_vendedor;
GRANT INSERT ON vendas, clientes TO papel_vendedor;
GRANT ALL ON ALL TABLES IN SCHEMA public TO papel_gerente;
