#ifdef GL_ES
precision mediump float;
#endif
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
#define M_PI 3.141592653589793
// boxes by @hintz 2013-05-08
void main(void)
{
	vec2 position = (gl_FragCoord.xy - 0.5 * resolution.xy) / resolution.x;
	float a = 0.2*time*M_PI/3.0;
	float r = length(position);
	float c = cos(a);
	float s = sin(a);
	mat2 rotate = mat2(c,s,-s,c);
	vec2 q = sin(rotate*(position+tan(2.0*position*rotate*rotate))*3.0*(1.5+sin(time*0.5)/r));
	q=sqrt(abs(q)-0.1);
	vec3 color = vec3(length(position+q));
	color.rg += smoothstep(0.2,.0,abs(position.x));
	vec2 p2 = (position+q) * rotate;
	color.gb += smoothstep(0.2,.0,abs(p2.x));
	vec2 p3 = p2 * rotate;
	color.br += smoothstep(0.2,.0,abs(p3.x));
	vec2 p4 = p3 * rotate;
	color.rg += smoothstep(0.2,.0,abs(p4.x));
	vec2 p5 = p4 * rotate;
	color.gb += smoothstep(0.2,.0,abs(p5.x));
	vec2 p6 = p5 * rotate;
	color.br += smoothstep(0.2,.0,abs(p6.x));
	color.g *= abs(position.x);
	color.b *= abs(p2.x);
	color.r *= abs(p3.x);	
	color.xy *= rotate;
	color.yz *= rotate;
	color = abs(color);
	gl_FragColor = vec4(color*color.zxy, 1.0);
}
