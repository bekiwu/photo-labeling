#====== @IMPORT ======#


labelframerLayers = Framer.Importer.load "imported/labelFramer"

HammerEvents =
	
	Tap: "tap"
	DoubleTap: "doubletap"
	Hold: "hold"
	Touch: "touch"
	Release: "release"
	Gesture: "gesture"

	Swipe: "swipe"
	SwipeUp: "swipeup"
	SwipeDown: "swipedown"
	SwipeLeft: "swipeleft"
	SwipeRight: "swiperight"
	
	Transform: "transform"
	TransformStart: "transformstart"
	TransformEnd: "transformend"

	Rotate: "rotate"

	Pinch: "pinch"
	PinchIn: "pinchin"
	PinchOut: "pinchout"

# Add the Hammer events to the base Framer events
window.Events = _.extend Events, HammerEvents

# Patch the on method on layers to listen to Hammer events
class HammerLayer extends Framer.Layer
	
	on: (eventName, f) ->
		
		if eventName in _.values(HammerEvents)
			@ignoreEvents = false			
			hammer = Hammer(@_element).on eventName, f
		
		else
			super eventName, f

# Replace the default Layer with the HammerLayer
window.Layer = HammerLayer





#====== @VARIABLES ======#


tagEmptyLayer = labelframerLayers.tagEmpty
pic1Layer = labelframerLayers.pic
tabBarLayer = labelframerLayers.tabBar
topBarLayer = labelframerLayers.topBar
keyboardLayer = labelframerLayers.keyboard

# Fixing a very weired bug of Framer when using Hammer
picLayer = new Layer
	x: pic1Layer.x
	y: pic1Layer.y
	width: pic1Layer.width
	height: pic1Layer.height

pic1Layer.superLayer = picLayer
pic1Layer.x = 0
pic1Layer.y = 0

topBarLayer.bringToFront()
tabBarLayer.bringToFront()
keyboardLayer.bringToFront()

tagHeight = 66
deviceWidth = 750
deviceHeight = 1334

# Tag intial width before expansion
tagInitWidth = 120
tagHeight = 66
tagWidth  = 234
tagPinX   = 30
tagPinY   = 60
tagPinMaxYRight = deviceWidth - tagPinY

green = '#04be02'
black70 = 'rgba(0,0,0,.7)'
keyboardBtnColor = '#3a3b3c'





#====== @GLOBAL INTIAL SETTINGS ======#


bg = new BackgroundLayer
	backgroundColor: '#000'

# Hide layers
tagEmptyLayer.visible = keyboardLayer.visible = false
keyboardLayer.y = deviceHeight

tag = new Layer
	width: tagInitWidth
	height: tagHeight
	borderRadius: tagHeight / 2
	superLayer: picLayer
	backgroundColor: black70
	visible: false
	rotation: -5

tagText = new Layer
	x: 30
	y: 19
	width: tagWidth
	height: 28
	backgroundColor: 'transparent'
	color: 'rgba(255, 255, 255, .2)'
	superLayer: tag
	visible: false

tagTextBorderStyle = '3px solid ' + green
tagText.style.borderLeft = tagTextBorderStyle
tagText.style.fontSize = '28px'

tagText.html = '添加标注'

# White dot in tag	
dot = new Layer
	x: 16
	y: 28
	width: 10
	height: 10
	backgroundColor: '#fff'
	borderRadius: '50%'
	superLayer: tag
	scale: 0

# Keyboard button on bottom right
keyboardBtn = new Layer
	x: 569
	y: 412
	color: '#fff'
	width: 175
	height: 84
	borderRadius: 10
	backgroundColor: keyboardBtnColor
	superLayer: keyboardLayer
	
keyboardBtn.style.fontSize = '32px'
keyboardBtn.style.lineHeight = '84px'
keyboardBtn.style.textAlign = 'center'
keyboardBtn.html = '完成'





#====== @PIC HOLD EVENT ======#

touchX = 0
touchY = 0

animationShake = new Animation
	layer: tag
	properties:
		rotation: 5
	time: 0.2
	repeat: 99999

picLayer.on Events.Hold, (event) ->
	
	touchX = event.gesture.srcEvent.offsetX
	touchY = event.gesture.srcEvent.offsetY
	
	tag.x = touchX
	tag.y = touchY
	tag.visible = true
	animationShake.start()
	
	



