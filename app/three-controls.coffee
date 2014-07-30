###
@author qiao / https://github.com/qiao
@author mrdoob / http://mrdoob.com
@author alteredq / http://alteredqualia.com/
@author WestLangley / http://github.com/WestLangley
@author erich666 / http://erichaines.com
@author jansegre / https://github.com/jansegre
###

#global THREE, console

# This set of controls performs orbiting, dollying (zooming), and panning. It maintains
# the "up" direction as +Y, unlike the TrackballControls. Touch on tablet and phones is
# supported.
#
#    Orbit - left mouse / touch: one finger move
#    Zoom - middle mouse, or mousewheel / touch: two finger spread or squish
#    Pan - right mouse, or arrow keys / touch: three finter swipe
#
# This is a drop-in replacement for (most) TrackballControls used in examples.
# That is, include this js file and wherever you see:
#    	controls = new THREE.TrackballControls( camera );
#      controls.target.z = 150;
# Simple substitute "OrbitControls" and the control should work as-is.

THREE = require("three")
#THREE.OrbitControls:: = Object.create(THREE.EventDispatcher::)
#THREE.OrbitControls = (object, domElement) ->
EPS = 0.000001


class THREE.OrbitControls extends THREE.EventDispatcher

  # API

  # Set to false to disable this control
  enabled: true

  # "target" sets the location of focus, where the control orbits around
  # and where it pans with respect to.
  target: new THREE.Vector3()

  # This option actually enables dollying in and out; left as "zoom" for
  # backwards compatibility
  noZoom: false
  zoomSpeed: 0.5

  # Limits to how far you can dolly in and out
  minDistance: 59.5
  maxDistance: 1187

  # Set to true to disable this control
  noRotate: false
  rotateSpeedLeft: 0.7
  rotateSpeedUp: 0.05

  # Set to true to disable this control
  noPan: false
  panSpeed: 0.0563
  keyPanSpeed: 7.0  # pixels moved per arrow key push
  fixedPanMatrix: [1, 0, 0, 0, 0, 0, -1]  # set to null to disabl

  # Set to true to automatically rotate around the target
  autoRotate: false
  autoRotateSpeed: 2.0 # 30 seconds per round when fps is 60

  # How far you can orbit vertically, upper and lower limits.
  # Range is 0 to Math.PI radians.
  minPolarAngle: 0  # radians
  maxPolarAngle: Math.PI / 2 - 0.2  # radians

  # Set to true to disable use of the keys
  noKeys: false

  # The four arrow keys
  keys:
    LEFT: 37
    UP: 38
    RIGHT: 39
    BOTTOM: 40

  rotateLeft: (angle) ->
    angle = getAutoRotationAngle()  unless angle?
    @thetaDelta -= angle

  rotateUp: (angle) ->
    angle = getAutoRotationAngle()  unless angle?
    @phiDelta -= angle

  # pass in distance in world space to move left
  panLeft: (distance) ->
    te = @fixedPanMatrix or @object.matrix.elements

    # get X column of matrix
    @panOffset.set te[0], te[1], te[2]
    @panOffset.multiplyScalar -distance

    @_pan.add @panOffset

  # pass in distance in world space to move up
  panUp: (distance) ->
    te = @fixedPanMatrix or @object.matrix.elements

    # get Y column of matrix
    @panOffset.set te[4], te[5], te[6]
    @panOffset.multiplyScalar distance

    @_pan.add @panOffset

  # pass in x,y of change desired in pixel space,
  # right and down are positive
  pan: (deltaX, deltaY) ->
    element = (if @domElement is document then @domElement.body else @domElement)

    if @object.fov?

      # perspective
      position = @object.position
      @offset = position.clone().sub(@target)
      targetDistance = @offset.length()

      # half of the fov is center to top of screen
      targetDistance *= Math.tan((@object.fov / 2) * Math.PI / 180.0)

      # we actually don't use screenWidth, since perspective camera is fixed to screen height
      @panLeft 2 * deltaX * targetDistance / element.clientHeight
      @panUp 2 * deltaY * targetDistance / element.clientHeight

    else if @object.top?

      # orthographic
      @panLeft deltaX * (@object.right - @object.left) / element.clientWidth
      @panUp deltaY * (@object.top - @object.bottom) / element.clientHeight
    else

      # camera neither orthographic or perspective
      console.warn "WARNING: OrbitControls encountered an unknown camera type - pan disabled."

  dollyIn: (dollyScale) ->
    dollyScale = @getZoomScale()  unless dollyScale?
    @scale /= dollyScale

  dollyOut: (dollyScale) ->
    dollyScale = @getZoomScale()  unless dollyScale?
    @scale *= dollyScale

  getAutoRotationAngle: -> 2 * Math.PI / 60 / 60 * @autoRotateSpeed
  getZoomScale: -> Math.pow 0.95, @zoomSpeed

  update: ->
    position = @object.position

    @offset.copy(position).sub @target

    # rotate offset to "y-axis-is-up" space
    @offset.applyQuaternion @quat

    # angle from z-axis around y-axis
    theta = Math.atan2(@offset.x, @offset.z)

    # angle from y-axis
    phi = Math.atan2(Math.sqrt(@offset.x * @offset.x + @offset.z * @offset.z), @offset.y)

    @rotateLeft getAutoRotationAngle()  if @autoRotate

    theta += @thetaDelta
    phi += @phiDelta

    # restrict phi to be between desired limits
    phi = Math.max(@minPolarAngle, Math.min(@maxPolarAngle, phi))

    # restrict phi to be betwee EPS and PI-EPS
    phi = Math.max(EPS, Math.min(Math.PI - EPS, phi))

    radius = @offset.length() * @scale

    # restrict radius to be between desired limits
    radius = Math.max(@minDistance, Math.min(@maxDistance, radius))

    # move target to panned location
    @target.add @_pan

    @offset.x = radius * Math.sin(phi) * Math.sin(theta)
    @offset.y = radius * Math.cos(phi)
    @offset.z = radius * Math.sin(phi) * Math.cos(theta)

    # rotate offset back to "camera-up-vector-is-up" space
    @offset.applyQuaternion @quatInverse

    position.copy(@target).add @offset

    @object.lookAt @target

    @thetaDelta = 0
    @phiDelta = 0
    @scale = 1
    @_pan.set 0, 0, 0

    # update condition is:
    # min(camera displacement, camera rotation in radians)^2 > EPS
    # using small-angle approximation cos(x/2) = 1 - x^2 / 8
    if @lastPosition.distanceToSquared(@object.position) > EPS or 8 * (1 - @lastQuaternion.dot(@object.quaternion)) > EPS
      @dispatchEvent @changeEvent
      @lastPosition.copy @object.position
      @lastQuaternion.copy @object.quaternion

  reset: ->
    @state = STATE.NONE
    @target.copy @target0
    @object.position.copy @position0
    @update()

  constructor: (@object, @domElement=document) ->

    #//////////
    # internals

    scope = this

    @rotateStart = new THREE.Vector2()
    @rotateEnd = new THREE.Vector2()
    @rotateDelta = new THREE.Vector2()
    @forcedRotate = false

    @panStart = new THREE.Vector2()
    @panEnd = new THREE.Vector2()
    @panDelta = new THREE.Vector2()

    @panOffset = new THREE.Vector3()
    @offset = new THREE.Vector3()

    @dollyStart = new THREE.Vector2()
    @dollyEnd = new THREE.Vector2()
    @dollyDelta = new THREE.Vector2()

    @phiDelta = 0
    @thetaDelta = 0
    @scale = 1
    @_pan = new THREE.Vector3()

    @lastPosition = new THREE.Vector3()
    @lastQuaternion = new THREE.Quaternion()

    STATE =
      NONE: -1
      ROTATE: 0
      DOLLY: 1
      PAN: 2
      TOUCH_ROTATE: 3
      TOUCH_DOLLY: 4
      TOUCH_PAN: 5

    @state = STATE.NONE

    # for reset
    @target0 = @target.clone()
    @position0 = @object.position.clone()

    # so camera.up is the orbit axis
    @quat = new THREE.Quaternion().setFromUnitVectors(object.up, new THREE.Vector3(0, 1, 0))
    @quatInverse = @quat.clone().inverse()

    # events
    @changeEvent = type: "change"
    @startEvent = type: "start"
    @endEvent = type: "end"

    onMouseDown = (event) ->

      return  if scope.enabled is false

      event.preventDefault()

      # right click or left click + cmd/ctr: rotate
      if event.button is 2 or (event.button is 0 and (event.metaKey or event.ctrlKey))

        return  if scope.noRotate is true

        scope.state = STATE.ROTATE
        scope.rotateStart.set event.clientX, event.clientY

      else if event.button is 0 # left click: pan

        return  if scope.noPan is true

        scope.state = STATE.PAN
        scope.panStart.set event.clientX, event.clientY

      else if event.button is 1

        return  if scope.noZoom is true

        scope.state = STATE.DOLLY
        scope.dollyStart.set event.clientX, event.clientY

      document.addEventListener "mousemove", onMouseMove, false
      document.addEventListener "mouseup", onMouseUp, false
      scope.dispatchEvent scope.startEvent

    onMouseMove = (event) ->

      return  if scope.enabled is false

      event.preventDefault()
      element = (if scope.domElement is document then scope.domElement.body else scope.domElement)

      if scope.state is STATE.ROTATE

        if scope.forcedRotate is true and not (event.metaKey or event.ctrlKey)
          return  if scope.noPan is true

          scope.state = STATE.PAN
          scope.panStart.set event.clientX, event.clientY
          return

        return  if scope.noRotate is true

        scope.rotateEnd.set event.clientX, event.clientY
        scope.rotateDelta.subVectors scope.rotateEnd, scope.rotateStart

        # rotating across whole screen goes 360 degrees around
        scope.rotateLeft 2 * Math.PI * scope.rotateDelta.x / element.clientWidth * scope.rotateSpeedLeft

        # rotating up and down along whole screen attempts to go 360, but limited to 180
        scope.rotateUp 2 * Math.PI * scope.rotateDelta.y / element.clientHeight * scope.rotateSpeedUp
        scope.rotateStart.copy scope.rotateEnd

      else if scope.state is STATE.DOLLY

        return  if scope.noZoom is true

        scope.dollyEnd.set event.clientX, event.clientY
        scope.dollyDelta.subVectors scope.dollyEnd, scope.dollyStart

        if scope.dollyDelta.y > 0
          scope.dollyIn()
        else
          scope.dollyOut()

        scope.dollyStart.copy scope.dollyEnd

      else if scope.state is STATE.PAN

        if event.metaKey or event.ctrlKey
          return  if scope.noRotate is true

          scope.state = STATE.ROTATE
          scope.forcedRotate = true
          scope.rotateStart.set event.clientX, event.clientY
          return

        return  if scope.noPan is true

        scope.panEnd.set event.clientX, event.clientY
        scope.panDelta.subVectors scope.panEnd, scope.panStart
        scope.pan scope.panDelta.x * scope.panSpeed, scope.panDelta.y * scope.panSpeed
        scope.panStart.copy scope.panEnd

      scope.update()

    onMouseUp = -> # event

      return  if scope.enabled is false

      document.removeEventListener "mousemove", onMouseMove, false
      document.removeEventListener "mouseup", onMouseUp, false
      scope.dispatchEvent scope.endEvent
      scope.state = STATE.NONE

    onMouseWheel = (event) ->

      return  if scope.enabled is false or scope.noZoom is true

      event.preventDefault()
      event.stopPropagation()

      delta = 0

      if event.wheelDelta? # WebKit / Opera / Explorer 9
        delta = event.wheelDelta
      # Firefox
      else delta = -event.detail  if event.detail?

      if delta > 0
        scope.dollyOut()
      else
        scope.dollyIn()

      scope.update()
      scope.dispatchEvent scope.startEvent
      scope.dispatchEvent scope.endEvent

    onKeyDown = (event) ->
      return  if scope.enabled is false or scope.noKeys is true or scope.noPan is true

      switch event.keyCode

        when scope.keys.UP
          scope.pan 0, scope.keyPanSpeed
          scope.update()

        when scope.keys.BOTTOM
          scope.pan 0, -scope.keyPanSpeed
          scope.update()

        when scope.keys.LEFT
          scope.pan scope.keyPanSpeed, 0
          scope.update()

        when scope.keys.RIGHT
          scope.pan -scope.keyPanSpeed, 0
          scope.update()

    touchstart = (event) ->
      return  if scope.enabled is false

      switch event.touches.length

        when 1 # one-fingered touch: pan

          return  if scope.noPan is true

          scope.state = STATE.TOUCH_PAN
          scope.panStart.set event.touches[0].pageX, event.touches[0].pageY

        when 2 # two-fingered touch: dolly

          return  if scope.noZoom is true

          scope.state = STATE.TOUCH_DOLLY
          dx = event.touches[0].pageX - event.touches[1].pageX
          dy = event.touches[0].pageY - event.touches[1].pageY
          distance = Math.sqrt(dx * dx + dy * dy)
          scope.dollyStart.set 0, distance

        when 3 # three-fingered touch: rotate

          return  if scope.noRotate is true

          scope.state = STATE.TOUCH_ROTATE
          scope.rotateStart.set event.touches[0].pageX, event.touches[0].pageY

        else
          scope.state = STATE.NONE

      scope.dispatchEvent scope.startEvent

    touchmove = (event) ->
      return  if scope.enabled is false

      event.preventDefault()
      event.stopPropagation()

      element = (if scope.domElement is document then scope.domElement.body else scope.domElement)

      switch event.touches.length

        when 1 # one-fingered touch: pan

          return  if scope.noPan is true
          return  if scope.state isnt STATE.TOUCH_PAN

          scope.panEnd.set event.touches[0].pageX, event.touches[0].pageY
          scope.panDelta.subVectors scope.panEnd, scope.panStart

          scope.pan scope.panDelta.x, scope.panDelta.y

          scope.panStart.copy scope.panEnd

          scope.update()

        when 2 # two-fingered touch: dolly

          return  if scope.noZoom is true
          return  if scope.state isnt STATE.TOUCH_DOLLY

          dx = event.touches[0].pageX - event.touches[1].pageX
          dy = event.touches[0].pageY - event.touches[1].pageY
          distance = Math.sqrt(dx * dx + dy * dy)

          scope.dollyEnd.set 0, distance
          scope.dollyDelta.subVectors scope.dollyEnd, scope.dollyStart

          if scope.dollyDelta.y > 0
            scope.dollyOut()
          else
            scope.dollyIn()

          scope.dollyStart.copy scope.dollyEnd

          scope.update()

        when 3 # three-fingered touch: rotate

          return  if scope.noRotate is true
          return  if scope.state isnt STATE.TOUCH_ROTATE

          scope.rotateEnd.set event.touches[0].pageX, event.touches[0].pageY
          scope.rotateDelta.subVectors scope.rotateEnd, scope.rotateStart

          # rotating across whole screen goes 360 degrees around
          scope.rotateLeft 2 * Math.PI * scope.rotateDelta.x / element.clientWidth * scope.rotateSpeedLeft

          # rotating up and down along whole screen attempts to go 360, but limited to 180
          scope.rotateUp 2 * Math.PI * scope.rotateDelta.y / element.clientHeight * scope.rotateSpeedUp
          scope.rotateStart.copy scope.rotateEnd

          scope.update()

        else

          scope.state = STATE.NONE

    touchend = -> # event
      return  if scope.enabled is false

      scope.dispatchEvent scope.endEvent
      scope.state = STATE.NONE

    @domElement.addEventListener "contextmenu", ((e) -> e.preventDefault()), false
    @domElement.addEventListener "mousedown", onMouseDown, false
    @domElement.addEventListener "mousewheel", onMouseWheel, false
    @domElement.addEventListener "DOMMouseScroll", onMouseWheel, false # firefox

    @domElement.addEventListener "touchstart", touchstart, false
    @domElement.addEventListener "touchend", touchend, false
    @domElement.addEventListener "touchmove", touchmove, false

    window.addEventListener "keydown", onKeyDown, false

    # force an update at start
    @update()
