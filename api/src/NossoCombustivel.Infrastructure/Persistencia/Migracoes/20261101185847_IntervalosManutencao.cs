using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class IntervalosManutencao : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "IntervalosManutencao",
                columns: table => new
                {
                    Chave = table.Column<string>(type: "character varying(400)", maxLength: 400, nullable: false),
                    Km = table.Column<int>(type: "integer", nullable: true),
                    Meses = table.Column<int>(type: "integer", nullable: true),
                    KmSevero = table.Column<int>(type: "integer", nullable: true),
                    MesesSevero = table.Column<int>(type: "integer", nullable: true),
                    Observacao = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: true),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_IntervalosManutencao", x => x.Chave);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "IntervalosManutencao");
        }
    }
}
