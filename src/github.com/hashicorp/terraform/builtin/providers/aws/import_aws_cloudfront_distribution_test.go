package aws

import (
	"testing"

	"github.com/hashicorp/terraform/helper/resource"
)

func TestAccAWSCloudFrontDistribution_importBasic(t *testing.T) {
	resourceName := "aws_cloudfront_distribution.s3_distribution"

	resource.Test(t, resource.TestCase{
		PreCheck:     func() { testAccPreCheck(t) },
		Providers:    testAccProviders,
		CheckDestroy: testAccCheckCloudFrontDistributionDestroy,
		Steps: []resource.TestStep{
			{
				Config: testAccAWSCloudFrontDistributionS3Config,
			},
			{
				ResourceName:      resourceName,
				ImportState:       true,
				ImportStateVerify: true,
				// Ignore retain_on_delete since it doesn't come from the AWS
				// API.
				ImportStateVerifyIgnore: []string{"retain_on_delete"},
			},
		},
	})
}
