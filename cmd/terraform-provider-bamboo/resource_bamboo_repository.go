package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/hashicorp/terraform/helper/schema"
)

type repositoryRequest struct {
	Name                 string `json:"name"`
	Username             string `json:"username"`
	Password             string `json:"password"`
	Branch               string `json:"branch"`
	Repository           string `json:"repository"`
	ShallowClones        bool   `json:"shallowClones"`
	UseSubmodules        bool   `json:"useSubmodules"`
	FetchWholeRepository bool   `json:"fetchWholeRepository"`
}

type repositoryResponse struct {
	ID                   int64  `json:"id"`
	Name                 string `json:"name"`
	Branch               string `json:"branch"`
	Repository           string `json:"repository"`
	ShallowClones        bool   `json:"shallowClones"`
	UseSubmodules        bool   `json:"useSubmodules"`
	FetchWholeRepository bool   `json:"fetchWholeRepository"`
}

func resourceBambooRepository() *schema.Resource {
	return &schema.Resource{
		Create: resourceBambooRepositoryCreate,
		Read:   resourceBambooRepositoryRead,
		Update: resourceBambooRepositoryUpdate,
		Delete: resourceBambooRepositoryDelete,
		Importer: &schema.ResourceImporter{
			State: schema.ImportStatePassthrough,
		},
		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"username": {
				Type:     schema.TypeString,
				Required: true,
			},
			"password": {
				Type:      schema.TypeString,
				Required:  true,
				Sensitive: true,
				StateFunc: hashPassword,
			},
			"branch": {
				Type:     schema.TypeString,
				Optional: true,
				Default:  "master",
			},
			"repository": {
				Type:     schema.TypeString,
				Required: true,
			},
			"shallow_clones": {
				Type:     schema.TypeBool,
				Optional: true,
				Default:  true,
			},
			"use_submodules": {
				Type:     schema.TypeBool,
				Optional: true,
				Default:  true,
			},
			"fetch_whole_repository": {
				Type:     schema.TypeBool,
				Optional: true,
				Default:  false,
			},
		},
	}
}

func resourceBambooRepositoryCreate(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)

	createRequest := &repositoryRequest{
		Name:                 d.Get("name").(string),
		Username:             d.Get("username").(string),
		Password:             d.Get("password").(string),
		Branch:               d.Get("branch").(string),
		Repository:           d.Get("repository").(string),
		ShallowClones:        d.Get("shallow_clones").(bool),
		UseSubmodules:        d.Get("use_submodules").(bool),
		FetchWholeRepository: d.Get("fetch_whole_repository").(bool),
	}
	b, err := json.Marshal(createRequest)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("POST", fmt.Sprintf("%s/rest/pardot/1.0/linkedrepos", config.URL), bytes.NewBuffer(b))
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

	response := new(repositoryResponse)
	err = json.NewDecoder(resp.Body).Decode(response)
	if err != nil {
		return err
	}

	d.SetId(fmt.Sprintf("%d", response.ID))
	return resourceBambooRepositoryRead(d, meta)
}

func resourceBambooRepositoryUpdate(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)
	id := d.Id()

	createRequest := &repositoryRequest{
		Name:                 d.Get("name").(string),
		Username:             d.Get("username").(string),
		Password:             d.Get("password").(string),
		Branch:               d.Get("branch").(string),
		Repository:           d.Get("repository").(string),
		ShallowClones:        d.Get("shallow_clones").(bool),
		UseSubmodules:        d.Get("use_submodules").(bool),
		FetchWholeRepository: d.Get("fetch_whole_repository").(bool),
	}
	b, err := json.Marshal(createRequest)
	if err != nil {
		return err
	}

	req, err := http.NewRequest("PUT", fmt.Sprintf("%s/rest/pardot/1.0/linkedrepos/%s", config.URL, id), bytes.NewBuffer(b))
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

	return resourceBambooRepositoryRead(d, meta)
}

func resourceBambooRepositoryRead(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)
	id := d.Id()

	req, err := http.NewRequest("GET", fmt.Sprintf("%s/rest/pardot/1.0/linkedrepos/%s", config.URL, id), nil)
	if err != nil {
		return err
	}
	req.SetBasicAuth(config.Username, config.Password)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode == 404 {
		d.SetId("")
		return nil
	} else if resp.StatusCode < 200 || resp.StatusCode > 299 {
		return fmt.Errorf("bad response code from Bamboo: %d", resp.StatusCode)
	}

	response := new(repositoryResponse)
	err = json.NewDecoder(resp.Body).Decode(response)
	if err != nil {
		return err
	}

	d.SetId(fmt.Sprintf("%d", response.ID))
	_ = d.Set("name", response.Name)
	_ = d.Set("branch", response.Branch)
	_ = d.Set("repository", response.Repository)
	_ = d.Set("shallow_clones", response.ShallowClones)
	_ = d.Set("use_submodules", response.UseSubmodules)
	_ = d.Set("fetch_whole_repository", response.FetchWholeRepository)
	return nil
}

func resourceBambooRepositoryDelete(d *schema.ResourceData, meta interface{}) error {
	config := meta.(*config)
	id := d.Id()

	req, err := http.NewRequest("DELETE", fmt.Sprintf("%s/rest/pardot/1.0/linkedrepos/%s", config.URL, id), nil)
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
