using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NossoCombustivel.Infrastructure.Persistencia.Migracoes
{
    /// <inheritdoc />
    public partial class CapacidadesVeiculo : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CapacidadesVeiculo",
                columns: table => new
                {
                    Chave = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    TipoVeiculo = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    Marca = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Modelo = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Ano = table.Column<int>(type: "integer", nullable: true),
                    CodigoFipe = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    TipoEnergia = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    TanqueL = table.Column<decimal>(type: "numeric(6,1)", precision: 6, scale: 1, nullable: true),
                    BateriaKwh = table.Column<decimal>(type: "numeric(6,1)", precision: 6, scale: 1, nullable: true),
                    CriadoEm = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CapacidadesVeiculo", x => x.Chave);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CapacidadesVeiculo");
        }
    }
}
