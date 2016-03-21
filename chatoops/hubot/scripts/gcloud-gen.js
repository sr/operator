// Description:
//  Undocumented.
//
// Commands:
//   hubot gcloud create-dev-instance  - Undocumented.
//   hubot gcloud list-instances  [project_id=value] - Undocumented.
//   hubot gcloud stop  [instance=value] [zone=value] - Undocumented.
//
// Configuration:
//   OPERATORD_ADDRESS
var path = require("path"),
	grpc = require("grpc"),
	protobuf = require("protobufjs");

var protodir = path.resolve(__dirname + "/../proto"),
	proto = protobuf.loadProtoFile({root: protodir, file: "gcloud.proto"})
	operator = proto.build("operator"),
	gcloud = grpc.loadObject(proto.ns).gcloud;

var address = process.env.OPERATORD_ADDRESS,
	client = new gcloud.GcloudService(address, grpc.Credentials.createInsecure());

module.exports = function(robot) {

	robot.respond(/gcloud create-dev-instance(.*)/, function(msg) {
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
		return client.createDevInstance(input, function(err, response) {
			if (err) {
				return msg.send("```\nCreateDevInstance error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

	robot.respond(/gcloud list-instances(.*)/, function(msg) {
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
		return client.listInstances(input, function(err, response) {
			if (err) {
				return msg.send("```\nListInstances error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

	robot.respond(/gcloud stop(.*)/, function(msg) {
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
		return client.stop(input, function(err, response) {
			if (err) {
				return msg.send("```\nStop error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

}
