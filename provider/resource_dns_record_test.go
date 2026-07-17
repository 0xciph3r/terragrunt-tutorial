package main

import (
	"testing"

	"github.com/hashicorp/terraform-plugin-framework/types"
)

func TestBuildRecordID(t *testing.T) {
	id := buildRecordID("example.com", "www", "A")
	if id != "example.com|www|A" {
		t.Fatalf("unexpected id: %s", id)
	}
}

func TestIsInvalidID(t *testing.T) {
	tests := []struct {
		name  string
		id    types.String
		want  bool
	}{
		{name: "null", id: types.StringNull(), want: true},
		{name: "unknown", id: types.StringUnknown(), want: true},
		{name: "empty", id: types.StringValue(""), want: true},
		{name: "valid", id: types.StringValue("zone|name|A"), want: false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isInvalidID(tt.id)
			if got != tt.want {
				t.Fatalf("isInvalidID(%v)=%v, want %v", tt.id, got, tt.want)
			}
		})
	}
}

