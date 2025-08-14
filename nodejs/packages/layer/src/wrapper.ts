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

// Wrapper for OpenTelemetry v2.0.0 compatibility

const api = require("@opentelemetry/api");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { Resource } = require("@opentelemetry/resources");
const { BatchSpanProcessor } = require("@opentelemetry/sdk-trace-base");
const { OTLPTraceExporter } = require("@opentelemetry/exporter-trace-otlp-http");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { AwsLambdaInstrumentation } = require("@opentelemetry/instrumentation-aws-lambda");
const { AwsInstrumentation } = require("@opentelemetry/instrumentation-aws-sdk");

// Simple initialization for v2.0.0
console.log("Initializing OpenTelemetry v2.0.0 wrapper");

const provider = new NodeTracerProvider({
  resource: Resource.default()
});

const exporter = new OTLPTraceExporter({
  url: process.env.OTEL_EXPORTER_OTLP_TRACES_ENDPOINT || "http://localhost:4318/v1/traces"
});

provider.addSpanProcessor(new BatchSpanProcessor(exporter));

// Register the provider
api.trace.setGlobalTracerProvider(provider);

// Register basic instrumentations
registerInstrumentations({
  instrumentations: [
    new AwsLambdaInstrumentation(),
    new AwsInstrumentation()
  ]
});

console.log("OpenTelemetry v2.0.0 wrapper initialized successfully");
