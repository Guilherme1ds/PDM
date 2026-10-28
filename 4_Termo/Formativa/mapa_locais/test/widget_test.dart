// Testes automatizados da lógica do app (rodar com: flutter test).
// Não dependem do Firebase, por isso rodam sem internet.

import 'package:flutter_test/flutter_test.dart';

import 'package:mapa_locais/models/local.dart';
import 'package:mapa_locais/utils/filtros.dart';

Local criar(String nome, String categoria, String cidade,
    {bool favorito = false}) {
  return Local(
    id: nome,
    nome: nome,
    categoria: categoria,
    cidade: cidade,
    avaliacao: 4.5,
    distancia: 1.0,
    horario: '08:00 - 18:00',
    descricao: '',
    favorito: favorito,
  );
}

void main() {
  final locais = [
    criar('Academia Fitness', 'Academia', 'São Paulo', favorito: true),
    criar('Smart Fit', 'Academia', 'Campinas'),
    criar('Cantina Bella', 'Restaurante', 'São Paulo'),
    criar('Hospital Campinas', 'Hospital', 'Campinas'),
  ];

  group('Model Local', () {
    test('fromMap e toMap preservam os dados', () {
      final original = criar('Teste', 'Academia', 'Jundiaí');
      final copia = Local.fromMap('Teste', original.toMap());

      expect(copia.nome, 'Teste');
      expect(copia.categoria, 'Academia');
      expect(copia.cidade, 'Jundiaí');
      expect(copia.avaliacao, 4.5);
    });

    test('fromMap usa valores padrão quando faltam campos', () {
      final local = Local.fromMap('abc', {'avaliacao': 4});
      expect(local.nome, '');
      expect(local.avaliacao, 4.0);
      expect(local.favorito, false);
    });
  });

  group('Pesquisa e filtros', () {
    test('T02 — pesquisa por "Academia" encontra por categoria', () {
      final r = filtrarLocais(locais, 'academia', 'Todas', 'Todos');
      expect(r.length, 2);
    });

    test('T03 — filtro por cidade Campinas', () {
      final r = filtrarLocais(locais, '', 'Campinas', 'Todos');
      expect(r.map((l) => l.nome).toList(), ['Smart Fit', 'Hospital Campinas']);
    });

    test('T04 — filtro por categoria Restaurante', () {
      final r = filtrarLocais(locais, '', 'Todas', 'Restaurante');
      expect(r.single.nome, 'Cantina Bella');
    });

    test('Filtros combinados (cidade + categoria)', () {
      final r = filtrarLocais(locais, '', 'São Paulo', 'Academia');
      expect(r.single.nome, 'Academia Fitness');
    });

    test('T09 — somente favoritos', () {
      final r =
          filtrarLocais(locais, '', 'Todas', 'Todos', somenteFavoritos: true);
      expect(r.single.nome, 'Academia Fitness');
    });

    test('Pesquisa sem resultado retorna lista vazia', () {
      final r = filtrarLocais(locais, 'xyz', 'Todas', 'Todos');
      expect(r, isEmpty);
    });
  });
}
