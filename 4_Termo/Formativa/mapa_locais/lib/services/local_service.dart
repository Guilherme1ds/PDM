import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/local.dart';

class LocalService {
  final CollectionReference locais = FirebaseFirestore.instance.collection('locais');

  Stream<List<Local>> listarLocais() {
    return locais.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Local.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

Future<void> adicionar(Local local) async {
  await locais.add(local.toMap());
}

Future<void> atualizar(Local local) async {
  await locais.doc(local.id).update(local.toMap());
}

Future<void> excluir(String id) async {
  await locais.doc(id).delete();
}

Future<void> alterarFavorito(
  String id,
  bool favorito,
) async {
  await locais.doc(id).update({
    'favorito': favorito,
  });
}
}

final LocalService service = LocalService();

StreamBuilder<List<Local>>(
  stream: service.listarLocais(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Center(
        child: Text('Erro ao carregar os locais.'),
      );
    }

    final locais = snapshot.data ?? [];

    if (locais.isEmpty) {
      return const Center(
        child: Text('Nenhum local encontrado.'),
      );
    }

    return ListView.builder(
      itemCount: locais.length,
      itemBuilder: (context, index) {
        final local = locais[index];

        return ListTile(
          title: Text(local.nome),
          subtitle: Text(local.categoria),
          onTap: () {
            // abrir detalhes
          },
        );
      },
    );
  },
)