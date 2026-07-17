package main

import (
	"context"

	"github.com/hashicorp/terraform-plugin-framework/path"
	"github.com/hashicorp/terraform-plugin-framework/resource"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/planmodifier"
	"github.com/hashicorp/terraform-plugin-framework/resource/schema/stringplanmodifier"
	"github.com/hashicorp/terraform-plugin-framework/types"
)

type dnsRecordResource struct {
	client *Client
}

type dnsRecordModel struct {
	ID         types.String `tfsdk:"id"`
	Zone       types.String `tfsdk:"zone"`
	Name       types.String `tfsdk:"name"`
	RecordType types.String `tfsdk:"type"`
	Value      types.String `tfsdk:"value"`
	TTL        types.Int64  `tfsdk:"ttl"`
}

func buildRecordID(zone, name, recordType string) string {
	return zone + "|" + name + "|" + recordType
}

func isInvalidID(id types.String) bool {
	return id.IsNull() || id.IsUnknown() || id.ValueString() == ""
}

func NewDnsRecordResource(client *Client) resource.Resource {
	return &dnsRecordResource{
		client: client,
	}
}

func (r *dnsRecordResource) Metadata(_ context.Context, req resource.MetadataRequest, resp *resource.MetadataResponse) {
	resp.TypeName = req.ProviderTypeName + "_record"
}

func (r *dnsRecordResource) Schema(_ context.Context, _ resource.SchemaRequest, resp *resource.SchemaResponse) {
	resp.Schema = schema.Schema{
		Attributes: map[string]schema.Attribute{
			"id": schema.StringAttribute{
				Computed: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.UseStateForUnknown(),
				},
			},
			"zone": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"name": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"type": schema.StringAttribute{
				Required: true,
				PlanModifiers: []planmodifier.String{
					stringplanmodifier.RequiresReplace(),
				},
			},
			"value": schema.StringAttribute{
				Required: true,
			},
			"ttl": schema.Int64Attribute{
				Required: true,
			},
		},
	}
}

func (r *dnsRecordResource) Create(ctx context.Context, req resource.CreateRequest, resp *resource.CreateResponse) {
	// Read the plan data into the model

	var plan dnsRecordModel
	diags := req.Plan.Get(ctx, &plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	if r.client == nil {
		resp.Diagnostics.AddError(
			"Provider client not configured",
			"The DNS provider client is nil. Ensure Configure() runs before resource operations.",
		)
		return
	}

	plan.ID = types.StringValue(buildRecordID(plan.Zone.ValueString(), plan.Name.ValueString(), plan.RecordType.ValueString()))

	if plan.TTL.ValueInt64() < 300 {
		resp.Diagnostics.AddWarning("TTL too low", "The TTL value is below the recommended minimum of 300 seconds. Consider using a higher value for better caching and performance.")
	}

	r.client.CreateRecord(plan.ID.ValueString(), plan.Value.ValueString(), plan.TTL.ValueInt64())

	diags = resp.State.Set(ctx, &plan)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

func (r *dnsRecordResource) Read(ctx context.Context, _ resource.ReadRequest, resp *resource.ReadResponse) {
	var state dnsRecordModel
	diags := resp.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	if r.client == nil {
		resp.Diagnostics.AddError(
			"Provider client not configured",
			"The DNS provider client is nil. Ensure Configure() runs before resource operations.",
		)
		return
	}

	if isInvalidID(state.ID) {
		resp.State.RemoveResource(ctx)
		return
	}

	if record, exists := r.client.GetRecord(state.ID.ValueString()); exists {
		state.Value = types.StringValue(record.Value)
		state.TTL = types.Int64Value(record.TTL)
	} else {
		resp.State.RemoveResource(ctx)
		return
	}

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

func (r *dnsRecordResource) Update(ctx context.Context, req resource.UpdateRequest, resp *resource.UpdateResponse) {
	var priorState dnsRecordModel
	diags := req.State.Get(ctx, &priorState)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	var state dnsRecordModel
	diags = req.Plan.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	if r.client == nil {
		resp.Diagnostics.AddError(
			"Provider client not configured",
			"The DNS provider client is nil. Ensure Configure() runs before resource operations.",
		)
		return
	}

	state.ID = priorState.ID

	if isInvalidID(state.ID) {
		resp.Diagnostics.AddError(
			"Invalid State",
			"Cannot update a resource with null, unknown, or empty ID.",
		)
		return
	}

	if state.TTL.ValueInt64() < 300 {
		resp.Diagnostics.AddWarning("TTL too low", "The TTL value is below the recommended minimum of 300 seconds. Consider using a higher value for better caching and performance.")
	}

	r.client.UpdateRecord(state.ID.ValueString(), state.Value.ValueString(), state.TTL.ValueInt64())

	diags = resp.State.Set(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}
}

func (r *dnsRecordResource) Delete(ctx context.Context, req resource.DeleteRequest, resp *resource.DeleteResponse) {
	var state dnsRecordModel
	diags := req.State.Get(ctx, &state)
	resp.Diagnostics.Append(diags...)
	if resp.Diagnostics.HasError() {
		return
	}

	if r.client == nil {
		resp.Diagnostics.AddError(
			"Provider client not configured",
			"The DNS provider client is nil. Ensure Configure() runs before resource operations.",
		)
		return
	}

	if isInvalidID(state.ID) {
		resp.State.RemoveResource(ctx)
		return
	}

	r.client.DeleteRecord(state.ID.ValueString())

	resp.State.RemoveResource(ctx)

}

func (r *dnsRecordResource) ImportState(ctx context.Context, req resource.ImportStateRequest, resp *resource.ImportStateResponse) {
	// map import id directly to state ID and rely on the Read method to hydrate the remaining attributes
	resource.ImportStatePassthroughID(ctx, path.Root("id"), req, resp)
}
