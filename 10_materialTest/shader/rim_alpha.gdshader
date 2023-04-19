//轮廓光效果
shader_type spatial;

varying vec3 cameraPos;//摄像机在世界空间的位置
varying vec3 fragNrm;//片元的法线
varying vec3 fragWorldPos;//片元的世界位置

uniform float rim = 2;//轮廓光的紧密度
uniform vec4 rimLightCol : hint_color = vec4(1, 1, 1, 1);
uniform vec4 albedo_color : hint_color = vec4(1, 1, 1, 1);//模型的基础颜色

void vertex()
{
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
        vec3 model_world_space = WORLD_MATRIX[3].xyz; 
        vec3 camera_world_space = CAMERA_MATRIX[3].xyz;
        fragWorldPos = model_world_space;
        cameraPos = camera_world_space;
        fragNrm = NORMAL;
}

void fragment()
{
        vec3 normal = normalize(fragNrm);
        vec3 toCam = normalize(cameraPos - fragWorldPos);
        
        float rimAmt = 1.0-max(0.0, dot(normal, toCam));
        rimAmt = pow(rimAmt, rim);
        

        
        vec4 rimCol = vec4(rimLightCol.rgb * rimAmt, 1.0);
        ALBEDO = albedo_color.rgb * rimCol.rgb;
        ALPHA = albedo_color.a;
}