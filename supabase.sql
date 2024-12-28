-- Limpa todas as políticas de RLS existentes
drop policy if exists cliente_access on clientes;
drop policy if exists cliente_contatos on contatos;
drop policy if exists cliente_webhooks on webhooks;
drop policy if exists cliente_campanhas on campanhas;
drop policy if exists cliente_contatos_campanha on contatos_campanha;
drop policy if exists cliente_snapshot on campanha_contatos_snapshot;
drop policy if exists cliente_logs on logs_envios;

-- Remove views
drop view if exists metricas_campanha;

-- Remove triggers
drop trigger if exists set_timestamp_clientes on clientes;
drop trigger if exists set_timestamp_contatos on contatos;
drop trigger if exists set_timestamp_webhooks on webhooks;
drop trigger if exists set_timestamp_campanhas on campanhas;
drop trigger if exists set_timestamp_snapshot on campanha_contatos_snapshot;
drop trigger if exists trigger_process_campaign_contacts on campanhas;
drop trigger if exists trigger_delete_campaign_contacts on campanhas;

-- Remove índices
drop index if exists idx_contatos_cliente_numero;
drop index if exists idx_contatos_numero;
drop index if exists idx_contatos_tags;
drop index if exists idx_contatos_cliente_status;
drop index if exists idx_campanhas_cliente_status;
drop index if exists idx_campanhas_datas;
drop index if exists idx_webhooks_cliente;
drop index if exists idx_contatos_campanha_status;
drop index if exists idx_contatos_campanha_processado;
drop index if exists idx_snapshot_status;
drop index if exists idx_snapshot_datas;
drop index if exists idx_snapshot_campanha;
drop index if exists idx_logs_snapshot_tentativa;
drop index if exists idx_contatos_campanha_unique;

-- Remove tabelas (com CASCADE para remover dependências)
drop table if exists logs_envios cascade;
drop table if exists campanha_contatos_snapshot cascade;
drop table if exists contatos_campanha cascade;
drop table if exists campanhas cascade;
drop table if exists webhooks cascade;
drop table if exists contatos cascade;
drop table if exists clientes cascade;

-- Remove funções (após remover todas as dependências)
drop function if exists update_updated_at() cascade;
drop function if exists process_campaign_contacts() cascade;
drop function if exists delete_campaign_contacts() cascade;

-- Remove tipos
drop type if exists status_campanha cascade;
drop type if exists tipo_campanha cascade;
drop type if exists status_envio cascade;
drop type if exists origem_contatos cascade;

-- Remove domínios
drop domain if exists email_valido;
drop domain if exists telefone_valido;
drop domain if exists nome_valido;

-----------------------------------------------------------------------------------
-- DOCUMENTAÇÃO DO SCHEMA
-----------------------------------------------------------------------------------
comment on schema public is 'Schema principal do sistema de campanhas de mensagens';

-----------------------------------------------------------------------------------
-- TIPOS ENUM E DOMÍNIOS
-----------------------------------------------------------------------------------
-- Define os possíveis estados de uma campanha
create type status_campanha as enum (
  'pending',     -- Campanha criada mas não iniciada
  'running',     -- Campanha atualmente executando
  'completed',   -- Todos os envios foram processados
  'error'        -- Campanha encontrou erro durante execução
);

-- Define os tipos de agendamento possíveis para uma campanha
create type tipo_campanha as enum (
  'agendada',   -- Envios programados para data futura específica
  'imediata',   -- Envios começam assim que status muda para em_andamento
  'recorrente'  -- Envios acontecem periodicamente entre data_inicio e data_fim
);

-- Define os possíveis estados de um envio individual
create type status_envio as enum (
  'pending',  -- Aguardando processamento
  'success',  -- Mensagem enviada com sucesso
  'error'     -- Falha no envio
);

-- Define as possíveis origens dos contatos de uma campanha
create type origem_contatos as enum (
  'lista',            -- Contatos vêm de uma lista pré-definida
  'csv',             -- Contatos importados de arquivo CSV
  'contatos_cliente' -- Contatos da base do cliente
);

-- Define os tipos de plano disponíveis
create type plano_cliente as enum (
  'basico',
  'premium',
  'enterprise'
);

comment on type plano_cliente is 'Tipos de plano disponíveis na plataforma';

-- Define a estrutura de rate limit
create type rate_limit_config as (
  diario integer,
  mensal integer,
  horario integer,
  concorrencia integer
);

comment on type rate_limit_config is 'Configuração de limites de envio';

