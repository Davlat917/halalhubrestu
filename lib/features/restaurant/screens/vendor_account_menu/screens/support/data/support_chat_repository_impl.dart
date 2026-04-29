import 'dart:async';
import 'dart:convert';

import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/support_chat_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@Injectable(as: SupportChatRepository)
class SupportChatRepositoryImpl implements SupportChatRepository {
  SupportChatRepositoryImpl(this._storage);

  final Storage _storage;

  final _controller = StreamController<ServiceSupportChatModel>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  static const _wsBase = 'wss://backend-api.wehalalhub.com/ws/faq/me/';

  @override
  Stream<ServiceSupportChatModel> get inbound => _controller.stream;

  @override
  Future<void> connect() async {
    await disconnect();
    final token = _storage.token.call();
    if (token == null || token.isEmpty) {
      throw StateError('Missing auth token');
    }
    final uri = Uri.parse('$_wsBase?token=${Uri.encodeQueryComponent(token)}');
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      _onSocketData,
      onError: (Object e, StackTrace st) {
        if (!_controller.isClosed) {
          _controller.addError(e, st);
        }
      },
      onDone: () {},
      cancelOnError: false,
    );
  }

  void _onSocketData(dynamic data) {
    if (data is! String) return;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      final model = ServiceSupportChatModel.fromJson(map);
      if (!_controller.isClosed) {
        _controller.add(model);
      }
    } catch (_) {
      // noto‘g‘ri JSON — e’tiborsiz
    }
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  @override
  void sendText(String content) {
    final text = content.trim();
    if (text.isEmpty) return;
    final payload = jsonEncode(<String, dynamic>{'content': text});
    _channel?.sink.add(payload);
  }
}
