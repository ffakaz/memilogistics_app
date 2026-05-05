enum AppEnvironment { development, staging, production, fake }

/// Minimal API configuration used by the app to switch between fake
/// and real backends. This implementation provides sensible defaults
/// so the rest of the codebase can rely on `ApiConfig.current`.
class ApiConfig {
	ApiConfig._({
		required this.env,
		required this.baseUrl,
		required this.connectTimeout,
		required this.receiveTimeout,
		required this.sendTimeout,
		this.enableLogging = false,
	});

	final AppEnvironment env;
	final String baseUrl;
	final Duration connectTimeout;
	final Duration receiveTimeout;
	final Duration sendTimeout;
	final bool enableLogging;

	static late ApiConfig current;

	bool get isFake => env == AppEnvironment.fake;

	/// Initialize the shared configuration for the given [env].
	static void init(AppEnvironment env) {
		switch (env) {
			case AppEnvironment.fake:
				current = ApiConfig._(
					env: env,
					baseUrl: 'https://fake.api/',
					connectTimeout: const Duration(seconds: 5),
					receiveTimeout: const Duration(seconds: 5),
					sendTimeout: const Duration(seconds: 5),
					enableLogging: true,
				);
				break;
			case AppEnvironment.development:
				current = ApiConfig._(
					env: env,
					baseUrl: 'https://dev.api/',
					connectTimeout: const Duration(seconds: 10),
					receiveTimeout: const Duration(seconds: 10),
					sendTimeout: const Duration(seconds: 10),
					enableLogging: true,
				);
				break;
			case AppEnvironment.staging:
			case AppEnvironment.production:
			default:
				current = ApiConfig._(
					env: env,
					baseUrl: 'https://api.example.com/',
					connectTimeout: const Duration(seconds: 10),
					receiveTimeout: const Duration(seconds: 10),
					sendTimeout: const Duration(seconds: 10),
					enableLogging: false,
				);
		}
	}
}
