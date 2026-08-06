--
-- PostgreSQL database dump
--

\restrict 8NsGv6bpQplaBZrdUjTzsGngbYUkJcGHek9RHyDcNrdpg9RFLvtFhtNnbGye5uB

-- Dumped from database version 18.4 (Postgres.app)
-- Dumped by pg_dump version 18.4 (Postgres.app)

-- Started on 2026-08-05 22:24:53 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 16502)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 16597)
-- Name: fn_log_preco_carro(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_log_preco_carro() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Só registra se o preço realmente mudou
    IF OLD.preco <> NEW.preco THEN
        INSERT INTO log_precos (id_carro, valor_antigo, valor_novo, usuario_db)
        VALUES (OLD.id_carro, OLD.preco, NEW.preco, CURRENT_USER);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_log_preco_carro() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 16565)
-- Name: fn_resumo_financeiro_vendas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_resumo_financeiro_vendas() RETURNS TABLE(total_vendas bigint, faturamento_total numeric, media_por_venda numeric, venda_mais_cara numeric, venda_mais_barata numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(id_venda),
        SUM(valor_final),
        AVG(valor_final),
        MAX(valor_final),
        MIN(valor_final)
    FROM vendas;
END;
$$;


ALTER FUNCTION public.fn_resumo_financeiro_vendas() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 16564)
-- Name: sp_registrar_venda(integer, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_registrar_venda(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Registra a venda
    INSERT INTO vendas (id_carro, id_cliente, valor_final, data_venda)
    VALUES (p_id_carro, p_id_cliente, p_valor_venda, CURRENT_DATE);

    -- Atualiza o status do carro para 'Vendido' (ID 2)
    UPDATE carros SET id_status = 2 WHERE id_carro = p_id_carro;

    RAISE NOTICE 'Venda concluída e status do veículo atualizado.';
END;
$$;


ALTER PROCEDURE public.sp_registrar_venda(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 16599)
-- Name: sp_registrar_venda_segura(integer, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_registrar_venda_segura(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Início do bloco de transação protegida
    -- Passo 1: Inserir a venda
    INSERT INTO vendas (id_carro, id_cliente, valor_final, data_venda)
    VALUES (p_id_carro, p_id_cliente, p_valor_venda, CURRENT_DATE);

    -- Passo 2: Mudar status para 'Vendido' (ID 2)
    UPDATE carros SET id_status = 2 WHERE id_carro = p_id_carro;

    RAISE NOTICE 'Venda concluída e status atualizado com sucesso.';

EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de qualquer erro, as alterações acima são descartadas (ROLLBACK)
        RAISE EXCEPTION 'Erro crítico na transação: %. Venda não realizada.', SQLERRM;
END;
$$;


ALTER PROCEDURE public.sp_registrar_venda_segura(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16524)
-- Name: carros; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carros (
    id_carro integer NOT NULL,
    modelo character varying(50) NOT NULL,
    ano integer,
    preco numeric(10,2),
    id_marca integer NOT NULL,
    id_status integer NOT NULL,
    CONSTRAINT carros_preco_check CHECK ((preco >= (0)::numeric))
);


ALTER TABLE public.carros OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16523)
-- Name: carros_id_carro_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carros_id_carro_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carros_id_carro_seq OWNER TO postgres;

--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 223
-- Name: carros_id_carro_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carros_id_carro_seq OWNED BY public.carros.id_carro;


--
-- TOC entry 222 (class 1259 OID 16515)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id_cliente integer NOT NULL,
    nome character varying(100) NOT NULL,
    contato character varying(50)
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16514)
-- Name: clientes_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_cliente_seq OWNER TO postgres;

--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 221
-- Name: clientes_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;


--
-- TOC entry 234 (class 1259 OID 16602)
-- Name: funcionarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.funcionarios (
    id_funcionario integer NOT NULL,
    nome character varying(100) NOT NULL,
    id_gerente integer
);


ALTER TABLE public.funcionarios OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16601)
-- Name: funcionarios_id_funcionario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.funcionarios_id_funcionario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.funcionarios_id_funcionario_seq OWNER TO postgres;

--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 233
-- Name: funcionarios_id_funcionario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.funcionarios_id_funcionario_seq OWNED BY public.funcionarios.id_funcionario;


--
-- TOC entry 232 (class 1259 OID 16589)
-- Name: log_precos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.log_precos (
    id_log integer NOT NULL,
    id_carro integer,
    valor_antigo numeric(10,2),
    valor_novo numeric(10,2),
    data_alteracao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    usuario_db character varying(50)
);


ALTER TABLE public.log_precos OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16588)
-- Name: log_precos_id_log_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.log_precos_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_precos_id_log_seq OWNER TO postgres;

