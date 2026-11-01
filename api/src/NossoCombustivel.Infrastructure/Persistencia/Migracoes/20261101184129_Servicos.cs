using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class Servicos : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Servicos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    VeiculoId = table.Column<Guid>(type: "uuid", nullable: false),
                    UsuarioId = table.Column<Guid>(type: "uuid", nullable: false),
                    Tipo = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    Data = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    Odometro = table.Column<int>(type: "integer", nullable: true),
                    Categorias = table.Column<string>(type: "character varying(400)", maxLength: 400, nullable: false),
                    Detalhes = table.Column<string>(type: "character varying(8000)", maxLength: 8000, nullable: true),
                    ValorTotal = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: false),
                    ValorPecas = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    ValorMaoDeObra = table.Column<decimal>(type: "numeric(10,2)", precision: 10, scale: 2, nullable: true),
                    LugarId = table.Column<Guid>(type: "uuid", nullable: true),
                    LugarNome = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    FormaPagamento = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    CartaoId = table.Column<Guid>(type: "uuid", nullable: true),
                    Observacao = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AtualizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExcluidoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    SincronizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Servicos", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Servicos_Veiculos_VeiculoId",
                        column: x => x.VeiculoId,
                        principalTable: "Veiculos",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Servicos_VeiculoId_SincronizadoEm",
                table: "Servicos",
                columns: new[] { "VeiculoId", "SincronizadoEm" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Servicos");
        }
    }
}
