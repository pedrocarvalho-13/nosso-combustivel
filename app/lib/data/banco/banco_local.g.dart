// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco_local.dart';

// ignore_for_file: type=lint
class $VeiculosTable extends Veiculos
    with TableInfo<$VeiculosTable, VeiculoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VeiculosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excluidoEmMeta = const VerificationMeta(
    'excluidoEm',
  );
  @override
  late final GeneratedColumn<DateTime> excluidoEm = GeneratedColumn<DateTime>(
    'excluido_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendenteMeta = const VerificationMeta(
    'pendente',
  );
  @override
  late final GeneratedColumn<bool> pendente = GeneratedColumn<bool>(
    'pendente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendente" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoVeiculo, String> tipoVeiculo =
      GeneratedColumn<String>(
        'tipo_veiculo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('carro'),
      ).withConverter<TipoVeiculo>($VeiculosTable.$convertertipoVeiculo);
  static const VerificationMeta _apelidoMeta = const VerificationMeta(
    'apelido',
  );
  @override
  late final GeneratedColumn<String> apelido = GeneratedColumn<String>(
    'apelido',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeloMeta = const VerificationMeta('modelo');
  @override
  late final GeneratedColumn<String> modelo = GeneratedColumn<String>(
    'modelo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anoMeta = const VerificationMeta('ano');
  @override
  late final GeneratedColumn<int> ano = GeneratedColumn<int>(
    'ano',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoFipeMeta = const VerificationMeta(
    'codigoFipe',
  );
  @override
  late final GeneratedColumn<String> codigoFipe = GeneratedColumn<String>(
    'codigo_fipe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoEnergia, String> tipoEnergia =
      GeneratedColumn<String>(
        'tipo_energia',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoEnergia>($VeiculosTable.$convertertipoEnergia);
  static const VerificationMeta _combustiveisMeta = const VerificationMeta(
    'combustiveis',
  );
  @override
  late final GeneratedColumn<String> combustiveis = GeneratedColumn<String>(
    'combustiveis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacidadeTanqueMlMeta =
      const VerificationMeta('capacidadeTanqueMl');
  @override
  late final GeneratedColumn<int> capacidadeTanqueMl = GeneratedColumn<int>(
    'capacidade_tanque_ml',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacidadeBateriaWhMeta =
      const VerificationMeta('capacidadeBateriaWh');
  @override
  late final GeneratedColumn<int> capacidadeBateriaWh = GeneratedColumn<int>(
    'capacidade_bateria_wh',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odometroInicialMeta = const VerificationMeta(
    'odometroInicial',
  );
  @override
  late final GeneratedColumn<int> odometroInicial = GeneratedColumn<int>(
    'odometro_inicial',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    usuarioId,
    tipoVeiculo,
    apelido,
    marca,
    modelo,
    ano,
    codigoFipe,
    tipoEnergia,
    combustiveis,
    capacidadeTanqueMl,
    capacidadeBateriaWh,
    odometroInicial,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'veiculos';
  @override
  VerificationContext validateIntegrity(
    Insertable<VeiculoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('excluido_em')) {
      context.handle(
        _excluidoEmMeta,
        excluidoEm.isAcceptableOrUnknown(data['excluido_em']!, _excluidoEmMeta),
      );
    }
    if (data.containsKey('pendente')) {
      context.handle(
        _pendenteMeta,
        pendente.isAcceptableOrUnknown(data['pendente']!, _pendenteMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    }
    if (data.containsKey('apelido')) {
      context.handle(
        _apelidoMeta,
        apelido.isAcceptableOrUnknown(data['apelido']!, _apelidoMeta),
      );
    } else if (isInserting) {
      context.missing(_apelidoMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    } else if (isInserting) {
      context.missing(_marcaMeta);
    }
    if (data.containsKey('modelo')) {
      context.handle(
        _modeloMeta,
        modelo.isAcceptableOrUnknown(data['modelo']!, _modeloMeta),
      );
    } else if (isInserting) {
      context.missing(_modeloMeta);
    }
    if (data.containsKey('ano')) {
      context.handle(
        _anoMeta,
        ano.isAcceptableOrUnknown(data['ano']!, _anoMeta),
      );
    }
    if (data.containsKey('codigo_fipe')) {
      context.handle(
        _codigoFipeMeta,
        codigoFipe.isAcceptableOrUnknown(data['codigo_fipe']!, _codigoFipeMeta),
      );
    }
    if (data.containsKey('combustiveis')) {
      context.handle(
        _combustiveisMeta,
        combustiveis.isAcceptableOrUnknown(
          data['combustiveis']!,
          _combustiveisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_combustiveisMeta);
    }
    if (data.containsKey('capacidade_tanque_ml')) {
      context.handle(
        _capacidadeTanqueMlMeta,
        capacidadeTanqueMl.isAcceptableOrUnknown(
          data['capacidade_tanque_ml']!,
          _capacidadeTanqueMlMeta,
        ),
      );
    }
    if (data.containsKey('capacidade_bateria_wh')) {
      context.handle(
        _capacidadeBateriaWhMeta,
        capacidadeBateriaWh.isAcceptableOrUnknown(
          data['capacidade_bateria_wh']!,
          _capacidadeBateriaWhMeta,
        ),
      );
    }
    if (data.containsKey('odometro_inicial')) {
      context.handle(
        _odometroInicialMeta,
        odometroInicial.isAcceptableOrUnknown(
          data['odometro_inicial']!,
          _odometroInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_odometroInicialMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VeiculoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VeiculoLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      excluidoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}excluido_em'],
      ),
      pendente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendente'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      ),
      tipoVeiculo: $VeiculosTable.$convertertipoVeiculo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo_veiculo'],
        )!,
      ),
      apelido: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apelido'],
      )!,
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      )!,
      modelo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modelo'],
      )!,
      ano: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ano'],
      ),
      codigoFipe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_fipe'],
      ),
      tipoEnergia: $VeiculosTable.$convertertipoEnergia.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo_energia'],
        )!,
      ),
      combustiveis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}combustiveis'],
      )!,
      capacidadeTanqueMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacidade_tanque_ml'],
      ),
      capacidadeBateriaWh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacidade_bateria_wh'],
      ),
      odometroInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometro_inicial'],
      )!,
    );
  }

  @override
  $VeiculosTable createAlias(String alias) {
    return $VeiculosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoVeiculo, String, String> $convertertipoVeiculo =
      const EnumNameConverter<TipoVeiculo>(TipoVeiculo.values);
  static JsonTypeConverter2<TipoEnergia, String, String> $convertertipoEnergia =
      const EnumNameConverter<TipoEnergia>(TipoEnergia.values);
}

class VeiculoLinha extends DataClass implements Insertable<VeiculoLinha> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? excluidoEm;
  final bool pendente;
  final String? usuarioId;
  final TipoVeiculo tipoVeiculo;
  final String apelido;
  final String marca;
  final String modelo;
  final int? ano;
  final String? codigoFipe;
  final TipoEnergia tipoEnergia;
  final String combustiveis;
  final int? capacidadeTanqueMl;
  final int? capacidadeBateriaWh;
  final int odometroInicial;
  const VeiculoLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.excluidoEm,
    required this.pendente,
    this.usuarioId,
    required this.tipoVeiculo,
    required this.apelido,
    required this.marca,
    required this.modelo,
    this.ano,
    this.codigoFipe,
    required this.tipoEnergia,
    required this.combustiveis,
    this.capacidadeTanqueMl,
    this.capacidadeBateriaWh,
    required this.odometroInicial,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || excluidoEm != null) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm);
    }
    map['pendente'] = Variable<bool>(pendente);
    if (!nullToAbsent || usuarioId != null) {
      map['usuario_id'] = Variable<String>(usuarioId);
    }
    {
      map['tipo_veiculo'] = Variable<String>(
        $VeiculosTable.$convertertipoVeiculo.toSql(tipoVeiculo),
      );
    }
    map['apelido'] = Variable<String>(apelido);
    map['marca'] = Variable<String>(marca);
    map['modelo'] = Variable<String>(modelo);
    if (!nullToAbsent || ano != null) {
      map['ano'] = Variable<int>(ano);
    }
    if (!nullToAbsent || codigoFipe != null) {
      map['codigo_fipe'] = Variable<String>(codigoFipe);
    }
    {
      map['tipo_energia'] = Variable<String>(
        $VeiculosTable.$convertertipoEnergia.toSql(tipoEnergia),
      );
    }
    map['combustiveis'] = Variable<String>(combustiveis);
    if (!nullToAbsent || capacidadeTanqueMl != null) {
      map['capacidade_tanque_ml'] = Variable<int>(capacidadeTanqueMl);
    }
    if (!nullToAbsent || capacidadeBateriaWh != null) {
      map['capacidade_bateria_wh'] = Variable<int>(capacidadeBateriaWh);
    }
    map['odometro_inicial'] = Variable<int>(odometroInicial);
    return map;
  }

  VeiculosCompanion toCompanion(bool nullToAbsent) {
    return VeiculosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      excluidoEm: excluidoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(excluidoEm),
      pendente: Value(pendente),
      usuarioId: usuarioId == null && nullToAbsent
          ? const Value.absent()
          : Value(usuarioId),
      tipoVeiculo: Value(tipoVeiculo),
      apelido: Value(apelido),
      marca: Value(marca),
      modelo: Value(modelo),
      ano: ano == null && nullToAbsent ? const Value.absent() : Value(ano),
      codigoFipe: codigoFipe == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoFipe),
      tipoEnergia: Value(tipoEnergia),
      combustiveis: Value(combustiveis),
      capacidadeTanqueMl: capacidadeTanqueMl == null && nullToAbsent
          ? const Value.absent()
          : Value(capacidadeTanqueMl),
      capacidadeBateriaWh: capacidadeBateriaWh == null && nullToAbsent
          ? const Value.absent()
          : Value(capacidadeBateriaWh),
      odometroInicial: Value(odometroInicial),
    );
  }

  factory VeiculoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VeiculoLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      excluidoEm: serializer.fromJson<DateTime?>(json['excluidoEm']),
      pendente: serializer.fromJson<bool>(json['pendente']),
      usuarioId: serializer.fromJson<String?>(json['usuarioId']),
      tipoVeiculo: $VeiculosTable.$convertertipoVeiculo.fromJson(
        serializer.fromJson<String>(json['tipoVeiculo']),
      ),
      apelido: serializer.fromJson<String>(json['apelido']),
      marca: serializer.fromJson<String>(json['marca']),
      modelo: serializer.fromJson<String>(json['modelo']),
      ano: serializer.fromJson<int?>(json['ano']),
      codigoFipe: serializer.fromJson<String?>(json['codigoFipe']),
      tipoEnergia: $VeiculosTable.$convertertipoEnergia.fromJson(
        serializer.fromJson<String>(json['tipoEnergia']),
      ),
      combustiveis: serializer.fromJson<String>(json['combustiveis']),
      capacidadeTanqueMl: serializer.fromJson<int?>(json['capacidadeTanqueMl']),
      capacidadeBateriaWh: serializer.fromJson<int?>(
        json['capacidadeBateriaWh'],
      ),
      odometroInicial: serializer.fromJson<int>(json['odometroInicial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'excluidoEm': serializer.toJson<DateTime?>(excluidoEm),
      'pendente': serializer.toJson<bool>(pendente),
      'usuarioId': serializer.toJson<String?>(usuarioId),
      'tipoVeiculo': serializer.toJson<String>(
        $VeiculosTable.$convertertipoVeiculo.toJson(tipoVeiculo),
      ),
      'apelido': serializer.toJson<String>(apelido),
      'marca': serializer.toJson<String>(marca),
      'modelo': serializer.toJson<String>(modelo),
      'ano': serializer.toJson<int?>(ano),
      'codigoFipe': serializer.toJson<String?>(codigoFipe),
      'tipoEnergia': serializer.toJson<String>(
        $VeiculosTable.$convertertipoEnergia.toJson(tipoEnergia),
      ),
      'combustiveis': serializer.toJson<String>(combustiveis),
      'capacidadeTanqueMl': serializer.toJson<int?>(capacidadeTanqueMl),
      'capacidadeBateriaWh': serializer.toJson<int?>(capacidadeBateriaWh),
      'odometroInicial': serializer.toJson<int>(odometroInicial),
    };
  }

  VeiculoLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> excluidoEm = const Value.absent(),
    bool? pendente,
    Value<String?> usuarioId = const Value.absent(),
    TipoVeiculo? tipoVeiculo,
    String? apelido,
    String? marca,
    String? modelo,
    Value<int?> ano = const Value.absent(),
    Value<String?> codigoFipe = const Value.absent(),
    TipoEnergia? tipoEnergia,
    String? combustiveis,
    Value<int?> capacidadeTanqueMl = const Value.absent(),
    Value<int?> capacidadeBateriaWh = const Value.absent(),
    int? odometroInicial,
  }) => VeiculoLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    excluidoEm: excluidoEm.present ? excluidoEm.value : this.excluidoEm,
    pendente: pendente ?? this.pendente,
    usuarioId: usuarioId.present ? usuarioId.value : this.usuarioId,
    tipoVeiculo: tipoVeiculo ?? this.tipoVeiculo,
    apelido: apelido ?? this.apelido,
    marca: marca ?? this.marca,
    modelo: modelo ?? this.modelo,
    ano: ano.present ? ano.value : this.ano,
    codigoFipe: codigoFipe.present ? codigoFipe.value : this.codigoFipe,
    tipoEnergia: tipoEnergia ?? this.tipoEnergia,
    combustiveis: combustiveis ?? this.combustiveis,
    capacidadeTanqueMl: capacidadeTanqueMl.present
        ? capacidadeTanqueMl.value
        : this.capacidadeTanqueMl,
    capacidadeBateriaWh: capacidadeBateriaWh.present
        ? capacidadeBateriaWh.value
        : this.capacidadeBateriaWh,
    odometroInicial: odometroInicial ?? this.odometroInicial,
  );
  VeiculoLinha copyWithCompanion(VeiculosCompanion data) {
    return VeiculoLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      excluidoEm: data.excluidoEm.present
          ? data.excluidoEm.value
          : this.excluidoEm,
      pendente: data.pendente.present ? data.pendente.value : this.pendente,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      tipoVeiculo: data.tipoVeiculo.present
          ? data.tipoVeiculo.value
          : this.tipoVeiculo,
      apelido: data.apelido.present ? data.apelido.value : this.apelido,
      marca: data.marca.present ? data.marca.value : this.marca,
      modelo: data.modelo.present ? data.modelo.value : this.modelo,
      ano: data.ano.present ? data.ano.value : this.ano,
      codigoFipe: data.codigoFipe.present
          ? data.codigoFipe.value
          : this.codigoFipe,
      tipoEnergia: data.tipoEnergia.present
          ? data.tipoEnergia.value
          : this.tipoEnergia,
      combustiveis: data.combustiveis.present
          ? data.combustiveis.value
          : this.combustiveis,
      capacidadeTanqueMl: data.capacidadeTanqueMl.present
          ? data.capacidadeTanqueMl.value
          : this.capacidadeTanqueMl,
      capacidadeBateriaWh: data.capacidadeBateriaWh.present
          ? data.capacidadeBateriaWh.value
          : this.capacidadeBateriaWh,
      odometroInicial: data.odometroInicial.present
          ? data.odometroInicial.value
          : this.odometroInicial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VeiculoLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipoVeiculo: $tipoVeiculo, ')
          ..write('apelido: $apelido, ')
          ..write('marca: $marca, ')
          ..write('modelo: $modelo, ')
          ..write('ano: $ano, ')
          ..write('codigoFipe: $codigoFipe, ')
          ..write('tipoEnergia: $tipoEnergia, ')
          ..write('combustiveis: $combustiveis, ')
          ..write('capacidadeTanqueMl: $capacidadeTanqueMl, ')
          ..write('capacidadeBateriaWh: $capacidadeBateriaWh, ')
          ..write('odometroInicial: $odometroInicial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    usuarioId,
    tipoVeiculo,
    apelido,
    marca,
    modelo,
    ano,
    codigoFipe,
    tipoEnergia,
    combustiveis,
    capacidadeTanqueMl,
    capacidadeBateriaWh,
    odometroInicial,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VeiculoLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.excluidoEm == this.excluidoEm &&
          other.pendente == this.pendente &&
          other.usuarioId == this.usuarioId &&
          other.tipoVeiculo == this.tipoVeiculo &&
          other.apelido == this.apelido &&
          other.marca == this.marca &&
          other.modelo == this.modelo &&
          other.ano == this.ano &&
          other.codigoFipe == this.codigoFipe &&
          other.tipoEnergia == this.tipoEnergia &&
          other.combustiveis == this.combustiveis &&
          other.capacidadeTanqueMl == this.capacidadeTanqueMl &&
          other.capacidadeBateriaWh == this.capacidadeBateriaWh &&
          other.odometroInicial == this.odometroInicial);
}

