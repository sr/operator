package canoe

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"fmt"
	"io"

	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"

	"git.dev.pardot.com/Pardot/bread/swagger/models"
)

// CompleteTerraformDeployReader is a Reader for the CompleteTerraformDeploy structure.
type CompleteTerraformDeployReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *CompleteTerraformDeployReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {

	case 200:
		result := NewCompleteTerraformDeployOK()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil

	default:
		return nil, runtime.NewAPIError("unknown error", response, response.Code())
	}
}

// NewCompleteTerraformDeployOK creates a CompleteTerraformDeployOK with default headers values
func NewCompleteTerraformDeployOK() *CompleteTerraformDeployOK {
	return &CompleteTerraformDeployOK{}
}

/*CompleteTerraformDeployOK handles this case with default header values.

CompleteTerraformDeployOK complete terraform deploy o k
*/
type CompleteTerraformDeployOK struct {
	Payload *models.BreadTerraformDeployResponse
}

func (o *CompleteTerraformDeployOK) Error() string {
	return fmt.Sprintf("[POST /api/grpc/complete_terraform_deploy][%d] completeTerraformDeployOK  %+v", 200, o.Payload)
}

func (o *CompleteTerraformDeployOK) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.BreadTerraformDeployResponse)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}
