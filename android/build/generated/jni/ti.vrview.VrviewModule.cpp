/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2011-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

/** This code is generated, do not edit by hand. **/

#include "ti.vrview.VrviewModule.h"

#include "AndroidUtil.h"
#include "JNIUtil.h"
#include "JSException.h"
#include "TypeConverter.h"
#include "V8Util.h"



#include "ti.vrview.PanoramaViewProxy.h"
#include "ti.vrview.VideoViewProxy.h"

#include "org.appcelerator.kroll.KrollModule.h"

#define TAG "VrviewModule"

using namespace v8;

namespace ti {
namespace vrview {


Persistent<FunctionTemplate> VrviewModule::proxyTemplate;
jclass VrviewModule::javaClass = NULL;

VrviewModule::VrviewModule() : titanium::Proxy()
{
}

void VrviewModule::bindProxy(Local<Object> exports, Local<Context> context)
{
	Isolate* isolate = context->GetIsolate();

	Local<FunctionTemplate> pt = getProxyTemplate(isolate);

	v8::TryCatch tryCatch(isolate);
	Local<Function> constructor;
	MaybeLocal<Function> maybeConstructor = pt->GetFunction(context);
	if (!maybeConstructor.ToLocal(&constructor)) {
		titanium::V8Util::fatalException(isolate, tryCatch);
		return;
	}

	Local<String> nameSymbol = NEW_SYMBOL(isolate, "Vrview"); // use symbol over string for efficiency
	MaybeLocal<Object> maybeInstance = constructor->NewInstance(context);
	Local<Object> moduleInstance;
	if (!maybeInstance.ToLocal(&moduleInstance)) {
		titanium::V8Util::fatalException(isolate, tryCatch);
		return;
	}
	exports->Set(nameSymbol, moduleInstance);
}

void VrviewModule::dispose(Isolate* isolate)
{
	LOGD(TAG, "dispose()");
	if (!proxyTemplate.IsEmpty()) {
		proxyTemplate.Reset();
	}

	titanium::KrollModule::dispose(isolate);
}

Local<FunctionTemplate> VrviewModule::getProxyTemplate(Isolate* isolate)
{
	if (!proxyTemplate.IsEmpty()) {
		return proxyTemplate.Get(isolate);
	}

	LOGD(TAG, "VrviewModule::getProxyTemplate()");

	javaClass = titanium::JNIUtil::findClass("ti/vrview/VrviewModule");
	EscapableHandleScope scope(isolate);

	// use symbol over string for efficiency
	Local<String> nameSymbol = NEW_SYMBOL(isolate, "Vrview");

	Local<FunctionTemplate> t = titanium::Proxy::inheritProxyTemplate(isolate,
		titanium::KrollModule::getProxyTemplate(isolate)
, javaClass, nameSymbol);

	proxyTemplate.Reset(isolate, t);
	t->Set(titanium::Proxy::inheritSymbol.Get(isolate),
		FunctionTemplate::New(isolate, titanium::Proxy::inherit<VrviewModule>));

	// Method bindings --------------------------------------------------------

	Local<ObjectTemplate> prototypeTemplate = t->PrototypeTemplate();
	Local<ObjectTemplate> instanceTemplate = t->InstanceTemplate();

	// Delegate indexed property get and set to the Java proxy.
	instanceTemplate->SetIndexedPropertyHandler(titanium::Proxy::getIndexedProperty,
		titanium::Proxy::setIndexedProperty);

	// Constants --------------------------------------------------------------
	JNIEnv *env = titanium::JNIScope::getEnv();
	if (!env) {
		LOGE(TAG, "Failed to get environment in VrviewModule");
		//return;
	}


			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "TYPE_MONO", 1);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "FORMAT_DEFAULT", 1);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "SENSOR_DELAY_NORMAL", 3);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "SENSOR_DELAY_FASTEST", 0);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "TYPE_STEREO_OVER_UNDER", 2);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "SENSOR_DELAY_GAME", 1);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "FORMAT_HLS", 2);

			DEFINE_INT_CONSTANT(isolate, prototypeTemplate, "SENSOR_DELAY_UI", 2);


	// Dynamic properties -----------------------------------------------------

	// Accessors --------------------------------------------------------------

	return scope.Escape(t);
}

// Methods --------------------------------------------------------------------

// Dynamic property accessors -------------------------------------------------


} // vrview
} // ti
