import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:mobile/core/services/secure_storage_service.dart';

class NotificationsLocalDataSource {
  static Database? _database;
  static final SecureStorageService _storage = SecureStorageService();

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications_secure.db');
    return _database!;
  }

  static Future<String> _getEncryptionKey() async {
    String? key = await _storage.read(key: 'db_encryption_key');
    if (key == null) {
      // Generate a new secure key if not exists (dummy logic for simple usage)
      key = DateTime.now().millisecondsSinceEpoch.toString() + "CORVUS_SECURE_KEY";
      await _storage.write(key: 'db_encryption_key', value: key);
    }
    return key;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    final key = await _getEncryptionKey();

    return await openDatabase(
      path,
      version: 4,
      password: key,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  static Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notifications ADD COLUMN authorName TEXT;');
      await db.execute('ALTER TABLE notifications ADD COLUMN authorPhotoUrl TEXT;');
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS notifications');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE notifications ADD COLUMN deepLink TEXT;');
      } catch (_) {}
    }
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        deepLink TEXT,
        timestamp TEXT NOT NULL,
        isRead INTEGER NOT NULL,
        authorName TEXT,
        authorPhotoUrl TEXT
      )
    ''');
  }

  static Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('notifications', notification);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'timestamp DESC');
  }

  static Future<int> markAsRead(String id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> markAllAsRead() async {
    final db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
    );
  }

  static Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM notifications WHERE isRead = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> deleteNotification(String id) async {
    final db = await database;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllRemote() async {
    final db = await database;
    await db.delete('notifications', where: "id NOT LIKE 'temp_%'");
  }

  static Future<void> deleteAll() async {
    final db = await database;
    await db.delete('notifications');
  }
}
