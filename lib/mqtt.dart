import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class clienttest {
  String host;
  String identifier;
  int port;
  int flag;
  MqttServerClient _client;
  clienttest(String host, String identifier, int port) {
    this.port = port;
    this.identifier = identifier;
    this.host = host;
    this._client =
        MqttServerClient.withPort(this.host, this.identifier, this.port);
  }

  Future<int> connect() async {
    _client.logging(on: true);
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    _client.onUnsubscribed = onUnsubscribed;
    _client.onSubscribed = onSubscribed;
    _client.onSubscribeFail = onSubscribeFail;
    _client.pongCallback = pong;

    try {
      await _client.connect();
    } catch (e) {
      print('Exception: $e');
      _client.disconnect();
    }
    _client.subscribe("init", MqttQos.atLeastOnce);
    _client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
      MqttPublishPayload.bytesToStringAsString(message.payload.message);

      print('Received message:$payload from topic: ${c[0].topic}>');
    });
  }

  void subscribe(String topic) {
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void sendmsg() {
    const pubTopic = 'out';
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello MQTT');
    _client.publishMessage(pubTopic, MqttQos.atLeastOnce, builder.payload);
  }

  // 连接成功
  void onConnected() {
    print('Connected');
  }

// 连接断开
  void onDisconnected() {
    print('Disconnected');
  }

// 订阅主题成功
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

// 订阅主题失败
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// 成功取消订阅
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// 收到 PING 响应
  void pong() {
    print('Ping response client callback invoked');
  }
}