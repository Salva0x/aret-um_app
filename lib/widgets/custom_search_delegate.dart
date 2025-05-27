import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomSearchDelegate extends SearchDelegate<String?> {
  String initialQuery;

  CustomSearchDelegate({this.initialQuery = ''}) {
    query = initialQuery;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty) // Solo muestra el botón si hay texto
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Limpiar',
          onPressed: () {
            query = "";
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Atrás',
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Introduce un término para buscar."));
    }

    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('users')
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThanOrEqualTo: '$query\uf8ff')
              .limit(10)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error al buscar: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No se encontraron resultados."));
        }

        final results = snapshot.data!.docs;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var itemData = results[index].data() as Map<String, dynamic>?;
            String name = itemData?['name'] ?? 'Nombre no disponible';
            String email = itemData?['email'] ?? 'Email no disponible';

            return ListTile(
              title: Text(name),
              subtitle: Text(email),
              onTap: () {
                close(context, name);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Muestra sugerencias mientras el usuario escribe
    if (query.isEmpty) {
      return const Center(child: Text('Escribe para buscar usuarios...'));
    }

    return FutureBuilder<QuerySnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('users')
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThanOrEqualTo: '$query\uf8ff')
              .limit(5)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar sugerencias."));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No hay sugerencias."));
        }

        final suggestions = snapshot.data!.docs;

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            var userData = suggestions[index].data() as Map<String, dynamic>?;
            String name = userData?['name'] ?? '';

            return ListTile(
              title: Text(name),
              onTap: () {
                query = name; // Pone la sugerencia en la barra de búsqueda
                showResults(
                  context,
                ); // Muestra los resultados para esa sugerencia
              },
            );
          },
        );
      },
    );
  }
}
