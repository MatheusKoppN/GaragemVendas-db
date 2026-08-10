-- 1. CONFIGURAÇÃO DE SEGURANÇA (ROLES)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'papel_gerente') THEN
        CREATE ROLE papel_gerente;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'papel_vendedor') THEN
        CREATE ROLE papel_vendedor;
    END IF;
END $$;

-- 2. ESTRUTURA DAS TABELAS (DDL)
CREATE TABLE IF NOT EXISTS marcas (
    id_marca SERIAL PRIMARY KEY,
    nome_marca VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS status_veiculos (
    id_status SERIAL PRIMARY KEY,
    descricao VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    contato VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS funcionarios (
    id_funcionario SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    id_gerente INTEGER REFERENCES funcionarios(id_funcionario)
);

CREATE TABLE IF NOT EXISTS carros (
    id_carro SERIAL PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    ano INTEGER,
    preco NUMERIC(10,2) CHECK (preco >= 0),
    id_marca INTEGER REFERENCES marcas(id_marca),
    id_status INTEGER REFERENCES status_veiculos(id_status)
);

CREATE TABLE IF NOT EXISTS vendas (
    id_venda SERIAL PRIMARY KEY,
    id_carro INTEGER NOT NULL REFERENCES carros(id_carro),
    id_cliente INTEGER NOT NULL REFERENCES clientes(id_cliente),
    data_venda DATE DEFAULT CURRENT_DATE,
    valor_final NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS log_precos (
    id_log SERIAL PRIMARY KEY,
    id_carro INTEGER,
    valor_antigo NUMERIC(10,2),
    valor_novo NUMERIC(10,2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario_db VARCHAR(50)
);

-- 3. POVOAMENTO DE DADOS (DML) - 20 CARROS E 10 VENDAS
INSERT INTO marcas (nome_marca) VALUES 
('Honda'), ('Toyota'), ('Ford'), ('Volkswagen'), ('Mercedes-Benz'), ('BMW'), ('Audi'), ('Fiat'), ('Chevrolet') 
ON CONFLICT DO NOTHING;

INSERT INTO status_veiculos (descricao) VALUES ('Disponível'), ('Vendido'), ('Reservado') ON CONFLICT DO NOTHING;

INSERT INTO clientes (nome, contato) VALUES 
('Ricardo Silva', '11 98888-8888'), ('Juliana Costa', '21 97777-7777'), ('Carlos Souza', '31 96666-5555'), 
('Fernanda Lima', '11 91111-2222'), ('Marcos Oliveira', '21 93333-4444'), ('Beatriz Santos', '31 95555-6666'), 
('Paulo Mendes', '41 97777-8888'), ('Amanda Rocha', '11 92222-3333'), ('Bruno Ferreira', '21 94444-5555'), 
('Camila Lima', '31 96666-7777') ON CONFLICT DO NOTHING;

INSERT INTO funcionarios (nome, id_gerente) VALUES ('Matheus Kopp', NULL); -- Gerente Geral
INSERT INTO funcionarios (nome, id_gerente) VALUES ('Thiago Mendes', 1), ('Beatriz Silva', 1);

INSERT INTO carros (modelo, ano, preco, id_marca, id_status) VALUES 
('Civic', 2022, 130000, 1, 1), ('Corolla', 2023, 145000, 2, 1), ('Mustang', 2021, 320000, 3, 1),
('Golf', 2020, 180000, 4, 1), ('C180', 2021, 185000, 5, 1), ('320i', 2023, 290000, 6, 1),
('A3', 2020, 145000, 7, 1), ('Uno', 2015, 35000, 8, 1), ('Onix', 2023, 85000, 9, 1),
('HB20', 2024, 92000, 2, 1), ('Compass', 2022, 180000, 3, 1), ('Kicks', 2023, 115000, 1, 1),
('XC60', 2021, 350000, 6, 1), ('Cruze', 2022, 125000, 9, 1), ('Creta', 2023, 140000, 2, 1),
('Renegade', 2021, 105000, 3, 1), ('Sentra', 2024, 155000, 1, 1), ('GLA 200', 2023, 295000, 5, 1),
('911 Carrera', 2024, 950000, 6, 1), ('Range Rover', 2023, 380000, 7, 1);

INSERT INTO vendas (id_carro, id_cliente, valor_final, data_venda) VALUES 
(1, 1, 128000, '2026-08-01'), (2, 2, 145000, '2026-08-02'), (3, 3, 315000, '2026-08-03'),
(4, 4, 178000, '2026-08-04'), (5, 5, 185000, '2026-08-05'), (6, 6, 285000, '2026-08-06'),
(7, 7, 140000, '2026-08-07'), (8, 8, 32000, '2026-08-08'), (9, 9, 83000, '2026-08-09'),
(10, 10, 90000, '2026-08-10');

-- 4. AUTOMAÇÃO: TRIGGER DE AUDITORIA
CREATE OR REPLACE FUNCTION fn_log_preco_carro() 
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN 
    IF OLD.preco <> NEW.preco THEN 
        INSERT INTO log_precos (id_carro, valor_antigo, valor_novo, usuario_db) 
        VALUES (OLD.id_carro, OLD.preco, NEW.preco, CURRENT_USER); 
    END IF; 
    RETURN NEW; 
END; $$;

CREATE TRIGGER trg_auditoria_preco 
AFTER UPDATE ON carros FOR EACH ROW 
EXECUTE FUNCTION fn_log_preco_carro();

-- 5. PROCEDURES DE VENDAS
CREATE OR REPLACE PROCEDURE sp_registrar_venda_segura(p_id_carro INT, p_id_cliente INTEGER, p_valor_venda NUMERIC) 
LANGUAGE plpgsql AS $$
BEGIN 
    INSERT INTO vendas (id_carro, id_cliente, valor_final, data_venda) 
    VALUES (p_id_carro, p_id_cliente, p_valor_venda, CURRENT_DATE);
    
    UPDATE carros SET id_status = 2 WHERE id_carro = p_id_carro;
EXCEPTION WHEN OTHERS THEN 
    RAISE EXCEPTION 'Erro crítico: %. Venda abortada para integridade.', SQLERRM; 
END; $$;

-- 6. PERMISSÕES
GRANT SELECT ON ALL TABLES IN SCHEMA public TO papel_vendedor;
GRANT ALL ON ALL TABLES IN SCHEMA public TO papel_gerente;