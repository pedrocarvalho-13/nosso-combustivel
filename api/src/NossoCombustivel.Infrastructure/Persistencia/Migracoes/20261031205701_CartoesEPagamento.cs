using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class CartoesEPagamento : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "CartaoId",
                table: "Recargas",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FormaPagamento",
                table: "Recargas",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "CartaoId",
                table: "Abastecimentos",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FormaPagamento",
                table: "Abastecimentos",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Cartoes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    DonoId = table.Column<Guid>(type: "uuid", nullable: false),
                    Nome = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: false),
                    Banco = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: true),
                    DiaFechamento = table.Column<int>(type: "integer", nullable: false),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AtualizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ExcluidoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    SincronizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cartoes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Cartoes_AspNetUsers_DonoId",
                        column: x => x.DonoId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Cartoes_DonoId_SincronizadoEm",
                table: "Cartoes",
                columns: new[] { "DonoId", "SincronizadoEm" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Cartoes");

            migrationBuilder.DropColumn(
                name: "CartaoId",
                table: "Recargas");

            migrationBuilder.DropColumn(
                name: "FormaPagamento",
                table: "Recargas");

            migrationBuilder.DropColumn(
                name: "CartaoId",
                table: "Abastecimentos");

            migrationBuilder.DropColumn(
                name: "FormaPagamento",
                table: "Abastecimentos");
        }
    }
}
