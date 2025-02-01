import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    level: Level.all,
    printer: PrettyPrinter()
  );

  static Logger get logger => _logger;
}
