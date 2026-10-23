// test/unit/utils/extension_auth_test.dart
//
// Tests for ExtensionAuth (approval store) and the extension server's
// enforcement of it over real loopback HTTP / WebSocket connections.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/utils/browser_extension_server.dart';
import 'package:screentime/utils/extension_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = '11111111-2222-3333-4444-555555555555';
const _id2 = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
final _token = 'a' * 64;
final _otherToken = 'b' * 64;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExtensionAuth', () {
    late ExtensionAuth auth;
    late bool required;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      required = true;
      auth = ExtensionAuth(requireApproval: () => required);
    });

    test('missing or malformed credentials are rejected and not queued', () {
      expect(auth.check(null, null), AuthStatus.missing);
      expect(auth.check(_id, null), AuthStatus.missing);
      expect(auth.check(null, _token), AuthStatus.missing);
      expect(auth.check('short', _token), AuthStatus.missing);
      expect(auth.check(_id, 'tooshort'), AuthStatus.missing);
      expect(auth.check(_id, 'x' * 40 + '!'), AuthStatus.missing);
      expect(auth.pending, isEmpty);
    });

    test('unknown browser is queued as pending until approved', () async {
      expect(auth.check(_id, _token, browserName: 'Chrome'),
          AuthStatus.pending);
      expect(auth.pending.single.id, _id);
      expect(auth.pending.single.name, 'Chrome');

      // Repeated attempts don't add duplicates.
      auth.check(_id, _token);
      expect(auth.pending, hasLength(1));

      expect(await auth.approve(_id), isTrue);
      expect(auth.pending, isEmpty);
      expect(auth.check(_id, _token), AuthStatus.approved);
    });

    test('approved browser with a different token is rejected', () async {
      auth.check(_id, _token);
      await auth.approve(_id);

      expect(auth.check(_id, _otherToken), AuthStatus.invalid);
      expect(auth.pending, isEmpty); // not re-queued, so it can't be hijacked
    });

    test('a token swap while pending is a conflict, not an update', () {
      auth.check(_id, _token);
      expect(auth.check(_id, _otherToken), AuthStatus.invalid);
      expect(auth.pending.single.id, _id);
    });

    test('denied browsers stay blocked until the user lets them ask again',
        () async {
      auth.check(_id, _token);
      await auth.deny(_id);
      expect(auth.check(_id, _token), AuthStatus.denied);
      expect(auth.pending, isEmpty);

      await auth.clearDenied();
      expect(auth.check(_id, _token), AuthStatus.pending);
    });

    test('revoked browser is queued again', () async {
      auth.check(_id, _token);
      await auth.approve(_id);
      await auth.revoke(_id);

      expect(auth.check(_id, _token), AuthStatus.pending);
    });

    test('everything is allowed when approval is not required', () {
      required = false;
      expect(auth.check(null, null), AuthStatus.approved);
      expect(auth.check(_id, _token), AuthStatus.approved);
      expect(auth.pending, isEmpty);
    });

    test('pending queue is capped', () {
      for (var i = 0; i < 30; i++) {
        auth.check('00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}',
            _token);
      }
      expect(auth.pending.length, 20);
    });

    test('blocked requests are counted, approved ones are not', () async {
      auth.check(null, null);
      auth.check(_id, _token);
      expect(auth.blockedCount, 2);
      await auth.approve(_id);
      auth.check(_id, _token);
      expect(auth.blockedCount, 2);
    });

    test('approvals and denials survive a reload; tokens are stored hashed',
        () async {
      auth.check(_id, _token, browserName: 'Firefox');
      await auth.approve(_id);
      auth.check(_id2, _token);
      await auth.deny(_id2);

      final reloaded = ExtensionAuth(requireApproval: () => true);
      await reloaded.load();
      expect(reloaded.check(_id, _token), AuthStatus.approved);
      expect(reloaded.approved.single.name, 'Firefox');
      expect(reloaded.check(_id2, _token), AuthStatus.denied);

      final raw = (await SharedPreferences.getInstance())
          .getString('extension_auth_v1')!;
      expect(raw.contains(_token), isFalse);
    });

    test('notifies listeners when the pending list changes', () async {
      var calls = 0;
      auth.addListener(() => calls++);
      auth.check(_id, _token);
      expect(calls, 1);
      await auth.approve(_id);
      expect(calls, 2);
    });
  });

  group('BrowserExtensionServer', () {
    const port = 46173;
    late HttpClient client;

    Future<({int status, Map<String, dynamic> body})> send(
      String method,
      String path, {
      Map<String, String> headers = const {},
      String? body,
    }) async {
      final req = await client.openUrl(
          method, Uri.parse('http://127.0.0.1:$port$path'));
      headers.forEach(req.headers.set);
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.write(body);
      }
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      return (
        status: res.statusCode,
        body: text.isEmpty ? <String, dynamic>{} : jsonDecode(text) as Map<String, dynamic>,
      );
    }

    Map<String, String> creds(String id, String token) => {
          'Authorization': 'Bearer $token',
          'X-Scolect-Browser': id,
          'X-Scolect-Browser-Name': 'TestBrowser',
        };

    setUpAll(() async {
      // flutter_test replaces HttpClient with a stub that answers 400 to
      // everything; these tests need real loopback connections.
      HttpOverrides.global = null;
      SharedPreferences.setMockInitialValues({});
      await SettingsManager().init();
      client = HttpClient();
      expect(await BrowserExtensionServer.startServer(port: port), isTrue);
    });

    tearDownAll(() async {
      client.close(force: true);
      await BrowserExtensionServer.dispose();
    });

    setUp(() {
      ExtensionAuth.instance.resetForTesting();
      SettingsManager().updateSetting(ExtensionAuth.settingKey, true);
    });

    test('ping is open and reports that auth is required', () async {
      final r = await send('GET', '/ping');
      expect(r.status, 200);
      expect(r.body['authRequired'], isTrue);
      expect(r.body.containsKey('pairing'), isFalse);
    });

    test('data routes reject requests without credentials', () async {
      for (final route in [
        ('POST', '/usage'),
        ('POST', '/api/browser-sync'),
        ('POST', '/clear-web-data'),
        ('GET', '/focus'),
        ('GET', '/ws'),
      ]) {
        final r = await send(route.$1, route.$2, body: route.$1 == 'POST' ? '{}' : null);
        expect(r.status, 401, reason: '${route.$1} ${route.$2}');
        expect(r.body['pairing'], 'missing');
      }
    });

    test('unknown browser gets 401 pending and shows up for approval', () async {
      final r = await send('POST', '/usage',
          headers: creds(_id, _token), body: '{}');
      expect(r.status, 401);
      expect(r.body['pairing'], 'pending');
      expect(ExtensionAuth.instance.pending.single.id, _id);
      expect(ExtensionAuth.instance.pending.single.name, 'TestBrowser');
    });

    test('ping with credentials reports the pairing state', () async {
      final pending = await send('GET', '/ping', headers: creds(_id, _token));
      expect(pending.body['pairing'], 'pending');

      await ExtensionAuth.instance.approve(_id);
      final ok = await send('GET', '/ping', headers: creds(_id, _token));
      expect(ok.body['pairing'], 'approved');
    });

    test('approved browser passes auth; wrong token and denied do not',
        () async {
      await send('GET', '/ping', headers: creds(_id, _token));
      await ExtensionAuth.instance.approve(_id);

      // Invalid JSON reaches the handler (400), proving auth passed.
      final ok = await send('POST', '/usage',
          headers: creds(_id, _token), body: 'not json');
      expect(ok.status, 400);

      final bad = await send('POST', '/usage',
          headers: creds(_id, _otherToken), body: '{}');
      expect(bad.status, 401);
      expect(bad.body['pairing'], 'invalid');

      await send('GET', '/ping', headers: creds(_id2, _token));
      await ExtensionAuth.instance.deny(_id2);
      final denied = await send('POST', '/usage',
          headers: creds(_id2, _token), body: '{}');
      expect(denied.status, 403);
      expect(denied.body['pairing'], 'denied');
    });

    test('an approved browser cannot post usage as another browser',
        () async {
      await send('GET', '/ping', headers: creds(_id, _token));
      await ExtensionAuth.instance.approve(_id);

      final r = await send('POST', '/usage',
          headers: creds(_id, _token),
          body: jsonEncode({
            'date': '2026-01-01',
            'domains': <dynamic>[],
            'browserId': _id2,
          }));
      expect(r.status, 403);
    });

    test('approval is off by default, so old extensions without a token work',
        () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsManager().init();
      expect(ExtensionAuth.instance.isRequired, isFalse);

      // No credentials at all, as an older extension build would send.
      final r = await send('POST', '/usage', body: 'not json');
      expect(r.status, 400); // reached the handler; not 401
    });

    test('with approval turned off, requests are not blocked', () async {
      SettingsManager().updateSetting(ExtensionAuth.settingKey, false);
      final r = await send('POST', '/usage', body: 'not json');
      expect(r.status, 400);
    });

    test('websocket upgrade is refused until the browser is approved',
        () async {
      final url = 'ws://127.0.0.1:$port/ws?browserId=$_id&token=$_token';

      await expectLater(WebSocket.connect(url), throwsA(isA<WebSocketException>()));

      await ExtensionAuth.instance.approve(_id);
      final ws = await WebSocket.connect(url);
      expect(ws.readyState, WebSocket.open);
      await ws.close();
    });

    test('CORS preflight allows the auth headers', () async {
      final req = await client.openUrl(
          'OPTIONS', Uri.parse('http://127.0.0.1:$port/usage'));
      req.headers.set('Origin', 'chrome-extension://abcdef');
      final res = await req.close();
      await res.drain<void>();
      expect(res.statusCode, 204);
      final allowed = res.headers.value('access-control-allow-headers')!;
      expect(allowed, contains('Authorization'));
      expect(allowed, contains('X-Scolect-Browser'));
    });
  });
}
