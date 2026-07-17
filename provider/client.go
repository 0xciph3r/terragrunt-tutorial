package main

type dnsRecord struct {
	Value string
	TTL   int64
}
type Client struct {
	records map[string]dnsRecord
}

func NewClient() *Client {
	return &Client{
		records: make(map[string]dnsRecord),
	}
}

func (c *Client) CreateRecord(id, value string, ttl int64) {
	c.records[id] = dnsRecord{
		Value: value,
		TTL:   ttl,
	}
}

func (c *Client) GetRecord(id string) (dnsRecord, bool) {
	record, exists := c.records[id]
	if !exists {
		return dnsRecord{}, false
	}
	return record, true
}

func (c *Client) UpdateRecord(id, value string, ttl int64) {
	if _, exists := c.records[id]; exists {
		c.records[id] = dnsRecord{
			Value: value,
			TTL:   ttl,
		}
	}
}

func (c *Client) DeleteRecord(id string) {
	delete(c.records, id)
}
