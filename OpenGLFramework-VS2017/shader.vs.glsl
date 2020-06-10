#version 330

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;
layout (location = 3) in vec2 aTexCoord;

out vec2 texCoord;

out vec3 vertex_color;
out vec3 vertex_normal;
out vec3 FragPos;

uniform mat4 um4p;	// projection matrix
uniform mat4 um4v;	// camera viewing transformation matrix
uniform mat4 um4m;	// rotation matrix

// material
uniform vec3 ka;
uniform vec3 kd;
uniform vec3 ks;


uniform int light_mode; // three light mode
uniform vec3 diffusion_intensity; //three light diffusion intensity
uniform float shininess; //three light shininess
uniform vec3 light_position; //three light position
uniform float cutoff; //spot light cutoff
uniform int permode;

uniform int textureLoc;

#define M_PI 3.1415926535897932384626433832795

void main() 
{
	texCoord = aTexCoord;
	gl_Position = um4p * um4v * um4m * vec4(aPos, 1.0);

	vec4 temp;
	mat4 mvp_n;
	vec3 normal_v;
	vec3 tPos;
	mat4 nmvp;

	nmvp = um4m * um4v;

	//position
	vertex_color = aColor;
	

	temp = nmvp*vec4(aPos.x, aPos.y, aPos.z, 1.0);
	FragPos =  vec3(temp.x,temp.y,temp.z);

	tPos = vec3(temp.x,temp.y,temp.z);
	// calculate for normal vector

	mvp_n = inverse(nmvp);
	mvp_n = transpose(mvp_n);
	temp = mvp_n*vec4(aNormal.x,aNormal.y,aNormal.z,0.0);
	normal_v = vec3(temp.x,temp.y,temp.z); 
	normal_v =normalize(normal_v);

	vertex_normal = normal_v;

	//temp = nmvp* vec4(light_position.x, light_position.y, light_position.z, 0.0);
	//vec3 light_position_r = vec3(temp.x,temp.y,temp.z);

	if(permode ==1 ){

	float spot_effect =1; //for spot light effect
	int exponent =50; //for spot light cutoff 
	float f=1;// attenuation
	
	vec3 ambient_intensity = vec3(0.15,0.15,0.15);
	vec3 specular_intensity = vec3(1,1,1);
	
	vec3 direction; //i change it by hand light direction
	vec3 camera_position = vec3(0,0,2); //in this assignment camera is fixed. later to revise
	
	//calculate f attenuation
	float d = length(tPos-light_position);
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
		direction =tPos - light_position;
	}
	if(light_mode == 3){
		direction =  vec3(0,0,-1);
	}
	direction = normalize(direction);

	//ambient light
	vec3 ambient_light = ambient_intensity*ka;
	
	// specular use halfway and specular light
	vec3 view_vec =tPos- camera_position  ;
	vec3 halfway = normalize(-view_vec - direction);
	vec3 specular_light = f*specular_intensity*ks*pow(dot(halfway, normal_v), shininess);

	// diffusion light
	vec3 diffusion_light = f*diffusion_intensity*kd*dot(-direction,normal_v) ;

	//spotlight effect
	
	if(light_mode ==3){
		float s =dot(normalize(tPos - light_position), normalize(direction));
		if( acos(s)* 180/M_PI > cutoff){
			spot_effect =0;
		}
		else{
			spot_effect = pow(max(s,0),exponent);
		}
	}
	
	vertex_normal =  ambient_light+  spot_effect*(diffusion_light + specular_light);
	}
}
