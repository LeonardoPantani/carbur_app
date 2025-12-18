abstract class StationServiceException implements Exception {}

class ApiException extends StationServiceException {}

class ApiTimeoutException extends StationServiceException {}

class NoRouteException extends StationServiceException {}

class NetworkException extends StationServiceException {}

class UnknownServiceException extends StationServiceException {}