#====== @PIC RELEASE EVENT ======#



picLayerInitX = picLayer.x
picLayerInitY = picLayer.y
picLayerInitOriginX = picLayer.originX
picLayerInitOriginY = picLayer.originY

picLayer.on Events.Release, (event) ->
	
	tabBarLayer.visible = topBarLayer.visible = false
	
	touchX = event.gesture.srcEvent.offsetX
	touchY = event.gesture.srcEvent.offsetY
	
	distanceX = tagPinX - touchX
	distanceY = tagPinY - touchY - picLayerInitY
	
	animationShake.stop()
	tag.rotation = 0
	
	# @TODO Add other conditions when tagging in different part of the pic
	if touchY <= picLayer.height / 2
		if touchX <= picLayer.width / 2
		
			tag.superLayer = false
			
			tagAnimation = 
			tag.animate
				properties:
					x: tagPinX
					y: tagPinY
				curve: 'spring'
				curveOptions:
					velocity: 10
					friction: 20
					tension: 200
				time: 0.15
			
			movedX = picLayerInitX + distanceX
			movedY = picLayerInitY + distanceY		
			
			if picLayer.height >= picLayer.width

				picLayer.originX = (Math.abs(movedX) + tagPinX) / picLayer.width
				picLayer.originY = (Math.abs(movedY) + tagPinY) / picLayer.height
				scale = (deviceHeight + Math.abs(movedY)*3) / picLayer.height				
				picAnimation = 
				picLayer.animate
					properties:
						x: movedX
						y: movedY
						scale: scale
					curve: 'spring'
					curveOptions:
						velocity: 10
						friction: 20
						tension: 200
					time: 0.3
				
				Utils.delay 0.3, ->
					tagExpandAnimation = 
					tag.animate
						properties:
							width: 234
						time: 0.2
						
					tagEmptyLayer.visible = true
					tagEmptyLayer.superLayer = tag
					tagEmptyLayer.x = 30
					tagEmptyLayer.y = 16
					
					tagEmptyLayer.animate
						properties:
							x: 185
							rotation: 180
						time: 0.2
						
					keyboardLayer.visible = true
					keyboardLayer.animate
						properties:
							y: deviceHeight - keyboardLayer.height
						curve: 'spring'
						curveOptions:
							velocity: 10
							friction: 20
							tension: 100
						time: 0.1
						
					tagText.visible = true
					
					picLayer.ignoreEvents = true

						


						
#====== @CONSTRUCTING SUGGESTION PANEL ======#


itemHeight = 80
itemWidth = 630

listItem = [
	[name: '小黄人大电影', category: '电影']
	[name: '小黄人餐厅', category: '地理位置']
	[name: '小黄猫低价甩卖', category: '商品']
	]
	
listItemAnimations = []

suggestPanel = new Layer
	width: 690
	height: itemHeight * listItem.length
	borderRadius: 6
	backgroundColor: 'rgba(0, 0, 0, .7)'
	opacity: 0

for item, i in listItem
	itemLayer = new Layer
		y: -itemHeight
		height: itemHeight
		width: itemWidth
		backgroundColor: 'transparent'
		superLayer: suggestPanel
	
	if i < listItem.length
		itemLayer.style.borderBottom = '1px solid rgba(255, 255, 255, .1)'
	
	itemLayer.centerX()
	
	itemNameLayer = new Layer
		color: '#fff'
		height: itemHeight
		width: itemWidth
		backgroundColor: 'transparent'
		superLayer: itemLayer
	itemNameLayer.style.lineHeight = itemHeight + 'px'
	itemNameLayer.style.fontSize = '28px'
	itemNameLayer.html = item[0].name
	
	itemCategoryLayer = new Layer
		color: 'rgba(255, 255, 255, .2)'
		height: itemHeight
		width: itemWidth
		backgroundColor: 'transparent'
		superLayer: itemLayer		
	itemCategoryLayer.style.lineHeight = itemHeight + 'px'
	itemCategoryLayer.style.textAlign = 'right'
	itemNameLayer.style.fontSize = '26px'
	itemCategoryLayer.html = item[0].category
	
	itemAnimation = new Animation
		layer: itemLayer
		properties:
			y: i * itemHeight
		time: 0.2
		
	listItemAnimations[i] = itemAnimation
	




