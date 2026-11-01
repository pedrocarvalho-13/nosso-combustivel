using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class Lugares : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_Postos",
                table: "Postos");

            migrationBuilder.RenameTable(
                name: "Postos",
                newName: "Lugares");

            migrationBuilder.RenameIndex(
                name: "IX_Postos_Origem_IdExterno",
                table: "Lugares",
                newName: "IX_Lugares_Origem_IdExterno");

            migrationBuilder.RenameIndex(
                name: "IX_Postos_Latitude_Longitude",
                table: "Lugares",
                newName: "IX_Lugares_Latitude_Longitude");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Lugares",
                table: "Lugares",
                column: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_Lugares",
                table: "Lugares");

            migrationBuilder.RenameTable(
                name: "Lugares",
                newName: "Postos");

            migrationBuilder.RenameIndex(
                name: "IX_Lugares_Origem_IdExterno",
                table: "Postos",
                newName: "IX_Postos_Origem_IdExterno");

            migrationBuilder.RenameIndex(
                name: "IX_Lugares_Latitude_Longitude",
                table: "Postos",
                newName: "IX_Postos_Latitude_Longitude");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Postos",
                table: "Postos",
                column: "Id");
        }
    }
}
