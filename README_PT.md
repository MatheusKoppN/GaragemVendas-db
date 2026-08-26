# GaragemVendas-db
**🚗 GaragemVendas: Sistema de Gestão de Estoque e Vendas**

Este projeto consiste no desenvolvimento de um sistema de banco de dados robusto para a gestão de uma garagem de veículos, utilizando PostgreSQL. O foco principal foi aplicar conceitos avançados de engenharia de dados, garantindo integridade, segurança e automação de processos de negócio
.

**🎯 Objetivo do Projeto**

Demonstrar o domínio de SQL em um cenário real, cobrindo desde a normalização de dados até a implementação de camadas de segurança e análise de Business Intelligence (BI)
.

**🛠️ Tecnologias Utilizadas**

SGBD: PostgreSQL
Ferramenta de Gestão: DBeaver
Linguagem: SQL (ANSI/ISO) e PL/pgSQL

**🏗️ Modelagem e Estrutura (DDL)**

O banco foi projetado seguindo as regras da 3ª Forma Normal (3FN) para eliminar redundâncias e evitar anomalias de atualização
:
Normalização: Divisão em entidades como carros, marcas, clientes, status_veiculos e vendas.

Hierarquia: Implementação de uma tabela de funcionarios com Self-Join, permitindo o gerenciamento de subordinados e gerentes dentro da mesma entidade.

Performance: Criação de índices B-Tree na coluna modelo para otimizar buscas textuais em grandes volumes de dados.


**🚀 Funcionalidades e Destaques Técnicos**

*1. Automação com Gatilhos (Triggers):*
Implementação de um mecanismo de auditoria automática. Sempre que o preço de um veículo é alterado, o gatilho trg_auditoria_preco registra o valor antigo, o novo valor e o usuário que realizou a alteração em uma tabela de log
.

*2. Transações Seguras (Propriedades ACID):*
Desenvolvimento da Stored Procedure sp_registrar_venda_segura. Ela garante a Atomicidade: ou a venda é registrada e o estoque atualizado simultaneamente, ou nada acontece em caso de erro, prevenindo inconsistências financeiras
.

*3. Segurança e Controle de Acesso (DCL):*
Configuração de Controle de Acesso Baseado em Funções (RBAC)
:

Papel Vendedor: Permissões limitadas a consultas e inserção de vendas.

Papel Gerente: Acesso total, incluindo permissão de exclusão e visualização de logs de auditoria.

*4. Análise Avançada (DQL e Views):*
Uso de Common Table Expressions (CTEs) para relatórios de faturamento complexos, permitindo calcular a participação percentual de cada marca nas vendas totais com alta legibilidade de código.

Além disso, Views foram criadas para simplificar consultas diárias, como a vw_estoque_disponivel.


**📂 Como Executar o Projeto**

Certifique-se de ter o PostgreSQL instalado.


Execute o script "VendaDeCarros.sql" disponível neste repositório.

O script já contém as Seeds necessárias para povoar o banco com marcas, carros e funcionários (incluindo o gerente Matheus Kopp) para testes imediatos.


**👨‍💻 Sobre o Autor**

Matheus Kopp do Nascimento - Programador e engenheiro eletricista em formação, atualmente focado em Banco de Dados.[ https://www.linkedin.com/in/matheus-kopp-do-nascimento-426a783b5/ ] 

-> +55 (45)99955-9505.
