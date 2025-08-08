const {
  NodeTracerConfig,
  NodeTracerProvider,
} = require("@opentelemetry/sdk-trace-node");
const {
  BatchSpanProcessor,
  ConsoleSpanExporter,
  SDKRegistrationConfig,
  SimpleSpanProcessor,
} = require("@opentelemetry/sdk-trace-base");
const {
  Instrumentation,
  registerInstrumentations,
} = require("@opentelemetry/instrumentation");
const { awsLambdaDetector } = require("@opentelemetry/resource-detector-aws");
const {
  detectResourcesSync,
  envDetector,
  processDetector,
} = require("@opentelemetry/resources");
const {
  AwsInstrumentation,
} = require("@opentelemetry/instrumentation-aws-sdk");
const {
  AwsLambdaInstrumentation,
} = require("@opentelemetry/instrumentation-aws-lambda");
const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { getEnv } = require("@opentelemetry/core");
const {
  OTLPTraceExporter,
} = require("@opentelemetry/exporter-trace-otlp-http");
const {
  MeterProvider,
  MeterProviderOptions,
} = require("@opentelemetry/sdk-metrics");

function defaultConfigureInstrumentations() {
  // Use require statements for instrumentation to avoid having to have transitive dependencies on all the typescript
  // definitions.
  const { DnsInstrumentation } = require("@opentelemetry/instrumentation-dns");
  const {
    ExpressInstrumentation,
  } = require("@opentelemetry/instrumentation-express");
  const {
    GraphQLInstrumentation,
  } = require("@opentelemetry/instrumentation-graphql");
  const {
    GrpcInstrumentation,
  } = require("@opentelemetry/instrumentation-grpc");
  const {
    HapiInstrumentation,
  } = require("@opentelemetry/instrumentation-hapi");
  const {
    HttpInstrumentation,
  } = require("@opentelemetry/instrumentation-http");
  const {
    IORedisInstrumentation,
  } = require("@opentelemetry/instrumentation-ioredis");
  const { KoaInstrumentation } = require("@opentelemetry/instrumentation-koa");
  const {
    MongoDBInstrumentation,
  } = require("@opentelemetry/instrumentation-mongodb");
  const {
    MySQLInstrumentation,
  } = require("@opentelemetry/instrumentation-mysql");
  const { NetInstrumentation } = require("@opentelemetry/instrumentation-net");
  const { PgInstrumentation } = require("@opentelemetry/instrumentation-pg");
  const {
    RedisInstrumentation,
  } = require("@opentelemetry/instrumentation-redis");
  return [
    new DnsInstrumentation(),
    new ExpressInstrumentation(),
    new GraphQLInstrumentation(),
    new GrpcInstrumentation(),
    new HapiInstrumentation(),
    new HttpInstrumentation(),
    new IORedisInstrumentation(),
    new KoaInstrumentation(),
    new MongoDBInstrumentation(),
    new MySQLInstrumentation(),
    new NetInstrumentation(),
    new PgInstrumentation(),
    new RedisInstrumentation(),
  ];
}

global.configureTracerProvider = function (tracerProvider) {};
global.configureTracer = function (defaultConfig) {
  return defaultConfig;
};
global.configureSdkRegistration = function (defaultSdkRegistration) {
  return defaultSdkRegistration;
};
global.configureMeter = function (defaultConfig) {
  return defaultConfig;
};
global.configureMeterProvider = function (meterProvider) {};
global.configureInstrumentations = function () {
  return [];
};

// configure lambda logging
const logLevel = getEnv().OTEL_LOG_LEVEL;
diag.setLogger(new DiagConsoleLogger(), logLevel);

console.log("Registering OpenTelemetry");

// By default use OpenTelemetry context propagation
let disableAwsContextPropagation = true;
const sumoOtelDisableAwsContextPropagationVal =
  process.env.SUMO_OTEL_DISABLE_AWS_CONTEXT_PROPAGATION;
if (
  sumoOtelDisableAwsContextPropagationVal === "false" ||
  sumoOtelDisableAwsContextPropagationVal === "False"
) {
  disableAwsContextPropagation = false;
}

// For debug purposes only
if (logLevel === DiagLogLevel.DEBUG) {
  console.log("Debug environment variables status");
  console.log(
    "AWS_LAMBDA_EXEC_WRAPPER value ",
    process.env.AWS_LAMBDA_EXEC_WRAPPER
  );
  console.log(
    "OTEL_RESOURCE_ATTRIBUTES value",
    process.env.OTEL_RESOURCE_ATTRIBUTES
  );
  console.log("OTEL_SERVICE_NAME value", process.env.OTEL_SERVICE_NAME);
  console.log("OTEL_TRACES_SAMPLER value", process.env.OTEL_TRACES_SAMPLER);
  console.log(
    "SUMOLOGIC_HTTP_TRACES_ENDPOINT_URL value",
    process.env.SUMOLOGIC_HTTP_TRACES_ENDPOINT_URL
  );
  console.log(
    "SUMO_OTEL_DISABLE_AWS_CONTEXT_PROPAGATION value",
    process.env.SUMO_OTEL_DISABLE_AWS_CONTEXT_PROPAGATION
  );
}

const instrumentations = [
  new AwsInstrumentation({
    suppressInternalInstrumentation: true,
  }),
  new AwsLambdaInstrumentation({
    disableAwsContextPropagation: disableAwsContextPropagation,
  }),
  ...(typeof configureInstrumentations === "function"
    ? configureInstrumentations
    : defaultConfigureInstrumentations)(),
];

// Register instrumentations synchronously to ensure code is patched even before provider is ready.
registerInstrumentations({
  instrumentations,
});

async function initializeProvider() {
  const resource = detectResourcesSync({
    detectors: [awsLambdaDetector, envDetector, processDetector],
  });

  let config = {
    resource,
  };
  if (typeof configureTracer === "function") {
    config = configureTracer(config);
  }

  const tracerProvider = new NodeTracerProvider(config);
  if (typeof configureTracerProvider === "function") {
    configureTracerProvider(tracerProvider);
  } else {
    // defaults
    tracerProvider.addSpanProcessor(
      new BatchSpanProcessor(new OTLPTraceExporter())
    );
  }
  // logging for debug
  if (logLevel === DiagLogLevel.DEBUG) {
    tracerProvider.addSpanProcessor(
      new SimpleSpanProcessor(new ConsoleSpanExporter())
    );
  }

  let sdkRegistrationConfig = {};
  if (typeof configureSdkRegistration === "function") {
    sdkRegistrationConfig = configureSdkRegistration(sdkRegistrationConfig);
  }
  tracerProvider.register(sdkRegistrationConfig);

  // Configure default meter provider (do not export metrics)
  let meterConfig = {
    resource,
  };
  if (typeof configureMeter === "function") {
    meterConfig = configureMeter(meterConfig);
  }

  const meterProvider = new MeterProvider(meterConfig);
  if (typeof configureMeterProvider === "function") {
    configureMeterProvider(meterProvider);
  }

  // Re-register instrumentation with initialized provider. Patched code will see the update.
  registerInstrumentations({
    instrumentations,
    tracerProvider,
    meterProvider,
  });
}
initializeProvider();
