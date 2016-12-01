package github

import (
	"github.com/google/go-github/github"
	"github.com/hashicorp/terraform/helper/schema"
)

func resourceGithubBranchProtection() *schema.Resource {
	return &schema.Resource{
		Create: resourceGithubBranchProtectionCreate,
		Read:   resourceGithubBranchProtectionRead,
		Update: resourceGithubBranchProtectionUpdate,
		Delete: resourceGithubBranchProtectionDelete,
		Importer: &schema.ResourceImporter{
			State: schema.ImportStatePassthrough,
		},

		Schema: map[string]*schema.Schema{
			"repository": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"branch": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"include_admins": {
				Type:     schema.TypeBool,
				Optional: true,
				Default:  false,
			},
			"strict": {
				Type:     schema.TypeBool,
				Optional: true,
				Default:  false,
			},
			"contexts": {
				Type:     schema.TypeList,
				Optional: true,
				Elem:     &schema.Schema{Type: schema.TypeString},
			},
			"users_restriction": {
				Type:     schema.TypeList,
				Optional: true,
				Elem:     &schema.Schema{Type: schema.TypeString},
			},
			"teams_restriction": {
				Type:     schema.TypeList,
				Optional: true,
				Elem:     &schema.Schema{Type: schema.TypeString},
			},
		},
	}
}

func resourceGithubBranchProtectionCreate(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*Organization).client
	r := d.Get("repository").(string)
	b := d.Get("branch").(string)

	protectionRequest, err := resourceGithubBranchProtectionRequestObject(d)
	if err != nil {
		return err
	}

	_, _, err = client.Repositories.UpdateBranchProtection(meta.(*Organization).name, r, b, protectionRequest)
	if err != nil {
		return err
	}
	d.SetId(buildTwoPartID(&r, &b))

	return resourceGithubBranchProtectionRead(d, meta)
}

func resourceGithubBranchProtectionRead(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*Organization).client
	r, b := parseTwoPartID(d.Id())

	githubProtection, _, err := client.Repositories.GetBranchProtection(meta.(*Organization).name, r, b)
	if err != nil {
		d.SetId("")
		return nil
	}

	d.Set("repository", r)
	d.Set("branch", b)

	rsc := githubProtection.RequiredStatusChecks
	if rsc != nil && rsc.IncludeAdmins != nil {
		d.Set("include_admins", *rsc.IncludeAdmins)
	} else {
		d.Set("include_admins", false)
	}

	if rsc != nil && rsc.Strict != nil {
		d.Set("strict", *rsc.Strict)
	} else {
		d.Set("strict", false)
	}

	if rsc != nil && rsc.Contexts != nil {
		d.Set("contexts", *rsc.Contexts)
	} else {
		d.Set("contexts", []string{})
	}

	restrictions := githubProtection.Restrictions
	if restrictions != nil && restrictions.Users != nil {
		logins := []string{}
		for _, u := range restrictions.Users {
			if u.Login != nil {
				logins = append(logins, *u.Login)
			}
		}
		d.Set("users_restriction", logins)
	} else {
		d.Set("users_restriction", nil)
	}

	if restrictions != nil && restrictions.Teams != nil {
		slugs := []string{}
		for _, t := range restrictions.Teams {
			if t.Slug != nil {
				slugs = append(slugs, *t.Slug)
			}
		}
		d.Set("teams_restriction", slugs)
	} else {
		d.Set("teams_restriction", nil)
	}

	return nil
}

func resourceGithubBranchProtectionUpdate(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*Organization).client
	r, b := parseTwoPartID(d.Id())

	protectionRequest, err := resourceGithubBranchProtectionRequestObject(d)
	if err != nil {
		return err
	}

	_, _, err = client.Repositories.UpdateBranchProtection(meta.(*Organization).name, r, b, protectionRequest)
	if err != nil {
		return err
	}
	d.SetId(buildTwoPartID(&r, &b))

	return resourceGithubBranchProtectionRead(d, meta)
}

func resourceGithubBranchProtectionDelete(d *schema.ResourceData, meta interface{}) error {
	client := meta.(*Organization).client
	r, b := parseTwoPartID(d.Id())

	_, err := client.Repositories.RemoveBranchProtection(meta.(*Organization).name, r, b)
	return err
}

func resourceGithubBranchProtectionRequestObject(d *schema.ResourceData) (*github.ProtectionRequest, error) {
	protectionRequest := new(github.ProtectionRequest)

	rsc := new(github.RequiredStatusChecks)
	protectionRequest.RequiredStatusChecks = rsc
	rsc.IncludeAdmins = github.Bool(d.Get("include_admins").(bool))
	rsc.Strict = github.Bool(d.Get("strict").(bool))

	rsc.Contexts = &[]string{}
	if vL, ok := d.GetOk("contexts"); ok {
		for _, c := range vL.([]interface{}) {
			*rsc.Contexts = append(*rsc.Contexts, c.(string))
		}
	}

	uL, uOK := d.GetOk("users_restriction")
	tL, tOK := d.GetOk("teams_restriction")
	if uOK || tOK {
		restrictions := &github.BranchRestrictionsRequest{
			Users: &[]string{},
			Teams: &[]string{},
		}
		protectionRequest.Restrictions = restrictions

		if uOK {
			for _, u := range uL.([]interface{}) {
				*restrictions.Users = append(*restrictions.Users, u.(string))
			}
		}
		if tOK {
			for _, t := range tL.([]interface{}) {
				*restrictions.Teams = append(*restrictions.Teams, t.(string))
			}
		}
	}

	return protectionRequest, nil
}
