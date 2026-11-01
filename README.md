# Pit Garage (antigo Nosso Combustível)

App para controlar quanto cada carro gasta com combustível ou eletricidade: gasto da semana e do mês, consumo real (km/l ou km/kWh), custo por km e projeção do mês. Atende carros a combustão, flex, diesel, híbridos e 100% elétricos, e permite compartilhar um carro entre várias pessoas.

Projeto de hobby, feito para usar com os amigos do trabalho. O escopo completo está em [docs/ESCOPO.md](docs/ESCOPO.md).

## Stack

| Parte | Tecnologia |
| --- | --- |
| App | Flutter (PWA no MVP; Android e iPhone nativos depois), Riverpod, go_router |
| API | ASP.NET Core (.NET 10), Clean Architecture, DDD |
| Banco | PostgreSQL (Neon) com EF Core |

## Estrutura

```
api/    Solução .NET: Domain, Application, Infrastructure, Api e testes
app/    App Flutter em MVVM: domain, data, ui, core
docs/   Escopo do projeto
```

## Como rodar

Pré-requisitos: .NET SDK 10 e Flutter 3.41 ou mais novo.

API:

```bash
cd api
dotnet test
dotnet run --project src/NossoCombustivel.Api
```

App no navegador:

```bash
cd app
flutter test
flutter run -d chrome
```

## Segredos

O repositório é público: nenhuma senha, chave ou conexão de banco entra no código. Em desenvolvimento, use o `user-secrets` do .NET:

```bash
cd api/src/NossoCombustivel.Api
dotnet user-secrets init
dotnet user-secrets set "ConnectionStrings:Banco" "<sua conexão do Neon>"
```

Em produção, os mesmos valores ficam nas variáveis de ambiente do Render (`ConnectionStrings__Banco`).