class VeiculosCompanion extends UpdateCompanion<VeiculoLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> excluidoEm;
  final Value<bool> pendente;
  final Value<String?> usuarioId;
  final Value<TipoVeiculo> tipoVeiculo;
  final Value<String> apelido;
  final Value<String> marca;
  final Value<String> modelo;
  final Value<int?> ano;
  final Value<String?> codigoFipe;
  final Value<TipoEnergia> tipoEnergia;
  final Value<String> combustiveis;
  final Value<int?> capacidadeTanqueMl;
  final Value<int?> capacidadeBateriaWh;
  final Value<int> odometroInicial;
  final Value<int> rowid;
  const VeiculosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.tipoVeiculo = const Value.absent(),
    this.apelido = const Value.absent(),
    this.marca = const Value.absent(),
    this.modelo = const Value.absent(),
    this.ano = const Value.absent(),
    this.codigoFipe = const Value.absent(),
    this.tipoEnergia = const Value.absent(),
    this.combustiveis = const Value.absent(),
    this.capacidadeTanqueMl = const Value.absent(),
    this.capacidadeBateriaWh = const Value.absent(),
    this.odometroInicial = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VeiculosCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.tipoVeiculo = const Value.absent(),
    required String apelido,
    required String marca,
    required String modelo,
    this.ano = const Value.absent(),
    this.codigoFipe = const Value.absent(),
    required TipoEnergia tipoEnergia,
    required String combustiveis,
    this.capacidadeTanqueMl = const Value.absent(),
    this.capacidadeBateriaWh = const Value.absent(),
    required int odometroInicial,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       apelido = Value(apelido),
       marca = Value(marca),
       modelo = Value(modelo),
       tipoEnergia = Value(tipoEnergia),
       combustiveis = Value(combustiveis),
       odometroInicial = Value(odometroInicial);
  static Insertable<VeiculoLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? excluidoEm,
    Expression<bool>? pendente,
    Expression<String>? usuarioId,
    Expression<String>? tipoVeiculo,
    Expression<String>? apelido,
    Expression<String>? marca,
    Expression<String>? modelo,
    Expression<int>? ano,
    Expression<String>? codigoFipe,
    Expression<String>? tipoEnergia,
    Expression<String>? combustiveis,
    Expression<int>? capacidadeTanqueMl,
    Expression<int>? capacidadeBateriaWh,
    Expression<int>? odometroInicial,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (excluidoEm != null) 'excluido_em': excluidoEm,
      if (pendente != null) 'pendente': pendente,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (tipoVeiculo != null) 'tipo_veiculo': tipoVeiculo,
      if (apelido != null) 'apelido': apelido,
      if (marca != null) 'marca': marca,
      if (modelo != null) 'modelo': modelo,
      if (ano != null) 'ano': ano,
      if (codigoFipe != null) 'codigo_fipe': codigoFipe,
      if (tipoEnergia != null) 'tipo_energia': tipoEnergia,
      if (combustiveis != null) 'combustiveis': combustiveis,
      if (capacidadeTanqueMl != null)
        'capacidade_tanque_ml': capacidadeTanqueMl,
      if (capacidadeBateriaWh != null)
        'capacidade_bateria_wh': capacidadeBateriaWh,
      if (odometroInicial != null) 'odometro_inicial': odometroInicial,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VeiculosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? excluidoEm,
    Value<bool>? pendente,
    Value<String?>? usuarioId,
    Value<TipoVeiculo>? tipoVeiculo,
    Value<String>? apelido,
    Value<String>? marca,
    Value<String>? modelo,
    Value<int?>? ano,
    Value<String?>? codigoFipe,
    Value<TipoEnergia>? tipoEnergia,
    Value<String>? combustiveis,
    Value<int?>? capacidadeTanqueMl,
    Value<int?>? capacidadeBateriaWh,
    Value<int>? odometroInicial,
    Value<int>? rowid,
  }) {
    return VeiculosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      excluidoEm: excluidoEm ?? this.excluidoEm,
      pendente: pendente ?? this.pendente,
      usuarioId: usuarioId ?? this.usuarioId,
      tipoVeiculo: tipoVeiculo ?? this.tipoVeiculo,
      apelido: apelido ?? this.apelido,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      codigoFipe: codigoFipe ?? this.codigoFipe,
      tipoEnergia: tipoEnergia ?? this.tipoEnergia,
      combustiveis: combustiveis ?? this.combustiveis,
      capacidadeTanqueMl: capacidadeTanqueMl ?? this.capacidadeTanqueMl,
      capacidadeBateriaWh: capacidadeBateriaWh ?? this.capacidadeBateriaWh,
      odometroInicial: odometroInicial ?? this.odometroInicial,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (excluidoEm.present) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm.value);
    }
    if (pendente.present) {
      map['pendente'] = Variable<bool>(pendente.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (tipoVeiculo.present) {
      map['tipo_veiculo'] = Variable<String>(
        $VeiculosTable.$convertertipoVeiculo.toSql(tipoVeiculo.value),
      );
    }
    if (apelido.present) {
      map['apelido'] = Variable<String>(apelido.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (modelo.present) {
      map['modelo'] = Variable<String>(modelo.value);
    }
    if (ano.present) {
      map['ano'] = Variable<int>(ano.value);
    }
    if (codigoFipe.present) {
      map['codigo_fipe'] = Variable<String>(codigoFipe.value);
    }
    if (tipoEnergia.present) {
      map['tipo_energia'] = Variable<String>(
        $VeiculosTable.$convertertipoEnergia.toSql(tipoEnergia.value),
      );
    }
    if (combustiveis.present) {
      map['combustiveis'] = Variable<String>(combustiveis.value);
    }
    if (capacidadeTanqueMl.present) {
      map['capacidade_tanque_ml'] = Variable<int>(capacidadeTanqueMl.value);
    }
    if (capacidadeBateriaWh.present) {
      map['capacidade_bateria_wh'] = Variable<int>(capacidadeBateriaWh.value);
    }
    if (odometroInicial.present) {
      map['odometro_inicial'] = Variable<int>(odometroInicial.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VeiculosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('tipoVeiculo: $tipoVeiculo, ')
          ..write('apelido: $apelido, ')
          ..write('marca: $marca, ')
          ..write('modelo: $modelo, ')
          ..write('ano: $ano, ')
          ..write('codigoFipe: $codigoFipe, ')
          ..write('tipoEnergia: $tipoEnergia, ')
          ..write('combustiveis: $combustiveis, ')
          ..write('capacidadeTanqueMl: $capacidadeTanqueMl, ')
          ..write('capacidadeBateriaWh: $capacidadeBateriaWh, ')
          ..write('odometroInicial: $odometroInicial, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AbastecimentosTable extends Abastecimentos
    with TableInfo<$AbastecimentosTable, AbastecimentoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbastecimentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excluidoEmMeta = const VerificationMeta(
    'excluidoEm',
  );
  @override
  late final GeneratedColumn<DateTime> excluidoEm = GeneratedColumn<DateTime>(
    'excluido_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendenteMeta = const VerificationMeta(
    'pendente',
  );
  @override
  late final GeneratedColumn<bool> pendente = GeneratedColumn<bool>(
    'pendente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendente" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _veiculoIdMeta = const VerificationMeta(
    'veiculoId',
  );
  @override
  late final GeneratedColumn<String> veiculoId = GeneratedColumn<String>(
    'veiculo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES veiculos (id)',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometroMeta = const VerificationMeta(
    'odometro',
  );
  @override
  late final GeneratedColumn<int> odometro = GeneratedColumn<int>(
    'odometro',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Combustivel, String> combustivel =
      GeneratedColumn<String>(
        'combustivel',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Combustivel>($AbastecimentosTable.$convertercombustivel);
  static const VerificationMeta _litrosMlMeta = const VerificationMeta(
    'litrosMl',
  );
  @override
  late final GeneratedColumn<int> litrosMl = GeneratedColumn<int>(
    'litros_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precoLitroMilesimosMeta =
      const VerificationMeta('precoLitroMilesimos');
  @override
  late final GeneratedColumn<int> precoLitroMilesimos = GeneratedColumn<int>(
    'preco_litro_milesimos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  @override
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tanqueCheioMeta = const VerificationMeta(
    'tanqueCheio',
  );
  @override
  late final GeneratedColumn<bool> tanqueCheio = GeneratedColumn<bool>(
    'tanque_cheio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tanque_cheio" IN (0, 1))',
    ),
  );
  static const VerificationMeta _postoMeta = const VerificationMeta('posto');
  @override
  late final GeneratedColumn<String> posto = GeneratedColumn<String>(
    'posto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postoIdMeta = const VerificationMeta(
    'postoId',
  );
  @override
  late final GeneratedColumn<String> postoId = GeneratedColumn<String>(
    'posto_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaPagamento?, String>
  formaPagamento =
      GeneratedColumn<String>(
        'forma_pagamento',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<FormaPagamento?>(
        $AbastecimentosTable.$converterformaPagamenton,
      );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<String> cartaoId = GeneratedColumn<String>(
    'cartao_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contaNaMediaMeta = const VerificationMeta(
    'contaNaMedia',
  );
  @override
  late final GeneratedColumn<bool> contaNaMedia = GeneratedColumn<bool>(
    'conta_na_media',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("conta_na_media" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    veiculoId,
    data,
    odometro,
    combustivel,
    litrosMl,
    precoLitroMilesimos,
    valorCentavos,
    tanqueCheio,
    posto,
    postoId,
    formaPagamento,
    cartaoId,
    contaNaMedia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'abastecimentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<AbastecimentoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('excluido_em')) {
      context.handle(
        _excluidoEmMeta,
        excluidoEm.isAcceptableOrUnknown(data['excluido_em']!, _excluidoEmMeta),
      );
    }
    if (data.containsKey('pendente')) {
      context.handle(
        _pendenteMeta,
        pendente.isAcceptableOrUnknown(data['pendente']!, _pendenteMeta),
      );
    }
    if (data.containsKey('veiculo_id')) {
      context.handle(
        _veiculoIdMeta,
        veiculoId.isAcceptableOrUnknown(data['veiculo_id']!, _veiculoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_veiculoIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('odometro')) {
      context.handle(
        _odometroMeta,
        odometro.isAcceptableOrUnknown(data['odometro']!, _odometroMeta),
      );
    } else if (isInserting) {
      context.missing(_odometroMeta);
    }
    if (data.containsKey('litros_ml')) {
      context.handle(
        _litrosMlMeta,
        litrosMl.isAcceptableOrUnknown(data['litros_ml']!, _litrosMlMeta),
      );
    } else if (isInserting) {
      context.missing(_litrosMlMeta);
    }
    if (data.containsKey('preco_litro_milesimos')) {
      context.handle(
        _precoLitroMilesimosMeta,
        precoLitroMilesimos.isAcceptableOrUnknown(
          data['preco_litro_milesimos']!,
          _precoLitroMilesimosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precoLitroMilesimosMeta);
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    if (data.containsKey('tanque_cheio')) {
      context.handle(
        _tanqueCheioMeta,
        tanqueCheio.isAcceptableOrUnknown(
          data['tanque_cheio']!,
          _tanqueCheioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tanqueCheioMeta);
    }
    if (data.containsKey('posto')) {
      context.handle(
        _postoMeta,
        posto.isAcceptableOrUnknown(data['posto']!, _postoMeta),
      );
    }
    if (data.containsKey('posto_id')) {
      context.handle(
        _postoIdMeta,
        postoId.isAcceptableOrUnknown(data['posto_id']!, _postoIdMeta),
      );
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    }
    if (data.containsKey('conta_na_media')) {
      context.handle(
        _contaNaMediaMeta,
        contaNaMedia.isAcceptableOrUnknown(
          data['conta_na_media']!,
          _contaNaMediaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AbastecimentoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AbastecimentoLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      excluidoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}excluido_em'],
      ),
      pendente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendente'],
      )!,
      veiculoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}veiculo_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      odometro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometro'],
      )!,
      combustivel: $AbastecimentosTable.$convertercombustivel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}combustivel'],
        )!,
      ),
      litrosMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}litros_ml'],
      )!,
      precoLitroMilesimos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preco_litro_milesimos'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
      tanqueCheio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tanque_cheio'],
      )!,
      posto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posto'],
      ),
      postoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posto_id'],
      ),
      formaPagamento: $AbastecimentosTable.$converterformaPagamenton.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma_pagamento'],
        ),
      ),
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cartao_id'],
      ),
      contaNaMedia: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}conta_na_media'],
      )!,
    );
  }

  @override
  $AbastecimentosTable createAlias(String alias) {
    return $AbastecimentosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Combustivel, String, String> $convertercombustivel =
      const EnumNameConverter<Combustivel>(Combustivel.values);
  static JsonTypeConverter2<FormaPagamento, String, String>
  $converterformaPagamento = const EnumNameConverter<FormaPagamento>(
    FormaPagamento.values,
  );
  static JsonTypeConverter2<FormaPagamento?, String?, String?>
  $converterformaPagamenton = JsonTypeConverter2.asNullable(
    $converterformaPagamento,
  );
}

class AbastecimentoLinha extends DataClass
    implements Insertable<AbastecimentoLinha> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? excluidoEm;
  final bool pendente;
  final String veiculoId;
  final DateTime data;
  final int odometro;
  final Combustivel combustivel;
  final int litrosMl;
  final int precoLitroMilesimos;
  final int valorCentavos;
  final bool tanqueCheio;
  final String? posto;
  final String? postoId;
  final FormaPagamento? formaPagamento;
  final String? cartaoId;
  final bool contaNaMedia;
  const AbastecimentoLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.excluidoEm,
    required this.pendente,
    required this.veiculoId,
    required this.data,
    required this.odometro,
    required this.combustivel,
    required this.litrosMl,
    required this.precoLitroMilesimos,
    required this.valorCentavos,
    required this.tanqueCheio,
    this.posto,
    this.postoId,
    this.formaPagamento,
    this.cartaoId,
    required this.contaNaMedia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || excluidoEm != null) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm);
    }
    map['pendente'] = Variable<bool>(pendente);
    map['veiculo_id'] = Variable<String>(veiculoId);
    map['data'] = Variable<DateTime>(data);
    map['odometro'] = Variable<int>(odometro);
    {
      map['combustivel'] = Variable<String>(
        $AbastecimentosTable.$convertercombustivel.toSql(combustivel),
      );
    }
    map['litros_ml'] = Variable<int>(litrosMl);
    map['preco_litro_milesimos'] = Variable<int>(precoLitroMilesimos);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    map['tanque_cheio'] = Variable<bool>(tanqueCheio);
    if (!nullToAbsent || posto != null) {
      map['posto'] = Variable<String>(posto);
    }
    if (!nullToAbsent || postoId != null) {
      map['posto_id'] = Variable<String>(postoId);
    }
    if (!nullToAbsent || formaPagamento != null) {
      map['forma_pagamento'] = Variable<String>(
        $AbastecimentosTable.$converterformaPagamenton.toSql(formaPagamento),
      );
    }
    if (!nullToAbsent || cartaoId != null) {
      map['cartao_id'] = Variable<String>(cartaoId);
    }
    map['conta_na_media'] = Variable<bool>(contaNaMedia);
    return map;
  }

  AbastecimentosCompanion toCompanion(bool nullToAbsent) {
    return AbastecimentosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      excluidoEm: excluidoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(excluidoEm),
      pendente: Value(pendente),
      veiculoId: Value(veiculoId),
      data: Value(data),
      odometro: Value(odometro),
      combustivel: Value(combustivel),
      litrosMl: Value(litrosMl),
      precoLitroMilesimos: Value(precoLitroMilesimos),
      valorCentavos: Value(valorCentavos),
      tanqueCheio: Value(tanqueCheio),
      posto: posto == null && nullToAbsent
          ? const Value.absent()
          : Value(posto),
      postoId: postoId == null && nullToAbsent
          ? const Value.absent()
          : Value(postoId),
      formaPagamento: formaPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(formaPagamento),
      cartaoId: cartaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartaoId),
      contaNaMedia: Value(contaNaMedia),
    );
  }

  factory AbastecimentoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AbastecimentoLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      excluidoEm: serializer.fromJson<DateTime?>(json['excluidoEm']),
      pendente: serializer.fromJson<bool>(json['pendente']),
      veiculoId: serializer.fromJson<String>(json['veiculoId']),
      data: serializer.fromJson<DateTime>(json['data']),
      odometro: serializer.fromJson<int>(json['odometro']),
      combustivel: $AbastecimentosTable.$convertercombustivel.fromJson(
        serializer.fromJson<String>(json['combustivel']),
      ),
      litrosMl: serializer.fromJson<int>(json['litrosMl']),
      precoLitroMilesimos: serializer.fromJson<int>(
        json['precoLitroMilesimos'],
      ),
      valorCentavos: serializer.fromJson<int>(json['valorCentavos']),
      tanqueCheio: serializer.fromJson<bool>(json['tanqueCheio']),
      posto: serializer.fromJson<String?>(json['posto']),
      postoId: serializer.fromJson<String?>(json['postoId']),
      formaPagamento: $AbastecimentosTable.$converterformaPagamenton.fromJson(
        serializer.fromJson<String?>(json['formaPagamento']),
      ),
      cartaoId: serializer.fromJson<String?>(json['cartaoId']),
      contaNaMedia: serializer.fromJson<bool>(json['contaNaMedia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'excluidoEm': serializer.toJson<DateTime?>(excluidoEm),
      'pendente': serializer.toJson<bool>(pendente),
      'veiculoId': serializer.toJson<String>(veiculoId),
      'data': serializer.toJson<DateTime>(data),
      'odometro': serializer.toJson<int>(odometro),
      'combustivel': serializer.toJson<String>(
        $AbastecimentosTable.$convertercombustivel.toJson(combustivel),
      ),
      'litrosMl': serializer.toJson<int>(litrosMl),
      'precoLitroMilesimos': serializer.toJson<int>(precoLitroMilesimos),
      'valorCentavos': serializer.toJson<int>(valorCentavos),
      'tanqueCheio': serializer.toJson<bool>(tanqueCheio),
      'posto': serializer.toJson<String?>(posto),
      'postoId': serializer.toJson<String?>(postoId),
      'formaPagamento': serializer.toJson<String?>(
        $AbastecimentosTable.$converterformaPagamenton.toJson(formaPagamento),
      ),
      'cartaoId': serializer.toJson<String?>(cartaoId),
      'contaNaMedia': serializer.toJson<bool>(contaNaMedia),
    };
  }

  AbastecimentoLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> excluidoEm = const Value.absent(),
    bool? pendente,
    String? veiculoId,
    DateTime? data,
    int? odometro,
    Combustivel? combustivel,
    int? litrosMl,
    int? precoLitroMilesimos,
    int? valorCentavos,
    bool? tanqueCheio,
    Value<String?> posto = const Value.absent(),
    Value<String?> postoId = const Value.absent(),
    Value<FormaPagamento?> formaPagamento = const Value.absent(),
    Value<String?> cartaoId = const Value.absent(),
    bool? contaNaMedia,
  }) => AbastecimentoLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    excluidoEm: excluidoEm.present ? excluidoEm.value : this.excluidoEm,
    pendente: pendente ?? this.pendente,
    veiculoId: veiculoId ?? this.veiculoId,
    data: data ?? this.data,
    odometro: odometro ?? this.odometro,
    combustivel: combustivel ?? this.combustivel,
    litrosMl: litrosMl ?? this.litrosMl,
    precoLitroMilesimos: precoLitroMilesimos ?? this.precoLitroMilesimos,
    valorCentavos: valorCentavos ?? this.valorCentavos,
    tanqueCheio: tanqueCheio ?? this.tanqueCheio,
    posto: posto.present ? posto.value : this.posto,
    postoId: postoId.present ? postoId.value : this.postoId,
    formaPagamento: formaPagamento.present
        ? formaPagamento.value
        : this.formaPagamento,
    cartaoId: cartaoId.present ? cartaoId.value : this.cartaoId,
    contaNaMedia: contaNaMedia ?? this.contaNaMedia,
  );
  AbastecimentoLinha copyWithCompanion(AbastecimentosCompanion data) {
    return AbastecimentoLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      excluidoEm: data.excluidoEm.present
          ? data.excluidoEm.value
          : this.excluidoEm,
      pendente: data.pendente.present ? data.pendente.value : this.pendente,
      veiculoId: data.veiculoId.present ? data.veiculoId.value : this.veiculoId,
      data: data.data.present ? data.data.value : this.data,
      odometro: data.odometro.present ? data.odometro.value : this.odometro,
      combustivel: data.combustivel.present
          ? data.combustivel.value
          : this.combustivel,
      litrosMl: data.litrosMl.present ? data.litrosMl.value : this.litrosMl,
      precoLitroMilesimos: data.precoLitroMilesimos.present
          ? data.precoLitroMilesimos.value
          : this.precoLitroMilesimos,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
      tanqueCheio: data.tanqueCheio.present
          ? data.tanqueCheio.value
          : this.tanqueCheio,
      posto: data.posto.present ? data.posto.value : this.posto,
      postoId: data.postoId.present ? data.postoId.value : this.postoId,
      formaPagamento: data.formaPagamento.present
          ? data.formaPagamento.value
          : this.formaPagamento,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      contaNaMedia: data.contaNaMedia.present
          ? data.contaNaMedia.value
          : this.contaNaMedia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AbastecimentoLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('veiculoId: $veiculoId, ')
          ..write('data: $data, ')
          ..write('odometro: $odometro, ')
          ..write('combustivel: $combustivel, ')
          ..write('litrosMl: $litrosMl, ')
          ..write('precoLitroMilesimos: $precoLitroMilesimos, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('tanqueCheio: $tanqueCheio, ')
          ..write('posto: $posto, ')
          ..write('postoId: $postoId, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('contaNaMedia: $contaNaMedia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    veiculoId,
    data,
    odometro,
    combustivel,
    litrosMl,
    precoLitroMilesimos,
    valorCentavos,
    tanqueCheio,
    posto,
    postoId,
    formaPagamento,
    cartaoId,
    contaNaMedia,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AbastecimentoLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.excluidoEm == this.excluidoEm &&
          other.pendente == this.pendente &&
          other.veiculoId == this.veiculoId &&
          other.data == this.data &&
          other.odometro == this.odometro &&
          other.combustivel == this.combustivel &&
          other.litrosMl == this.litrosMl &&
          other.precoLitroMilesimos == this.precoLitroMilesimos &&
          other.valorCentavos == this.valorCentavos &&
          other.tanqueCheio == this.tanqueCheio &&
          other.posto == this.posto &&
          other.postoId == this.postoId &&
          other.formaPagamento == this.formaPagamento &&
          other.cartaoId == this.cartaoId &&
          other.contaNaMedia == this.contaNaMedia);
}

class AbastecimentosCompanion extends UpdateCompanion<AbastecimentoLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> excluidoEm;
  final Value<bool> pendente;
  final Value<String> veiculoId;
  final Value<DateTime> data;
  final Value<int> odometro;
  final Value<Combustivel> combustivel;
  final Value<int> litrosMl;
  final Value<int> precoLitroMilesimos;
  final Value<int> valorCentavos;
  final Value<bool> tanqueCheio;
  final Value<String?> posto;
  final Value<String?> postoId;
  final Value<FormaPagamento?> formaPagamento;
  final Value<String?> cartaoId;
  final Value<bool> contaNaMedia;
  final Value<int> rowid;
  const AbastecimentosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    this.veiculoId = const Value.absent(),
    this.data = const Value.absent(),
    this.odometro = const Value.absent(),
    this.combustivel = const Value.absent(),
    this.litrosMl = const Value.absent(),
    this.precoLitroMilesimos = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.tanqueCheio = const Value.absent(),
    this.posto = const Value.absent(),
    this.postoId = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.contaNaMedia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AbastecimentosCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    required String veiculoId,
    required DateTime data,
    required int odometro,
    required Combustivel combustivel,
    required int litrosMl,
    required int precoLitroMilesimos,
    required int valorCentavos,
    required bool tanqueCheio,
    this.posto = const Value.absent(),
    this.postoId = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.contaNaMedia = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       veiculoId = Value(veiculoId),
       data = Value(data),
       odometro = Value(odometro),
       combustivel = Value(combustivel),
       litrosMl = Value(litrosMl),
       precoLitroMilesimos = Value(precoLitroMilesimos),
       valorCentavos = Value(valorCentavos),
       tanqueCheio = Value(tanqueCheio);
  static Insertable<AbastecimentoLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? excluidoEm,
    Expression<bool>? pendente,
    Expression<String>? veiculoId,
    Expression<DateTime>? data,
    Expression<int>? odometro,
    Expression<String>? combustivel,
    Expression<int>? litrosMl,
    Expression<int>? precoLitroMilesimos,
    Expression<int>? valorCentavos,
    Expression<bool>? tanqueCheio,
    Expression<String>? posto,
    Expression<String>? postoId,
    Expression<String>? formaPagamento,
    Expression<String>? cartaoId,
    Expression<bool>? contaNaMedia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (excluidoEm != null) 'excluido_em': excluidoEm,
      if (pendente != null) 'pendente': pendente,
      if (veiculoId != null) 'veiculo_id': veiculoId,
      if (data != null) 'data': data,
      if (odometro != null) 'odometro': odometro,
      if (combustivel != null) 'combustivel': combustivel,
      if (litrosMl != null) 'litros_ml': litrosMl,
      if (precoLitroMilesimos != null)
        'preco_litro_milesimos': precoLitroMilesimos,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (tanqueCheio != null) 'tanque_cheio': tanqueCheio,
      if (posto != null) 'posto': posto,
      if (postoId != null) 'posto_id': postoId,
      if (formaPagamento != null) 'forma_pagamento': formaPagamento,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (contaNaMedia != null) 'conta_na_media': contaNaMedia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AbastecimentosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? excluidoEm,
    Value<bool>? pendente,
    Value<String>? veiculoId,
    Value<DateTime>? data,
    Value<int>? odometro,
    Value<Combustivel>? combustivel,
    Value<int>? litrosMl,
    Value<int>? precoLitroMilesimos,
    Value<int>? valorCentavos,
    Value<bool>? tanqueCheio,
    Value<String?>? posto,
    Value<String?>? postoId,
    Value<FormaPagamento?>? formaPagamento,
    Value<String?>? cartaoId,
    Value<bool>? contaNaMedia,
    Value<int>? rowid,
  }) {
    return AbastecimentosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      excluidoEm: excluidoEm ?? this.excluidoEm,
      pendente: pendente ?? this.pendente,
      veiculoId: veiculoId ?? this.veiculoId,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      combustivel: combustivel ?? this.combustivel,
      litrosMl: litrosMl ?? this.litrosMl,
      precoLitroMilesimos: precoLitroMilesimos ?? this.precoLitroMilesimos,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      tanqueCheio: tanqueCheio ?? this.tanqueCheio,
      posto: posto ?? this.posto,
      postoId: postoId ?? this.postoId,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      cartaoId: cartaoId ?? this.cartaoId,
      contaNaMedia: contaNaMedia ?? this.contaNaMedia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (excluidoEm.present) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm.value);
    }
    if (pendente.present) {
      map['pendente'] = Variable<bool>(pendente.value);
    }
    if (veiculoId.present) {
      map['veiculo_id'] = Variable<String>(veiculoId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (odometro.present) {
      map['odometro'] = Variable<int>(odometro.value);
    }
    if (combustivel.present) {
      map['combustivel'] = Variable<String>(
        $AbastecimentosTable.$convertercombustivel.toSql(combustivel.value),
      );
    }
    if (litrosMl.present) {
      map['litros_ml'] = Variable<int>(litrosMl.value);
    }
    if (precoLitroMilesimos.present) {
      map['preco_litro_milesimos'] = Variable<int>(precoLitroMilesimos.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (tanqueCheio.present) {
      map['tanque_cheio'] = Variable<bool>(tanqueCheio.value);
    }
    if (posto.present) {
      map['posto'] = Variable<String>(posto.value);
    }
    if (postoId.present) {
      map['posto_id'] = Variable<String>(postoId.value);
    }
    if (formaPagamento.present) {
      map['forma_pagamento'] = Variable<String>(
        $AbastecimentosTable.$converterformaPagamenton.toSql(
          formaPagamento.value,
        ),
      );
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<String>(cartaoId.value);
    }
    if (contaNaMedia.present) {
      map['conta_na_media'] = Variable<bool>(contaNaMedia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbastecimentosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('veiculoId: $veiculoId, ')
          ..write('data: $data, ')
          ..write('odometro: $odometro, ')
          ..write('combustivel: $combustivel, ')
          ..write('litrosMl: $litrosMl, ')
          ..write('precoLitroMilesimos: $precoLitroMilesimos, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('tanqueCheio: $tanqueCheio, ')
          ..write('posto: $posto, ')
          ..write('postoId: $postoId, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('contaNaMedia: $contaNaMedia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecargasTable extends Recargas
    with TableInfo<$RecargasTable, RecargaLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecargasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excluidoEmMeta = const VerificationMeta(
    'excluidoEm',
  );
  @override
  late final GeneratedColumn<DateTime> excluidoEm = GeneratedColumn<DateTime>(
    'excluido_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendenteMeta = const VerificationMeta(
    'pendente',
  );
  @override
  late final GeneratedColumn<bool> pendente = GeneratedColumn<bool>(
    'pendente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendente" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _veiculoIdMeta = const VerificationMeta(
    'veiculoId',
  );
  @override
  late final GeneratedColumn<String> veiculoId = GeneratedColumn<String>(
    'veiculo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES veiculos (id)',
    ),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometroMeta = const VerificationMeta(
    'odometro',
  );
  @override
  late final GeneratedColumn<int> odometro = GeneratedColumn<int>(
    'odometro',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalRecarga, String> local =
      GeneratedColumn<String>(
        'local',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalRecarga>($RecargasTable.$converterlocal);
  static const VerificationMeta _energiaWhMeta = const VerificationMeta(
    'energiaWh',
  );
  @override
  late final GeneratedColumn<int> energiaWh = GeneratedColumn<int>(
    'energia_wh',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precoKwhMilesimosMeta = const VerificationMeta(
    'precoKwhMilesimos',
  );
  @override
  late final GeneratedColumn<int> precoKwhMilesimos = GeneratedColumn<int>(
    'preco_kwh_milesimos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  @override
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cargaCompletaMeta = const VerificationMeta(
    'cargaCompleta',
  );
  @override
  late final GeneratedColumn<bool> cargaCompleta = GeneratedColumn<bool>(
    'carga_completa',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("carga_completa" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FormaPagamento?, String>
  formaPagamento = GeneratedColumn<String>(
    'forma_pagamento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<FormaPagamento?>($RecargasTable.$converterformaPagamenton);
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  @override
  late final GeneratedColumn<String> cartaoId = GeneratedColumn<String>(
    'cartao_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contaNaMediaMeta = const VerificationMeta(
    'contaNaMedia',
  );
  @override
  late final GeneratedColumn<bool> contaNaMedia = GeneratedColumn<bool>(
    'conta_na_media',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("conta_na_media" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    veiculoId,
    data,
    odometro,
    local,
    energiaWh,
    precoKwhMilesimos,
    valorCentavos,
    cargaCompleta,
    formaPagamento,
    cartaoId,
    contaNaMedia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recargas';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecargaLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('excluido_em')) {
      context.handle(
        _excluidoEmMeta,
        excluidoEm.isAcceptableOrUnknown(data['excluido_em']!, _excluidoEmMeta),
      );
    }
    if (data.containsKey('pendente')) {
      context.handle(
        _pendenteMeta,
        pendente.isAcceptableOrUnknown(data['pendente']!, _pendenteMeta),
      );
    }
    if (data.containsKey('veiculo_id')) {
      context.handle(
        _veiculoIdMeta,
        veiculoId.isAcceptableOrUnknown(data['veiculo_id']!, _veiculoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_veiculoIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('odometro')) {
      context.handle(
        _odometroMeta,
        odometro.isAcceptableOrUnknown(data['odometro']!, _odometroMeta),
      );
    } else if (isInserting) {
      context.missing(_odometroMeta);
    }
    if (data.containsKey('energia_wh')) {
      context.handle(
        _energiaWhMeta,
        energiaWh.isAcceptableOrUnknown(data['energia_wh']!, _energiaWhMeta),
      );
    } else if (isInserting) {
      context.missing(_energiaWhMeta);
    }
    if (data.containsKey('preco_kwh_milesimos')) {
      context.handle(
        _precoKwhMilesimosMeta,
        precoKwhMilesimos.isAcceptableOrUnknown(
          data['preco_kwh_milesimos']!,
          _precoKwhMilesimosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precoKwhMilesimosMeta);
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    if (data.containsKey('carga_completa')) {
      context.handle(
        _cargaCompletaMeta,
        cargaCompleta.isAcceptableOrUnknown(
          data['carga_completa']!,
          _cargaCompletaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cargaCompletaMeta);
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    }
    if (data.containsKey('conta_na_media')) {
      context.handle(
        _contaNaMediaMeta,
        contaNaMedia.isAcceptableOrUnknown(
          data['conta_na_media']!,
          _contaNaMediaMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecargaLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecargaLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      excluidoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}excluido_em'],
      ),
      pendente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendente'],
      )!,
      veiculoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}veiculo_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
      odometro: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometro'],
      )!,
      local: $RecargasTable.$converterlocal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}local'],
        )!,
      ),
      energiaWh: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energia_wh'],
      )!,
      precoKwhMilesimos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preco_kwh_milesimos'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
      cargaCompleta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}carga_completa'],
      )!,
      formaPagamento: $RecargasTable.$converterformaPagamenton.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}forma_pagamento'],
        ),
      ),
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cartao_id'],
      ),
      contaNaMedia: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}conta_na_media'],
      )!,
    );
  }

  @override
  $RecargasTable createAlias(String alias) {
    return $RecargasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalRecarga, String, String> $converterlocal =
      const EnumNameConverter<LocalRecarga>(LocalRecarga.values);
  static JsonTypeConverter2<FormaPagamento, String, String>
  $converterformaPagamento = const EnumNameConverter<FormaPagamento>(
    FormaPagamento.values,
  );
  static JsonTypeConverter2<FormaPagamento?, String?, String?>
  $converterformaPagamenton = JsonTypeConverter2.asNullable(
    $converterformaPagamento,
  );
}

class RecargaLinha extends DataClass implements Insertable<RecargaLinha> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? excluidoEm;
  final bool pendente;
  final String veiculoId;
  final DateTime data;
  final int odometro;
  final LocalRecarga local;
  final int energiaWh;
  final int precoKwhMilesimos;
  final int valorCentavos;
  final bool cargaCompleta;
  final FormaPagamento? formaPagamento;
  final String? cartaoId;
  final bool contaNaMedia;
  const RecargaLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.excluidoEm,
    required this.pendente,
    required this.veiculoId,
    required this.data,
    required this.odometro,
    required this.local,
    required this.energiaWh,
    required this.precoKwhMilesimos,
    required this.valorCentavos,
    required this.cargaCompleta,
    this.formaPagamento,
    this.cartaoId,
    required this.contaNaMedia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || excluidoEm != null) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm);
    }
    map['pendente'] = Variable<bool>(pendente);
    map['veiculo_id'] = Variable<String>(veiculoId);
    map['data'] = Variable<DateTime>(data);
    map['odometro'] = Variable<int>(odometro);
    {
      map['local'] = Variable<String>(
        $RecargasTable.$converterlocal.toSql(local),
      );
    }
    map['energia_wh'] = Variable<int>(energiaWh);
    map['preco_kwh_milesimos'] = Variable<int>(precoKwhMilesimos);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    map['carga_completa'] = Variable<bool>(cargaCompleta);
    if (!nullToAbsent || formaPagamento != null) {
      map['forma_pagamento'] = Variable<String>(
        $RecargasTable.$converterformaPagamenton.toSql(formaPagamento),
      );
    }
    if (!nullToAbsent || cartaoId != null) {
      map['cartao_id'] = Variable<String>(cartaoId);
    }
    map['conta_na_media'] = Variable<bool>(contaNaMedia);
    return map;
  }

  RecargasCompanion toCompanion(bool nullToAbsent) {
    return RecargasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      excluidoEm: excluidoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(excluidoEm),
      pendente: Value(pendente),
      veiculoId: Value(veiculoId),
      data: Value(data),
      odometro: Value(odometro),
      local: Value(local),
      energiaWh: Value(energiaWh),
      precoKwhMilesimos: Value(precoKwhMilesimos),
      valorCentavos: Value(valorCentavos),
      cargaCompleta: Value(cargaCompleta),
      formaPagamento: formaPagamento == null && nullToAbsent
          ? const Value.absent()
          : Value(formaPagamento),
      cartaoId: cartaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartaoId),
      contaNaMedia: Value(contaNaMedia),
    );
  }

  factory RecargaLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecargaLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      excluidoEm: serializer.fromJson<DateTime?>(json['excluidoEm']),
      pendente: serializer.fromJson<bool>(json['pendente']),
      veiculoId: serializer.fromJson<String>(json['veiculoId']),
      data: serializer.fromJson<DateTime>(json['data']),
      odometro: serializer.fromJson<int>(json['odometro']),
      local: $RecargasTable.$converterlocal.fromJson(
        serializer.fromJson<String>(json['local']),
      ),
      energiaWh: serializer.fromJson<int>(json['energiaWh']),
      precoKwhMilesimos: serializer.fromJson<int>(json['precoKwhMilesimos']),
      valorCentavos: serializer.fromJson<int>(json['valorCentavos']),
      cargaCompleta: serializer.fromJson<bool>(json['cargaCompleta']),
      formaPagamento: $RecargasTable.$converterformaPagamenton.fromJson(
        serializer.fromJson<String?>(json['formaPagamento']),
      ),
      cartaoId: serializer.fromJson<String?>(json['cartaoId']),
      contaNaMedia: serializer.fromJson<bool>(json['contaNaMedia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'excluidoEm': serializer.toJson<DateTime?>(excluidoEm),
      'pendente': serializer.toJson<bool>(pendente),
      'veiculoId': serializer.toJson<String>(veiculoId),
      'data': serializer.toJson<DateTime>(data),
      'odometro': serializer.toJson<int>(odometro),
      'local': serializer.toJson<String>(
        $RecargasTable.$converterlocal.toJson(local),
      ),
      'energiaWh': serializer.toJson<int>(energiaWh),
      'precoKwhMilesimos': serializer.toJson<int>(precoKwhMilesimos),
      'valorCentavos': serializer.toJson<int>(valorCentavos),
      'cargaCompleta': serializer.toJson<bool>(cargaCompleta),
      'formaPagamento': serializer.toJson<String?>(
        $RecargasTable.$converterformaPagamenton.toJson(formaPagamento),
      ),
      'cartaoId': serializer.toJson<String?>(cartaoId),
      'contaNaMedia': serializer.toJson<bool>(contaNaMedia),
    };
  }

  RecargaLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> excluidoEm = const Value.absent(),
    bool? pendente,
    String? veiculoId,
    DateTime? data,
    int? odometro,
    LocalRecarga? local,
    int? energiaWh,
    int? precoKwhMilesimos,
    int? valorCentavos,
    bool? cargaCompleta,
    Value<FormaPagamento?> formaPagamento = const Value.absent(),
    Value<String?> cartaoId = const Value.absent(),
    bool? contaNaMedia,
  }) => RecargaLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    excluidoEm: excluidoEm.present ? excluidoEm.value : this.excluidoEm,
    pendente: pendente ?? this.pendente,
    veiculoId: veiculoId ?? this.veiculoId,
    data: data ?? this.data,
    odometro: odometro ?? this.odometro,
    local: local ?? this.local,
    energiaWh: energiaWh ?? this.energiaWh,
    precoKwhMilesimos: precoKwhMilesimos ?? this.precoKwhMilesimos,
    valorCentavos: valorCentavos ?? this.valorCentavos,
    cargaCompleta: cargaCompleta ?? this.cargaCompleta,
    formaPagamento: formaPagamento.present
        ? formaPagamento.value
        : this.formaPagamento,
    cartaoId: cartaoId.present ? cartaoId.value : this.cartaoId,
    contaNaMedia: contaNaMedia ?? this.contaNaMedia,
  );
  RecargaLinha copyWithCompanion(RecargasCompanion data) {
    return RecargaLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      excluidoEm: data.excluidoEm.present
          ? data.excluidoEm.value
          : this.excluidoEm,
      pendente: data.pendente.present ? data.pendente.value : this.pendente,
      veiculoId: data.veiculoId.present ? data.veiculoId.value : this.veiculoId,
      data: data.data.present ? data.data.value : this.data,
      odometro: data.odometro.present ? data.odometro.value : this.odometro,
      local: data.local.present ? data.local.value : this.local,
      energiaWh: data.energiaWh.present ? data.energiaWh.value : this.energiaWh,
      precoKwhMilesimos: data.precoKwhMilesimos.present
          ? data.precoKwhMilesimos.value
          : this.precoKwhMilesimos,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
      cargaCompleta: data.cargaCompleta.present
          ? data.cargaCompleta.value
          : this.cargaCompleta,
      formaPagamento: data.formaPagamento.present
          ? data.formaPagamento.value
          : this.formaPagamento,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      contaNaMedia: data.contaNaMedia.present
          ? data.contaNaMedia.value
          : this.contaNaMedia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecargaLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('veiculoId: $veiculoId, ')
          ..write('data: $data, ')
          ..write('odometro: $odometro, ')
          ..write('local: $local, ')
          ..write('energiaWh: $energiaWh, ')
          ..write('precoKwhMilesimos: $precoKwhMilesimos, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('cargaCompleta: $cargaCompleta, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('contaNaMedia: $contaNaMedia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    veiculoId,
    data,
    odometro,
    local,
    energiaWh,
    precoKwhMilesimos,
    valorCentavos,
    cargaCompleta,
    formaPagamento,
    cartaoId,
    contaNaMedia,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecargaLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.excluidoEm == this.excluidoEm &&
          other.pendente == this.pendente &&
          other.veiculoId == this.veiculoId &&
          other.data == this.data &&
          other.odometro == this.odometro &&
          other.local == this.local &&
          other.energiaWh == this.energiaWh &&
          other.precoKwhMilesimos == this.precoKwhMilesimos &&
          other.valorCentavos == this.valorCentavos &&
          other.cargaCompleta == this.cargaCompleta &&
          other.formaPagamento == this.formaPagamento &&
          other.cartaoId == this.cartaoId &&
          other.contaNaMedia == this.contaNaMedia);
}

class RecargasCompanion extends UpdateCompanion<RecargaLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> excluidoEm;
  final Value<bool> pendente;
  final Value<String> veiculoId;
  final Value<DateTime> data;
  final Value<int> odometro;
  final Value<LocalRecarga> local;
  final Value<int> energiaWh;
  final Value<int> precoKwhMilesimos;
  final Value<int> valorCentavos;
  final Value<bool> cargaCompleta;
  final Value<FormaPagamento?> formaPagamento;
  final Value<String?> cartaoId;
  final Value<bool> contaNaMedia;
  final Value<int> rowid;
  const RecargasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    this.veiculoId = const Value.absent(),
    this.data = const Value.absent(),
    this.odometro = const Value.absent(),
    this.local = const Value.absent(),
    this.energiaWh = const Value.absent(),
    this.precoKwhMilesimos = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.cargaCompleta = const Value.absent(),
    this.formaPagamento = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.contaNaMedia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecargasCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    required String veiculoId,
    required DateTime data,
    required int odometro,
    required LocalRecarga local,
    required int energiaWh,
    required int precoKwhMilesimos,
    required int valorCentavos,
    required bool cargaCompleta,
    this.formaPagamento = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.contaNaMedia = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       veiculoId = Value(veiculoId),
       data = Value(data),
       odometro = Value(odometro),
       local = Value(local),
       energiaWh = Value(energiaWh),
       precoKwhMilesimos = Value(precoKwhMilesimos),
       valorCentavos = Value(valorCentavos),
       cargaCompleta = Value(cargaCompleta);
  static Insertable<RecargaLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? excluidoEm,
    Expression<bool>? pendente,
    Expression<String>? veiculoId,
    Expression<DateTime>? data,
    Expression<int>? odometro,
    Expression<String>? local,
    Expression<int>? energiaWh,
    Expression<int>? precoKwhMilesimos,
    Expression<int>? valorCentavos,
    Expression<bool>? cargaCompleta,
    Expression<String>? formaPagamento,
    Expression<String>? cartaoId,
    Expression<bool>? contaNaMedia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (excluidoEm != null) 'excluido_em': excluidoEm,
      if (pendente != null) 'pendente': pendente,
      if (veiculoId != null) 'veiculo_id': veiculoId,
      if (data != null) 'data': data,
      if (odometro != null) 'odometro': odometro,
      if (local != null) 'local': local,
      if (energiaWh != null) 'energia_wh': energiaWh,
      if (precoKwhMilesimos != null) 'preco_kwh_milesimos': precoKwhMilesimos,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (cargaCompleta != null) 'carga_completa': cargaCompleta,
      if (formaPagamento != null) 'forma_pagamento': formaPagamento,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (contaNaMedia != null) 'conta_na_media': contaNaMedia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecargasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? excluidoEm,
    Value<bool>? pendente,
    Value<String>? veiculoId,
    Value<DateTime>? data,
    Value<int>? odometro,
    Value<LocalRecarga>? local,
    Value<int>? energiaWh,
    Value<int>? precoKwhMilesimos,
    Value<int>? valorCentavos,
    Value<bool>? cargaCompleta,
    Value<FormaPagamento?>? formaPagamento,
    Value<String?>? cartaoId,
    Value<bool>? contaNaMedia,
    Value<int>? rowid,
  }) {
    return RecargasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      excluidoEm: excluidoEm ?? this.excluidoEm,
      pendente: pendente ?? this.pendente,
      veiculoId: veiculoId ?? this.veiculoId,
      data: data ?? this.data,
      odometro: odometro ?? this.odometro,
      local: local ?? this.local,
      energiaWh: energiaWh ?? this.energiaWh,
      precoKwhMilesimos: precoKwhMilesimos ?? this.precoKwhMilesimos,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      cargaCompleta: cargaCompleta ?? this.cargaCompleta,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      cartaoId: cartaoId ?? this.cartaoId,
      contaNaMedia: contaNaMedia ?? this.contaNaMedia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (excluidoEm.present) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm.value);
    }
    if (pendente.present) {
      map['pendente'] = Variable<bool>(pendente.value);
    }
    if (veiculoId.present) {
      map['veiculo_id'] = Variable<String>(veiculoId.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (odometro.present) {
      map['odometro'] = Variable<int>(odometro.value);
    }
    if (local.present) {
      map['local'] = Variable<String>(
        $RecargasTable.$converterlocal.toSql(local.value),
      );
    }
    if (energiaWh.present) {
      map['energia_wh'] = Variable<int>(energiaWh.value);
    }
    if (precoKwhMilesimos.present) {
      map['preco_kwh_milesimos'] = Variable<int>(precoKwhMilesimos.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (cargaCompleta.present) {
      map['carga_completa'] = Variable<bool>(cargaCompleta.value);
    }
    if (formaPagamento.present) {
      map['forma_pagamento'] = Variable<String>(
        $RecargasTable.$converterformaPagamenton.toSql(formaPagamento.value),
      );
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<String>(cartaoId.value);
    }
    if (contaNaMedia.present) {
      map['conta_na_media'] = Variable<bool>(contaNaMedia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecargasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('veiculoId: $veiculoId, ')
          ..write('data: $data, ')
          ..write('odometro: $odometro, ')
          ..write('local: $local, ')
          ..write('energiaWh: $energiaWh, ')
          ..write('precoKwhMilesimos: $precoKwhMilesimos, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('cargaCompleta: $cargaCompleta, ')
          ..write('formaPagamento: $formaPagamento, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('contaNaMedia: $contaNaMedia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartoesTable extends Cartoes with TableInfo<$CartoesTable, CartaoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _excluidoEmMeta = const VerificationMeta(
    'excluidoEm',
  );
  @override
  late final GeneratedColumn<DateTime> excluidoEm = GeneratedColumn<DateTime>(
    'excluido_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendenteMeta = const VerificationMeta(
    'pendente',
  );
  @override
  late final GeneratedColumn<bool> pendente = GeneratedColumn<bool>(
    'pendente',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pendente" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bancoMeta = const VerificationMeta('banco');
  @override
  late final GeneratedColumn<String> banco = GeneratedColumn<String>(
    'banco',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diaFechamentoMeta = const VerificationMeta(
    'diaFechamento',
  );
  @override
  late final GeneratedColumn<int> diaFechamento = GeneratedColumn<int>(
    'dia_fechamento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    usuarioId,
    nome,
    banco,
    diaFechamento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cartoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartaoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('excluido_em')) {
      context.handle(
        _excluidoEmMeta,
        excluidoEm.isAcceptableOrUnknown(data['excluido_em']!, _excluidoEmMeta),
      );
    }
    if (data.containsKey('pendente')) {
      context.handle(
        _pendenteMeta,
        pendente.isAcceptableOrUnknown(data['pendente']!, _pendenteMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('banco')) {
      context.handle(
        _bancoMeta,
        banco.isAcceptableOrUnknown(data['banco']!, _bancoMeta),
      );
    }
    if (data.containsKey('dia_fechamento')) {
      context.handle(
        _diaFechamentoMeta,
        diaFechamento.isAcceptableOrUnknown(
          data['dia_fechamento']!,
          _diaFechamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaFechamentoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CartaoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartaoLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      excluidoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}excluido_em'],
      ),
      pendente: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pendente'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      banco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banco'],
      ),
      diaFechamento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_fechamento'],
      )!,
    );
  }

  @override
  $CartoesTable createAlias(String alias) {
    return $CartoesTable(attachedDatabase, alias);
  }
}

class CartaoLinha extends DataClass implements Insertable<CartaoLinha> {
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? excluidoEm;
  final bool pendente;
  final String usuarioId;
  final String nome;
  final String? banco;
  final int diaFechamento;
  const CartaoLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    this.excluidoEm,
    required this.pendente,
    required this.usuarioId,
    required this.nome,
    this.banco,
    required this.diaFechamento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    if (!nullToAbsent || excluidoEm != null) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm);
    }
    map['pendente'] = Variable<bool>(pendente);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || banco != null) {
      map['banco'] = Variable<String>(banco);
    }
    map['dia_fechamento'] = Variable<int>(diaFechamento);
    return map;
  }

  CartoesCompanion toCompanion(bool nullToAbsent) {
    return CartoesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      excluidoEm: excluidoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(excluidoEm),
      pendente: Value(pendente),
      usuarioId: Value(usuarioId),
      nome: Value(nome),
      banco: banco == null && nullToAbsent
          ? const Value.absent()
          : Value(banco),
      diaFechamento: Value(diaFechamento),
    );
  }

  factory CartaoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartaoLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      excluidoEm: serializer.fromJson<DateTime?>(json['excluidoEm']),
      pendente: serializer.fromJson<bool>(json['pendente']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      nome: serializer.fromJson<String>(json['nome']),
      banco: serializer.fromJson<String?>(json['banco']),
      diaFechamento: serializer.fromJson<int>(json['diaFechamento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'excluidoEm': serializer.toJson<DateTime?>(excluidoEm),
      'pendente': serializer.toJson<bool>(pendente),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'nome': serializer.toJson<String>(nome),
      'banco': serializer.toJson<String?>(banco),
      'diaFechamento': serializer.toJson<int>(diaFechamento),
    };
  }

  CartaoLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    Value<DateTime?> excluidoEm = const Value.absent(),
    bool? pendente,
    String? usuarioId,
    String? nome,
    Value<String?> banco = const Value.absent(),
    int? diaFechamento,
  }) => CartaoLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    excluidoEm: excluidoEm.present ? excluidoEm.value : this.excluidoEm,
    pendente: pendente ?? this.pendente,
    usuarioId: usuarioId ?? this.usuarioId,
    nome: nome ?? this.nome,
    banco: banco.present ? banco.value : this.banco,
    diaFechamento: diaFechamento ?? this.diaFechamento,
  );
  CartaoLinha copyWithCompanion(CartoesCompanion data) {
    return CartaoLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      excluidoEm: data.excluidoEm.present
          ? data.excluidoEm.value
          : this.excluidoEm,
      pendente: data.pendente.present ? data.pendente.value : this.pendente,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      nome: data.nome.present ? data.nome.value : this.nome,
      banco: data.banco.present ? data.banco.value : this.banco,
      diaFechamento: data.diaFechamento.present
          ? data.diaFechamento.value
          : this.diaFechamento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartaoLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('nome: $nome, ')
          ..write('banco: $banco, ')
          ..write('diaFechamento: $diaFechamento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    excluidoEm,
    pendente,
    usuarioId,
    nome,
    banco,
    diaFechamento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartaoLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.excluidoEm == this.excluidoEm &&
          other.pendente == this.pendente &&
          other.usuarioId == this.usuarioId &&
          other.nome == this.nome &&
          other.banco == this.banco &&
          other.diaFechamento == this.diaFechamento);
}

class CartoesCompanion extends UpdateCompanion<CartaoLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<DateTime?> excluidoEm;
  final Value<bool> pendente;
  final Value<String> usuarioId;
  final Value<String> nome;
  final Value<String?> banco;
  final Value<int> diaFechamento;
  final Value<int> rowid;
  const CartoesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.nome = const Value.absent(),
    this.banco = const Value.absent(),
    this.diaFechamento = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartoesCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.excluidoEm = const Value.absent(),
    this.pendente = const Value.absent(),
    required String usuarioId,
    required String nome,
    this.banco = const Value.absent(),
    required int diaFechamento,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       usuarioId = Value(usuarioId),
       nome = Value(nome),
       diaFechamento = Value(diaFechamento);
  static Insertable<CartaoLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<DateTime>? excluidoEm,
    Expression<bool>? pendente,
    Expression<String>? usuarioId,
    Expression<String>? nome,
    Expression<String>? banco,
    Expression<int>? diaFechamento,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (excluidoEm != null) 'excluido_em': excluidoEm,
      if (pendente != null) 'pendente': pendente,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (nome != null) 'nome': nome,
      if (banco != null) 'banco': banco,
      if (diaFechamento != null) 'dia_fechamento': diaFechamento,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<DateTime?>? excluidoEm,
    Value<bool>? pendente,
    Value<String>? usuarioId,
    Value<String>? nome,
    Value<String?>? banco,
    Value<int>? diaFechamento,
    Value<int>? rowid,
  }) {
    return CartoesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      excluidoEm: excluidoEm ?? this.excluidoEm,
      pendente: pendente ?? this.pendente,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      banco: banco ?? this.banco,
      diaFechamento: diaFechamento ?? this.diaFechamento,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (excluidoEm.present) {
      map['excluido_em'] = Variable<DateTime>(excluidoEm.value);
    }
    if (pendente.present) {
      map['pendente'] = Variable<bool>(pendente.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (banco.present) {
      map['banco'] = Variable<String>(banco.value);
    }
    if (diaFechamento.present) {
      map['dia_fechamento'] = Variable<int>(diaFechamento.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartoesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('excluidoEm: $excluidoEm, ')
          ..write('pendente: $pendente, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('nome: $nome, ')
          ..write('banco: $banco, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenciasTable extends Preferencias
    with TableInfo<$PreferenciasTable, PreferenciaLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenciaLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  PreferenciaLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenciaLinha(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $PreferenciasTable createAlias(String alias) {
    return $PreferenciasTable(attachedDatabase, alias);
  }
}

class PreferenciaLinha extends DataClass
    implements Insertable<PreferenciaLinha> {
  final String chave;
  final String valor;
  const PreferenciaLinha({required this.chave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  PreferenciasCompanion toCompanion(bool nullToAbsent) {
    return PreferenciasCompanion(chave: Value(chave), valor: Value(valor));
  }

  factory PreferenciaLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenciaLinha(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  PreferenciaLinha copyWith({String? chave, String? valor}) =>
      PreferenciaLinha(chave: chave ?? this.chave, valor: valor ?? this.valor);
  PreferenciaLinha copyWithCompanion(PreferenciasCompanion data) {
    return PreferenciaLinha(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenciaLinha(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenciaLinha &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class PreferenciasCompanion extends UpdateCompanion<PreferenciaLinha> {
  final Value<String> chave;
  final Value<String> valor;
  final Value<int> rowid;
  const PreferenciasCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenciasCompanion.insert({
    required String chave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       valor = Value(valor);
  static Insertable<PreferenciaLinha> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenciasCompanion copyWith({
    Value<String>? chave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return PreferenciasCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenciasCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BancoLocal extends GeneratedDatabase {
  _$BancoLocal(QueryExecutor e) : super(e);
  $BancoLocalManager get managers => $BancoLocalManager(this);
  late final $VeiculosTable veiculos = $VeiculosTable(this);
  late final $AbastecimentosTable abastecimentos = $AbastecimentosTable(this);
  late final $RecargasTable recargas = $RecargasTable(this);
  late final $CartoesTable cartoes = $CartoesTable(this);
  late final $PreferenciasTable preferencias = $PreferenciasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    veiculos,
    abastecimentos,
    recargas,
    cartoes,
    preferencias,
  ];
}

typedef $$VeiculosTableCreateCompanionBuilder =
    VeiculosCompanion Function({
      required String id,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      Value<String?> usuarioId,
      Value<TipoVeiculo> tipoVeiculo,
      required String apelido,
      required String marca,
      required String modelo,
      Value<int?> ano,
      Value<String?> codigoFipe,
      required TipoEnergia tipoEnergia,
      required String combustiveis,
      Value<int?> capacidadeTanqueMl,
      Value<int?> capacidadeBateriaWh,
      required int odometroInicial,
      Value<int> rowid,
    });
typedef $$VeiculosTableUpdateCompanionBuilder =
    VeiculosCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      Value<String?> usuarioId,
      Value<TipoVeiculo> tipoVeiculo,
      Value<String> apelido,
      Value<String> marca,
      Value<String> modelo,
      Value<int?> ano,
      Value<String?> codigoFipe,
      Value<TipoEnergia> tipoEnergia,
      Value<String> combustiveis,
      Value<int?> capacidadeTanqueMl,
      Value<int?> capacidadeBateriaWh,
      Value<int> odometroInicial,
      Value<int> rowid,
    });

final class $$VeiculosTableReferences
    extends BaseReferences<_$BancoLocal, $VeiculosTable, VeiculoLinha> {
  $$VeiculosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AbastecimentosTable, List<AbastecimentoLinha>>
  _abastecimentosRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.abastecimentos,
    aliasName: 'veiculos__id__abastecimentos__veiculo_id',
  );

  $$AbastecimentosTableProcessedTableManager get abastecimentosRefs {
    final manager = $$AbastecimentosTableTableManager(
      $_db,
      $_db.abastecimentos,
    ).filter((f) => f.veiculoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_abastecimentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecargasTable, List<RecargaLinha>>
  _recargasRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.recargas,
    aliasName: 'veiculos__id__recargas__veiculo_id',
  );

  $$RecargasTableProcessedTableManager get recargasRefs {
    final manager = $$RecargasTableTableManager(
      $_db,
      $_db.recargas,
    ).filter((f) => f.veiculoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recargasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VeiculosTableFilterComposer
    extends Composer<_$BancoLocal, $VeiculosTable> {
  $$VeiculosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoVeiculo, TipoVeiculo, String>
  get tipoVeiculo => $composableBuilder(
    column: $table.tipoVeiculo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get apelido => $composableBuilder(
    column: $table.apelido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoFipe => $composableBuilder(
    column: $table.codigoFipe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoEnergia, TipoEnergia, String>
  get tipoEnergia => $composableBuilder(
    column: $table.tipoEnergia,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get combustiveis => $composableBuilder(
    column: $table.combustiveis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacidadeTanqueMl => $composableBuilder(
    column: $table.capacidadeTanqueMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacidadeBateriaWh => $composableBuilder(
    column: $table.capacidadeBateriaWh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometroInicial => $composableBuilder(
    column: $table.odometroInicial,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> abastecimentosRefs(
    Expression<bool> Function($$AbastecimentosTableFilterComposer f) f,
  ) {
    final $$AbastecimentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.abastecimentos,
      getReferencedColumn: (t) => t.veiculoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbastecimentosTableFilterComposer(
            $db: $db,
            $table: $db.abastecimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recargasRefs(
    Expression<bool> Function($$RecargasTableFilterComposer f) f,
  ) {
    final $$RecargasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recargas,
      getReferencedColumn: (t) => t.veiculoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecargasTableFilterComposer(
            $db: $db,
            $table: $db.recargas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VeiculosTableOrderingComposer
    extends Composer<_$BancoLocal, $VeiculosTable> {
  $$VeiculosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoVeiculo => $composableBuilder(
    column: $table.tipoVeiculo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apelido => $composableBuilder(
    column: $table.apelido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelo => $composableBuilder(
    column: $table.modelo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ano => $composableBuilder(
    column: $table.ano,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoFipe => $composableBuilder(
    column: $table.codigoFipe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoEnergia => $composableBuilder(
    column: $table.tipoEnergia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get combustiveis => $composableBuilder(
    column: $table.combustiveis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacidadeTanqueMl => $composableBuilder(
    column: $table.capacidadeTanqueMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacidadeBateriaWh => $composableBuilder(
    column: $table.capacidadeBateriaWh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometroInicial => $composableBuilder(
    column: $table.odometroInicial,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VeiculosTableAnnotationComposer
    extends Composer<_$BancoLocal, $VeiculosTable> {
  $$VeiculosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendente =>
      $composableBuilder(column: $table.pendente, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoVeiculo, String> get tipoVeiculo =>
      $composableBuilder(
        column: $table.tipoVeiculo,
        builder: (column) => column,
      );

  GeneratedColumn<String> get apelido =>
      $composableBuilder(column: $table.apelido, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get modelo =>
      $composableBuilder(column: $table.modelo, builder: (column) => column);

  GeneratedColumn<int> get ano =>
      $composableBuilder(column: $table.ano, builder: (column) => column);

  GeneratedColumn<String> get codigoFipe => $composableBuilder(
    column: $table.codigoFipe,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoEnergia, String> get tipoEnergia =>
      $composableBuilder(
        column: $table.tipoEnergia,
        builder: (column) => column,
      );

  GeneratedColumn<String> get combustiveis => $composableBuilder(
    column: $table.combustiveis,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacidadeTanqueMl => $composableBuilder(
    column: $table.capacidadeTanqueMl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacidadeBateriaWh => $composableBuilder(
    column: $table.capacidadeBateriaWh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odometroInicial => $composableBuilder(
    column: $table.odometroInicial,
    builder: (column) => column,
  );

  Expression<T> abastecimentosRefs<T extends Object>(
    Expression<T> Function($$AbastecimentosTableAnnotationComposer a) f,
  ) {
    final $$AbastecimentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.abastecimentos,
      getReferencedColumn: (t) => t.veiculoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AbastecimentosTableAnnotationComposer(
            $db: $db,
            $table: $db.abastecimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recargasRefs<T extends Object>(
    Expression<T> Function($$RecargasTableAnnotationComposer a) f,
  ) {
    final $$RecargasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recargas,
      getReferencedColumn: (t) => t.veiculoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecargasTableAnnotationComposer(
            $db: $db,
            $table: $db.recargas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VeiculosTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $VeiculosTable,
          VeiculoLinha,
          $$VeiculosTableFilterComposer,
          $$VeiculosTableOrderingComposer,
          $$VeiculosTableAnnotationComposer,
          $$VeiculosTableCreateCompanionBuilder,
          $$VeiculosTableUpdateCompanionBuilder,
          (VeiculoLinha, $$VeiculosTableReferences),
          VeiculoLinha,
          PrefetchHooks Function({bool abastecimentosRefs, bool recargasRefs})
        > {
  $$VeiculosTableTableManager(_$BancoLocal db, $VeiculosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VeiculosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VeiculosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VeiculosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                Value<String?> usuarioId = const Value.absent(),
                Value<TipoVeiculo> tipoVeiculo = const Value.absent(),
                Value<String> apelido = const Value.absent(),
                Value<String> marca = const Value.absent(),
                Value<String> modelo = const Value.absent(),
                Value<int?> ano = const Value.absent(),
                Value<String?> codigoFipe = const Value.absent(),
                Value<TipoEnergia> tipoEnergia = const Value.absent(),
                Value<String> combustiveis = const Value.absent(),
                Value<int?> capacidadeTanqueMl = const Value.absent(),
                Value<int?> capacidadeBateriaWh = const Value.absent(),
                Value<int> odometroInicial = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VeiculosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                usuarioId: usuarioId,
                tipoVeiculo: tipoVeiculo,
                apelido: apelido,
                marca: marca,
                modelo: modelo,
                ano: ano,
                codigoFipe: codigoFipe,
                tipoEnergia: tipoEnergia,
                combustiveis: combustiveis,
                capacidadeTanqueMl: capacidadeTanqueMl,
                capacidadeBateriaWh: capacidadeBateriaWh,
                odometroInicial: odometroInicial,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                Value<String?> usuarioId = const Value.absent(),
                Value<TipoVeiculo> tipoVeiculo = const Value.absent(),
                required String apelido,
                required String marca,
                required String modelo,
                Value<int?> ano = const Value.absent(),
                Value<String?> codigoFipe = const Value.absent(),
                required TipoEnergia tipoEnergia,
                required String combustiveis,
                Value<int?> capacidadeTanqueMl = const Value.absent(),
                Value<int?> capacidadeBateriaWh = const Value.absent(),
                required int odometroInicial,
                Value<int> rowid = const Value.absent(),
              }) => VeiculosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                usuarioId: usuarioId,
                tipoVeiculo: tipoVeiculo,
                apelido: apelido,
                marca: marca,
                modelo: modelo,
                ano: ano,
                codigoFipe: codigoFipe,
                tipoEnergia: tipoEnergia,
                combustiveis: combustiveis,
                capacidadeTanqueMl: capacidadeTanqueMl,
                capacidadeBateriaWh: capacidadeBateriaWh,
                odometroInicial: odometroInicial,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VeiculosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({abastecimentosRefs = false, recargasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (abastecimentosRefs) db.abastecimentos,
                    if (recargasRefs) db.recargas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (abastecimentosRefs)
                        await $_getPrefetchedData<
                          VeiculoLinha,
                          $VeiculosTable,
                          AbastecimentoLinha
                        >(
                          currentTable: table,
                          referencedTable: $$VeiculosTableReferences
                              ._abastecimentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VeiculosTableReferences(
                                db,
                                table,
                                p0,
                              ).abastecimentosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.veiculoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recargasRefs)
                        await $_getPrefetchedData<
                          VeiculoLinha,
                          $VeiculosTable,
                          RecargaLinha
                        >(
                          currentTable: table,
                          referencedTable: $$VeiculosTableReferences
                              ._recargasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VeiculosTableReferences(
                                db,
                                table,
                                p0,
                              ).recargasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.veiculoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VeiculosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $VeiculosTable,
      VeiculoLinha,
      $$VeiculosTableFilterComposer,
      $$VeiculosTableOrderingComposer,
      $$VeiculosTableAnnotationComposer,
      $$VeiculosTableCreateCompanionBuilder,
      $$VeiculosTableUpdateCompanionBuilder,
      (VeiculoLinha, $$VeiculosTableReferences),
      VeiculoLinha,
      PrefetchHooks Function({bool abastecimentosRefs, bool recargasRefs})
    >;
typedef $$AbastecimentosTableCreateCompanionBuilder =
    AbastecimentosCompanion Function({
      required String id,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      required String veiculoId,
      required DateTime data,
      required int odometro,
      required Combustivel combustivel,
      required int litrosMl,
      required int precoLitroMilesimos,
      required int valorCentavos,
      required bool tanqueCheio,
      Value<String?> posto,
      Value<String?> postoId,
      Value<FormaPagamento?> formaPagamento,
      Value<String?> cartaoId,
      Value<bool> contaNaMedia,
      Value<int> rowid,
    });
typedef $$AbastecimentosTableUpdateCompanionBuilder =
    AbastecimentosCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      Value<String> veiculoId,
      Value<DateTime> data,
      Value<int> odometro,
      Value<Combustivel> combustivel,
      Value<int> litrosMl,
      Value<int> precoLitroMilesimos,
      Value<int> valorCentavos,
      Value<bool> tanqueCheio,
      Value<String?> posto,
      Value<String?> postoId,
      Value<FormaPagamento?> formaPagamento,
      Value<String?> cartaoId,
      Value<bool> contaNaMedia,
      Value<int> rowid,
    });

final class $$AbastecimentosTableReferences
    extends
        BaseReferences<_$BancoLocal, $AbastecimentosTable, AbastecimentoLinha> {
  $$AbastecimentosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VeiculosTable _veiculoIdTable(_$BancoLocal db) =>
      db.veiculos.createAlias('abastecimentos__veiculo_id__veiculos__id');

  $$VeiculosTableProcessedTableManager get veiculoId {
    final $_column = $_itemColumn<String>('veiculo_id')!;

    final manager = $$VeiculosTableTableManager(
      $_db,
      $_db.veiculos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_veiculoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AbastecimentosTableFilterComposer
    extends Composer<_$BancoLocal, $AbastecimentosTable> {
  $$AbastecimentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometro => $composableBuilder(
    column: $table.odometro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Combustivel, Combustivel, String>
  get combustivel => $composableBuilder(
    column: $table.combustivel,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get litrosMl => $composableBuilder(
    column: $table.litrosMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precoLitroMilesimos => $composableBuilder(
    column: $table.precoLitroMilesimos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tanqueCheio => $composableBuilder(
    column: $table.tanqueCheio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posto => $composableBuilder(
    column: $table.posto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postoId => $composableBuilder(
    column: $table.postoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaPagamento?, FormaPagamento, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get contaNaMedia => $composableBuilder(
    column: $table.contaNaMedia,
    builder: (column) => ColumnFilters(column),
  );

  $$VeiculosTableFilterComposer get veiculoId {
    final $$VeiculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.veiculoId,
      referencedTable: $db.veiculos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VeiculosTableFilterComposer(
            $db: $db,
            $table: $db.veiculos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbastecimentosTableOrderingComposer
    extends Composer<_$BancoLocal, $AbastecimentosTable> {
  $$AbastecimentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometro => $composableBuilder(
    column: $table.odometro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get combustivel => $composableBuilder(
    column: $table.combustivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get litrosMl => $composableBuilder(
    column: $table.litrosMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precoLitroMilesimos => $composableBuilder(
    column: $table.precoLitroMilesimos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tanqueCheio => $composableBuilder(
    column: $table.tanqueCheio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posto => $composableBuilder(
    column: $table.posto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postoId => $composableBuilder(
    column: $table.postoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get contaNaMedia => $composableBuilder(
    column: $table.contaNaMedia,
    builder: (column) => ColumnOrderings(column),
  );

  $$VeiculosTableOrderingComposer get veiculoId {
    final $$VeiculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.veiculoId,
      referencedTable: $db.veiculos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VeiculosTableOrderingComposer(
            $db: $db,
            $table: $db.veiculos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbastecimentosTableAnnotationComposer
    extends Composer<_$BancoLocal, $AbastecimentosTable> {
  $$AbastecimentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendente =>
      $composableBuilder(column: $table.pendente, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get odometro =>
      $composableBuilder(column: $table.odometro, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Combustivel, String> get combustivel =>
      $composableBuilder(
        column: $table.combustivel,
        builder: (column) => column,
      );

  GeneratedColumn<int> get litrosMl =>
      $composableBuilder(column: $table.litrosMl, builder: (column) => column);

  GeneratedColumn<int> get precoLitroMilesimos => $composableBuilder(
    column: $table.precoLitroMilesimos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get tanqueCheio => $composableBuilder(
    column: $table.tanqueCheio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posto =>
      $composableBuilder(column: $table.posto, builder: (column) => column);

  GeneratedColumn<String> get postoId =>
      $composableBuilder(column: $table.postoId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FormaPagamento?, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cartaoId =>
      $composableBuilder(column: $table.cartaoId, builder: (column) => column);

  GeneratedColumn<bool> get contaNaMedia => $composableBuilder(
    column: $table.contaNaMedia,
    builder: (column) => column,
  );

  $$VeiculosTableAnnotationComposer get veiculoId {
    final $$VeiculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.veiculoId,
      referencedTable: $db.veiculos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VeiculosTableAnnotationComposer(
            $db: $db,
            $table: $db.veiculos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AbastecimentosTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $AbastecimentosTable,
          AbastecimentoLinha,
          $$AbastecimentosTableFilterComposer,
          $$AbastecimentosTableOrderingComposer,
          $$AbastecimentosTableAnnotationComposer,
          $$AbastecimentosTableCreateCompanionBuilder,
          $$AbastecimentosTableUpdateCompanionBuilder,
          (AbastecimentoLinha, $$AbastecimentosTableReferences),
          AbastecimentoLinha,
          PrefetchHooks Function({bool veiculoId})
        > {
  $$AbastecimentosTableTableManager(_$BancoLocal db, $AbastecimentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AbastecimentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AbastecimentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AbastecimentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                Value<String> veiculoId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> odometro = const Value.absent(),
                Value<Combustivel> combustivel = const Value.absent(),
                Value<int> litrosMl = const Value.absent(),
                Value<int> precoLitroMilesimos = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<bool> tanqueCheio = const Value.absent(),
                Value<String?> posto = const Value.absent(),
                Value<String?> postoId = const Value.absent(),
                Value<FormaPagamento?> formaPagamento = const Value.absent(),
                Value<String?> cartaoId = const Value.absent(),
                Value<bool> contaNaMedia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbastecimentosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                veiculoId: veiculoId,
                data: data,
                odometro: odometro,
                combustivel: combustivel,
                litrosMl: litrosMl,
                precoLitroMilesimos: precoLitroMilesimos,
                valorCentavos: valorCentavos,
                tanqueCheio: tanqueCheio,
                posto: posto,
                postoId: postoId,
                formaPagamento: formaPagamento,
                cartaoId: cartaoId,
                contaNaMedia: contaNaMedia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                required String veiculoId,
                required DateTime data,
                required int odometro,
                required Combustivel combustivel,
                required int litrosMl,
                required int precoLitroMilesimos,
                required int valorCentavos,
                required bool tanqueCheio,
                Value<String?> posto = const Value.absent(),
                Value<String?> postoId = const Value.absent(),
                Value<FormaPagamento?> formaPagamento = const Value.absent(),
                Value<String?> cartaoId = const Value.absent(),
                Value<bool> contaNaMedia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AbastecimentosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                veiculoId: veiculoId,
                data: data,
                odometro: odometro,
                combustivel: combustivel,
                litrosMl: litrosMl,
                precoLitroMilesimos: precoLitroMilesimos,
                valorCentavos: valorCentavos,
                tanqueCheio: tanqueCheio,
                posto: posto,
                postoId: postoId,
                formaPagamento: formaPagamento,
                cartaoId: cartaoId,
                contaNaMedia: contaNaMedia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AbastecimentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({veiculoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (veiculoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.veiculoId,
                                referencedTable: $$AbastecimentosTableReferences
                                    ._veiculoIdTable(db),
                                referencedColumn:
                                    $$AbastecimentosTableReferences
                                        ._veiculoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AbastecimentosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $AbastecimentosTable,
      AbastecimentoLinha,
      $$AbastecimentosTableFilterComposer,
      $$AbastecimentosTableOrderingComposer,
      $$AbastecimentosTableAnnotationComposer,
      $$AbastecimentosTableCreateCompanionBuilder,
      $$AbastecimentosTableUpdateCompanionBuilder,
      (AbastecimentoLinha, $$AbastecimentosTableReferences),
      AbastecimentoLinha,
      PrefetchHooks Function({bool veiculoId})
    >;
typedef $$RecargasTableCreateCompanionBuilder =
    RecargasCompanion Function({
      required String id,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      required String veiculoId,
      required DateTime data,
      required int odometro,
      required LocalRecarga local,
      required int energiaWh,
      required int precoKwhMilesimos,
      required int valorCentavos,
      required bool cargaCompleta,
      Value<FormaPagamento?> formaPagamento,
      Value<String?> cartaoId,
      Value<bool> contaNaMedia,
      Value<int> rowid,
    });
typedef $$RecargasTableUpdateCompanionBuilder =
    RecargasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      Value<String> veiculoId,
      Value<DateTime> data,
      Value<int> odometro,
      Value<LocalRecarga> local,
      Value<int> energiaWh,
      Value<int> precoKwhMilesimos,
      Value<int> valorCentavos,
      Value<bool> cargaCompleta,
      Value<FormaPagamento?> formaPagamento,
      Value<String?> cartaoId,
      Value<bool> contaNaMedia,
      Value<int> rowid,
    });

final class $$RecargasTableReferences
    extends BaseReferences<_$BancoLocal, $RecargasTable, RecargaLinha> {
  $$RecargasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VeiculosTable _veiculoIdTable(_$BancoLocal db) =>
      db.veiculos.createAlias('recargas__veiculo_id__veiculos__id');

  $$VeiculosTableProcessedTableManager get veiculoId {
    final $_column = $_itemColumn<String>('veiculo_id')!;

    final manager = $$VeiculosTableTableManager(
      $_db,
      $_db.veiculos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_veiculoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecargasTableFilterComposer
    extends Composer<_$BancoLocal, $RecargasTable> {
  $$RecargasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometro => $composableBuilder(
    column: $table.odometro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalRecarga, LocalRecarga, String>
  get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get energiaWh => $composableBuilder(
    column: $table.energiaWh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precoKwhMilesimos => $composableBuilder(
    column: $table.precoKwhMilesimos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cargaCompleta => $composableBuilder(
    column: $table.cargaCompleta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FormaPagamento?, FormaPagamento, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get contaNaMedia => $composableBuilder(
    column: $table.contaNaMedia,
    builder: (column) => ColumnFilters(column),
  );

  $$VeiculosTableFilterComposer get veiculoId {
    final $$VeiculosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.veiculoId,
      referencedTable: $db.veiculos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VeiculosTableFilterComposer(
            $db: $db,
            $table: $db.veiculos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecargasTableOrderingComposer
    extends Composer<_$BancoLocal, $RecargasTable> {
  $$RecargasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometro => $composableBuilder(
    column: $table.odometro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energiaWh => $composableBuilder(
    column: $table.energiaWh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precoKwhMilesimos => $composableBuilder(
    column: $table.precoKwhMilesimos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cargaCompleta => $composableBuilder(
    column: $table.cargaCompleta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cartaoId => $composableBuilder(
    column: $table.cartaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get contaNaMedia => $composableBuilder(
    column: $table.contaNaMedia,
    builder: (column) => ColumnOrderings(column),
  );

  $$VeiculosTableOrderingComposer get veiculoId {
    final $$VeiculosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.veiculoId,
      referencedTable: $db.veiculos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VeiculosTableOrderingComposer(
            $db: $db,
            $table: $db.veiculos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecargasTableAnnotationComposer
    extends Composer<_$BancoLocal, $RecargasTable> {
  $$RecargasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendente =>
      $composableBuilder(column: $table.pendente, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get odometro =>
      $composableBuilder(column: $table.odometro, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalRecarga, String> get local =>
      $composableBuilder(column: $table.local, builder: (column) => column);

  GeneratedColumn<int> get energiaWh =>
      $composableBuilder(column: $table.energiaWh, builder: (column) => column);

  GeneratedColumn<int> get precoKwhMilesimos => $composableBuilder(
    column: $table.precoKwhMilesimos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get cargaCompleta => $composableBuilder(
    column: $table.cargaCompleta,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FormaPagamento?, String>
  get formaPagamento => $composableBuilder(
    column: $table.formaPagamento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cartaoId =>
      $composableBuilder(column: $table.cartaoId, builder: (column) => column);

  GeneratedColumn<bool> get contaNaMedia => $composableBuilder(
    column: $table.contaNaMedia,
    builder: (column) => column,
  );

  $$VeiculosTableAnnotationComposer get veiculoId {
    final $$VeiculosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.veiculoId,
      referencedTable: $db.veiculos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VeiculosTableAnnotationComposer(
            $db: $db,
            $table: $db.veiculos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecargasTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $RecargasTable,
          RecargaLinha,
          $$RecargasTableFilterComposer,
          $$RecargasTableOrderingComposer,
          $$RecargasTableAnnotationComposer,
          $$RecargasTableCreateCompanionBuilder,
          $$RecargasTableUpdateCompanionBuilder,
          (RecargaLinha, $$RecargasTableReferences),
          RecargaLinha,
          PrefetchHooks Function({bool veiculoId})
        > {
  $$RecargasTableTableManager(_$BancoLocal db, $RecargasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecargasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecargasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecargasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                Value<String> veiculoId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> odometro = const Value.absent(),
                Value<LocalRecarga> local = const Value.absent(),
                Value<int> energiaWh = const Value.absent(),
                Value<int> precoKwhMilesimos = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<bool> cargaCompleta = const Value.absent(),
                Value<FormaPagamento?> formaPagamento = const Value.absent(),
                Value<String?> cartaoId = const Value.absent(),
                Value<bool> contaNaMedia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecargasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                veiculoId: veiculoId,
                data: data,
                odometro: odometro,
                local: local,
                energiaWh: energiaWh,
                precoKwhMilesimos: precoKwhMilesimos,
                valorCentavos: valorCentavos,
                cargaCompleta: cargaCompleta,
                formaPagamento: formaPagamento,
                cartaoId: cartaoId,
                contaNaMedia: contaNaMedia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                required String veiculoId,
                required DateTime data,
                required int odometro,
                required LocalRecarga local,
                required int energiaWh,
                required int precoKwhMilesimos,
                required int valorCentavos,
                required bool cargaCompleta,
                Value<FormaPagamento?> formaPagamento = const Value.absent(),
                Value<String?> cartaoId = const Value.absent(),
                Value<bool> contaNaMedia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecargasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                veiculoId: veiculoId,
                data: data,
                odometro: odometro,
                local: local,
                energiaWh: energiaWh,
                precoKwhMilesimos: precoKwhMilesimos,
                valorCentavos: valorCentavos,
                cargaCompleta: cargaCompleta,
                formaPagamento: formaPagamento,
                cartaoId: cartaoId,
                contaNaMedia: contaNaMedia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecargasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({veiculoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (veiculoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.veiculoId,
                                referencedTable: $$RecargasTableReferences
                                    ._veiculoIdTable(db),
                                referencedColumn: $$RecargasTableReferences
                                    ._veiculoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecargasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $RecargasTable,
      RecargaLinha,
      $$RecargasTableFilterComposer,
      $$RecargasTableOrderingComposer,
      $$RecargasTableAnnotationComposer,
      $$RecargasTableCreateCompanionBuilder,
      $$RecargasTableUpdateCompanionBuilder,
      (RecargaLinha, $$RecargasTableReferences),
      RecargaLinha,
      PrefetchHooks Function({bool veiculoId})
    >;
typedef $$CartoesTableCreateCompanionBuilder =
    CartoesCompanion Function({
      required String id,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      required String usuarioId,
      required String nome,
      Value<String?> banco,
      required int diaFechamento,
      Value<int> rowid,
    });
typedef $$CartoesTableUpdateCompanionBuilder =
    CartoesCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<DateTime?> excluidoEm,
      Value<bool> pendente,
      Value<String> usuarioId,
      Value<String> nome,
      Value<String?> banco,
      Value<int> diaFechamento,
      Value<int> rowid,
    });

class $$CartoesTableFilterComposer
    extends Composer<_$BancoLocal, $CartoesTable> {
  $$CartoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get banco => $composableBuilder(
    column: $table.banco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartoesTableOrderingComposer
    extends Composer<_$BancoLocal, $CartoesTable> {
  $$CartoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pendente => $composableBuilder(
    column: $table.pendente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usuarioId => $composableBuilder(
    column: $table.usuarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get banco => $composableBuilder(
    column: $table.banco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartoesTableAnnotationComposer
    extends Composer<_$BancoLocal, $CartoesTable> {
  $$CartoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get excluidoEm => $composableBuilder(
    column: $table.excluidoEm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pendente =>
      $composableBuilder(column: $table.pendente, builder: (column) => column);

  GeneratedColumn<String> get usuarioId =>
      $composableBuilder(column: $table.usuarioId, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get banco =>
      $composableBuilder(column: $table.banco, builder: (column) => column);

  GeneratedColumn<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => column,
  );
}

class $$CartoesTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $CartoesTable,
          CartaoLinha,
          $$CartoesTableFilterComposer,
          $$CartoesTableOrderingComposer,
          $$CartoesTableAnnotationComposer,
          $$CartoesTableCreateCompanionBuilder,
          $$CartoesTableUpdateCompanionBuilder,
          (
            CartaoLinha,
            BaseReferences<_$BancoLocal, $CartoesTable, CartaoLinha>,
          ),
          CartaoLinha,
          PrefetchHooks Function()
        > {
  $$CartoesTableTableManager(_$BancoLocal db, $CartoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> banco = const Value.absent(),
                Value<int> diaFechamento = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CartoesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                usuarioId: usuarioId,
                nome: nome,
                banco: banco,
                diaFechamento: diaFechamento,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<DateTime?> excluidoEm = const Value.absent(),
                Value<bool> pendente = const Value.absent(),
                required String usuarioId,
                required String nome,
                Value<String?> banco = const Value.absent(),
                required int diaFechamento,
                Value<int> rowid = const Value.absent(),
              }) => CartoesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                excluidoEm: excluidoEm,
                pendente: pendente,
                usuarioId: usuarioId,
                nome: nome,
                banco: banco,
                diaFechamento: diaFechamento,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartoesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $CartoesTable,
      CartaoLinha,
      $$CartoesTableFilterComposer,
      $$CartoesTableOrderingComposer,
      $$CartoesTableAnnotationComposer,
      $$CartoesTableCreateCompanionBuilder,
      $$CartoesTableUpdateCompanionBuilder,
      (CartaoLinha, BaseReferences<_$BancoLocal, $CartoesTable, CartaoLinha>),
      CartaoLinha,
      PrefetchHooks Function()
    >;
typedef $$PreferenciasTableCreateCompanionBuilder =
    PreferenciasCompanion Function({
      required String chave,
      required String valor,
      Value<int> rowid,
    });
typedef $$PreferenciasTableUpdateCompanionBuilder =
    PreferenciasCompanion Function({
      Value<String> chave,
      Value<String> valor,
      Value<int> rowid,
    });

class $$PreferenciasTableFilterComposer
    extends Composer<_$BancoLocal, $PreferenciasTable> {
  $$PreferenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenciasTableOrderingComposer
    extends Composer<_$BancoLocal, $PreferenciasTable> {
  $$PreferenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenciasTableAnnotationComposer
    extends Composer<_$BancoLocal, $PreferenciasTable> {
  $$PreferenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$PreferenciasTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $PreferenciasTable,
          PreferenciaLinha,
          $$PreferenciasTableFilterComposer,
          $$PreferenciasTableOrderingComposer,
          $$PreferenciasTableAnnotationComposer,
          $$PreferenciasTableCreateCompanionBuilder,
          $$PreferenciasTableUpdateCompanionBuilder,
          (
            PreferenciaLinha,
            BaseReferences<_$BancoLocal, $PreferenciasTable, PreferenciaLinha>,
          ),
          PreferenciaLinha,
          PrefetchHooks Function()
        > {
  $$PreferenciasTableTableManager(_$BancoLocal db, $PreferenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferenciasCompanion(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => PreferenciasCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $PreferenciasTable,
      PreferenciaLinha,
      $$PreferenciasTableFilterComposer,
      $$PreferenciasTableOrderingComposer,
      $$PreferenciasTableAnnotationComposer,
      $$PreferenciasTableCreateCompanionBuilder,
      $$PreferenciasTableUpdateCompanionBuilder,
      (
        PreferenciaLinha,
        BaseReferences<_$BancoLocal, $PreferenciasTable, PreferenciaLinha>,
      ),
      PreferenciaLinha,
      PrefetchHooks Function()
    >;

class $BancoLocalManager {
  final _$BancoLocal _db;
  $BancoLocalManager(this._db);
  $$VeiculosTableTableManager get veiculos =>
      $$VeiculosTableTableManager(_db, _db.veiculos);
  $$AbastecimentosTableTableManager get abastecimentos =>
      $$AbastecimentosTableTableManager(_db, _db.abastecimentos);
  $$RecargasTableTableManager get recargas =>
      $$RecargasTableTableManager(_db, _db.recargas);
  $$CartoesTableTableManager get cartoes =>
      $$CartoesTableTableManager(_db, _db.cartoes);
  $$PreferenciasTableTableManager get preferencias =>
      $$PreferenciasTableTableManager(_db, _db.preferencias);
}
