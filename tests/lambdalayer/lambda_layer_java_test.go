package lambdalayer

import (
	"github.com/samber/lo"
	"github.com/stretchr/testify/require"
	"sort"
	"testing"
)

var javaFunctionName = getLambdaFunctionName()
var javaAwsAccountId = getAwsAccountId()

var commonJavaAttributes = map[string]string{
	"application":            "lambda-tests",
	"cloud.account.id":       javaAwsAccountId,
	"cloud.platform":         "aws_lambda",
	"cloud.provider":         "aws",
	"cloud.region":           "eu-central-1",
	"telemetry.sdk.language": "java",
	"telemetry.sdk.name":     "opentelemetry",
	"telemetry.sdk.version":  "1.30.1",
	"service.name":           javaFunctionName,
	"faas.name":              javaFunctionName,
	"faas.version":           "$LATEST",
}

func TestSpansjava(t *testing.T) {
	// t.Parallel()
	cases := []struct {
		serviceName       string
		expectedSpanCount int
		expectedSpans     []Span
	}{
		{
			serviceName:       javaFunctionName,
			expectedSpanCount: 2,
			expectedSpans: []Span{
				{
					Name:         "GET /" + javaFunctionName,
					ParentSpanId: "",
					Attributes: lo.Assign(
						commonJavaAttributes,
						map[string]string{
							"faas.trigger": "http",
							"http.method":  "GET",
						}),
				},
				{
					Name: "S3.ListBuckets",
					Attributes: lo.Assign(
						commonJavaAttributes,
						map[string]string{
							"net.peer.name":    "s3.eu-central-1.amazonaws.com",
							"http.method":      "GET",
							"http.status_code": "200",
							"http.url":         "https://s3.eu-central-1.amazonaws.com/",
							"rpc.method":       "ListBuckets",
							"rpc.service":      "S3",
							"rpc.system":       "aws-api",
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
