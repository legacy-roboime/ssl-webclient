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
  var ball_radius, default_geometry_field, drawBalls, drawField, drawRobots, field_path, inner_height, inner_width, left_goal_path, pad, right_goal_path, robot_front_cut, robot_label, robot_path, robot_radius, robot_transform, socket, svg, ticks_to_time, updateRefereeState;

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
    if (is_blue_left == null) {
      is_blue_left = true;
    }
    svg.select(".field-line").datum(field_geometry).transition().duration(750).attr("d", field_path);
    svg.select(".left-goal").classed("blue", is_blue_left).classed("yellow", !is_blue_left).datum(field_geometry).transition().duration(750).attr("d", left_goal_path);
    return svg.select(".right-goal").classed("blue", !is_blue_left).classed("yellow", is_blue_left).datum(field_geometry).transition().duration(750).attr("d", right_goal_path);
  };

  drawRobots = function(robots, color) {
    var label, robot;
    robot = svg.selectAll(".robot." + color).data(robots);
    robot.attr("d", robot_path).attr("transform", robot_transform);
    robot.enter().append("path").classed("robot", true).classed(color, true).attr("d", robot_path).attr("transform", robot_transform);
    robot.exit().remove();
    label = svg.selectAll(".robot-label." + color).data(robots);
    label.text(robot_label).attr("x", function(r) {
      return r.x;
    }).attr("y", function(r) {
      return -r.y;
    });
    label.enter().append("text").classed("robot-label", true).classed(color, true).text(robot_label).attr("text-anchor", "middle").attr("alignment-baseline", "central").attr("x", function(r) {
      return r.x;
    }).attr("y", function(r) {
      return -r.y;
    });
    return label.exit().remove();
  };

  drawBalls = function(balls) {
    var ball;
    ball = svg.selectAll(".ball").data(balls);
    ball.attr("cx", function(b) {
      return b.x;
    }).attr("cy", function(b) {
      return -b.y;
    });
    ball.enter().append("circle").classed("ball", true).attr("r", ball_radius).attr("cx", function(b) {
      return b.x;
    }).attr("cy", function(b) {
      return -b.y;
    });
    return ball.exit().remove();
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

  updateRefereeState = function(referee) {
    var blue_team, yellow_team;
    d3.select("#time_left").datum(referee).html(function(d) {
      return ticks_to_time(d.stage_time_left);
    });
    yellow_team = d3.select("#team_yellow").datum(referee.yellow);
    yellow_team.select(".team_name").html(function(d) {
      return d.name;
    });
    yellow_team.select(".score").html(function(d) {
      return d.score;
    });
    blue_team = d3.select("#team_blue").datum(referee.blue);
    blue_team.select(".team_name").html(function(d) {
      return d.name;
    });
    return blue_team.select(".score").html(function(d) {
      return d.score;
    });
  };

  svg.append("path").classed("field-line", true);

  svg.append("path").classed("left-goal", true);

  svg.append("path").classed("right-goal", true);

  drawField(default_geometry_field);

  socket = io.connect('http://ssl-webclient.heroku.com:80/');

  socket.on("ssl_packet", function(packet) {
    var detection, geometry;
    detection = packet.detection, geometry = packet.geometry;
    if (detection != null) {
      drawRobots(detection.robots_yellow, "yellow");
      drawRobots(detection.robots_blue, "blue");
      drawBalls(detection.balls);
    }
    if (geometry != null) {
      return drawField(geometry.field);
    }
  });

  socket.on("ssl_refbox_packet", function(packet) {
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