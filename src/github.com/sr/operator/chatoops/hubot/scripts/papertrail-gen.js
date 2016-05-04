// Description:
//  Undocumented.
//
// Commands:
//   hubot papertrail search  [query=value] - Undocumented.
//
// Configuration:
//   OPERATORD_ADDRESS
var path = require("path"),
	grpc = require("grpc"),
	protobuf = require("protobufjs");

var protodir = path.resolve(__dirname + "/../proto"),
	proto = protobuf.loadProtoFile({root: protodir, file: "papertrail.proto"})
	operator = proto.build("operator"),
	papertrail = grpc.loadObject(proto.ns).papertrail;

var address = process.env.OPERATORD_ADDRESS,
	client = new papertrail.PapertrailService(address, grpc.Credentials.createInsecure());

module.exports = function(robot) {

	robot.respond(/papertrail search(.*)/, function(msg) {
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
		return client.search(input, function(err, response) {
			if (err) {
				return msg.send("```\nSearch error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

}
