shader_type spatial;

varying vec3 world_position;
varying vec3 world_normal;
varying vec3 world_camera;

void vertex()
{
        world_position = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
        world_normal = (WORLD_MATRIX * vec4(NORMAL,0.0)).xyz;
        world_camera = (CAMERA_MATRIX * vec4(0, 0, 0, 1)).xyz;
}

void fragment(){
    vec2 uv =  world_position.xy;

    for(float i = 1.0; i < 10.0; i++){
        uv.x += 0.6 / i * cos(i * 2.5* uv.y + TIME);
        uv.y += 0.6 / i * cos(i * 1.5 * uv.x + TIME);
    }
    
    ALBEDO = vec3(0.1)/abs(sin(TIME-uv.y-uv.x));
}