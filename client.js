/*
Copyright (C) 2013 RoboIME

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
*/


(function() {
  var LogParser, ball_radius, default_geometry_field, drawBalls, drawField, drawRobots, field_path, inner_height, inner_width, left_goal_path, log_reader, pad, right_goal_path, robot_front_cut, robot_label, robot_path, robot_radius, robot_transform, socket, svg, ticks_to_time, updateRefereeState, updateVisionState, _packets;

  inner_width = 7200;

  inner_height = 5200;

  svg = (function() {
    var _svg;
    _svg = d3.select("#field").append("svg").attr("viewBox", "-" + (inner_width / 2) + " -" + (inner_height / 2) + " " + inner_width + " " + inner_height).attr("x", "50%").attr("y", "50%").call(d3.behavior.zoom().scaleExtent([.75, 10]).on("zoom", function() {
      return svg.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
    }));
    return _svg.append("g");
  })();

  default_geometry_field = {
    line_width: 10,
    field_length: 6000,
    field_width: 4000,
    boundary_width: 250,
    referee_width: 500,
    goal_width: 700,
    goal_depth: 180,
    goal_wall_width: 20,
    center_circle_radius: 500,
    defense_radius: 500,
    defense_stretch: 350,
    free_kick_from_defense_dist: 700,
    penalty_spot_from_field_line_dist: 450,
    penalty_line_from_spot_dist: 350
  };

  field_path = function(g) {
    var path;
    path = "";
    path += "M " + (-g.field_length / 2) + " " + (-g.field_width / 2) + "\nh " + g.field_length + "\nv " + g.field_width + "\nh-" + g.field_length + "\nv-" + g.field_width + "\nm " + g.line_width + " " + g.line_width + "\nv " + (g.field_width - 2 * g.line_width) + "\nh " + (g.field_length - 2 * g.line_width) + "\nv-" + (g.field_width - 2 * g.line_width) + "\nh-" + (g.field_length - 2 * g.line_width);
    path += "M " + (g.line_width / 2) + "-" + (g.field_width / 2) + "\nv " + g.field_width + "\nh-" + g.line_width + "\nv-" + g.field_width + "\nh " + g.line_width;
    path += "M 0-" + g.center_circle_radius + "\na " + g.center_circle_radius + " " + g.center_circle_radius + " 0 0 1 0 " + (2 * g.center_circle_radius) + "\na " + g.center_circle_radius + " " + g.center_circle_radius + " 0 0 1 0-" + (2 * g.center_circle_radius) + "\nm 0 " + g.line_width + "\na " + (g.center_circle_radius - g.line_width) + " " + (g.center_circle_radius - g.line_width) + " 0 0 0 0 " + (2 * (g.center_circle_radius - g.line_width)) + "\na " + (g.center_circle_radius - g.line_width) + " " + (g.center_circle_radius - g.line_width) + " 0 0 0 0-" + (2 * (g.center_circle_radius - g.line_width));
    path += "M 0-" + (1.5 * g.line_width) + "\na " + (1.5 * g.line_width) + " " + (1.5 * g.line_width) + " 0 0 1 0 " + (3 * g.line_width) + "\na " + (1.5 * g.line_width) + " " + (1.5 * g.line_width) + " 0 0 1 0-" + (3 * g.line_width);
    path += "M-" + (g.field_length / 2) + "-" + (g.defense_radius + g.defense_stretch / 2) + "\na " + g.defense_radius + " " + g.defense_radius + " 0 0 1 " + g.defense_radius + " " + g.defense_radius + "\nv " + g.defense_stretch + "\na " + g.defense_radius + " " + g.defense_radius + " 0 0 1-" + g.defense_radius + " " + g.defense_radius + "\nv-" + g.line_width + "\na " + (g.defense_radius - g.line_width) + " " + (g.defense_radius - g.line_width) + " 0 0 0 " + (g.defense_radius - g.line_width) + "-" + (g.defense_radius - g.line_width) + "\nv-" + g.defense_stretch + "\na " + (g.defense_radius - g.line_width) + " " + (g.defense_radius - g.line_width) + " 0 0 0-" + (g.defense_radius - g.line_width) + "-" + (g.defense_radius - g.line_width);
    path += "M " + (g.field_length / 2) + " " + (g.defense_radius + g.defense_stretch / 2) + "\na " + g.defense_radius + " " + g.defense_radius + " 0 0 1-" + g.defense_radius + "-" + g.defense_radius + "\nv-" + g.defense_stretch + "\na " + g.defense_radius + " " + g.defense_radius + " 0 0 1 " + g.defense_radius + "-" + g.defense_radius + "\nv " + g.line_width + "\na " + (g.defense_radius - g.line_width) + " " + (g.defense_radius - g.line_width) + " 0 0 0-" + (g.defense_radius - g.line_width) + " " + (g.defense_radius - g.line_width) + "\nv " + g.defense_stretch + "\na " + (g.defense_radius - g.line_width) + " " + (g.defense_radius - g.line_width) + " 0 0 0 " + (g.defense_radius - g.line_width) + " " + (g.defense_radius - g.line_width);
    path += "M-" + (g.field_length / 2 - g.penalty_spot_from_field_line_dist - g.line_width) + " 0\na " + (1 * g.line_width) + " " + (1 * g.line_width) + " 0 0 1 " + (2 * g.line_width) + " 0\na " + (1 * g.line_width) + " " + (1 * g.line_width) + " 0 0 1-" + (2 * g.line_width) + " 0";
    path += "M " + (g.field_length / 2 - g.penalty_spot_from_field_line_dist - g.line_width) + " 0\na " + (1 * g.line_width) + " " + (1 * g.line_width) + " 0 0 1 " + (2 * g.line_width) + " 0\na " + (1 * g.line_width) + " " + (1 * g.line_width) + " 0 0 1-" + (2 * g.line_width) + " 0";
    path += "z";
    return path;
  };

  left_goal_path = function(g) {
    return "M-" + (g.field_length / 2) + "-" + (g.goal_width / 2 + g.goal_wall_width / 2) + "\nh-" + (g.goal_depth + g.goal_wall_width) + "\nv " + (g.goal_width + 2 * g.goal_wall_width) + "\nh " + (g.goal_depth + g.goal_wall_width) + "\nv-" + g.goal_wall_width + "\nh-" + g.goal_depth + "\nv-" + g.goal_width + "\nh " + g.goal_depth + "\nz";
  };

  right_goal_path = function(g) {
    return "M " + (g.field_length / 2) + "-" + (g.goal_width / 2 + g.goal_wall_width / 2) + "\nh " + (g.goal_depth + g.goal_wall_width) + "\nv " + (g.goal_width + 2 * g.goal_wall_width) + "\nh-" + (g.goal_depth + g.goal_wall_width) + "\nv-" + g.goal_wall_width + "\nh " + g.goal_depth + "\nv-" + g.goal_width + "\nh-" + g.goal_depth + "\nz";
  };

  robot_radius = 90;

  robot_front_cut = 65;

  robot_path = function(r) {
    return "M " + (r.x.toFixed(4)) + " " + ((-r.y).toFixed(4)) + "\nm " + robot_front_cut + " " + (Math.sqrt(robot_radius * robot_radius - robot_front_cut * robot_front_cut).toFixed(4)) + "\na " + robot_radius + " " + robot_radius + " 0 1 1 0-" + (2 * robot_front_cut) + "\nz";
  };

  robot_transform = function(r) {
    return "rotate(" + ((180 * r.orientation / Math.PI).toFixed(4)) + ", " + (r.x.toFixed(4)) + ", " + ((-r.y).toFixed(4)) + ")";
  };

  ball_radius = 21.5;

  robot_label = function(r) {
    return r.robot_id;
  };

  drawField = function(field_geometry, is_blue_left) {
    var f, sp;
    if (is_blue_left == null) {
      is_blue_left = true;
    }
    f = svg.datum(field_geometry);
    f.select(".field-line").transition().duration(750).attr("d", field_path);
    f.select(".left-goal").classed("blue", is_blue_left).classed("yellow", !is_blue_left).transition().duration(750).attr("d", left_goal_path);
    f.select(".right-goal").classed("blue", !is_blue_left).classed("yellow", is_blue_left).transition().duration(750).attr("d", right_goal_path);
    sp = 25;
    f.select(".time-left").attr("x", 0).attr("y", function(f) {
      return -f.field_width / 2 - sp;
    });
    f.select(".left-name").attr("x", function(f) {
      return -f.field_length / 2 + sp;
    }).attr("y", function(f) {
      return -f.field_width / 2 + sp;
    });
    return f.select(".right-name").attr("x", function(f) {
      return f.field_length / 2 - sp;
    }).attr("y", function(f) {
      return -f.field_width / 2 + sp;
    });
  };

  drawRobots = function(robots, color) {
    var label, robot;
    robot = svg.selectAll(".robot." + color).data(robots, function(d) {
      return d.robot_id;
    });
    robot.attr("d", robot_path).attr("transform", robot_transform);
    robot.enter().append("path").classed("robot", true).classed(color, true).attr("d", robot_path).attr("transform", robot_transform);
    label = svg.selectAll(".robot-label." + color).data(robots, function(d) {
      return d.robot_id;
    });
    label.text(robot_label).attr("x", function(r) {
      return r.x;
    }).attr("y", function(r) {
      return -r.y;
    });
    return label.enter().append("text").classed("robot-label", true).classed(color, true).text(robot_label).attr("x", function(r) {
      return r.x;
    }).attr("y", function(r) {
      return -r.y;
    });
  };

  drawBalls = function(balls) {
    var ball;
    ball = svg.selectAll(".ball").data(balls);
    ball.attr("cx", function(b) {
      return b.x;
    }).attr("cy", function(b) {
      return -b.y;
    });
    return ball.enter().append("circle").classed("ball", true).attr("r", ball_radius).attr("cx", function(b) {
      return b.x;
    }).attr("cy", function(b) {
      return -b.y;
    });
  };

  pad = function(n, width, z) {
    z = z || "0";
    n = n + "";
    if (n.length >= width) {
      return n;
    } else {
      return new Array(width - n.length + 1).join(z) + n;
    }
  };

  ticks_to_time = function(ticks) {
    var time;
    if (ticks != null) {
      time = "" + (~~(Math.abs(ticks) / (60 * 1000000))) + ":" + (pad(Math.abs(~~(ticks / 1000000)) % 60, 2));
      if (ticks > 0) {
        return time;
      } else {
        return "-" + time;
      }
    } else {
      return "--:--";
    }
  };

  updateRefereeState = function(referee, is_blue_left) {
    var left, right, _ref;
    if (is_blue_left == null) {
      is_blue_left = true;
    }
    svg.select(".time-left").datum(referee.stage_time_left).text(ticks_to_time);
    _ref = is_blue_left ? [referee.blue, referee.yellow] : [referee.yellow, referee.blue], left = _ref[0], right = _ref[1];
    svg.select(".left-name").datum(left).text(function(d) {
      return d.name;
    });
    return svg.select(".right-name").datum(right).text(function(d) {
      return d.name;
    });
  };

  updateVisionState = function(vision) {
    var detection, geometry;
    detection = vision.detection, geometry = vision.geometry;
    if (detection != null) {
      drawRobots(detection.robots_yellow, "yellow");
      drawRobots(detection.robots_blue, "blue");
      drawBalls(detection.balls);
    }
    if (geometry != null) {
      return drawField(geometry.field);
    }
  };

  svg.append("path").classed("field-line", true);

  svg.append("path").classed("left-goal", true);

  svg.append("path").classed("right-goal", true);

  svg.append("text").classed("time-left", true);

  svg.append("text").classed("team-name", true).classed("left-name", true).attr("text-anchor", "start").attr("alignment-baseline", "hanging");

  svg.append("text").classed("team-name", true).classed("right-name", true).attr("text-anchor", "end").attr("alignment-baseline", "hanging");

  drawField(default_geometry_field);

  window.ProtoBuf = dcodeIO.ProtoBuf;

  window.logparser = LogParser = (function() {
    var header, refbox_builder, vision_builder;

    header = "SSL_LOG_FILE";

    vision_builder = dcodeIO.ProtoBuf.protoFromFile("protos/messages_robocup_ssl_wrapper.proto").build("SSL_WrapperPacket");

    refbox_builder = dcodeIO.ProtoBuf.protoFromFile("protos/referee.proto").build("SSL_Referee");

    function LogParser(buffer) {
      var ver;
      this.buffer = buffer;
      this.offset = header.length + 4;
      this.dataview = new DataView(this.buffer);
      if (!this.check_type()) {
        throw new Error("Invalid file format");
      }
      if ((ver = this.check_version()) !== 1) {
        throw new Error("Unsupported log format version " + ver);
      }
    }

    LogParser.prototype.check_type = function() {
      return decodeURIComponent(String.fromCharCode.apply(null, Array.prototype.slice.apply(new Uint8Array(this.buffer, 0, header.length)))) === header;
    };

    LogParser.prototype.check_version = function() {
      return this.dataview.getUint32(header.length);
    };

    LogParser.prototype.parse_packet = function() {
      var e, packet, size, timestamp, type;
      timestamp = new Date(dcodeIO.Long.fromBits(this.dataview.getUint32(this.offset + 4), this.dataview.getUint32(this.offset)).toNumber() / 1000 / 1000);
      type = this.dataview.getUint32(this.offset + 8);
      size = this.dataview.getUint32(this.offset + 12);
      switch (type) {
        case 1:
          packet = "TODO";
          break;
        case 2:
          packet = vision_builder.decode(this.buffer.slice(this.offset + 16, this.offset + 16 + size));
          break;
        case 3:
          try {
            packet = refbox_builder.decode(this.buffer.slice(this.offset + 16, this.offset + 16 + size));
          } catch (_error) {
            e = _error;
            console.log(e);
          }
          break;
        default:
          packet = "UNSUPPORTED";
      }
      this.offset += 16 + size;
      return {
        timestamp: timestamp,
        type: type,
        packet: packet
      };
    };

    LogParser.prototype.all = function(cb) {
      console.log("parsing...");
      while (this.offset < this.buffer.byteLength - 1) {
        cb(this.parse_packet());
      }
      return console.log("...done");
    };

    LogParser.prototype.rewind = function() {
      return this.offset = header.length + 4;
    };

    LogParser.prototype.play = function(cb) {
      var delta,
        _this = this;
      if (this.offset < this.buffer.byteLength - 1) {
        this.previous = this.previous || this.parse_packet();
        this.current = this.parse_packet();
        delta = this.current.timestamp - this.previous.timestamp;
        if (delta < 0) {
          delta = 0;
        }
        setTimeout((function() {
          return _this.play(cb);
        }), delta);
        this.previous = this.current;
        return cb(this.current);
      } else {
        return console.log("reached end");
      }
    };

    return LogParser;

  })();

  window.packets = _packets = [];

  log_reader = new FileReader();

  log_reader.onload = function(e) {
    var log_parser;
    window.result = log_reader.result;
    log_parser = new LogParser(log_reader.result);
    return log_parser.play(function(p) {
      console.log("render");
      switch (p.type) {
        case 2:
          return updateVisionState(p.packet);
        case 3:
          return updateRefereeState(p.packet);
        default:
          return console.log(p);
      }
    });
  };

  $("#file-input").on("change", function(e) {
    var f, _i, _len, _ref, _results;
    _ref = e.target.files;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      f = _ref[_i];
      _results.push(log_reader.readAsArrayBuffer(f));
    }
    return _results;
  });

  socket = io.connect();

  socket.on("vision_packet", function(packet) {
    return updateVisionState(packet);
  });

  socket.on("refbox_packet", function(packet) {
    return updateRefereeState(packet);
  });

  $(function() {
    var field;
    $("[data-toggle='tooltip']").tooltip();
    field = $("#field")[0];
    return $(".fullscreen-btn").click(function() {
      if (screenfull.enabled) {
        return screenfull.toggle(field);
      }
    });
  });

}).call(this);

/*
//@ sourceMappingURL=client.js.map
*/