# Teste local

Ambiente para testar o app inteiro na máquina, sem tocar no banco do Neon.

## Banco

```bash
docker run -d --name nosso-combustivel-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=nosso_combustivel -p 5433:5432 postgres:17-alpine
```

Migrations no banco local:

```bash
dotnet ef database update -p src/NossoCombustivel.Infrastructure -s src/NossoCombustivel.Api --connection "Host=localhost;Port=5433;Database=nosso_combustivel;Username=postgres;Password=postgres"
```

## API

Na pasta `api`, com a variável `ConnectionStrings__Banco` apontando para o banco acima:

```bash
dotnet run --project src/NossoCombustivel.Api --launch-profile http
```

## App

Na pasta `app`:

```bash
flutter run -d web-server --web-port 5400 --web-hostname localhost
```

## Conta de teste

Existe só no banco local do Docker.

- E-mail: `teste.local@nossocombustivel.test`
- Senha: `testelocal123`
