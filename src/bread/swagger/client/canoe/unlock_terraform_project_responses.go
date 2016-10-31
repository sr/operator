package canoe

// This file was generated by the swagger tool.
// Editing this file might prove futile when you re-run the swagger generate command

import (
	"fmt"
	"io"

	"github.com/go-openapi/runtime"

	strfmt "github.com/go-openapi/strfmt"

	"bread/swagger/models"
)

// UnlockTerraformProjectReader is a Reader for the UnlockTerraformProject structure.
type UnlockTerraformProjectReader struct {
	formats strfmt.Registry
}

// ReadResponse reads a server response into the received o.
func (o *UnlockTerraformProjectReader) ReadResponse(response runtime.ClientResponse, consumer runtime.Consumer) (interface{}, error) {
	switch response.Code() {

	case 200:
		result := NewUnlockTerraformProjectOK()
		if err := result.readResponse(response, consumer, o.formats); err != nil {
			return nil, err
		}
		return result, nil

	default:
		return nil, runtime.NewAPIError("unknown error", response, response.Code())
	}
}

// NewUnlockTerraformProjectOK creates a UnlockTerraformProjectOK with default headers values
func NewUnlockTerraformProjectOK() *UnlockTerraformProjectOK {
	return &UnlockTerraformProjectOK{}
}

/*UnlockTerraformProjectOK handles this case with default header values.

UnlockTerraformProjectOK unlock terraform project o k
*/
type UnlockTerraformProjectOK struct {
	Payload *models.CanoeTerraformDeployResponse
}

func (o *UnlockTerraformProjectOK) Error() string {
	return fmt.Sprintf("[POST /api/grpc/unlock_terraform_project][%d] unlockTerraformProjectOK  %+v", 200, o.Payload)
}

func (o *UnlockTerraformProjectOK) readResponse(response runtime.ClientResponse, consumer runtime.Consumer, formats strfmt.Registry) error {

	o.Payload = new(models.CanoeTerraformDeployResponse)

	// response payload
	if err := consumer.Consume(response.Body(), o.Payload); err != nil && err != io.EOF {
		return err
	}

	return nil
}