--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 231
-- Name: log_precos_id_log_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.log_precos_id_log_seq OWNED BY public.log_precos.id_log;


--
-- TOC entry 220 (class 1259 OID 16504)
-- Name: marcas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marcas (
    id_marca integer NOT NULL,
    nome_marca character varying(50) NOT NULL
);


ALTER TABLE public.marcas OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16503)
-- Name: marcas_id_marca_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.marcas_id_marca_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.marcas_id_marca_seq OWNER TO postgres;

--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 219
-- Name: marcas_id_marca_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.marcas_id_marca_seq OWNED BY public.marcas.id_marca;


--
-- TOC entry 229 (class 1259 OID 16567)
-- Name: status_veiculos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_veiculos (
    id_status integer NOT NULL,
    descricao character varying(20) NOT NULL
);


ALTER TABLE public.status_veiculos OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16566)
-- Name: status_veiculos_id_status_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.status_veiculos_id_status_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.status_veiculos_id_status_seq OWNER TO postgres;

--
-- TOC entry 3934 (class 0 OID 0)
-- Dependencies: 228
-- Name: status_veiculos_id_status_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.status_veiculos_id_status_seq OWNED BY public.status_veiculos.id_status;


--
-- TOC entry 226 (class 1259 OID 16540)
-- Name: vendas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendas (
    id_venda integer NOT NULL,
    id_carro integer NOT NULL,
    id_cliente integer NOT NULL,
    data_venda date DEFAULT CURRENT_DATE,
    valor_final numeric(10,2)
);


ALTER TABLE public.vendas OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16539)
-- Name: vendas_id_venda_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vendas_id_venda_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vendas_id_venda_seq OWNER TO postgres;

--
-- TOC entry 3937 (class 0 OID 0)
-- Dependencies: 225
-- Name: vendas_id_venda_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vendas_id_venda_seq OWNED BY public.vendas.id_venda;


--
-- TOC entry 230 (class 1259 OID 16583)
-- Name: vw_estoque_disponivel; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_estoque_disponivel AS
 SELECT c.modelo,
    m.nome_marca AS marca,
    c.preco,
    s.descricao AS status_atual
   FROM ((public.carros c
     JOIN public.marcas m ON ((c.id_marca = m.id_marca)))
     JOIN public.status_veiculos s ON ((c.id_status = s.id_status)))
  WHERE (c.id_status = 1);


ALTER VIEW public.vw_estoque_disponivel OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16560)
-- Name: vw_relatorio_vendas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_relatorio_vendas AS
 SELECT cl.nome AS cliente,
    c.modelo AS veiculo,
    v.valor_final AS valor,
    v.data_venda AS data_compra
   FROM ((public.vendas v
     JOIN public.clientes cl ON ((v.id_cliente = cl.id_cliente)))
     JOIN public.carros c ON ((v.id_carro = c.id_carro)));


ALTER VIEW public.vw_relatorio_vendas OWNER TO postgres;

--
-- TOC entry 3714 (class 2604 OID 16527)
-- Name: carros id_carro; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carros ALTER COLUMN id_carro SET DEFAULT nextval('public.carros_id_carro_seq'::regclass);


--
-- TOC entry 3713 (class 2604 OID 16518)
-- Name: clientes id_cliente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);


--
-- TOC entry 3720 (class 2604 OID 16605)
-- Name: funcionarios id_funcionario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios ALTER COLUMN id_funcionario SET DEFAULT nextval('public.funcionarios_id_funcionario_seq'::regclass);


--
-- TOC entry 3718 (class 2604 OID 16592)
-- Name: log_precos id_log; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_precos ALTER COLUMN id_log SET DEFAULT nextval('public.log_precos_id_log_seq'::regclass);


--
-- TOC entry 3712 (class 2604 OID 16507)
-- Name: marcas id_marca; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas ALTER COLUMN id_marca SET DEFAULT nextval('public.marcas_id_marca_seq'::regclass);


--
-- TOC entry 3717 (class 2604 OID 16570)
-- Name: status_veiculos id_status; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_veiculos ALTER COLUMN id_status SET DEFAULT nextval('public.status_veiculos_id_status_seq'::regclass);


