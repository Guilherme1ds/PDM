import '../models/local.dart';
import 'constantes.dart';

/// Pesquisa e filtros em memória (seção 16 do tutorial).
///
/// Fica separado das telas para poder ser testado em test/widget_test.dart.
List<Local> filtrarLocais(
  List<Local> locais,
  String texto,
  String cidade,
  String categoria, {
  bool somenteFavoritos = false,
}) {
  final termo = texto.trim().toLowerCase();

  return locais.where((local) {
    final correspondeCidade = cidade == todasCidades || local.cidade == cidade;

    final correspondeCategoria =
        categoria == todasCategorias || local.categoria == categoria;

    final correspondeTexto = termo.isEmpty ||
        local.nome.toLowerCase().contains(termo) ||
        local.categoria.toLowerCase().contains(termo);

    final correspondeFavorito = !somenteFavoritos || local.favorito;

    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto &&
        correspondeFavorito;
  }).toList();
}