-- Domínios para validações comuns
create domain email_valido as text
check(
  value ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
);

create domain telefone_valido as text
check(
  value ~* '^\+?[1-9][0-9]{7,14}$'
);

create domain nome_valido as text
check(
  length(value) between 2 and 100
);

-- Define os canais de envio disponíveis na plataforma
create type canal_envio as enum (
  'whatsapp',
  'telegram',
  'sms',
  'email'
);

comment on type canal_envio is 'Canais de envio disponíveis na plataforma';

-----------------------------------------------------------------------------------
-- FUNÇÕES UTILITÁRIAS
-----------------------------------------------------------------------------------
-- Função para atualização automática do campo updated_at
create or replace function update_updated_at()
returns trigger 
security invoker
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

comment on function update_updated_at() is 'Função utilizada para atualizar automaticamente o campo updated_at';

-----------------------------------------------------------------------------------
-- TABELAS PRINCIPAIS
-----------------------------------------------------------------------------------
-- Armazena informações dos clientes do sistema
create table clientes (
  id bigint primary key generated always as identity,
  nome nome_valido not null,
  descricao text check (length(descricao) <= 500),
  limite_diario_envio int not null check (limite_diario_envio > 0),
  status boolean default true,
  tipo_cliente plano_cliente not null,
  configuracoes jsonb default '{}',
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

comment on table clientes is 'Armazena informações dos clientes que utilizam o sistema';
comment on column clientes.limite_diario_envio is 'Limite máximo de mensagens que podem ser enviadas por dia';
comment on column clientes.configuracoes is 'Configurações específicas do cliente em formato JSON';

-- Armazena contatos base dos clientes (contatos permanentes)
create table contatos (
  id bigint primary key generated always as identity,
  cliente_id bigint references clientes (id),
  nome nome_valido,
  numero telefone_valido not null,
  email email_valido,
  tags text[] default '{}',
  status boolean default true,
  opt_in boolean default false,
  opt_in_date timestamptz,
  metadados jsonb default '{}',
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint tags_length_check check (array_length(tags, 1) <= 10)
);

-- Cria índice único para evitar duplicação de números por cliente
create unique index idx_contatos_cliente_numero 
on contatos(cliente_id, numero) 
where deleted_at is null;

comment on table contatos is 'Contatos permanentes vinculados aos clientes';
comment on column contatos.tags is 'Array de tags para segmentação, limitado a 10 tags';
comment on column contatos.metadados is 'Informações adicionais do contato em formato JSON';

-- Armazena as campanhas de envio
create table campanhas (
  id bigint primary key generated always as identity,
  cliente_id bigint references clientes (id),
  nome nome_valido not null,
  descricao text check (length(descricao) <= 500),
  tipo_campanha tipo_campanha not null,
  origem_contatos origem_contatos not null,
  configuracao_mensagens jsonb default '{}',
  data_inicio_envio timestamptz not null,
  data_fim_envio timestamptz,
  status status_campanha not null default 'pending',
  metadados jsonb default '{}',
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint check_datas check (
    data_fim_envio is null or data_fim_envio > data_inicio_envio
  ),
  custom_webhook_id bigint references custom_webhooks(id),
  provider_id bigint references providers(id),
  constraint check_exclusivo_webhook check (
    (custom_webhook_id is not null and provider_id is null) or 
    (custom_webhook_id is null and provider_id is not null)
  )
);

comment on table campanhas is 'Campanhas de envio de mensagens';
comment on column campanhas.configuracao_mensagens is 'Configurações das mensagens incluindo templates, variáveis e regras de envio';
comment on column campanhas.metadados is 'Informações adicionais da campanha em formato JSON';

-- Armazena todos os contatos vinculados a campanhas (antes do início)
create table contatos_campanha (
  id bigint primary key generated always as identity,
  cliente_id bigint references clientes (id),
  campanha_id bigint references campanhas (id),
  nome nome_valido,
  numero telefone_valido not null,
  email email_valido,
  dados_adicionais jsonb default '{}',
  origem text not null,
  processado boolean default false,
  status boolean default true,
  validacoes jsonb default '{}',
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Cria índice único para evitar duplicação de contatos na campanha
create unique index idx_contatos_campanha_unique 
on contatos_campanha(cliente_id, campanha_id, numero) 
where deleted_at is null;

comment on table contatos_campanha is 'Contatos específicos vinculados a campanhas antes do processamento';
comment on column contatos_campanha.dados_adicionais is 'Dados específicos do contato para esta campanha';
comment on column contatos_campanha.validacoes is 'Resultado das validações realizadas no contato';

-- Armazena snapshot dos contatos no momento que a campanha inicia e controla envios
create table campanha_contatos_snapshot (
  id bigint primary key generated always as identity,
  campanha_id bigint references campanhas (id),
  contato_campanha_id bigint references contatos_campanha (id),
  nome nome_valido,
  numero telefone_valido not null,
  email email_valido,
  dados_processados jsonb not null,
  status_envio status_envio not null default 'pending',
  mensagem_personalizada text,
  data_agendada_envio timestamptz not null,
  tentativas_envio int default 0,
  ultima_tentativa timestamptz,
  proximo_retry timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  constraint check_tentativas check (tentativas_envio >= 0 and tentativas_envio <= 5)
);

comment on table campanha_contatos_snapshot is 'Snapshot dos contatos e controle de envios da campanha';
comment on column campanha_contatos_snapshot.dados_processados is 'Dados do contato após processamento das regras da campanha';
comment on column campanha_contatos_snapshot.status_envio is 'Status atual do envio para este contato';
comment on column campanha_contatos_snapshot.mensagem_personalizada is 'Mensagem personalizada para este contato';
comment on column campanha_contatos_snapshot.data_agendada_envio is 'Data agendada para o envio';
comment on column campanha_contatos_snapshot.tentativas_envio is 'Número de tentativas de envio realizadas';
comment on column campanha_contatos_snapshot.ultima_tentativa is 'Data da última tentativa de envio';
comment on column campanha_contatos_snapshot.proximo_retry is 'Data calculada para próxima tentativa em caso de erro';

-- Registra todos os eventos de envio
create table logs_envios (
  id bigint primary key generated always as identity,
  snapshot_id bigint references campanha_contatos_snapshot (id),
  numero_tentativa int not null default 1,
  timestamp_envio timestamptz not null,
  status status_envio not null,
  descricao_erro text,
  dados_resposta jsonb,
  created_at timestamptz default now(),
  constraint check_numero_tentativa check (numero_tentativa > 0 and numero_tentativa <= 5)
);

comment on table logs_envios is 'Log detalhado de todas as tentativas de envio';
comment on column logs_envios.snapshot_id is 'Referência ao snapshot do contato que recebeu a tentativa de envio';
comment on column logs_envios.numero_tentativa is 'Número da tentativa de envio (1 a 5)';
comment on column logs_envios.status is 'Status do envio (pending, success, error)';
comment on column logs_envios.dados_resposta is 'Resposta completa da API de envio em formato JSON';

-- Cria índice para otimizar consultas de log por snapshot e tentativa
create index idx_logs_snapshot_tentativa on logs_envios(snapshot_id, numero_tentativa);

-----------------------------------------------------------------------------------
-- TABELA DE USUÁRIOS
-----------------------------------------------------------------------------------
-- Armazena os usuários do sistema e suas permissões
create table app_users (
  id bigint primary key generated always as identity,
  auth_user_id uuid not null references auth.users (id) on delete cascade,
  cliente_id bigint not null references clientes (id),
  role text not null check (role in ('admin','member')) default 'member',
  metadados jsonb default '{}',
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

comment on table app_users is 'Usuários do sistema e suas permissões';
comment on column app_users.auth_user_id is 'ID do usuário no auth.users do Supabase';
comment on column app_users.role is 'Papel do usuário: admin (administrador) ou member (membro)';
comment on column app_users.metadados is 'Informações adicionais do usuário em formato JSON';

-- Cria índice para otimizar consultas de usuário por cliente
create index idx_app_users_cliente on app_users(cliente_id) where deleted_at is null;
create index idx_app_users_auth on app_users(auth_user_id) where deleted_at is null;

-- Trigger para atualização automática de updated_at
create trigger set_timestamp_app_users
  before update on app_users
  for each row execute function update_updated_at();

-- Habilita RLS para app_users
alter table app_users enable row level security;

-----------------------------------------------------------------------------------
-- ROW LEVEL SECURITY
-----------------------------------------------------------------------------------
-- Habilita RLS para todas as tabelas
alter table clientes enable row level security;
alter table contatos enable row level security;
alter table campanhas enable row level security;
alter table contatos_campanha enable row level security;
alter table campanha_contatos_snapshot enable row level security;
alter table logs_envios enable row level security;
alter table app_users enable row level security;
alter table custom_webhooks enable row level security;

-- Políticas para app_users
create policy app_users_select on app_users
  for select
  using (
    auth.uid() = auth_user_id
    or exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = app_users.cliente_id
      and au.role = 'admin'
    )
  );

create policy app_users_insert on app_users
  for insert
  with check (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = app_users.cliente_id
      and au.role = 'admin'
    )
  );

create policy app_users_update on app_users
  for update
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = app_users.cliente_id
      and au.role = 'admin'
    )
  );

