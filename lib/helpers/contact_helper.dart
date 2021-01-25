import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

final String contactTable = "contactTable";
final String idColunm = "idColunm";
final String nomeColunm = "nomeColunm";
final String emailColunm = "emailColunm";
final String telefoneColunm = "telefoneColunm";
final String imageColunm = "imageColunm";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contact.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db
          .execute("CREATE TABLE $contactTable($idColunm INTEGER PRIMARY KEY,"
              "$nomeColunm TEXT, $emailColunm TEXT, $telefoneColunm TEXT,"
              " $imageColunm TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColunm,
          nomeColunm,
          emailColunm,
          telefoneColunm,
          imageColunm
        ],
        where: "$idColunm = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColunm = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColunm = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map map in listMap) {
      listContact.add(Contact.fromMap(map));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String nome;
  String email;
  String telefone;
  String image;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColunm];
    nome = map[nomeColunm];
    email = map[emailColunm];
    telefone = map[telefoneColunm];
    image = map[imageColunm];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColunm: nome,
      emailColunm: email,
      telefoneColunm: telefone,
      imageColunm: image
    };
    if (id != null) {
      map[idColunm] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, nome: $nome, email: $email, telefone: $telefone, image: $image)";
  }
}
