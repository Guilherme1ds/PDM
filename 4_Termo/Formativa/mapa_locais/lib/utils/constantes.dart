import 'package:flutter/material.dart';

/// Cidades disponíveis no seletor (RF01 — no mínimo três).
const List<String> cidades = ['São Paulo', 'Campinas', 'Jundiaí'];

/// Categorias usadas no filtro e no formulário de cadastro.
const List<String> categorias = [
  'Academia',
  'Restaurante',
  'Hospital',
  'Farmácia',
  'Mercado',
];

/// Valores especiais que significam "sem filtro".
const String todasCidades = 'Todas';
const String todasCategorias = 'Todos';

/// Ícone exibido para cada categoria (usado como "imagem" do local).
IconData iconeCategoria(String categoria) {
  switch (categoria) {
    case 'Academia':
      return Icons.fitness_center;
    case 'Restaurante':
      return Icons.restaurant;
    case 'Hospital':
      return Icons.local_hospital;
    case 'Farmácia':
      return Icons.local_pharmacy;
    case 'Mercado':
      return Icons.shopping_cart;
    default:
      return Icons.place;
  }
}
