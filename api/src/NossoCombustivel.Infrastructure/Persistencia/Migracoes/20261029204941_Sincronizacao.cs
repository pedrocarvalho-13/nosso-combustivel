using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class Sincronizacao : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Veiculos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DonoId = table.Column<Guid>(type: "uuid", nullable: false),
                    Apelido = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Marca = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Modelo = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Ano = table.Column<int>(type: "integer", nullable: true),
                    CodigoFipe = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    TipoEnergia = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Combustiveis = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CapacidadeTanqueL = table.Column<decimal>(type: "numeric(8,3)", precision: 8, scale: 3, nullable: true),
                    CapacidadeBateriaKwh = table.Column<decimal>(type: "numeric(8,3)", precision: 8, scale: 3, nullable: true),
                    OdometroInicial = table.Column<int>(type: "integer", nullable: false),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AtualizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExcluidoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    SincronizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Veiculos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Veiculos_AspNetUsers_DonoId",
                        column: x => x.DonoId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Abastecimentos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Combustivel = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Litros = table.Column<decimal>(type: "numeric(8,3)", precision: 8, scale: 3, nullable: false),
                    PrecoLitro = table.Column<decimal>(type: "numeric(6,3)", precision: 6, scale: 3, nullable: false),
                    TanqueCheio = table.Column<bool>(type: "boolean", nullable: false),
                    Posto = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    VeiculoId = table.Column<Guid>(type: "uuid", nullable: false),
                    UsuarioId = table.Column<Guid>(type: "uuid", nullable: false),
                    Data = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    Odometro = table.Column<int>(type: "integer", nullable: false),
                    ValorTotal = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AtualizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExcluidoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    SincronizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Abastecimentos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Abastecimentos_Veiculos_VeiculoId",
                        column: x => x.VeiculoId,
                        principalTable: "Veiculos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Recargas",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Local = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Kwh = table.Column<decimal>(type: "numeric(8,3)", precision: 8, scale: 3, nullable: false),
                    PrecoKwh = table.Column<decimal>(type: "numeric(6,3)", precision: 6, scale: 3, nullable: false),
                    CargaCompleta = table.Column<bool>(type: "boolean", nullable: false),
                    VeiculoId = table.Column<Guid>(type: "uuid", nullable: false),
                    UsuarioId = table.Column<Guid>(type: "uuid", nullable: false),
                    Data = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    Odometro = table.Column<int>(type: "integer", nullable: false),
                    ValorTotal = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AtualizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExcluidoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    SincronizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Recargas", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Recargas_Veiculos_VeiculoId",
                        column: x => x.VeiculoId,
                        principalTable: "Veiculos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Abastecimentos_VeiculoId_SincronizadoEm",
                table: "Abastecimentos",
                columns: new[] { "VeiculoId", "SincronizadoEm" });

            migrationBuilder.CreateIndex(
                name: "IX_Recargas_VeiculoId_SincronizadoEm",
                table: "Recargas",
                columns: new[] { "VeiculoId", "SincronizadoEm" });

            migrationBuilder.CreateIndex(
                name: "IX_Veiculos_DonoId_SincronizadoEm",
                table: "Veiculos",
                columns: new[] { "DonoId", "SincronizadoEm" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Abastecimentos");

            migrationBuilder.DropTable(
                name: "Recargas");

            migrationBuilder.DropTable(
                name: "Veiculos");
        }
    }
}
