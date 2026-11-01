using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class TipoPostoEGasolina : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Tipo",
                table: "Postos",
                type: "character varying(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "Combustivel");

            migrationBuilder.AddColumn<string>(
                name: "TipoGasolina",
                table: "Abastecimentos",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Tipo",
                table: "Postos");

            migrationBuilder.DropColumn(
                name: "TipoGasolina",
                table: "Abastecimentos");
        }
    }
}