create policy app_users_delete on app_users
  for delete
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = app_users.cliente_id
      and au.role = 'admin'
    )
  );

-- Políticas para clientes
create policy cliente_access_select on clientes
  for select
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = id
    )
  );

create policy cliente_access_insert on clientes
  for insert
  with check (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = id
      and au.role = 'admin'
    )
  );

create policy cliente_access_update on clientes
  for update
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = id
      and au.role = 'admin'
    )
  );

create policy cliente_access_delete on clientes
  for delete
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = id
      and au.role = 'admin'
    )
  );

-- Políticas para contatos
create policy cliente_contatos_select on contatos
  for select
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos.cliente_id
    )
  );

create policy cliente_contatos_insert on contatos
  for insert
  with check (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos.cliente_id
    )
  );

create policy cliente_contatos_update on contatos
  for update
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos.cliente_id
    )
  );

create policy cliente_contatos_delete on contatos
  for delete
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos.cliente_id
      and au.role = 'admin'
    )
  );

-- Políticas para campanhas
create policy cliente_campanhas_select on campanhas
  for select
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = campanhas.cliente_id
    )
  );

create policy cliente_campanhas_insert on campanhas
  for insert
  with check (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = campanhas.cliente_id
    )
  );

create policy cliente_campanhas_update on campanhas
  for update
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = campanhas.cliente_id
    )
  );

