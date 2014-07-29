###
Copyright (C) 2013 RoboIME

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
###

module.exports =

  options:
    "3d": true
    is_blue_left: true
    show_frame_skip: false
    show_trail: false
    #ignore_cams: [0, 1, 2, 3]
    ignore_cams: ["intel"]
    vflip: 1
    hflip: 1
    xyswitch: false

  default_geometry_field:
    line_width: 10
    field_length: 6000
    field_width: 4000
    boundary_width: 250
    referee_width: 500
    goal_width: 700
    goal_depth: 180
    goal_wall_width: 20
    center_circle_radius: 500
    defense_radius: 500
    defense_stretch: 350
    free_kick_from_defense_dist: 700
    penalty_spot_from_field_line_dist: 450
    penalty_line_from_spot_dist: 350

  cmd2txt: (c) ->
    switch c
      # All robots should completely stop moving.
      when 0 then "halt"
      # Robots must keep 50 cm from the ball.
      when 1 then "stop"
      # A prepared kickoff or penalty may now be taken.
      when 2 then "start"
      # The ball is dropped and free for either team.
      when 3 then "force start"
      # The yellow team may move into kickoff position.
      when 4 then "prepare kickoff yellow"
      # The blue team may move into kickoff position.
      when 5 then "prepare kickoff blue"
      # The yellow team may move into penalty position.
      when 6 then "prepare penalty yellow"
      # The blue team may move into penalty position.
      when 7 then "prepare penalty blue"
      # The yellow team may take a direct free kick.
      when 8 then "direct free yellow"
      # The blue team may take a direct free kick.
      when 9 then "direct free blue"
      # The yellow team may take an indirect free kick.
      when 10 then "indirect free yellow"
      # The blue team may take an indirect free kick.
      when 11 then "indirect free blue"
      # The yellow team is currently in a timeout.
      when 12 then "timeout yellow"
      # The blue team is currently in a timeout.
      when 13 then "timeout blue"
      # The yellow team just scored a goal.
      # For information only.
      # For rules compliance, teams must treat as STOP.
      when 14 then "goal yellow"
      # The blue team just scored a goal.
      when 15 then "goal blue"

  stg2txt: (s) ->
    switch s
      # The first half is about to start.
      # A kickoff is called within this stage.
      # This stage ends with the NORMAL_START.
      when 0 then "pre game"
      # The first half of the normal game, before half time.
      when 1 then "first half"
      # Half time between first and second halves.
      when 2 then "half time"
      # The second half is about to start.
      # A kickoff is called within this stage.
      # This stage ends with the NORMAL_START.
      when 3 then "pre second half"
      # The second half of the normal game, after half time.
      when 4 then "second half"
      # The break before extra time.
      when 5 then "extra time break"
      # The first half of extra time is about to start.
      # A kickoff is called within this stage.
      # This stage ends with the NORMAL_START.
      when 6 then "pre extra first half"
      # The first half of extra time.
      when 7 then "extra first half"
      # Half time between first and second extra halves.
      when 8 then "extra half time"
      # The second half of extra time is about to start.
      # A kickoff is called within this stage.
      # This stage ends with the NORMAL_START.
      when 9 then "pre extra second half"
      # The second half of extra time.
      when 10 then "extra second half"
      # The break before penalty shootout.
      when 11 then "penalty shootout break"
      # The penalty shootout.
      when 12 then "penalty shootout"
      # The game is over.
      when 13 then "post game"


# XXX this is so options can be changes from browsers console
global.options = module.exports.options
