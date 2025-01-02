// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:sqflite/sqflite.dart';

Future<void> fusionnerLignesRelevephoto(
  BuildContext context,
  String numeroDossier,
) async {
  Database? db;
  try {
    // Obtenir une référence à la base de données
    db = await SQLiteManager.instance.database;

    // Récupérer toutes les lignes correspondant au numéro de dossier
    final List<Map<String, dynamic>> rows = await db.query(
      'relevephoto',
      where: 'numero_dossier = ?',
      whereArgs: [numeroDossier],
    );

    if (rows.isEmpty) {
      throw Exception('Chargement des photos en cours');
    }

    // Créer un map pour stocker les données fusionnées
    final Map<String, dynamic> fusionnees = {'numero_dossier': numeroDossier};

    // Parcourir toutes les lignes correspondantes
    for (final row in rows) {
      // Parcourir toutes les colonnes de chaque ligne
      row.forEach((colonne, valeur) {
        // Ignorer la colonne numero_dossier et id
        if (colonne != 'numero_dossier' && colonne != 'id') {
          // Fusionner les données de photo
          if (colonne == 'photo_data' && valeur != null && valeur != '') {
            fusionnees[colonne] = valeur; // Conserver la dernière photo
          } else if (valeur != null && valeur != '') {
            fusionnees[colonne] = valeur; // Fusionner les autres données
          }
        }
      });
    }

    // Commencer une transaction
    await db.transaction((txn) async {
      // Supprimer toutes les lignes existantes pour ce numéro de dossier
      await txn.delete(
        'relevephoto',
        where: 'numero_dossier = ?',
        whereArgs: [numeroDossier],
      );

      // Insérer la nouvelle ligne fusionnée
      await txn.insert('relevephoto', fusionnees);
    });

    // Vérifier que la fusion a bien été enregistrée
    final List<Map<String, dynamic>> verificationRows = await db.query(
      'relevephoto',
      where: 'numero_dossier = ?',
      whereArgs: [numeroDossier],
    );

    if (verificationRows.length != 1) {
      throw Exception('Chargement des photos en cours');
    }

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chargement des photos en cours')),
    );
  } catch (e) {
    // Gérer les erreurs
    print('Chargement des photos en cours');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chargement des photos en cours')),
    );
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
