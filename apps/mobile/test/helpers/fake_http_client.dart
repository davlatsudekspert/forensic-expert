import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// So‘rovni ushlab qoluvchi soxta [HttpClient] (tarmoqsiz). Haqiqiy
/// transportlarning (`HttpClientTransport`, `HttpClientTtsHttp`) sarlavha
/// qo‘shish yo‘lini sinash uchun.
class FakeHttpClient implements HttpClient {
  FakeHttpClient({this.status = 200, this.body = '{}'});

  int status;
  String body;
  final List<FakeRequest> requests = [];

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final r = FakeRequest(method, url, status, body);
    requests.add(r);
    return r;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeHeaders implements HttpHeaders {
  final Map<String, String> values = {};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    values[name.toLowerCase()] = '$value';
  }

  @override
  ContentType? contentType;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeRequest implements HttpClientRequest {
  FakeRequest(this.method, this.url, this._status, this._body);

  @override
  final String method;
  final Uri url;
  final int _status;
  final String _body;
  final FakeHeaders _headers = FakeHeaders();
  final StringBuffer written = StringBuffer();

  Map<String, String> get sent => _headers.values;

  @override
  HttpHeaders get headers => _headers;

  @override
  void write(Object? object) => written.write(object);

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async =>
      FakeResponse(_status, utf8.encode(_body));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  FakeResponse(this.statusCode, this._bytes);

  @override
  final int statusCode;
  final List<int> _bytes;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(_bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
