package lambdalayer

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
)

const (
	defaultReceiverSpansListPath          = "spans-list"
	defaultReceiverPort                   = "3000"
	receiverEndpointEnvironmentVariable   = "RECEIVER_ENDPOINT"
	lambdaFunctionNameEnvironmentVariable = "LAMBDA_FUNCTION_NAME"
	awsAccountIdEnvironmentVariable       = "AWS_ACCOUNT_ID"
)

func getLambdaFunctionName() string {
	var lambdaFunctionName, ok = os.LookupEnv(lambdaFunctionNameEnvironmentVariable)
	if ok {
		return lambdaFunctionName
	} else {
		fmt.Println("Please provide lambda function name using environment variable \"LAMBDA_FUNCTION_NAME\"")
		os.Exit(1)
		return ""
	}
}

func getAwsAccountId() string {
	var awsAccountId, ok = os.LookupEnv(awsAccountIdEnvironmentVariable)
	if ok {
		return awsAccountId
	} else {
		fmt.Printf("Please provide AWS Account ID using environment variable \"%s\"\n", awsAccountIdEnvironmentVariable)
		os.Exit(1)
		return ""
	}
}

type SpanSorter []Span

func (a SpanSorter) Len() int           { return len(a) }
func (a SpanSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a SpanSorter) Less(i, j int) bool { return a[i].Name < a[j].Name }

type Span struct {
	Name         string            `json:"name,omitempty"`
	Id           string            `json:"id,omitempty"`
	TraceId      string            `json:"trace_id,omitempty"`
	ParentSpanId string            `json:"parent_span_id,"`
	Attributes   map[string]string `json:"attributes,omitempty"`
}

type MockReceiver struct {
	receiverEndpoint string
}

func NewMockReceiver() *MockReceiver {

	receiverEndpoint, ok := os.LookupEnv(receiverEndpointEnvironmentVariable)
	if ok {
		return &MockReceiver{receiverEndpoint: receiverEndpoint}
	} else {
		fmt.Println("Please provide receiver endpoint using environment variable \"RECEIVER_ENDPOINT\"")
		return &MockReceiver{}
	}
}

func receiverURL(endpoint string) string {
	return fmt.Sprintf("http://%s:%s/%s", endpoint, defaultReceiverPort, defaultReceiverSpansListPath)
}

var ErrFailedAPICall = errors.New("bad response from MockReceiver API")

// Get spans
func (rp *MockReceiver) GetSpans(serviceName string) ([]Span, error) {
	url := fmt.Sprintf("%s?service.name=%s", receiverURL(rp.receiverEndpoint), serviceName)
	res, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to get spans: %v: %w", err, ErrFailedAPICall)
	}
	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status code: %d - %s: %w", res.StatusCode, res.Status, ErrFailedAPICall)
	}

	var spans []Span
	if err := json.NewDecoder(res.Body).Decode(&spans); err != nil {
		return nil, fmt.Errorf("failed to decode body into Release slice: %w", err)
	}

	return spans, nil
}
