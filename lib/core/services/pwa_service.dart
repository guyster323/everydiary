// 조건부 import를 사용하여 플랫폼별 구현 선택
export 'pwa_service_stub.dart' if (dart.library.html) 'pwa_service_web.dart';
