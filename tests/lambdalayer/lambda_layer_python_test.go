package lambdalayer

import (
	"sort"
	"testing"

	"github.com/samber/lo"
	"github.com/stretchr/testify/require"
)

var pythonFunctionName = getLambdaFunctionName()
var pythonAwsAccountId = getAwsAccountId()

var commonPythonAttributes = map[string]string{
	"application":            "lambda-tests",
	"cloud.account.id":       pythonAwsAccountId,
	"cloud.provider":         "aws",
	"cloud.region":           "eu-central-1",
	"telemetry.auto.version": "0.41b0",
	"telemetry.sdk.language": "python",
	"telemetry.sdk.name":     "opentelemetry",
	"telemetry.sdk.version":  "1.20.0",
	"service.name":           pythonFunctionName,
	"faas.name":              pythonFunctionName,
	"faas.version":           "$LATEST",
}

func TestSpanspython(t *testing.T) {
	t.Parallel()
	cases := []struct {
		serviceName       string
		expectedSpanCount int
		expectedSpans     []Span
	}{
		{
			serviceName:       pythonFunctionName,
			expectedSpanCount: 3,
			expectedSpans: []Span{
				{
					Name:         "lambda_function.lambda_handler",
					ParentSpanId: "",
					Attributes: lo.Assign(
						commonPythonAttributes,
						map[string]string{
							"faas.trigger":     "http",
							"http.route":       "/" + pythonFunctionName,
							"http.scheme":      "https",
							"http.status_code": "200",
							"http.target":      "/" + pythonFunctionName,
						}),
				},
				{
					Name: "S3.ListBuckets",
					Attributes: lo.Assign(
						commonPythonAttributes,
						map[string]string{
							"rpc.service":      "S3",
							"rpc.system":       "aws-api",
							"http.status_code": "200",
						}),
				},
				{
					Name: "HTTP GET",
					Attributes: lo.Assign(
						commonPythonAttributes,
						map[string]string{
							"http.url":    "http://httpbin.org/",
							"http.method": "GET",
						}),
				},
			},
		},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.serviceName, func(t *testing.T) {
			t.Parallel()

			rp := NewMockReceiver()

			gotSpans, gotErr := rp.GetSpans(tc.serviceName)
			if gotErr == nil {
				// Sort spans before tests
				sort.Sort(SpanSorter(gotSpans))
				sort.Sort(SpanSorter(tc.expectedSpans))

				require.Len(t, gotSpans, tc.expectedSpanCount)
				compareSpan(t, gotSpans, tc.expectedSpans)
			}
		})
	}
}
