package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/hashicorp/terraform/helper/schema"
)

type buildPlanRequest struct {
	Key                 string `json:"key"`
	Name                string `json:"name"`
	Description         string `json:"description"`
	DefaultRepositoryID int64  `json:"defaultRepositoryId"`
}

type buildPlanResponse struct {
	Key                 string `json:"key"`
	Name                string `json:"name"`
	Description         string `json:"description"`
	DefaultRepositoryID int64  `json:"defaultRepositoryId"`
}

func resourceBambooBuildPlan() *schema.Resource {
	return &schema.Resource{
		Create: resourceBambooBuildPlanCreate,
		Read:   resourceBambooBuildPlanRead,
		Delete: resourceBambooBuildPlanDelete,
		Importer: &schema.ResourceImporter{
			State: schema.ImportStatePassthrough,
		},
		Schema: map[string]*schema.Schema{
			"key": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"description": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "",
				ForceNew: true,
			},
			"default_repository_id": {
				Type:     schema.TypeInt,
				Required: true,
				ForceNew: true,
			},
		},
	}
}

func resourceBambooBuildPlanCreate(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)
	key := d.Get("key").(string)

	createRequest := &buildPlanRequest{
		Key:                 d.Get("key").(string),
		Name:                d.Get("name").(string),
		Description:         d.Get("description").(string),
		DefaultRepositoryID: d.Get("default_repository_id").(int64),
	}
	b, err := json.Marshal(createRequest)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/rest/pardot/1.0/buildplans", config.URL), bytes.NewBuffer(b))
	if err != nil {
		return err
	}
	req.Header.Set("content-type", "application/json")
	req.SetBasicAuth(config.Username, config.Password)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("bad response code from Bamboo: %d", resp.StatusCode)
	}

	d.SetId(key)
	return resourceBambooBuildPlanRead(d, meta)
}

func resourceBambooBuildPlanRead(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)
	key := d.Id()

	req, err := http.NewRequest("GET", fmt.Sprintf("%s/rest/pardot/1.0/buildplans/%s", config.URL, key), nil)
	if err != nil {
		return err
	}
	req.SetBasicAuth(config.Username, config.Password)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}

	if resp.StatusCode == 404 {
		d.SetId("")
		return nil
	} else if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("bad response code from Bamboo: %d", resp.StatusCode)
	}

	response := new(buildPlanResponse)
	err = json.NewDecoder(resp.Body).Decode(response)
	if err != nil {
		return err
	}

	d.SetId(response.Key)
	_ = d.Set("key", response.Key)
	_ = d.Set("name", response.Name)
	_ = d.Set("description", response.Description)
	_ = d.Set("default_repository_id", response.DefaultRepositoryID)
	return nil
}

func resourceBambooBuildPlanDelete(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)
	key := d.Id()

	req, err := http.NewRequest("DELETE", fmt.Sprintf("%s/rest/pardot/1.0/buildplans/%s", config.URL, key), nil)
	if err != nil {
		return err
	}
	req.SetBasicAuth(config.Username, config.Password)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}

	if resp.StatusCode == 404 {
		d.SetId("")
		return nil
	} else if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("bad response code from Bamboo: %d", resp.StatusCode)
	}

	d.SetId("")
	return nil
}
