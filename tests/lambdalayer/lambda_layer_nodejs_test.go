package lambdalayer

import (
	"github.com/samber/lo"
	"github.com/stretchr/testify/require"
	"sort"
	"testing"
)

var nodejsFunctionName = getLambdaFunctionName()
var nodejsAwsAccountId = getAwsAccountId()

var commonNodeJSAttributes = map[string]string{
	"application":            "lambda-tests",
	"cloud.account.id":       nodejsAwsAccountId,
	"cloud.platform":         "aws_lambda",
	"cloud.provider":         "aws",
	"cloud.region":           "eu-central-1",
	"telemetry.sdk.language": "nodejs",
	"telemetry.sdk.name":     "opentelemetry",
	"telemetry.sdk.version":  "1.17.1",
	"service.name":           nodejsFunctionName,
	"process.runtime.name":   "nodejs",
	"faas.name":              nodejsFunctionName,
	"faas.version":           "$LATEST",
}

func TestSpansnodejs(t *testing.T) {
	// t.Parallel()
	cases := []struct {
		serviceName       string
		expectedSpanCount int
		expectedSpans     []Span
	}{
		{
			serviceName:       nodejsFunctionName,
			expectedSpanCount: 2,
			expectedSpans: []Span{
				{
					Name:         nodejsFunctionName,
					ParentSpanId: "",
					Attributes:   commonNodeJSAttributes,
				},
				{
					Name: "S3.ListBuckets",
					Attributes: lo.Assign(
						commonNodeJSAttributes,
						map[string]string{
							"aws.service.api":        "S3",
							"rpc.service":            "S3",
							"aws.service.identifier": "s3",
							"rpc.system":             "aws-api",
							"http.status_code":       "200",
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