--
-- TOC entry 3715 (class 2604 OID 16543)
-- Name: vendas id_venda; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas ALTER COLUMN id_venda SET DEFAULT nextval('public.vendas_id_venda_seq'::regclass);


--
-- TOC entry 3901 (class 0 OID 16524)
-- Dependencies: 224
-- Data for Name: carros; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carros (id_carro, modelo, ano, preco, id_marca, id_status) FROM stdin;
7	A3	2020	145000.00	7	1
9	M3	2022	580000.00	6	1
10	Onix	2023	85000.00	9	1
24	GLA 200	2023	295000.00	5	1
1	Civic	2022	130000.00	1	2
2	Corolla	2023	145000.00	2	2
3	Mustang	2021	320000.00	3	2
4	Golf	2020	180000.00	4	2
5	C180	2021	185000.00	5	2
6	320i	2023	290000.00	6	2
8	Uno	2015	35000.00	8	2
11	HB20	2024	92000.00	10	2
12	Compass	2022	180000.00	11	2
13	Kicks	2023	115000.00	12	2
14	XC60	2021	350000.00	13	2
15	Cruze	2022	125000.00	9	2
16	Creta	2023	140000.00	10	2
17	Renegade	2021	105000.00	11	2
18	Sentra	2024	155000.00	12	2
25	911 Carrera	2024	950000.00	14	1
26	Range Rover Evoque	2023	380000.00	15	1
31	Cayenne	2023	720000.00	14	1
32	Defender	2024	650000.00	15	1
33	Civic Type R	2023	430000.00	1	1
34	Corolla Cross	2024	195000.00	2	1
35	Mustang Mach-E	2023	450000.00	3	1
36	Golf GTI	2022	280000.00	4	1
37	EQE 300	2024	680000.00	5	1
38	M4 Competition	2023	790000.00	6	1
39	RS6 Avant	2024	1150000.00	7	1
19	S60	2022	280000.00	13	2
20	City	2023	118000.00	1	2
21	Yaris	2024	98000.00	2	2
22	Territory	2023	210000.00	3	2
23	Polo	2022	95000.00	4	2
27	Model 3	2024	320000.00	16	2
28	L200 Triton	2022	210000.00	17	2
29	Kwid	2023	65000.00	18	2
30	Duster	2024	115000.00	18	2
\.


--
-- TOC entry 3899 (class 0 OID 16515)
-- Dependencies: 222
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id_cliente, nome, contato) FROM stdin;
1	Ricardo Silva	11 98888-8888
2	Juliana Costa	21 97777-7777
3	Carlos Souza	31 96666-5555
4	Fernanda Lima	11 91111-2222
5	Marcos Oliveira	21 93333-4444
6	Beatriz Santos	31 95555-6666
7	Paulo Mendes	41 97777-8888
8	Amanda Rocha	11 92222-3333
9	Bruno Ferreira	21 94444-5555
10	Camila Lima	31 96666-7777
11	Diego Souza	41 98888-9999
12	Elena Martins	11 90000-1111
13	Fabio Alencar	21 91111-2222
14	Gabriela Costa	31 93333-4444
15	Hugo Mendes	41 95555-6666
16	Isabela Neves	51 97777-8888
17	Jorge Valente	61 99999-0000
18	Ricardo Souza	11 94444-1111
19	Patrícia Amaral	21 95555-2222
20	Gustavo Henrique	31 96666-3333
21	Letícia Campos	41 97777-4444
22	André Vizone	51 98888-5555
\.


--
-- TOC entry 3909 (class 0 OID 16602)
-- Dependencies: 234
-- Data for Name: funcionarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.funcionarios (id_funcionario, nome, id_gerente) FROM stdin;
1	Matheus Kopp	\N
2	Thiago Mendes	1
3	Beatriz Silva	1
4	Lucas Oliveira	1
5	Carolina Ferraz	1
6	Marcos Reus	1
7	Sérgio Moro	1
\.


--
-- TOC entry 3907 (class 0 OID 16589)
-- Dependencies: 232
-- Data for Name: log_precos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.log_precos (id_log, id_carro, valor_antigo, valor_novo, data_alteracao, usuario_db) FROM stdin;
\.


--
-- TOC entry 3897 (class 0 OID 16504)
-- Dependencies: 220
-- Data for Name: marcas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marcas (id_marca, nome_marca) FROM stdin;
1	Honda
2	Toyota
3	Ford
4	Volkswagen
5	Mercedes-Benz
6	BMW
7	Audi
8	Fiat
9	Chevrolet
10	Hyundai
11	Jeep
12	Nissan
13	Volvo
14	Porsche
15	Land Rover
16	Tesla
17	Mitsubishi
18	Renault
\.


