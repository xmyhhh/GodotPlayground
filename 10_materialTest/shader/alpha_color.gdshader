shader_type spatial;
render_mode vertex_lighting, cull_back, diffuse_lambert, depth_draw_always;
//背面剔除，对透明几何体进行不透明的深度预传，不开启高光反射, 不接收光照
uniform vec4 base_color : hint_color;
uniform float _rim_size : hint_range(0,8) = 1.0;
varying float alpha;

void vertex() {
        alpha = base_color.a;
}

void fragment() {
        ALBEDO = base_color.rgb;
        ALPHA = alpha;
}

void light() {
 float NdotL = max(0.0, dot(NORMAL, LIGHT)) * ATTENUATION.x;
        
 float rimDot = max(0.0, dot(VIEW, NORMAL));
 float rim = pow(1.0 - rimDot, _rim_size);
       
 DIFFUSE_LIGHT = (NdotL + rim) * base_color.rgb;

}