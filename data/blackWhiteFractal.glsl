#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
varying vec2 surfacePosition;

void main( void ) {

	vec4 p = vec4(surfacePosition, 0.0, 0.0);
	vec4 c = vec4(-1.0+2.0*mouse, 1.0, 1.0);
	
	float color = 999.0;
	for (int i = 0; i < 200; i++) {
		p = vec4(p.x*p.x - p.y*p.y + c.x, 2.0*p.x*p.y + c.y, 
			 2.0*p.x*p.z - 2.0*p.y*p.w + c.z, 2.0*p.x*p.w + 2.0*p.y*p.z + c.w);
		color = min(color, length(p.xy)/length(p.zw));
	}

	gl_FragColor = vec4( pow(color, 0.25) );

}