create policy cliente_campanhas_delete on campanhas
  for delete
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = campanhas.cliente_id
      and au.role = 'admin'
    )
  );

-- Políticas para contatos_campanha
create policy cliente_contatos_campanha_select on contatos_campanha
  for select
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos_campanha.cliente_id
    )
  );

create policy cliente_contatos_campanha_insert on contatos_campanha
  for insert
  with check (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos_campanha.cliente_id
    )
  );

create policy cliente_contatos_campanha_update on contatos_campanha
  for update
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos_campanha.cliente_id
    )
  );

create policy cliente_contatos_campanha_delete on contatos_campanha
  for delete
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = contatos_campanha.cliente_id
      and au.role = 'admin'
    )
  );

-- Políticas para campanha_contatos_snapshot
create policy cliente_snapshot_select on campanha_contatos_snapshot
  for select
  using (
    exists (
      select 1 from campanhas c
      join app_users au on au.cliente_id = c.cliente_id
      where c.id = campanha_id
      and au.auth_user_id = auth.uid()
    )
  );

create policy cliente_snapshot_insert on campanha_contatos_snapshot
  for insert
  with check (
    exists (
      select 1 from campanhas c
      join app_users au on au.cliente_id = c.cliente_id
      where c.id = campanha_id
      and au.auth_user_id = auth.uid()
    )
  );

create policy cliente_snapshot_update on campanha_contatos_snapshot
  for update
  using (
    exists (
      select 1 from campanhas c
      join app_users au on au.cliente_id = c.cliente_id
      where c.id = campanha_id
      and au.auth_user_id = auth.uid()
    )
  );

create policy cliente_snapshot_delete on campanha_contatos_snapshot
  for delete
  using (
    exists (
      select 1 from campanhas c
      join app_users au on au.cliente_id = c.cliente_id
      where c.id = campanha_id
      and au.auth_user_id = auth.uid()
      and au.role = 'admin'
    )
  );

-- Políticas para logs_envios
create policy cliente_logs_select on logs_envios
  for select
  using (
    exists (
      select 1 from campanha_contatos_snapshot ccs
      join campanhas c on c.id = ccs.campanha_id
      join app_users au on au.cliente_id = c.cliente_id
      where ccs.id = snapshot_id 
      and au.auth_user_id = auth.uid()
    )
  );

create policy cliente_logs_insert on logs_envios
  for insert
  with check (
    exists (
      select 1 from campanha_contatos_snapshot ccs
      join campanhas c on c.id = ccs.campanha_id
      join app_users au on au.cliente_id = c.cliente_id
      where ccs.id = snapshot_id 
      and au.auth_user_id = auth.uid()
    )
  );

