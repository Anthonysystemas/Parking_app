import '../database.dart';

class UsuarioPerfilTable extends SupabaseTable<UsuarioPerfilRow> {
  @override
  String get tableName => 'usuario_perfil';

  @override
  UsuarioPerfilRow createRow(Map<String, dynamic> data) =>
      UsuarioPerfilRow(data);
}

class UsuarioPerfilRow extends SupabaseDataRow {
  UsuarioPerfilRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => UsuarioPerfilTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get nombre => getField<String>('nombre')!;
  set nombre(String value) => setField<String>('nombre', value);

  String get placa => getField<String>('placa')!;
  set placa(String value) => setField<String>('placa', value);

  String get userid => getField<String>('userid')!;
  set userid(String value) => setField<String>('userid', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