#====== @KEYBOARD EVENT ======#


keyboardLayer.on Events.Click, ->
	
	tagText.html = '小黄'
	tagText.color = '#fff'
	tagText.width = 60
	tagText.style.borderLeft = 'none'
	tagText.style.borderRight = tagTextBorderStyle
	
	suggestPanel.x = tag.x
	suggestPanel.y = tag.y
	
	Utils.delay 0.2, ->
		
		# Animate y and opacity seperately
		suggestPanelAnimation =
		suggestPanel.animate
			properties:
				y: tag.maxY + 10
			curve: 'spring'
			curveOptions:
				velocity: 10
				friction: 15
				tension: 300
			time: 0.2
			
		suggestPanel.animate
			properties:
				opacity: 1
			time: 0.2
		
		for animation in listItemAnimations
			animation.start()
				
		keyboardBtn.backgroundColor = green
			
	keyboardLayer.ignoreEvents = true





#====== @CLOSING TAG ======#


tagEmptyLayer.on Events.Click, ->
	
	# Prevent animation conflict
	tagEmptyLayer.animateStop()
	picLayer.animateStop()
	keyboardLayer.animateStop()
	
	tagCloseAnimation = 
	tagEmptyLayer.animate
		properties:
			rotation: 0
			x: 30
		time: 0.2
	
	# Reset pic
	picLayer.animate
		properties:
			x: picLayerInitX
			y: picLayerInitY
			scale: 1
		curve: 'spring'
		curveOptions:
			velocity: 10
			friction: 20
			tension: 200
		time: 0.1
	
	picLayer.originX = picLayerInitOriginX
	picLayer.originY = picLayerInitOriginY
	picLayer.ignoreEvents = false
	
	# Reset keyboard	
	keyboardLayer.animate
		properties:
			y: deviceHeight
		curve: 'spring'
		curveOptions:
			velocity: 10
			friction: 20
			tension: 100
		time: 0.1
	
	# Reset other components
	tagCloseAnimation.on 'stop', ->
		tagEmptyLayer.visible = false
		
		tag.visible = false
		tag.width = tagInitWidth
		tag.superLayer = picLayer
		
		tagText.visible = false
		tagText.width = tagWidth
		tagText.style.borderLeft = tagTextBorderStyle
		tagText.style.borderRight = 'none'
		
		topBarLayer.visible = tabBarLayer.visible = true
		
		
				
			
#====== @FINISHING TAG ======#

tagOffset = 60

keyboardBtn.on Events.Click, ->
	
	# Prevent animation conflict
	tagEmptyLayer.animateStop()
	suggestPanel.animateStop()
	tagText.animateStop()
	keyboardLayer.animateStop()
	
	tagEmptyLayer.animate
		properties:
			rotation: 360
			x: tagEmptyLayer.x + tagOffset
		time: 0.2
		
	suggestPanel.animate
		properties:
			y: tag.y
			opacity: 0
		time: 0.2
		
	
	# Move tagText
	tagTextOffsetAnimation = 
	tagText.animate
		properties:
			x: tagText.x + tagOffset / 2
		time: 0.2
	
	tagTextOffsetAnimation.on 'stop', ->
		dotAnimation =
		dot.animate
			properties:
				scale: 1
			curve: 'spring'
			curveOptions:
				velocity: 10
				friction: 20
				tension: 100
			time: 0.1
		
		tagText.html = '小黄'
		tagText.style.border = '0'
		tagText.width = tagWidth
			
		tagEmptyLayer.visible = false
	
	# Reset keyboard	
	keyboardLayer.animate
		properties:
			y: deviceHeight
		curve: 'spring'
		curveOptions:
			velocity: 10
			friction: 20
			tension: 100
		time: 0.1
		
	keyboardBtn.backgroundColor = keyboardBtnColor
	
	# Reset pic
	picLayerAnimation = 
	picLayer.animate
		properties:
			x: picLayerInitX
			y: picLayerInitY
			scale: 1
		curve: 'spring'
		curveOptions:
			velocity: 10
			friction: 20
			tension: 200
		time: 0.1
		
	tag.animate
		properties:
			x: touchX
			y: touchY
			width: 160
		time: 0.1
	
	Utils.delay 0.12, ->
		tag.superLayer = picLayer
		topBarLayer.visible = tabBarLayer.visible = true
	
	