package main

import "testing"

func TestClientCRUD(t *testing.T) {
	c := NewClient()

	id := buildRecordID("example.com", "api", "A")
	c.CreateRecord(id, "1.2.3.4", 300)

	record, ok := c.GetRecord(id)
	if !ok {
		t.Fatalf("expected record to exist after create")
	}
	if record.Value != "1.2.3.4" || record.TTL != 300 {
		t.Fatalf("unexpected record after create: %#v", record)
	}

	c.UpdateRecord(id, "5.6.7.8", 600)
	record, ok = c.GetRecord(id)
	if !ok {
		t.Fatalf("expected record to exist after update")
	}
	if record.Value != "5.6.7.8" || record.TTL != 600 {
		t.Fatalf("unexpected record after update: %#v", record)
	}

	c.DeleteRecord(id)
	if _, ok = c.GetRecord(id); ok {
		t.Fatalf("expected record to be deleted")
	}
}