create policy cliente_logs_update on logs_envios
  for update
  using (
    exists (
      select 1 from campanha_contatos_snapshot ccs
      join campanhas c on c.id = ccs.campanha_id
      join app_users au on au.cliente_id = c.cliente_id
      where ccs.id = snapshot_id 
      and au.auth_user_id = auth.uid()
      and au.role = 'admin'
    )
  );

create policy cliente_logs_delete on logs_envios
  for delete
  using (
    exists (
      select 1 from campanha_contatos_snapshot ccs
      join campanhas c on c.id = ccs.campanha_id
      join app_users au on au.cliente_id = c.cliente_id
      where ccs.id = snapshot_id 
      and au.auth_user_id = auth.uid()
      and au.role = 'admin'
    )
  );

-----------------------------------------------------------------------------------
-- FUNÇÃO DE PROCESSAMENTO DE CAMPANHA
-----------------------------------------------------------------------------------
-- Processa automaticamente os contatos quando campanha muda para em_andamento
create or replace function process_campaign_contacts()
returns trigger
security invoker
set search_path = public
as $$
declare
  v_provider_rate_limit rate_limit_config;
  v_total_contatos integer;
  v_envios_diarios integer;
  v_envios_mensais integer;
  v_pendentes_diarios integer;
  v_pendentes_mensais integer;
begin
  -- Verifica se é uma mudança de status válida
  if new.status = 'running' and old.status = 'pending' then
    -- Se for provider, verifica limites
    if new.provider_id is not null then
      -- Obtém o rate limit do provider
      select rate_limit into v_provider_rate_limit
      from providers
      where id = new.provider_id;
      
      -- Conta quantos contatos serão processados nesta campanha
      select count(*) into v_total_contatos
      from contatos_campanha cc
      where cc.campanha_id = new.id
      and cc.deleted_at is null
      and cc.status = true
      and not cc.processado;

      -- Verifica limite diário
      if v_provider_rate_limit.diario is not null then
        -- Conta envios já realizados hoje
        select 
          count(*) filter (where status_envio = 'success'),
          count(*) filter (where status_envio = 'pending')
        into v_envios_diarios, v_pendentes_diarios
        from campanha_contatos_snapshot ccs 
        join campanhas c on c.id = ccs.campanha_id
        where c.cliente_id = new.cliente_id 
        and c.provider_id = new.provider_id
        and ccs.data_agendada_envio >= date_trunc('day', now());
        
        if v_envios_diarios + v_pendentes_diarios + v_total_contatos > v_provider_rate_limit.diario then
          raise exception 'Limite diário de envios seria excedido. Disponível: %, Necessário: %', 
            v_provider_rate_limit.diario - (v_envios_diarios + v_pendentes_diarios),
            v_total_contatos;
        end if;
      end if;
      
      -- Verifica limite mensal
      if v_provider_rate_limit.mensal is not null then
        -- Conta envios já realizados este mês
        select 
          count(*) filter (where status_envio = 'success'),
          count(*) filter (where status_envio = 'pending')
        into v_envios_mensais, v_pendentes_mensais
        from campanha_contatos_snapshot ccs 
        join campanhas c on c.id = ccs.campanha_id
        where c.cliente_id = new.cliente_id 
        and c.provider_id = new.provider_id
        and ccs.data_agendada_envio >= date_trunc('month', now());
        
        if v_envios_mensais + v_pendentes_mensais + v_total_contatos > v_provider_rate_limit.mensal then
          raise exception 'Limite mensal de envios seria excedido. Disponível: %, Necessário: %',
            v_provider_rate_limit.mensal - (v_envios_mensais + v_pendentes_mensais),
            v_total_contatos;
        end if;
      end if;

      -- Verifica limite de concorrência se definido
      if v_provider_rate_limit.concorrencia is not null then
        if exists (
          select 1
          from campanhas c
          where c.cliente_id = new.cliente_id
          and c.provider_id = new.provider_id
          and c.status = 'running'
          and c.id != new.id
          group by c.cliente_id
          having count(*) >= v_provider_rate_limit.concorrencia
        ) then
          raise exception 'Limite de campanhas concorrentes atingido para este provider: %', 
            v_provider_rate_limit.concorrencia;
        end if;
      end if;
    end if;

    -- Se origem é contatos_cliente, importa para contatos_campanha
    if new.origem_contatos = 'contatos_cliente' then
      insert into contatos_campanha (
        cliente_id,
        campanha_id,
        nome,
        numero,
        email,
        origem,
        dados_adicionais
      )
      select 
        new.cliente_id,
        new.id,
        c.nome,
        c.numero,
        c.email,
        'contatos_cliente',
        jsonb_build_object(
          'from_contatos', true,
          'tags', c.tags
        )
      from contatos c
      where c.cliente_id = new.cliente_id
      and c.deleted_at is null
      and c.status = true
      on conflict do nothing;
    end if;

    -- Cria snapshot de todos os contatos não processados
    insert into campanha_contatos_snapshot (
      campanha_id,
      contato_campanha_id,
      nome,
      numero,
      email,
      dados_processados,
      data_agendada_envio,
      mensagem_personalizada,
      provider_snapshot
    )
    select 
      new.id,
      cc.id,
      cc.nome,
      cc.numero,
      cc.email,
      jsonb_build_object(
        'origem', cc.origem,
        'dados_originais', cc.dados_adicionais,
        'configuracao_mensagens', new.configuracao_mensagens,
        'processado_em', now(),
        'validacoes', cc.validacoes
      ),
      case 
        when new.tipo_campanha = 'imediata' then now()
        else new.data_inicio_envio
      end,
      null, -- mensagem_personalizada será definida posteriormente se necessário
      case
        when new.custom_webhook_id is not null then (
          select jsonb_build_object(
            'tipo', 'custom',
            'id', cw.id,
            'canal_envio', cw.canal_envio,
            'url', cw.url,
            'headers', cw.headers,
            'metadados', cw.metadados,
            'snapshot_em', now(),
            'cliente_id', cw.cliente_id
          )
          from custom_webhooks cw
          where cw.id = new.custom_webhook_id
          and cw.deleted_at is null
          and cw.status = true
        )
        else (
          select jsonb_build_object(
            'tipo', 'provider',
            'id', p.id,
            'canal_envio', p.canal_envio,
            'nome', p.nome,
            'config', p.config,
            'rate_limit', p.rate_limit,
            'plano_minimo', p.plano_minimo,
            'snapshot_em', now()
          )
          from providers p
          where p.id = new.provider_id
          and p.deleted_at is null
          and p.habilitado = true
        )
      end
    from contatos_campanha cc
    where cc.campanha_id = new.id
    and cc.deleted_at is null
    and cc.status = true
    and not cc.processado;

    -- Marca contatos como processados
    update contatos_campanha
    set 
      processado = true,
      validacoes = jsonb_build_object(
        'processado_em', now(),
        'processado', true
      )
    where campanha_id = new.id
    and not processado
    and id in (
      select contato_campanha_id 
      from campanha_contatos_snapshot 
      where campanha_id = new.id
    );

    -- Registra log inicial com número da tentativa
    insert into logs_envios (
      snapshot_id,
      numero_tentativa,
      timestamp_envio,
      status,
      dados_resposta
    )
    select 
      ccs.id,
      1, -- Primeira tentativa
      now(),
      'pending'::status_envio,
      jsonb_build_object(
        'tipo_campanha', new.tipo_campanha,
        'data_agendada', ccs.data_agendada_envio,
        'provider', ccs.provider_snapshot
      )
    from campanha_contatos_snapshot ccs
    where ccs.campanha_id = new.id;

  end if;
  return new;
