/*
 * Copyright The OpenTelemetry Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
  detectResources,
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
const { getStringFromEnv } = require("@opentelemetry/core");
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
    new AwsInstrumentation(),
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

// Environment-based exporter configuration (OTel 2.0 pattern)
function getExportersFromEnv() {
  if (
    process.env.OTEL_TRACES_EXPORTER == null ||
    process.env.OTEL_TRACES_EXPORTER.trim() === ''
  ) {
    return [new OTLPTraceExporter()];
  }
  if (process.env.OTEL_TRACES_EXPORTER.includes('none')) {
    return null;
  }

  const stringToExporter = new Map([
    ['otlp', () => new OTLPTraceExporter()],
    ['console', () => new ConsoleSpanExporter()],
  ]);
  const exporters: any[] = [];
  process.env.OTEL_TRACES_EXPORTER.split(',').map((exporterName: string) => {
    exporterName = exporterName.toLowerCase().trim();
    const exporter = stringToExporter.get(exporterName);
    if (exporter) {
      const createdExporter = exporter();
      exporters.push(createdExporter);
    } else {
      console.warn(
        `Invalid exporter "${exporterName}" specified in the environment variable OTEL_TRACES_EXPORTER`,
      );
    }
  });
  
  if (exporters.length === 0) {
    return [new OTLPTraceExporter()];
  }
  
  return exporters;
}

// configure lambda logging
const logLevel: any = getStringFromEnv('OTEL_LOG_LEVEL') || DiagLogLevel.INFO;
diag.setLogger(new DiagConsoleLogger(), logLevel);

// Map vendor-specific endpoint to OTel variable before exporter creation
// Keep using localhost collector but ensure proper endpoint mapping
if (process.env.SUMO_OTLP_HTTP_ENDPOINT_URL && !process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT) {
  // Use localhost collector as intended, but log the Sumo endpoint for collector to use
  process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT = "http://localhost:4318/v1/traces";
} else if (!process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT) {
  // Default fallback to localhost collector
  process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT = "http://localhost:4318/v1/traces";
}

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

async function initializeTracerProvider(resource: any) {
  let config = {
    resource,
    spanProcessors: [] as any[],
  };

  const exporters = getExportersFromEnv();
  if (!exporters) {
    return undefined;
  }

  if (typeof configureTracer === "function") {
    config = configureTracer(config);
  }

  // Configure span processors based on exporters
  if (exporters.length) {
    config.spanProcessors = [];
    exporters.forEach((exporter: any) => {
      if (exporter instanceof ConsoleSpanExporter) {
        config.spanProcessors.push(new SimpleSpanProcessor(exporter));
      } else {
        config.spanProcessors.push(new BatchSpanProcessor(exporter));
      }
    });
  }

  config.spanProcessors = config.spanProcessors || [];
  if (config.spanProcessors.length === 0) {
    // Default
    config.spanProcessors.push(new BatchSpanProcessor(new OTLPTraceExporter()));
  }

  // Logging for debug
  if ((logLevel as any) === DiagLogLevel.DEBUG) {
    config.spanProcessors.push(
      new SimpleSpanProcessor(new ConsoleSpanExporter())
    );
  }

  const tracerProvider = new NodeTracerProvider(config);

  let sdkRegistrationConfig = {};
  if (typeof configureSdkRegistration === "function") {
    sdkRegistrationConfig = configureSdkRegistration(sdkRegistrationConfig);
  }
  tracerProvider.register(sdkRegistrationConfig);

  return tracerProvider;
}

async function initializeProvider() {
  const resource = await detectResources({
    detectors: [awsLambdaDetector, envDetector, processDetector],
  });

  const tracerProvider = await initializeTracerProvider(resource);
  
  if (!tracerProvider) {
    return;
  }

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