--
-- TOC entry 3905 (class 0 OID 16567)
-- Dependencies: 229
-- Data for Name: status_veiculos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_veiculos (id_status, descricao) FROM stdin;
1	Disponível
2	Vendido
3	Reservado
\.


--
-- TOC entry 3903 (class 0 OID 16540)
-- Dependencies: 226
-- Data for Name: vendas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vendas (id_venda, id_carro, id_cliente, data_venda, valor_final) FROM stdin;
4	4	1	2026-08-05	180000.00
1	1	1	2026-08-01	130000.00
2	2	2	2026-08-03	145000.00
3	3	3	2026-08-05	320000.00
5	6	5	2026-08-05	285000.00
6	5	4	2026-08-05	180000.00
7	8	7	2026-08-05	32000.00
8	11	9	2026-08-05	92000.00
9	12	10	2026-08-05	175000.00
10	13	11	2026-08-05	110000.00
11	14	12	2026-08-05	340000.00
12	15	13	2026-08-05	122000.00
13	16	14	2026-08-05	138000.00
14	17	15	2026-08-05	100000.00
15	18	16	2026-08-05	150000.00
16	19	18	2026-08-05	940000.00
17	20	19	2026-08-05	375000.00
18	21	20	2026-08-05	315000.00
19	22	21	2026-08-05	205000.00
20	23	22	2026-08-05	63000.00
21	27	8	2026-08-05	425000.00
22	28	9	2026-08-05	190000.00
23	29	10	2026-08-05	445000.00
24	30	11	2026-08-05	275000.00
\.


--
-- TOC entry 3941 (class 0 OID 0)
-- Dependencies: 223
-- Name: carros_id_carro_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carros_id_carro_seq', 39, true);


--
-- TOC entry 3942 (class 0 OID 0)
-- Dependencies: 221
-- Name: clientes_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 22, true);


--
-- TOC entry 3943 (class 0 OID 0)
-- Dependencies: 233
-- Name: funcionarios_id_funcionario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.funcionarios_id_funcionario_seq', 7, true);


--
-- TOC entry 3944 (class 0 OID 0)
-- Dependencies: 231
-- Name: log_precos_id_log_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.log_precos_id_log_seq', 1, false);


--
-- TOC entry 3945 (class 0 OID 0)
-- Dependencies: 219
-- Name: marcas_id_marca_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.marcas_id_marca_seq', 18, true);


--
-- TOC entry 3946 (class 0 OID 0)
-- Dependencies: 228
-- Name: status_veiculos_id_status_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.status_veiculos_id_status_seq', 3, true);


--
-- TOC entry 3947 (class 0 OID 0)
-- Dependencies: 225
-- Name: vendas_id_venda_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vendas_id_venda_seq', 24, true);


--
-- TOC entry 3729 (class 2606 OID 16533)
-- Name: carros carros_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carros
    ADD CONSTRAINT carros_pkey PRIMARY KEY (id_carro);


--
-- TOC entry 3727 (class 2606 OID 16522)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);


--
-- TOC entry 3740 (class 2606 OID 16609)
-- Name: funcionarios funcionarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT funcionarios_pkey PRIMARY KEY (id_funcionario);


--
-- TOC entry 3738 (class 2606 OID 16596)
-- Name: log_precos log_precos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.log_precos
    ADD CONSTRAINT log_precos_pkey PRIMARY KEY (id_log);


--
-- TOC entry 3723 (class 2606 OID 16513)
-- Name: marcas marcas_nome_marca_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_nome_marca_key UNIQUE (nome_marca);


--
-- TOC entry 3725 (class 2606 OID 16511)
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id_marca);


--
-- TOC entry 3734 (class 2606 OID 16576)
-- Name: status_veiculos status_veiculos_descricao_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_veiculos
    ADD CONSTRAINT status_veiculos_descricao_key UNIQUE (descricao);


--
-- TOC entry 3736 (class 2606 OID 16574)
-- Name: status_veiculos status_veiculos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_veiculos
    ADD CONSTRAINT status_veiculos_pkey PRIMARY KEY (id_status);


--
-- TOC entry 3732 (class 2606 OID 16549)
-- Name: vendas vendas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT vendas_pkey PRIMARY KEY (id_venda);


