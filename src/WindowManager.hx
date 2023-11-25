package;

import haxe.Json;
import js.Browser.*;
import js.Browser;
import js.html.*;
import js.lib.Object;

class WindowManager {
	var _windows:Array<WindowDataObj> = [];
	var _count:Int;
	var _id:Int;
	var _winData:WindowDataObj;
	var _winShapeChangeCallback:Dynamic;
	var _winChangeCallback:Dynamic;

	public function new() {
		trace('WindowManager');

		// event listener for when localStorage is changed from another window
		window.onstorage = (event:StorageEvent) -> {
			if (event.key == "windows") {
				var newWindows = Json.parse(event.newValue);
				var winChange = this._didWindowsChange(this._windows, newWindows);

				this._windows = newWindows;

				if (winChange) {
					if (this._winChangeCallback)
						this._winChangeCallback();
				}
			}
		};

		// event listener for when current window is about to ble closed
		window.addEventListener('beforeunload', function(e) {
			var index = this.getWindowIndexFromId(this._id);

			// remove this window from the list and update local storage
			this._windows.splice(index, 1);
			this.updateWindowsLocalStorage();
		});
	}

	// check if theres any changes to the window list
	function _didWindowsChange(pWins:Array<WindowDataObj>, nWins:Array<WindowDataObj>) {
		if (pWins.length != nWins.length) {
			return true;
		} else {
			var c = false;

			for (i in 0...pWins.length) {
				if (pWins[i].id != nWins[i].id)
					c = true;
			}
			return c;
		}
	}

	// initiate current window (add metadata for custom data to store with each window instance)
	public function init(metaData:{}) {
		this._windows = []; // default
		if (window.localStorage.getItem("windows") != null) {
			this._windows = Json.parse(window.localStorage.getItem("windows"));
		}
		this._count = 0; // default
		if (window.localStorage.getItem("count") != null) {
			this._count = Std.parseInt(window.localStorage.getItem("count"));
		}
		this._count++;
		this._id = this._count;
		var shape = this.getWinShape();
		this._winData = {id: this._id, shape: shape, metaData: metaData};
		this._windows.push(this._winData);
		window.localStorage.setItem("count", Std.string(this._count));
		this.updateWindowsLocalStorage();
	}

	function getWinShape():WindowShapeObj {
		var shape = {
			x: window.screenX,
			y: window.screenY,
			w: window.innerWidth,
			h: window.innerHeight
		};
		return shape;
	}

	function getWindowIndexFromId(id:Int):Int {
		var index = -1;

		for (i in 0...this._windows.length) {
			if (this._windows[i].id == id)
				index = i;
		}
		return index;
	}

	function updateWindowsLocalStorage() {
		window.localStorage.setItem("windows", Json.stringify(this._windows));
	}

	public function update() {
		// console.log(step);
		var winShape = this.getWinShape();
		// console.log(winShape.x, winShape.y);
		if (winShape.x != this._winData.shape.x || winShape.y != this._winData.shape.y || winShape.w != this._winData.shape.w
			|| winShape.h != this._winData.shape.h) {
			this._winData.shape = winShape;
			var index = this.getWindowIndexFromId(this._id);
			this._windows[index].shape = winShape;
			// console.log(windows);
			if (this._winShapeChangeCallback)
				this._winShapeChangeCallback();
			this.updateWindowsLocalStorage();
		}
	}

	public function setWinShapeChangeCallback(callback) {
		this._winShapeChangeCallback = callback;
	}

	public function setWinChangeCallback(callback) {
		this._winChangeCallback = callback;
	}

	public function getWindows() {
		return this._windows;
	}

	/**
	 * @example
	 * 	var windowData:WindowDataObj = this.windowManager.getThisWindowData();
	 * @return WindowDataObj
	 */
	public function getThisWindowData():WindowDataObj {
		return this._winData;
	}

	public function getThisWindowID() {
		return this._id;
	}
}

typedef WindowShapeObj = {
	var x:Dynamic;
	var y:Dynamic;
	var w:Dynamic;
	var h:Dynamic;
}

typedef WindowDataObj = {
	var id:Int;
	var shape:WindowShapeObj;
	var metaData:Dynamic;
}
