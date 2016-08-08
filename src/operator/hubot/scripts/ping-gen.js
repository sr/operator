// Description:
//  Undocumented.
//
// Commands:
//   hubot ping ping  - Undocumented.
//
// Configuration:
//   OPERATORD_ADDRESS
var path = require("path"),
	grpc = require("grpc"),
	protobuf = require("protobufjs");

var protodir = path.resolve(__dirname + "/../proto"),
	proto = protobuf.loadProtoFile({root: protodir, file: "ping.proto"})
	operator = proto.build("operator"),
	ping = grpc.loadObject(proto.ns).ping;

var address = process.env.OPERATORD_ADDRESS,
	client = new ping.Pinger(address, grpc.credentials.createInsecure());

module.exports = function(robot) {

	robot.respond(/ping ping(.*)/, function(msg) {
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
		return client.ping(input, function(err, response) {
			if (err) {
				return msg.send("```\nPing error: " + err.message + "\n```")
			} else {
				return msg.send("```\n" + response.output.PlainText + "\n```")
			}
		});
	});

}
