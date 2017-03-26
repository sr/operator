package main

import (
	"github.com/hashicorp/terraform/helper/schema"
	"github.com/hashicorp/terraform/terraform"
)

type config struct {
	URL      string
	Username string
	Password string
}

func Provider() terraform.ResourceProvider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"url": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "The URL to the Bamboo installation",
			},
			"username": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "Bamboo username",
			},
			"password": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "Bamboo password",
				Sensitive:   true,
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"bamboo_repository": resourceBambooRepository(),
			"bamboo_build_plan": resourceBambooBuildPlan(),
		},
		ConfigureFunc: configure,
	}
}

func configure(d *schema.ResourceData) (interface{}, error) {
	return &config{
		URL:      d.Get("url").(string),
		Username: d.Get("username").(string),
		Password: d.Get("password").(string),
	}, nil
}
