package bread

// ACL is the Access Control List for all gRPC methods exposed via chat.
var ACL = []*ACLEntry{
	{
		Call: &RPC{
			Package: "bread",
			Service: "Pinger",
			Method:  "Ping",
		},
		Group: "developers",
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Ping",
			Method:  "Ping",
		},
		Group: "developers",
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Ping",
			Method:  "SlowLoris",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Deploy",
			Method:  "ListTargets",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Deploy",
			Method:  "ListBuilds",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Deploy",
			Method:  "Trigger",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Tickets",
			Method:  "Mine",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
	{
		Call: &RPC{
			Package: "bread",
			Service: "Tickets",
			Method:  "SprintStatus",
		},
		Group:             "developers",
		PhoneAuthOptional: true,
	},
}
