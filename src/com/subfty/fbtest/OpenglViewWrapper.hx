package com.subfty.fbtest;

import openfl.display.OpenGLView;
import flash.geom.Rectangle;

class OpenglViewWrapper extends OpenGLView {
    public var renderFunc : Void -> Void;

    public function new(renderFunc : Void -> Void) {
        super();
        this.renderFunc = renderFunc;
    }

    override public dynamic function render(rect : Rectangle) : Void {
        renderFunc();
    }
}
