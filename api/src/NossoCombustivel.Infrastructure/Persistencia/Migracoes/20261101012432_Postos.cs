using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class Postos : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "PostoId",
                table: "Abastecimentos",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AreasBuscadas",
                columns: table => new
                {
                    Chave = table.Column<string>(type: "character varying(80)", maxLength: 80, nullable: false),
                    BuscadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AreasBuscadas", x => x.Chave);
                });

            migrationBuilder.CreateTable(
                name: "Postos",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Origem = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    IdExterno = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: true),
                    Nome = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Bandeira = table.Column<string>(type: "character varying(60)", maxLength: 60, nullable: true),
                    Endereco = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    Latitude = table.Column<double>(type: "double precision", nullable: false),
                    Longitude = table.Column<double>(type: "double precision", nullable: false),
                    CriadoPor = table.Column<Guid>(type: "uuid", nullable: true),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    AtualizadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Postos", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Abastecimentos_PostoId",
                table: "Abastecimentos",
                column: "PostoId");

            migrationBuilder.CreateIndex(
                name: "IX_Postos_Latitude_Longitude",
                table: "Postos",
                columns: new[] { "Latitude", "Longitude" });

            migrationBuilder.CreateIndex(
                name: "IX_Postos_Origem_IdExterno",
                table: "Postos",
                columns: new[] { "Origem", "IdExterno" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AreasBuscadas");

            migrationBuilder.DropTable(
                name: "Postos");

            migrationBuilder.DropIndex(
                name: "IX_Abastecimentos_PostoId",
                table: "Abastecimentos");

            migrationBuilder.DropColumn(
                name: "PostoId",
                table: "Abastecimentos");
        }
    }
}
