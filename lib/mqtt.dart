import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:stupidhome/notify.dart';
import 'main.dart';

class MqttApp {
  String host;
  String identifier;
  var msgIn, msgOut;
  int port;
  MqttServerClient _client;
  BuildContext context;
  NotificationManager notificationManager;
  MqttApp(String host, String identifier, int port,
      NotificationManager notificationManager) {
    this.port = port;
    this.identifier = identifier;
    this.host = host;
    this._client =
        MqttServerClient.withPort(this.host, this.identifier, this.port);
    this.notificationManager = notificationManager;
  }

  //Connect to the Mqtt server
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
    _client.updates.listen((
      List<MqttReceivedMessage<MqttMessage>> c,
    ) {
      final MqttPublishMessage message = c[0].payload;
      final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

      try {
        this.msgIn = jsonDecode(payload);
      } catch (e) {
        this.msgIn = payload;
      }
      try {
        if (msgIn.split(' ')[0] == 'find_stranger') {
          notificationManager.showNotification('注意', '发现陌生人');
        }
      } catch (e) {}
      try {
        if (msgIn['action_name'] == 'hand_shake' && msgIn['state'] == 0) {
          //deviceList.add(msgIn['device_id']);
        }
      } catch (e) {}
      print(payload);
    });

    return 1;
  }

  //Subscribe the topic
  Future<void> subscribe(String topic) async {
    var count = 0;
    while (_client.connectionStatus.state != MqttConnectionState.connected &&
        count < 1000) {
      _client.connect();
      Future.delayed(Duration(milliseconds: 5000), () {});
      count++;
    }
    _client.subscribe(topic, MqttQos.exactlyOnce);
  }

  //Send message to the server
  void sendMsg(String msg, String pubTopic) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    _client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload);
  }

  //Disconnect
  Future<void> mqttdisconnect() async {
    await _client.disconnect();
  }

  // Connected callback
  void onConnected() {
    print('Connected');
  }

  //Disconnected callback
  void onDisconnected() {
    print('Disconnected');
  }

  //Subscribed callbalck
  void onSubscribed(String topic) {
    print('Subscribed topic: $topic');
  }

//Failed tp subscribe callback
  void onSubscribeFail(String topic) {
    print('Failed to subscribe $topic');
  }

// Unsubscribed callback
  void onUnsubscribed(String topic) {
    print('Unsubscribed topic: $topic');
  }

// Ping callback
  void pong() {
    print('Ping response client callback invoked');
  }
}
