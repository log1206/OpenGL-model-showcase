#version 330

in vec2 texCoord;

in vec3 vertex_color;
in vec3 vertex_normal;
in vec3 FragPos;

uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;
uniform int light_mode; // three light mode
uniform vec3 diffusion_intensity; //three light diffusion intensity
uniform float shininess; //three light shininess
uniform vec3 light_position; //three light position
uniform float cutoff; //spot light cutoff
uniform int permode;


#define M_PI 3.1415926535897932384626433832795

out vec4 fragColor;

// [TODO] passing texture from main.cpp
// Hint: sampler2D

uniform sampler2D text;

void main() {
	//fragColor = vec4(texCoord.xy, 0, 1);
	fragColor =  texture(text, texCoord) * vec4(vertex_normal, 1);
	// [TODO] sampleing from texture
	// Hint: texture

	vec3 pos = vec3(FragPos.x, FragPos.y, FragPos.z);

	if(permode == 0 ){

	float spot_effect =1; //for spot light effect
	int exponent =50; //for spot light cutoff 
	float f=1;// attenuation
	
	vec3 ambient_intensity = vec3(0.15,0.15,0.15);
	vec3 specular_intensity = vec3(1,1,1);
	
	vec3 direction; //i change it by hand light direction
	vec3 camera_position = vec3(0,0,2); //in this assignment camera is fixed. later to revise
	
	//calculate f attenuation
	float d = length(pos-light_position);
	if(light_mode == 1){ //direction
		f = 1;
	}
	else if(light_mode == 2){ //position
	float c =2/(0.01+0.8*d+0.1*d*d);
		f = min(1,c);
	}
	else if(light_mode == 3){ //spot
		float c =5/(0.05+0.3*d+0.6*d*d);
		
			f = min(1,c);
			
	}

	//calculate for light direction
	if(light_mode == 1){
		direction = -light_position;
	}
	if(light_mode == 2){
		direction = pos - light_position;
	}
	if(light_mode == 3){
		direction =  vec3(0,0,-1);
	}
	direction = normalize(direction);

	//ambient light
	vec3 ambient_light = ambient_intensity*ka;
	
	// specular use halfway and specular light
	vec3 view_vec = pos- camera_position  ;
	vec3 halfway = normalize(-view_vec - direction);
	vec3 specular_light = f*specular_intensity*ks*pow(dot(halfway, vertex_normal), shininess);

	// diffusion light
	vec3 diffusion_light = f*diffusion_intensity*kd*dot(-direction, vertex_normal) ;

	//spotlight effect
	
	if(light_mode ==3){
		float s =dot(normalize(pos - light_position), normalize(direction));
		if( acos(s)*180/M_PI  > cutoff){
			spot_effect =0;
		}
		else{
				spot_effect = pow(max(s,0),exponent);
		}
	}
	
	vec3 temp =  ambient_light + spot_effect*( diffusion_light + specular_light);
	
	fragColor = texture(text, texCoord) * vec4(temp.x,temp.y,temp.z,1.0);
	}
}
