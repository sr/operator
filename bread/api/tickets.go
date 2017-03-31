package breadapi

import (
	"bytes"
	"errors"
	"fmt"

	"git.dev.pardot.com/Pardot/infrastructure/bread/chatbot"
	"git.dev.pardot.com/Pardot/infrastructure/bread/jira"
	operatorhipchat "github.com/sr/operator/hipchat"
	"golang.org/x/net/context"

	"git.dev.pardot.com/Pardot/infrastructure/bread/generated/pb"
)

type TicketsServer struct {
	Hipchat operatorhipchat.Client
	Jira    jira.Client
	Project string
}

func (s *TicketsServer) SprintStatus(ctx context.Context, req *breadpb.TicketRequest) (*breadpb.TicketResponse, error) {
	var query string
	if req.IncludeResolved == "true" {
		query = fmt.Sprintf("project = '%s' AND Sprint IN openSprints() ORDER BY status ASC", s.Project)
	} else {
		query = fmt.Sprintf("project = '%s' AND Sprint IN openSprints() AND Resolution IS NULL ORDER BY status ASC", s.Project)
	}

	tickets, err := s.Jira.Search(
		ctx,
		query,
		[]string{"key", "summary", "status", "assignee"},
		100,
	)
	if err != nil {
		return nil, fmt.Errorf("unable to retrieve tickets: %s", err)
	}

	var txt, html bytes.Buffer
	_, _ = html.WriteString("<table><tr><th>Issue ID</th><th>Status</th><th>Assignee</th><th>Summary</th></tr>")
	for _, issue := range tickets {
		if issue.Fields == nil {
			continue
		}
		fmt.Fprintf(&txt, "%s %s %s\n", issue.Key, issue.StatusName(), issue.Fields.Summary)
		var summary string
		if issue.Fields == nil {
			summary = ""
		}
		// Truncate long summary to avoid wrapping message displayed on 15' MBPs
		if len(issue.Fields.Summary) > 90 {
			summary = fmt.Sprintf("%s...", issue.Fields.Summary[0:87])
		} else {
			summary = issue.Fields.Summary
		}
		fmt.Fprintf(
			&html,
			"<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n",
			fmt.Sprintf(`<a href="%s">%s</a>`, issue.HTMLURL(), issue.Key),
			issue.StatusName(),
			issue.GetAssigneeKey(),
			summary,
		)
	}
	return &breadpb.TicketResponse{}, chatbot.SendRoomMessage(ctx, s.Hipchat, &chatbot.Message{
		Text: txt.String(),
		HTML: html.String(),
	})
}

func (s *TicketsServer) Mine(ctx context.Context, req *breadpb.TicketRequest) (*breadpb.TicketResponse, error) {
	email := chatbot.EmailFromContext(ctx)
	if email == "" {
		return nil, errors.New("unable to retrieve list of assigned tickets without and email address")
	}

	tickets, err := s.Jira.Search(
		ctx,
		fmt.Sprintf("project = '%s' AND Resolution IS NULL AND assignee = '%s' ORDER BY status ASC", s.Project, email),
		[]string{"key", "summary", "status"},
		100,
	)
	if err != nil {
		return nil, fmt.Errorf("unable to retrieve tickets: %s", err)
	}
	var txt, html bytes.Buffer
	_, _ = html.WriteString("<table><tr><th>Issue ID</th><th>Status</th><th>Summary</th></tr>")
	for _, issue := range tickets {
		if issue.Fields == nil {
			continue
		}
		fmt.Fprintf(&txt, "%s %s %s\n", issue.Key, issue.StatusName(), issue.Fields.Summary)
		fmt.Fprintf(
			&html,
			"<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n",
			fmt.Sprintf(`<a href="%s">%s</a>`, issue.HTMLURL(), issue.Key),
			issue.StatusName(),
			issue.Fields.Summary,
		)
	}
	return &breadpb.TicketResponse{}, chatbot.SendRoomMessage(ctx, s.Hipchat, &chatbot.Message{
		Text: txt.String(),
		HTML: html.String(),
	})
}