--
-- TOC entry 3730 (class 1259 OID 16587)
-- Name: idx_modelo_carro; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_modelo_carro ON public.carros USING btree (modelo);


--
-- TOC entry 3746 (class 2620 OID 16598)
-- Name: carros trg_auditoria_preco; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_preco AFTER UPDATE ON public.carros FOR EACH ROW EXECUTE FUNCTION public.fn_log_preco_carro();


--
-- TOC entry 3741 (class 2606 OID 16534)
-- Name: carros carros_id_marca_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carros
    ADD CONSTRAINT carros_id_marca_fkey FOREIGN KEY (id_marca) REFERENCES public.marcas(id_marca);


--
-- TOC entry 3745 (class 2606 OID 16610)
-- Name: funcionarios fk_gerente; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.funcionarios
    ADD CONSTRAINT fk_gerente FOREIGN KEY (id_gerente) REFERENCES public.funcionarios(id_funcionario);


--
-- TOC entry 3742 (class 2606 OID 16578)
-- Name: carros fk_status; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carros
    ADD CONSTRAINT fk_status FOREIGN KEY (id_status) REFERENCES public.status_veiculos(id_status);


--
-- TOC entry 3743 (class 2606 OID 16550)
-- Name: vendas vendas_id_carro_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT vendas_id_carro_fkey FOREIGN KEY (id_carro) REFERENCES public.carros(id_carro);


--
-- TOC entry 3744 (class 2606 OID 16555)
-- Name: vendas vendas_id_cliente_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT vendas_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);


--
-- TOC entry 3915 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 237
-- Name: PROCEDURE sp_registrar_venda(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_registrar_venda(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric) TO papel_gerente;


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 242
-- Name: PROCEDURE sp_registrar_venda_segura(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON PROCEDURE public.sp_registrar_venda_segura(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric) TO papel_vendedor;
GRANT ALL ON PROCEDURE public.sp_registrar_venda_segura(IN p_id_carro integer, IN p_id_cliente integer, IN p_valor_venda numeric) TO papel_gerente;


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE carros; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.carros TO papel_vendedor;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.carros TO papel_gerente;


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 223
-- Name: SEQUENCE carros_id_carro_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.carros_id_carro_seq TO papel_gerente;


--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE clientes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE public.clientes TO papel_vendedor;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.clientes TO papel_gerente;


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 221
-- Name: SEQUENCE clientes_id_cliente_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.clientes_id_cliente_seq TO papel_gerente;


--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE funcionarios; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.funcionarios TO papel_gerente;


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 233
-- Name: SEQUENCE funcionarios_id_funcionario_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.funcionarios_id_funcionario_seq TO papel_gerente;


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE log_precos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.log_precos TO papel_gerente;


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 231
-- Name: SEQUENCE log_precos_id_log_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.log_precos_id_log_seq TO papel_gerente;


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE marcas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.marcas TO papel_vendedor;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.marcas TO papel_gerente;


--
-- TOC entry 3932 (class 0 OID 0)
-- Dependencies: 219
-- Name: SEQUENCE marcas_id_marca_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.marcas_id_marca_seq TO papel_gerente;


--
-- TOC entry 3933 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE status_veiculos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.status_veiculos TO papel_vendedor;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.status_veiculos TO papel_gerente;


--
-- TOC entry 3935 (class 0 OID 0)
-- Dependencies: 228
-- Name: SEQUENCE status_veiculos_id_status_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.status_veiculos_id_status_seq TO papel_gerente;


--
-- TOC entry 3936 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE vendas; Type: ACL; Schema: public; Owner: postgres
--

GRANT INSERT ON TABLE public.vendas TO papel_vendedor;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vendas TO papel_gerente;


--
-- TOC entry 3938 (class 0 OID 0)
-- Dependencies: 225
-- Name: SEQUENCE vendas_id_venda_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.vendas_id_venda_seq TO papel_gerente;


--
-- TOC entry 3939 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE vw_estoque_disponivel; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_estoque_disponivel TO papel_gerente;


--
-- TOC entry 3940 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE vw_relatorio_vendas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.vw_relatorio_vendas TO papel_gerente;


-- Completed on 2026-08-05 22:24:53 -03

--
-- PostgreSQL database dump complete
--

\unrestrict 8NsGv6bpQplaBZrdUjTzsGngbYUkJcGHek9RHyDcNrdpg9RFLvtFhtNnbGye5uB

