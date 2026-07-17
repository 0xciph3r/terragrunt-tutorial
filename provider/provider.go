package main

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/datasource"
	"github.com/hashicorp/terraform-plugin-framework/provider"
	"github.com/hashicorp/terraform-plugin-framework/resource"
)

// dnsProvider implements the provider.Provider interface.
type dnsProvider struct {
	client *Client
}

// NewProvider creates and returns a dnsProvider struct.
func NewProvider() provider.Provider {
	return &dnsProvider{}
}

// Metadata returns the provider type name.
func (p *dnsProvider) Metadata(_ context.Context, _ provider.MetadataRequest, resp *provider.MetadataResponse) {
	resp.TypeName = "dns"
}

// Schema defines the provider-level schema for configuration data.
func (p *dnsProvider) Schema(_ context.Context, _ provider.SchemaRequest, resp *provider.SchemaResponse) {
	// No provider-level configuration needed for this lab yet
}

// Configure prepares a provider instance for use.
func (p *dnsProvider) Configure(_ context.Context, _ provider.ConfigureRequest, resp *provider.ConfigureResponse) {
	// No-op for now
	p.client = NewClient()
}

// Resources defines the resources implemented by the provider.
func (p *dnsProvider) Resources(_ context.Context) []func() resource.Resource {
	return []func() resource.Resource{
		func() resource.Resource {
			return NewDnsRecordResource(p.client)
		},
	}
}

// DataSources defines the data sources implemented by the provider.
func (p *dnsProvider) DataSources(_ context.Context) []func() datasource.DataSource {
	return []func() datasource.DataSource{}
}
