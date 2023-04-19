shader_type spatial;
render_mode vertex_lighting,diffuse_lambert,cull_back,depth_draw_always,specular_disabled;

uniform float time_scale :hint_range(0.0, 5.0) = 1.8;
uniform float pivot:hint_range(0.0, 10.0) = 3;
uniform float wave:hint_range(0.0, 1.0) = 0.5;
uniform float twist:hint_range(0.0, 1.0) = 0.3;
uniform float mask_black:hint_range(0.0, 1.0)= 0.2;
uniform float mask_white:hint_range(0.0, 1.0) = 0.8;

uniform sampler2D basic_tex;
uniform float _rim_size : hint_range(0,8) = 5.0;

void vertex()
{
	//time_scale is a uniform float
	float time = TIME * time_scale;
	//angle is scaled by 0.1 so that the fish only pivots and doesn't rotate all the way around
	//pivot is a uniform float
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	VERTEX.xz = rotation_matrix * VERTEX.xz;
	float body = (VERTEX.z + 1.0) / 2.0; //for a fish centered at (0, 0) with a length of 2
	//wave is a uniform float
	VERTEX.x += cos(time + body) * wave;
	//twist is a uniform float
	float twist_angle = cos(time + body) * 0.3 * twist;
	mat2 twist_matrix = mat2(vec2(cos(twist_angle), -sin(twist_angle)), vec2(sin(twist_angle), cos(twist_angle)));
	VERTEX.xy = twist_matrix * VERTEX.xy;
	//mask_black and mask_white are uniforms
	float mask = smoothstep(mask_black, mask_white, 1.0 - body);
	//wave motion with mask
	VERTEX.x += cos(time + body) * mask * wave;
	//twist motion with mask
	VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, mask);
}

void fragment() {
 ALBEDO = texture(basic_tex, UV.xy).rgb ;
}


void light() {
 float NdotL = max(0.0, dot(NORMAL, LIGHT)) * ATTENUATION.x;

 float rimDot = max(0.0, dot(VIEW, NORMAL));
 float rim = pow(1.0 - rimDot, _rim_size);

 DIFFUSE_LIGHT = ALBEDO.rgb * (NdotL + rim);

}
