package bread

import "github.com/sr/operator"

// ACL is the Access Control List for all gRPC methods exposed via chat.
var ACL = []*ACLEntry{
	{
		Call: &operator.Call{
			Service: "bread.Ping",
			Method:  "Ping",
		},
		Group: "developers",
	},
	{
		Call: &operator.Call{
			Service: "bread.Ping",
			Method:  "SlowLoris",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &operator.Call{
			Service: "bread.Deploy",
			Method:  "ListTargets",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &operator.Call{
			Service: "bread.Deploy",
			Method:  "ListBuilds",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &operator.Call{
			Service: "bread.Deploy",
			Method:  "Trigger",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &operator.Call{
			Service: "bread.Tickets",
			Method:  "Mine",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &operator.Call{
			Service: "bread.Tickets",
			Method:  "SprintStatus",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
}

type ACLEntry struct {
	Call              *operator.Call
	Group             string
	PhoneAuthOptional bool
}
