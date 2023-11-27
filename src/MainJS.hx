package;

import WindowManager.WindowDataObj;
import haxe.Log;
import js.Browser.*;
import js.html.*;

class MainJS {
	// final t = THREE;
	// var camera, scene, renderer, world;
	// var near, far;
	// var pixR = window.devicePixelRatio ? window.devicePixelRatio : 1;
	// var cubes = [];
	var sceneOffsetTarget = {x: 0.0, y: 0.0};
	var sceneOffset = {x: 0.0, y: 0.0};

	var windowManager:WindowManager;
	var initialized = false;

	var today:Float = Date.now().getTime();
	var internalTime:Float; // = getTime();

	public function new() {
		document.addEventListener("DOMContentLoaded", (event) -> {
			if (new URLSearchParams(window.location.search).get("clear") != null) {
				window.localStorage.clear();
			} else {
				// this code is essential to circumvent that some browsers preload the content
				// of some pages before you actually hit the url
				document.onvisibilitychange = () -> {
					if (document.visibilityState != VisibilityState.HIDDEN && !initialized) {
						init();
					}
				};
				window.onload = () -> {
					if (document.visibilityState != VisibilityState.HIDDEN) {
						init();
					}
				};
			}
		});
	}

	function init() {
		// setup syncing date
		var now:Date = Date.now();
		today = new Date(now.getFullYear(), now.getMonth(), now.getDay(), 0, 0, 0).getTime();
		internalTime = getTime();

		// done initializing?
		initialized = true;

		// add a short timeout because window.offsetX reports wrong values before a short period
		window.setTimeout(() -> {
			setupScene();
			setupWindowManager();
			resize();
			updateWindowShape(false);
			render(null);
			window.onresize = resize;
		}, 500);
	}

	function setupScene() {
		console.log('setupScene');

		var div = document.createDirectoryElement();
		div.classList.add('container');
		div.id = 'wrapper';

		var img = document.createImageElement();
		img.src = 'img/logo_rawworks_text.webp';

		var w = window.outerWidth;
		var h = window.outerHeight;

		// // Display the dimensions
		console.log('Screen outerWidth: ' + w + 'px');
		console.log('Screen outerHeight: ' + h + 'px');

		// Get the width and height of the screen
		var screenWidth = window.screen.width;
		var screenHeight = window.screen.height;

		// // Display the dimensions
		console.log('Screen width: ' + screenWidth + 'px');
		console.log('Screen height: ' + screenHeight + 'px');

		// Get the available width and height of the screen
		var availableScreenWidth = window.screen.availWidth;
		var availableScreenHeight = window.screen.availHeight;

		// Display the available width and height
		console.log("Available Screen Width: " + availableScreenWidth);
		console.log("Available Screen Height: " + availableScreenHeight);

		div.style.width = availableScreenWidth + 'px';
		div.style.height = availableScreenHeight + 'px';

		div.style.border = '1px solid green';
		div.style.position = 'absolute';
		// div.style.left = '${200}px';

		div.appendChild(img);

		document.body.appendChild(div);
	}

	function setupWindowManager() {
		console.log('setupWindowManager');

		windowManager = new WindowManager();
		windowManager.setWinShapeChangeCallback(updateWindowShape);
		windowManager.setWinChangeCallback(windowsUpdated);

		// here you can add your custom metadata to each windows instance
		var metaData = {foo: "bar"};

		// this will init the windowmanager and add this window to the centralised pool of windows
		windowManager.init(metaData);

		// call update windows initially (it will later be called by the win change callback)
		// windowsUpdated();
	}

	function windowsUpdated() {}

	function updateWindowShape(easing = true) {
		console.log('updateWindowShape');
		// storing the actual offset in a proxy that we update against in the render function
		sceneOffsetTarget = {
			x: -window.screenX,
			y: -window.screenY
		};
		if (!easing)
			sceneOffset = sceneOffsetTarget;
	}

	function render(fl:Float):Void {
		var t = getTime();

		windowManager.update();

		// console.log('x');
		// console.log(this.windowManager.getThisWindowID());
		// console.log(this.windowManager.getThisWindowData());

		var windowData:WindowDataObj = this.windowManager.getThisWindowData();

		var div = document.getElementById('wrapper');
		// console.info(div);
		div.style.left = '${windowData.shape.x * -1}px';
		div.style.top = '${windowData.shape.y*-1}px';

		window.requestAnimationFrame(render);
	}

	// resize the renderer to fit the window size
	function resize() {
		console.log('resize');
		var width = window.innerWidth;
		var height = window.innerHeight;
	}

	// ____________________________________ tools ____________________________________

	/**
	 * get time in seconds since beginning of the day
	 * (so that all windows use the same time)
	 */
	function getTime():Float {
		return (Date.now().getTime() - this.today) / 1000.0;
	}

	// ____________________________________ main ____________________________________

	static public function main() {
		var app = new MainJS();
	}
}
