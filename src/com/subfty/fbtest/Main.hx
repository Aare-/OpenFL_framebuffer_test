package com.subfty.fbtest;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;

import openfl.display.OpenGLView;
import openfl.display.Bitmap;
import openfl.gl.GLFramebuffer;
import openfl.gl.GL;
import openfl.Lib;
import openfl.Assets;

import flash.display.StageAlign;
import flash.display.StageScaleMode;

/**
 *
 * ...
 * @author Filip Loster
 */

class Main extends Sprite {  
    public static var SCREEN_W : Float;
    public static var SCREEN_H : Float;    

    var dogeContainer : Sprite;
    var space : Bitmap;
    var doge : Bitmap;
    
    var renderFilter : RenderFilter;

    public static var screenBuffer : GLFramebuffer;

    override public function new(){     
        super();

        screenBuffer = new GLFramebuffer(GL.version, GL.getParameter(GL.FRAMEBUFFER_BINDING));        

        SCREEN_W = Lib.current.stage.stageWidth / 1.0;
        SCREEN_H = Lib.current.stage.stageHeight / 1.0;        

        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        Lib.current.stage.align = StageAlign.TOP_LEFT;                        

        renderFilter = new RenderFilter();

        space = new Bitmap(Assets.getBitmapData("img/space.jpg"));
        space.x = 0;
        space.y = 0;

        doge = new Bitmap(Assets.getBitmapData("img/test.jpeg"));
        doge.x = -263;
        doge.y = -264;        

        trace("siema!");

        dogeContainer = new Sprite();
        dogeContainer.addChild(doge);
        dogeContainer.scaleX = 0.35;
        dogeContainer.scaleY = 0.35;

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

        addChild(space);
        addChild(
            new OpenglViewWrapper(function(){
                renderFilter.begin();
                
            }));
        addChild(dogeContainer);
        addChild(
            new OpenglViewWrapper(function(){
                renderFilter.end();
                renderFilter.render();
            }));
    }
    
    var lastTick : Int;
    var totalDelta : Int = 0;
	function onEnterFrame(e : Event) {
        var tick = Lib.getTimer();
		var delta = tick - lastTick;
        lastTick += delta;

        totalDelta += delta;

        dogeContainer.x = Math.sin(totalDelta * 0.001) * 100 + SCREEN_W / 2;
        dogeContainer.y = Math.cos(totalDelta * 0.001) * 100 + SCREEN_H / 2;
        dogeContainer.rotation += Math.sin(totalDelta * 0.01) * Math.PI * 0.25;
        
	}
}
