/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * Warning: This file is GENERATED, and should not be modified
 */
var bootstrap = kroll.NativeModule.require("bootstrap"),
	invoker = kroll.NativeModule.require("invoker"),
	Titanium = kroll.binding("Titanium").Titanium;

function moduleBootstrap(moduleBinding) {
	function lazyGet(object, binding, name, namespace) {
		return bootstrap.lazyGet(object, binding,
			name, namespace, moduleBinding.getBinding);
	}

	var module = moduleBinding.getBinding("ti.vrview.VrviewModule")["Vrview"];
	var invocationAPIs = module.invocationAPIs = [];
	module.apiName = "Vrview";

	function addInvocationAPI(module, moduleNamespace, namespace, api) {
		invocationAPIs.push({ namespace: namespace, api: api });
	}

	addInvocationAPI(module, "Vrview", "Vrview", "createPanoramaView");addInvocationAPI(module, "Vrview", "Vrview", "createVideoView");
		if (!("__propertiesDefined__" in module)) {Object.defineProperties(module, {
"PanoramaView": {
get: function() {
var PanoramaView =  lazyGet(this, "ti.vrview.PanoramaViewProxy", "PanoramaView", "PanoramaView");
return PanoramaView;
},
configurable: true
},
"VideoView": {
get: function() {
var VideoView =  lazyGet(this, "ti.vrview.VideoViewProxy", "VideoView", "VideoView");
return VideoView;
},
configurable: true
},

});
module.constructor.prototype.createPanoramaView = function() {
return new module["PanoramaView"](arguments);
}
module.constructor.prototype.createVideoView = function() {
return new module["VideoView"](arguments);
}
}
module.__propertiesDefined__ = true;
return module;

}
exports.bootstrap = moduleBootstrap;
