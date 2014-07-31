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

#numeral = require("numeral")
THREE = require("three")
$ = require("jquery")
require("./three-controls")
{options, default_geometry_field, cmd2txt, stg2txt} = require("./draw")

# XXX for debugging only
global.THREE = THREE

NEAR = 100
MIDDLE = 200
FAR = 700
VERYFAR = 2200
FOG_DENSITY = 0.0011
FOG_START = 1700
FOG_FINISH = 2200
NULL_WIDTH = 0.1
GOAL_HEIGHT = 16
ZOOM_MIN = 96
ZOOM_MAX = 1914

ORANGE      = 0xff931f
ORANGE2     = 0xc57a29
YELLOW      = 0xede528
YELLOW2     = 0xd5c512
BLUE        = 0x3276b1
BLUE2       = 0x285e8e
FIELD_GREEN = 0x19770f
WHITE       = 0xefefef
BLACK       = 0x030303
FOG_COLOR   = 0x0c3c08
#GRID_COLOR  = 0x071a05
#GRID_COLOR  = 0x145f0c
GRID_COLOR  = 0x166b0d
#GRID_COLOR  = 0x19770f

# scale
s = (x) -> x / 10

max_frame_distance = 5


class Painter
  constructor: (elem) ->
    # XXX for debugging:
    global.painter = @

    @detection = null
    @shouldDrawDetection = false
    @geometry = null
    @shouldDrawGeometry = false
    @referee = null
    @shouldDrawReferee = false
    @timestamp = null

    @container = $(elem)
    @scene = new THREE.Scene()

    # TEST OBJECT
    ##geometry = new THREE.BoxGeometry 4, 4, 4
    #geometry = new THREE.SphereGeometry 2.15, 32, 16
    ##material = new THREE.MeshBasicMaterial color: ORANGE
    ##material = new THREE.MeshLambertMaterial color: ORANGE
    #material = new THREE.MeshPhongMaterial color: ORANGE
    #@mesh = new THREE.Mesh(geometry, material)
    #@mesh.position.set(0, 2.15, 0)
    ##@mesh.castShadow = true
    ##@mesh.receiveShadow = true
    #@scene.add(@mesh)

    # RENEDERER
    #@renderer = new THREE.CanvasRenderer antialias: true, alpha: true
    @renderer = new THREE.WebGLRenderer antialias: true, alpha: true
    @renderer.setSize window.innerWidth, window.innerHeight
    #@renderer.setClearColor FIELD_GREEN, 1
    #@renderer.setClearColor @scene.fog.color, 0
    #@renderer.setClearColor FOG_COLOR, 1
    @renderer.autoClear = false
    #@renderer.shadowMapEnabled = true
    #@renderer.shadowMapType = THREE.PCFShadowMap
    @clock = new THREE.Clock()
    @container.append @renderer.domElement
    window.addEventListener "resize", (=> @adjustSize()), false

    # CAMERA
    @camera = new THREE.PerspectiveCamera 32, window.innerWidth / window.innerHeight, 1, VERYFAR
    @camera.position.set(0, 959.5, 0)
    #@camera.position.set(-50, 200, 200)
    #@camera.rotation.set(-0.814, -0.136, -0.143)

    # CONTROLS
    @controls = new THREE.OrbitControls @camera, @renderer.domElement
    @controls.minDistance = ZOOM_MIN
    @controls.maxDistance = ZOOM_MAX
    @controls.damping = 0.001

    # STATS
    @stats = new Stats()
    @stats.domElement.style.position = "absolute"
    @stats.domElement.style.top = "2px"
    @stats.domElement.style.left = "2px"
    @stats.domElement.style.zIndex = 100
    @container.append @stats.domElement

    # MATERIALS
    #@lineMaterial = new THREE.MeshBasicMaterial color: WHITE
    @lineMaterial = new THREE.MeshLambertMaterial color: WHITE
    @blueMaterial = new THREE.MeshLambertMaterial color: BLUE
    @yellowMaterial = new THREE.MeshLambertMaterial color: YELLOW
    #@lineMaterial = new THREE.MeshPhongMaterial color: WHITE
    #@lineMaterial.reflectivity = 0
    #@lineMaterial.refractionRatio = 0
    #@lineMaterial.ambient = WHITE
    @ballMaterial = new THREE.MeshPhongMaterial color: ORANGE
    @ballGeometry = new THREE.SphereGeometry 2.15, 32, 16

    # draw default sized field
    @createScene()
    #@drawField(default_geometry_field)
    @start()

  animate: ->
    requestAnimationFrame(=> @animate()) unless @_stop
    #delta = @clock.getDelta()

    if @shouldDrawField
      @shouldDrawField = false
      @drawField @geometry.field

    if @shouldDrawReferee
      @shouldDrawReferee = false
      @drawReferee @referee

    if @shouldDrawDetection
      @shouldDrawDetection = false

      @lastFrame = @detection.frame_number
      @drawRobots @detection.robots_yellow, "yellow"
      @drawRobots @detection.robots_blue, "blue"
      @drawBalls @detection.balls

    @controls.update()
    @stats.update()
    @renderer.render(@scene, @camera)

  updateVision: (packet, @timestamp=new Date()) ->
    if packet.detection
      unless packet.detection.camera_id in options.ignore_cams
        @detection = packet.detection
        @shouldDrawDetection = true

    if packet.geometry
      @geometry = packet.geometry
      @shouldDrawField = true

    #@mesh.rotation.x += 0.01
    #@mesh.rotation.y += 0.02

  updateReferee: (@referee, @timestamp=new Date()) ->
    @shouldDrawReferee = true

  adjustSize: ->
    @camera.aspect = window.innerWidth / window.innerHeight
    @camera.updateProjectionMatrix()
    @renderer.setSize window.innerWidth, window.innerHeight

  hide: -> @container.addClass("hide")
  show: -> @container.removeClass("hide")

  stop: -> @_stop = true
  start: ->
    @_stop = false
    @animate()

  addLight: (dx, dy, dz, i) ->
    light = new THREE.DirectionalLight WHITE, i
    light.position.set(dx, dy, dz).normalize()
    @scene.add light

  createScene: ->
    @scene.fog = new THREE.Fog FOG_COLOR, FOG_START, FOG_FINISH
    #@scene.fog = new THREE.FogExp2 FOG_COLOR, FOG_DENSITY

    # LIGHTS
    #@addLight( 1,  1,  1, 1.54)
    # top, strong
    @addLight( 1,  1, -1, 0.72)
    @addLight(-1,  1, -1, 0.72)
    # bottom, weak
    @addLight(-1, -1,  1, 0.31)
    @addLight( 1, -1,  1, 0.31)
    # others, weaker
    @addLight( 1,  1,  1, 0.19)
    @addLight( 1, -1, -1, 0.19)
    @addLight(-1,  1,  1, 0.19)
    @addLight(-1, -1, -1, 0.19)

    #light = new THREE.DirectionalLight WHITE, 1.83
    #light.position.set(1, 1, 1).normalize()
    #@scene.add light
    #light = new THREE.DirectionalLight WHITE
    #light.position.set(-1, -1, -1).normalize()
    #@scene.add light
    #light = new THREE.AmbientLight 0x505050
    #@scene.add light

    # GROUND
    plane = new THREE.PlaneGeometry 100, 100
    #planeMaterial = new THREE.MeshPhongMaterial color: FIELD_GREEN
    planeMaterial = new THREE.MeshLambertMaterial color: FIELD_GREEN
    planeMaterial.ambient = planeMaterial.color

    ground = new THREE.Mesh(plane, planeMaterial)
    ground.position.set(0, -NULL_WIDTH, 0)
    ground.rotation.x = -Math.PI / 2
    ground.scale.set(100, 100, 1)
    @scene.add ground

    # GRID
    grid = new THREE.GridHelper(2000, 10)
    grid.setColors GRID_COLOR, GRID_COLOR
    @scene.add grid

    # BASIC HOLDERS
    @balls = []
    @blueRobots = {}
    @yellowRobots = {}

    # THE FIELD
    @addField(default_geometry_field)

  addField: (g) ->
    @lastGeometryJSON = JSON.stringify(g)
    @isBlueLeft = options.is_blue_left

    fieldGeom = new THREE.ShapeGeometry @fieldContourShape(g)
    @fieldMesh = new THREE.Mesh fieldGeom, @lineMaterial
    @fieldMesh.rotation.x = -Math.PI / 2
    @fieldMesh.position.y = NULL_WIDTH
    @scene.add @fieldMesh

    circleGeom = new THREE.ShapeGeometry @flatRingShape(g), curveSegments: 36
    @circleMesh = new THREE.Mesh circleGeom, @lineMaterial
    @circleMesh.rotation.x = -Math.PI / 2
    @circleMesh.position.y = NULL_WIDTH
    @scene.add @circleMesh

    spotGeom = new THREE.ShapeGeometry @spotShape(g, 1.5)
    @spotMesh = new THREE.Mesh spotGeom, @lineMaterial
    @spotMesh.rotation.x = -Math.PI / 2
    @spotMesh.position.y = NULL_WIDTH
    @scene.add @spotMesh

    rSpotGeom = new THREE.ShapeGeometry @spotShape(g)
    @rSpotMesh = new THREE.Mesh rSpotGeom, @lineMaterial
    @rSpotMesh.rotation.x = -Math.PI / 2
    @rSpotMesh.position.y = NULL_WIDTH
    @rSpotMesh.position.x = s(g.field_length / 2 - g.penalty_spot_from_field_line_dist - g.line_width / 2)
    @scene.add @rSpotMesh

    lSpotGeom = new THREE.ShapeGeometry @spotShape(g)
    @lSpotMesh = new THREE.Mesh lSpotGeom, @lineMaterial
    @lSpotMesh.rotation.x = -Math.PI / 2
    @lSpotMesh.position.y = NULL_WIDTH
    @lSpotMesh.position.x = -s(g.field_length / 2 - g.penalty_spot_from_field_line_dist - g.line_width / 2)
    @scene.add @lSpotMesh

    rDefGeom = new THREE.ShapeGeometry @defenseAreaShape(g), curveSegments: 12
    @rDefMesh = new THREE.Mesh rDefGeom, @lineMaterial
    @rDefMesh.rotation.x = -Math.PI / 2
    @rDefMesh.position.y = NULL_WIDTH
    @scene.add @rDefMesh

    lDefGeom = new THREE.ShapeGeometry @defenseAreaShape(g), curveSegments: 12
    @lDefMesh = new THREE.Mesh lDefGeom, @lineMaterial
    @lDefMesh.rotation.x = -Math.PI / 2
    @lDefMesh.rotation.z = Math.PI
    @lDefMesh.position.y = NULL_WIDTH
    @scene.add @lDefMesh

    rGoalGeom = @goalGeom(g)
    @rGoalMesh = new THREE.Mesh rGoalGeom, if @isBlueLeft then @yellowMaterial else @blueMaterial
    @rGoalMesh.rotation.x = -Math.PI / 2
    @rGoalMesh.position.y = NULL_WIDTH
    @scene.add @rGoalMesh

    lGoalGeom = @goalGeom(g)
    @lGoalMesh = new THREE.Mesh lGoalGeom, if @isBlueLeft then @blueMaterial else @yellowMaterial
    @lGoalMesh.rotation.x = -Math.PI / 2
    @lGoalMesh.position.y = NULL_WIDTH
    @lGoalMesh.rotation.z = Math.PI
    @scene.add @lGoalMesh

  removeField: ->
    @scene.remove @fieldMesh
    @scene.remove @circleMesh
    @scene.remove @spotMesh
    @scene.remove @rSpotMesh
    @scene.remove @lSpotMesh
    @scene.remove @rDefMesh
    @scene.remove @lDefMesh
    @scene.remove @rGoalMesh
    @scene.remove @lGoalMesh

  goalGeom: (g) ->
    goal = new THREE.Shape()
    goal.moveTo s(g.field_length / 2), s(g.goal_width / 2)
    goal.lineTo s(g.field_length / 2 + g.goal_depth), s(g.goal_width / 2)
    goal.lineTo s(g.field_length / 2 + g.goal_depth), -s(g.goal_width / 2)
    goal.lineTo s(g.field_length / 2), -s(g.goal_width / 2)
    goal.lineTo s(g.field_length / 2), -s(g.goal_width / 2 + g.goal_wall_width)
    goal.lineTo s(g.field_length / 2 + g.goal_depth + g.goal_wall_width), -s(g.goal_width / 2 + g.goal_wall_width)
    goal.lineTo s(g.field_length / 2 + g.goal_depth + g.goal_wall_width), s(g.goal_width / 2 + g.goal_wall_width)
    goal.lineTo s(g.field_length / 2), s(g.goal_width / 2 + g.goal_wall_width)
    goal.lineTo s(g.field_length / 2), s(g.goal_width / 2)
    goal.extrude amount: GOAL_HEIGHT, bevelEnabled: false

  defenseAreaShape: (g) ->
    area = new THREE.Shape()
    area.moveTo s(g.field_length / 2), s(g.defense_radius + g.defense_stretch / 2)
    area.absarc s(g.field_length / 2), s(g.defense_stretch / 2), s(g.defense_radius), Math.PI / 2, Math.PI, true
    area.lineTo s(g.field_length / 2 - g.defense_radius), -s(g.defense_stretch / 2)
    area.absarc s(g.field_length / 2), -s(g.defense_stretch / 2), s(g.defense_radius), Math.PI, 3 * Math.PI / 2, true
    area.lineTo s(g.field_length / 2), -s(g.defense_radius + g.defense_stretch / 2 - g.line_width)
    area.absarc s(g.field_length / 2), -s(g.defense_stretch / 2), s(g.defense_radius - g.line_width), 3 * Math.PI / 2, Math.PI, true
    area.lineTo s(g.field_length / 2 - g.defense_radius + g.line_width), s(g.defense_stretch / 2)
    area.absarc s(g.field_length / 2), s(g.defense_stretch / 2), s(g.defense_radius - g.line_width), Math.PI, Math.PI / 2, true
    area.lineTo s(g.field_length / 2), s(g.defense_radius + g.defense_stretch / 2)
    area

  spotShape: (g, r=1.0) ->
    spot = new THREE.Shape()
    spot.moveTo s(g.line_width * r), 0
    spot.absarc 0, 0, s(g.line_width * r), 0, Math.PI * 2, false
    spot

  flatRingShape: (g) ->
    circle = new THREE.Shape()
    circle.moveTo s(g.center_circle_radius), 0
    circle.absarc 0, 0, s(g.center_circle_radius), 0, Math.PI * 2, false
    hole = new THREE.Path()
    hole.moveTo s(g.center_circle_radius - g.line_width), 0
    hole.absarc 0, 0, s(g.center_circle_radius - g.line_width), 0, Math.PI * 2, true
    #hole.absarc 10, 10, 10, 0, Math.PI * 2, true
    circle.holes.push hole
    circle


  fieldContourShape: (g) ->
    shape = new THREE.Shape()
    shape.moveTo -s(g.field_length / 2), -s(g.field_width / 2)
    shape.lineTo -s(g.field_length / 2),  s(g.field_width / 2)
    shape.lineTo  s(g.field_length / 2),  s(g.field_width / 2)
    shape.lineTo  s(g.field_length / 2), -s(g.field_width / 2)
    shape.lineTo -s(g.field_length / 2), -s(g.field_width / 2)
    hole = new THREE.Path()
    hole.moveTo -s(g.field_length / 2 - g.line_width), -s(g.field_width / 2 - g.line_width)
    hole.lineTo -s(g.line_width / 2),                  -s(g.field_width / 2 - g.line_width)
    hole.lineTo -s(g.line_width / 2),                   s(g.field_width / 2 - g.line_width)
    hole.lineTo -s(g.field_length / 2 - g.line_width),  s(g.field_width / 2 - g.line_width)
    hole.lineTo -s(g.field_length / 2 - g.line_width), -s(g.field_width / 2 - g.line_width)
    shape.holes.push hole
    hole = new THREE.Path()
    hole.moveTo  s(g.field_length / 2 - g.line_width),  s(g.field_width / 2 - g.line_width)
    hole.lineTo  s(g.line_width / 2),                   s(g.field_width / 2 - g.line_width)
    hole.lineTo  s(g.line_width / 2),                  -s(g.field_width / 2 - g.line_width)
    hole.lineTo  s(g.field_length / 2 - g.line_width), -s(g.field_width / 2 - g.line_width)
    hole.lineTo  s(g.field_length / 2 - g.line_width),  s(g.field_width / 2 - g.line_width)
    shape.holes.push hole
    shape

  drawField: (geometry) ->
    if JSON.stringify(geometry) isnt @lastGeometryJSON or @isBlueLeft isnt options.is_blue_left
      console.log 'hello'
      @removeField()
      @addField geometry

  drawReferee: -> return
  drawRobots: -> return

  createBall: (b) ->
    ball = new THREE.Mesh @ballGeometry, @ballMaterial
    ball.position.set s(b.x), 2.15, -s(b.y)
    ball.lastFrame = @lastFrame
    ball

  drawBalls: (balls) ->
    for b in @balls
      if Math.abs(b.lastFrame - @lastFrame) > max_frame_distance
        @scene.remove b

    for ball in balls
      b = @createBall ball
      @scene.add b
      @balls.push b

exports.Painter = Painter
