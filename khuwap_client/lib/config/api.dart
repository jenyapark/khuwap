const String coreHost = String.fromEnvironment(
  'CORE_HOST',
  defaultValue: 'localhost',
);
const String corePort = String.fromEnvironment(
  'CORE_PORT',
  defaultValue: '8000',
);

String get coreUrl => 'http://$coreHost:$corePort';