end;
$$ language plpgsql;

comment on function process_campaign_contacts() is 'Processa contatos quando campanha é iniciada, respeitando limites e regras';

-- Trigger que executa o processamento de contatos
create trigger trigger_process_campaign_contacts
  after update on campanhas
  for each row
  execute function process_campaign_contacts();

-----------------------------------------------------------------------------------
-- FUNÇÃO PARA DELETAR CONTATOS DA CAMPANHA
-----------------------------------------------------------------------------------
create or replace function delete_campaign_contacts()
returns trigger
security invoker
set search_path = public
as $$
begin
  -- Se a campanha está sendo deletada (soft delete)
  if new.deleted_at is not null and old.deleted_at is null then
    -- Deleta (soft delete) todos os contatos vinculados a esta campanha
    update contatos_campanha
    set deleted_at = now()
    where campanha_id = old.id
    and deleted_at is null;
  end if;
  return new;
end;
$$ language plpgsql;

comment on function delete_campaign_contacts() is 'Função para deletar contatos quando uma campanha é deletada';

-- Trigger que executa o delete em cascata dos contatos
create trigger trigger_delete_campaign_contacts
  after update on campanhas
  for each row
  execute function delete_campaign_contacts();

-----------------------------------------------------------------------------------
-- TABELAS DE WEBHOOKS
-----------------------------------------------------------------------------------
-- Armazena webhooks customizados criados pelos clientes
create table custom_webhooks (
  id bigint primary key generated always as identity,
  cliente_id bigint not null references clientes (id),
  canal_envio canal_envio not null,
  nome text not null check (length(nome) between 3 and 100),
  url text not null check (url ~* '^https?://'),
  headers jsonb default '{}',
  metadados jsonb default '{}',
  status boolean default true,
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

comment on table custom_webhooks is 'Webhooks customizados criados pelos clientes';

-- Armazena providers pré-configurados disponíveis na plataforma
create table providers (
  id bigint primary key generated always as identity,
  nome text not null check (length(nome) between 3 and 100),
  canal_envio canal_envio not null,
  plano_minimo plano_cliente not null,
  habilitado boolean default true,
  config jsonb default '{}',
  rate_limit rate_limit_config default '{"diario": null, "mensal": null, "horario": null, "concorrencia": null}',
  deleted_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

comment on table providers is 'Providers pré-configurados disponíveis na plataforma';
comment on column providers.plano_minimo is 'Plano mínimo necessário para usar este provider';
comment on column providers.rate_limit is 'Limites de envio do provider (null = sem limite)';

-- View para providers disponíveis por cliente
create or replace view providers_disponiveis with (security_invoker = true) as
with envios_diarios as (
  select 
    camp.cliente_id,
    camp.provider_id,
    count(*) as total_enviados,
    count(*) filter (where ccs.status_envio = 'pending') as total_pendentes
  from campanha_contatos_snapshot ccs 
  join campanhas camp on camp.id = ccs.campanha_id
  where ccs.data_agendada_envio >= date_trunc('day', now())
  and ccs.status_envio in ('success', 'pending')
  group by camp.cliente_id, camp.provider_id
),
envios_mensais as (
  select 
    camp.cliente_id,
    camp.provider_id,
    count(*) as total_enviados,
    count(*) filter (where ccs.status_envio = 'pending') as total_pendentes
  from campanha_contatos_snapshot ccs 
  join campanhas camp on camp.id = ccs.campanha_id
  where ccs.data_agendada_envio >= date_trunc('month', now())
  and ccs.status_envio in ('success', 'pending')
  group by camp.cliente_id, camp.provider_id
)
select 
  p.*,
  c.id as cliente_id,
  c.tipo_cliente,
  case 
    when p.plano_minimo = 'basico' then true
    when p.plano_minimo = 'premium' and c.tipo_cliente in ('premium', 'enterprise') then true
    when p.plano_minimo = 'enterprise' and c.tipo_cliente = 'enterprise' then true
    else false
  end as disponivel,
  case
    when (p.rate_limit).diario is not null then 
      coalesce(ed.total_enviados, 0) + coalesce(ed.total_pendentes, 0) < (p.rate_limit).diario
    else true
  end as dentro_limite_diario,
  case
    when (p.rate_limit).mensal is not null then 
      coalesce(em.total_enviados, 0) + coalesce(em.total_pendentes, 0) < (p.rate_limit).mensal
    else true
  end as dentro_limite_mensal,
  case
    when (p.rate_limit).diario is not null then
      (p.rate_limit).diario - (coalesce(ed.total_enviados, 0) + coalesce(ed.total_pendentes, 0))
    else null
  end as envios_disponiveis_hoje,
  case
    when (p.rate_limit).mensal is not null then
      (p.rate_limit).mensal - (coalesce(em.total_enviados, 0) + coalesce(em.total_pendentes, 0))
    else null
  end as envios_disponiveis_mes
from providers p
cross join clientes c
left join envios_diarios ed on ed.cliente_id = c.id and ed.provider_id = p.id
left join envios_mensais em on em.cliente_id = c.id and em.provider_id = p.id
where p.deleted_at is null 
and p.habilitado = true
and c.deleted_at is null
and c.status = true
and exists (
  select 1 from app_users au
  where au.auth_user_id = auth.uid()
  and au.cliente_id = c.id
);

comment on view providers_disponiveis is 'Providers disponíveis para cada cliente baseado no seu plano e limites de envio';

-- Modifica a tabela campanha_contatos_snapshot para incluir dados do provider
alter table campanha_contatos_snapshot
add column provider_snapshot jsonb default '{}';

comment on column campanha_contatos_snapshot.provider_snapshot is 'Snapshot das configurações do provider no momento do envio';

-- Triggers para atualização automática de updated_at
create trigger set_timestamp_custom_webhooks
  before update on custom_webhooks
  for each row execute function update_updated_at();

create trigger set_timestamp_providers
  before update on providers
  for each row execute function update_updated_at();

-- Índices para otimização de consultas
create index idx_custom_webhooks_cliente on custom_webhooks(cliente_id) where deleted_at is null;
create index idx_custom_webhooks_canal on custom_webhooks(canal_envio) where status = true and deleted_at is null;
create index idx_providers_canal on providers(canal_envio) where habilitado = true and deleted_at is null;

-- Habilita RLS para custom_webhooks
alter table custom_webhooks enable row level security;

-- Políticas RLS para custom_webhooks
create policy custom_webhooks_select on custom_webhooks
  for select
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = custom_webhooks.cliente_id
    )
  );

