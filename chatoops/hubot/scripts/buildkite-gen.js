// Description:
//  Interact with the Buildkite.com Continuous Integration server. Retrieve the  status of projects, setup new ones, and trigger builds.
//
// Commands:
//   hubot buildkite status  [slug=value] - List the status of all (i.e. the status of the last build) of one or  all projects.
//   hubot buildkite list-builds  [project_slug=value] - List the last builds of one or all projects, optionally limited to a  project.
//
// Configuration:
//   OPERATORD_ADDRESS
var path = require("path"),
	grpc = require("grpc"),
	protobuf = require("protobufjs");

var protodir = path.resolve(__dirname + "/../proto"),
	proto = protobuf.loadProtoFile({root: protodir, file: "buildkite.proto"})
	operator = proto.build("operator"),
	buildkite = grpc.loadObject(proto.ns).buildkite;

var address = process.env.OPERATORD_ADDRESS,
	client = new buildkite.BuildkiteService(address, grpc.Credentials.createInsecure());

module.exports = function(robot) {

	robot.respond(/buildkite status(.*)/, function(msg) {
		var input = {},
			ref = msg.match[1].split(" ");
		input.source = {
			type: operator.SourceType.HUBOT,
			room: {name: msg.message.room},
			user: {
				id: msg.message.user.id,
				login: msg.message.user.name,
			}
		}
		for (i = 0, len = ref.length; i < len; i++) {
			var arg = ref[i],
				parts = arg.split("=");
			if (parts.length === 2 && parts[0] !== "" && parts[1] !== "") {
				input[parts[0]] = parts[1];
			}
		}
		return client.status(input, function(err, response) {
			if (err) {
				return msg.send("```\nStatus error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

	robot.respond(/buildkite list-builds(.*)/, function(msg) {
		var input = {},
			ref = msg.match[1].split(" ");
		input.source = {
			type: operator.SourceType.HUBOT,
			room: {name: msg.message.room},
			user: {
				id: msg.message.user.id,
				login: msg.message.user.name,
			}
		}
		for (i = 0, len = ref.length; i < len; i++) {
			var arg = ref[i],
				parts = arg.split("=");
			if (parts.length === 2 && parts[0] !== "" && parts[1] !== "") {
				input[parts[0]] = parts[1];
			}
		}
		return client.listBuilds(input, function(err, response) {
			if (err) {
				return msg.send("```\nListBuilds error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

}
