export {};

declare global {
  var configureTracerProvider: ((tracerProvider: any) => void) | undefined;
  var configureTracer: ((defaultConfig: any) => any) | undefined;
  var configureSdkRegistration: ((defaultSdkRegistration: any) => any) | undefined;
  var configureMeter: ((defaultConfig: any) => any) | undefined;
  var configureMeterProvider: ((meterProvider: any) => void) | undefined;
  var configureInstrumentations: (() => any[]) | undefined;
  var configureAwsInstrumentation: ((config: any) => any) | undefined;
}