create policy custom_webhooks_insert on custom_webhooks
  for insert
  with check (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = custom_webhooks.cliente_id
      and au.role = 'admin'
    )
  );

create policy custom_webhooks_update on custom_webhooks
  for update
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = custom_webhooks.cliente_id
      and au.role = 'admin'
    )
  );

create policy custom_webhooks_delete on custom_webhooks
  for delete
  using (
    exists (
      select 1 from app_users au
      where au.auth_user_id = auth.uid()
      and au.cliente_id = custom_webhooks.cliente_id
      and au.role = 'admin'
    )
  );

-- Providers não precisa de RLS pois é global

-----------------------------------------------------------------------------------
-- ÍNDICES
-----------------------------------------------------------------------------------
-- Índices otimizados considerando soft delete e consultas frequentes
create index idx_contatos_numero on contatos(numero) where deleted_at is null;
create index idx_contatos_tags on contatos using gin(tags);
create index idx_contatos_cliente_status on contatos(cliente_id, status) where deleted_at is null;
create index idx_campanhas_cliente_status on campanhas(cliente_id, status) where deleted_at is null;
create index idx_campanhas_datas on campanhas(data_inicio_envio, data_fim_envio) 
where status = 'running';
create index idx_contatos_campanha_status on contatos_campanha(status) where deleted_at is null;
create index idx_contatos_campanha_processado on contatos_campanha(processado) where deleted_at is null;

