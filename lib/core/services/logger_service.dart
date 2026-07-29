import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  File? _logFile;
  final int _maxDaysToKeepLogs = 30;

  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/corvus_security.log');
    await _rotateLogsIfNecessary();
  }

  Future<void> logAction(String message) async => _writeLog('ACTION', message);
  Future<void> logWarning(String message) async => _writeLog('WARNING', message);
  Future<void> logError(String message) async => _writeLog('ERROR', message);

  Future<void> _writeLog(String level, String message) async {
    if (_logFile == null) return;
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] [$level] $message\n';
    await _logFile!.writeAsString(logEntry, mode: FileMode.append);
  }

  Future<void> _rotateLogsIfNecessary() async {
    if (_logFile == null || !(await _logFile!.exists())) return;
    final lastModified = await _logFile!.lastModified();
    final difference = DateTime.now().difference(lastModified).inDays;

    // reiniciar los logs de forma segura en el dia 31 mayor a 30 dias 
    if (difference > _maxDaysToKeepLogs) {
      await _logFile!.delete();
      await _writeLog('SYSTEM', 'Ciclo de 30 días completado. Logs reiniciados por seguridad.');
    }
  }
}
