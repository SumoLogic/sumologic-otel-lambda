package lambdalayer

import (
	"fmt"
	"github.com/stretchr/testify/assert"
	"testing"
)

func compareSpan(t *testing.T, instrSpan []Span, expectedSpan []Span) {
	for i := range instrSpan {
		// Test name
		assert.Equal(t, instrSpan[i].Name, expectedSpan[i].Name)
		// Test attributes
		assert.True(t, spanAttributesContain(instrSpan[i], expectedSpan[i]))
		// Test probable root span (avoid traces with unknown root span)
		if expectedSpan[i].ParentSpanId != "" {
			assert.Equal(t, instrSpan[i].ParentSpanId, expectedSpan[i].ParentSpanId)
		}
	}
}

func spanAttributesContain(span Span, expSpan Span) bool {
	for key, val := range expSpan.Attributes {
		sVal, ok := span.Attributes[key]
		if ok {
			if sVal == val {
				continue
			} else {
				fmt.Printf("Expected attributes: %s\n", expSpan.Attributes)
				fmt.Printf("Span attributes: %s\n", span.Attributes)
				fmt.Printf("spanAttributesContain key=%s, value: %s!=%s\n", key, sVal, val)
				return false
			}
		} else {
			fmt.Printf("Expected attributes: %s\n", expSpan.Attributes)
			fmt.Printf("Span attributes: %s\n", span.Attributes)
			fmt.Printf("spanAttributesContain key=%s not in span", key)
			return false
		}
	}
	return true
}