-- Índices para a tabela de snapshot
create index idx_snapshot_status on campanha_contatos_snapshot(status_envio);
create index idx_snapshot_datas on campanha_contatos_snapshot(data_agendada_envio) 
where status_envio = 'pending';
create index idx_snapshot_campanha on campanha_contatos_snapshot(campanha_id);

-----------------------------------------------------------------------------------
-- VIEWS
-----------------------------------------------------------------------------------
-- View para métricas de campanha
create or replace view metricas_campanha with (security_invoker = true) as
select 
  c.id as campanha_id,
  c.nome as campanha_nome,
  c.status,
  count(distinct cc.id) as total_contatos,
  count(distinct ccs.id) as contatos_processados,
  count(distinct case when ccs.status_envio = 'success' then ccs.id end) as enviados_sucesso,
  count(distinct case when ccs.status_envio = 'error' then ccs.id end) as enviados_erro
from campanhas c
left join contatos_campanha cc on cc.campanha_id = c.id
left join campanha_contatos_snapshot ccs on ccs.campanha_id = c.id
where c.deleted_at is null
group by c.id, c.nome, c.status;

comment on view metricas_campanha is 'Visão consolidada das métricas de cada campanha';

-----------------------------------------------------------------------------------
-- TRIGGERS
-----------------------------------------------------------------------------------
-- Triggers para atualização automática de updated_at
create trigger set_timestamp_clientes
  before update on clientes
  for each row execute function update_updated_at();

create trigger set_timestamp_contatos
  before update on contatos
  for each row execute function update_updated_at();

create trigger set_timestamp_campanhas
  before update on campanhas
  for each row execute function update_updated_at();

create trigger set_timestamp_snapshot
  before update on campanha_contatos_snapshot
  for each row execute function update_updated_at();

-- Índices para otimizar a view providers_disponiveis
create index idx_providers_plano_minimo on providers(plano_minimo) 
where deleted_at is null and habilitado = true;

create index idx_clientes_tipo_cliente on clientes(tipo_cliente) 
where deleted_at is null and status = true;

-- Índices adicionais para otimizar contagens e verificações de limite
create index idx_snapshot_cliente_provider_data on campanha_contatos_snapshot(campanha_id, status_envio)
include (data_agendada_envio);

create index idx_campanhas_cliente_provider_status on campanhas(cliente_id, provider_id, status)
where status = 'running';
