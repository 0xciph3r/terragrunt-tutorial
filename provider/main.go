package main

import (
	"context"
	"flag"
	"log"

	"github.com/hashicorp/terraform-plugin-framework/providerserver"
)

func main() {
	debugFlag := flag.Bool("debug", false, "set to true to run the provider with support for debuggers like delve")
	flag.Parse()

	err := providerserver.Serve(context.Background(), NewProvider, providerserver.ServeOpts{
		Address: "registry.terraform.io/0xciph3r/dns", // Provider address (namespace/type)
		Debug:   *debugFlag,
	})
	if err != nil {
		log.Fatalf("Error serving provider: %v", err)
	}
}
