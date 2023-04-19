shader_type spatial;
render_mode vertex_lighting,diffuse_lambert,cull_back,depth_draw_always,specular_disabled;
//基于顶点着色的光照，漫反射，背面剔除，仅绘制不透明几何体的深度(不透明)，关闭高光反射效果

uniform float _rim_size : hint_range(0,8) = 5.0;
uniform sampler2D texture : hint_albedo;

void fragment() {
 vec3 temp_albedo = texture(texture, UV.xy).rgb;

 ALBEDO = temp_albedo;
}


void light() {
 float NdotL = max(0.0, dot(NORMAL, LIGHT)) * ATTENUATION.x;

 float rimDot = max(0.0, dot(VIEW, NORMAL));
 float rim = pow(1.0 - rimDot, _rim_size);

 DIFFUSE_LIGHT = ALBEDO.rgb * (NdotL + rim);

}