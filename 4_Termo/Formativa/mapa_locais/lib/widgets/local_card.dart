import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/constantes.dart';

/// Item da lista de resultados (Tela 2 do wireframe).
class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const LocalCard({
    super.key,
    required this.local,
    required this.onTap,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final estiloCinza = TextStyle(fontSize: 12, color: Colors.grey.shade700);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // "Imagem" do local
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  iconeCategoria(local.categoria),
                  size: 32,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),

              // Informações
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            local.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (local.favorito)
                          const Icon(Icons.favorite, size: 16, color: Colors.red),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(local.categoria, style: estiloCinza),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 2),
                        Text(
                          '${local.distancia.toStringAsFixed(1)} km',
                          style: estiloCinza,
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          local.avaliacao.toStringAsFixed(1),
                          style: estiloCinza,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu editar / excluir
              PopupMenuButton<String>(
                tooltip: 'Opções',
                onSelected: (opcao) {
                  if (opcao == 'editar') onEditar();
                  if (opcao == 'excluir') onExcluir();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Excluir'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: cores.outline),
            ],
          ),
        ),
      ),
    );
  }
}
