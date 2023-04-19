shader_type spatial;
render_mode vertex_lighting,diffuse_lambert, cull_back, depth_draw_always, specular_disabled;
//基于顶点着色的光照效果，漫反射，背面剔除，总是深度测试，不开启高光反射


uniform float _rim_size : hint_range(0,8) = 1.0;
uniform vec4 base_color : hint_color = vec4(1, 1, 1, 1);

void fragment() {
 ALBEDO = base_color.rgb;
}


void light() {
 float NdotL = max(0.0, dot(NORMAL, LIGHT)) * ATTENUATION.x;
        
 float rimDot = max(0.0, dot(VIEW, NORMAL));
 float rim = pow(1.0 - rimDot, _rim_size);
       
 DIFFUSE_LIGHT = (NdotL + rim) * base_color.rgb;

}