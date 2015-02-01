package com.subfty.fbtest;

import openfl.Lib;

import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLRenderbuffer;
import openfl.gl.GLProgram;
import openfl.gl.GLTexture;
import openfl.gl.GLShader;

import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import openfl.gl.GLUniformLocation;
import openfl.utils.Float32Array;
import openfl.utils.UInt8Array;
import openfl.utils.UInt8Array;

/**
* ...
* @author fblost
*/
class RenderFilter {      
    var vertex_shader : String 
    = "
uniform mat4 projectionMatrix;

attribute vec2 aPos;
attribute vec4 aSize;

varying vec2 vTexCoord;

void main(){
    vTexCoord = vec2(aPos.x, 1.0 - aPos.y);
    gl_Position = projectionMatrix * 
                  vec4(aPos.x * aSize.z + aSize.x, 
                       aPos.y * aSize.w + aSize.y, 0., 1.);                    
}
";
    
    var fragment_shader : String = "
uniform sampler2D uSampler;

varying vec2 vTexCoord;

void main( void ) {     
     vec4 r = texture2D(uSampler, vTexCoord + vec2(0.01, 0.0));
     vec4 g = texture2D(uSampler, vTexCoord + vec2(0.0, 0.01));
     vec4 b = texture2D(uSampler, vTexCoord + vec2(0.01, 0.01));
     vec4 a = texture2D(uSampler, vTexCoord);

     gl_FragColor = vec4(r.r, g.g, b.b, a.a) + vec4(0.1, 0., 0., 0.);    
}


";

    public var vertexBuffer   : GLBuffer;

    public var framebuffer : GLFramebuffer;
    public var texture     : GLTexture;

    public var texWidth  : Int;
    public var texHeight : Int;        

    var shaderProgram : GLProgram;

    var texSamplerL : GLUniformLocation;
    var projMatrixL : GLUniformLocation;

    var projMatrix : Matrix3D;

    var aPos : Int;
    var aSize : Int;

    var srcRect : Rectangle;
    var targetRenderRect : Rectangle;
    var resRect : Rectangle;

    public function new() {                
        projMatrix = Matrix3D.create2D(0, 0);        
        projMatrix.append(Matrix3D.createOrtho (0,
                                                Main.SCREEN_W,
                                                Main.SCREEN_H,
                                                0, 1000, -1000));        

        targetRenderRect = new Rectangle(0, 0, Main.SCREEN_W, Main.SCREEN_H);                
        srcRect = new Rectangle(0, 0, Main.SCREEN_W, Main.SCREEN_H);
        resRect = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageWidth);

        shaderProgram = prepareShader();        

        setupBuffer();        
    }

    function prepareShader() {
        var prog = GL.createProgram();        

        GL.attachShader(prog, compileShader(vertex_shader, GL.VERTEX_SHADER));
        GL.attachShader(prog, compileShader(fragment_shader, GL.FRAGMENT_SHADER));
        GL.linkProgram(prog);

        if (GL.getProgramParameter(prog, GL.LINK_STATUS) == 0){
            var result = GL.getProgramInfoLog(prog);
            trace("error creating shader program with result: " + result);
            if (result!="")
                throw result;
        }

        texSamplerL = GL.getUniformLocation(prog, "texSampler");
        projMatrixL = GL.getUniformLocation(prog, "projectionMatrix");

        aPos = GL.getAttribLocation(prog, "aPos");
        aSize = GL.getAttribLocation(prog, "aSize");

        return prog;
    }

    function compileShader(source : String, type : Int) {            
        var shader = GL.createShader(type);

        GL.shaderSource(shader, source);
        GL.compileShader(shader);

        if (GL.getShaderParameter(shader, GL.COMPILE_STATUS) == 0){
            var err = GL.getShaderInfoLog(shader);
            trace("error creating shader with error: " + err);
            if (err!="")
                throw err;
        }

        return shader;
    }

    function setupBuffer(){        
        framebuffer = GL.createFramebuffer();
        GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);

        texture = GL.createTexture();
        GL.bindTexture(GL.TEXTURE_2D, texture);

        texWidth = 2;
        texHeight = 2;
        while(texWidth < Main.SCREEN_W || texHeight < Main.SCREEN_H) {
            texWidth *= 2;
            texHeight *= 2;        
        }        

        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA,
                      texWidth, texHeight,
                      0, GL.RGBA, GL.UNSIGNED_BYTE, null);

        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);
        
        GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, texture, 0);
        GL.bindFramebuffer( GL.FRAMEBUFFER, Main.screenBuffer);

        
        var vertices = [1, 1,
                        0, 1,
                        1, 0,
                        0, 0
                        ];

        vertexBuffer = GL.createBuffer ();
        GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);
        GL.bufferData (GL.ARRAY_BUFFER, new Float32Array (cast vertices), GL.STATIC_DRAW);
        GL.bindBuffer (GL.ARRAY_BUFFER, null);

        //GL.bindTexture(GL.TEXTURE_2D, null);
    }

	public inline function clear() {
		GL.bindFramebuffer(GL.FRAMEBUFFER, framebuffer);
        GL.clearColor(0.0, 0.0, 0.0, 0.0);
        GL.clear(GL.COLOR_BUFFER_BIT);
	}
	
    public inline function begin() {
        clear();

        GL.viewport(0, 0,
                    Std.int(Main.SCREEN_W),
                    Std.int(Main.SCREEN_H));
    }

    public inline function end(){
        GL.bindFramebuffer( GL.FRAMEBUFFER, Main.screenBuffer);
        GL.viewport(0, 0,
                    Std.int(Main.SCREEN_W),
                    Std.int(Main.SCREEN_H));

    }    

    public inline function render() {        
        GL.useProgram (shaderProgram);

        GL.uniformMatrix3D (projMatrixL, false, projMatrix);

        GL.uniform1i(texSamplerL, 0);
        GL.activeTexture(GL.TEXTURE0);
        GL.bindTexture (GL.TEXTURE_2D, texture);

        GL.bindBuffer (GL.ARRAY_BUFFER, vertexBuffer);

        GL.enableVertexAttribArray (aPos);
        GL.vertexAttribPointer (aPos, 2, GL.FLOAT, false, 0, 0);        
      
        var wScale : Float = texWidth / Main.SCREEN_W;
        var hScale : Float = texHeight / Main.SCREEN_H;
        GL.vertexAttrib4f(aSize,
                          0, -Main.SCREEN_H * (-1.0 + hScale),                          
                          Main.SCREEN_W * wScale, Main.SCREEN_H * hScale);        

        GL.drawArrays (GL.TRIANGLE_STRIP, 0, 4);

        GL.disableVertexAttribArray(aPos);
        GL.bindBuffer(GL.ARRAY_BUFFER, null);
        GL.bindTexture(GL.TEXTURE_2D, null); 
    }

    public function dispose(){
        GL.deleteBuffer(vertexBuffer);
        GL.deleteTexture(texture);
    }    
}