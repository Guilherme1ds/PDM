import 'package:flutter/material.dart';

/// Pede confirmação antes de excluir (seção 19 do tutorial).
/// Retorna true somente se o usuário tocar em "Excluir".
Future<bool> confirmarExclusao(BuildContext context, String nomeLocal) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Excluir local?'),
        content: Text(
          '"$nomeLocal" será removido do banco.\n'
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );

  return confirmou ?? false;
}
