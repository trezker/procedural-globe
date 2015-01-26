module alledged.lightnode;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

import alledged.scenenode;

class Lightnode: Scenenode {
public:
	//Initialized to opengl default values.
	this() {
		position = vec3(0, 0, 1);
		ambient = vec4(0.2, 0.2, 0.2, 1);
		diffuse = vec4(0.8, 0.8, 0.8, 1);
		specular = vec4(0, 0, 0, 1);
	}

	void Set_ambient(float r, float g, float b, float a) {
		ambient = vec4(r, g, b, a);
	}

	void Set_diffuse(float r, float g, float b, float a) {
		diffuse = vec4(r, g, b, a);
	}
	
	void Set_specular(float r, float g, float b, float a) {
		specular = vec4(r, g, b, a);
	}
	
	void Set_ambient(vec4 v) {
		ambient = v;
	}

	void Set_diffuse(vec4 v) {
		diffuse = v;
	}

	void Set_specular(vec4 v) {
		specular = v;
	}

	vec4 Get_ambient() {
		return ambient;
	}

	vec4 Get_diffuse() {
		return diffuse;
	}

	vec4 Get_specular() {
		return specular;
	}

	override void Prerender() {
		if(lights_in_use >= GL_MAX_LIGHTS) {
			++lights_in_use;
			writeln("Lights used are more than GL_MAX_LIGHTS by ", lights_in_use - GL_MAX_LIGHTS);
			return;
		}
		int light = GL_LIGHT0+lights_in_use;
		vec4 LightPosition = vec4(position.x, position.y, position.z, directional?0.0f:1.0f);
		glLightfv(light, GL_AMBIENT, ambient.value_ptr);
		glLightfv(light, GL_DIFFUSE, diffuse.value_ptr);
		glLightfv(light, GL_SPECULAR, specular.value_ptr);
		glLightfv(light, GL_POSITION, LightPosition.value_ptr);
		glEnable(light);
		++lights_in_use;
	}

	override void Postrender() {
		if(lights_in_use > GL_MAX_LIGHTS) {
			--lights_in_use;
			return;
		}
		--lights_in_use;
		int light = GL_LIGHT0+lights_in_use;
		glDisable(light);
	}

	void Set_position(vec3 pos, bool d) {
		position = pos;
		directional = d;
	}
private:
	static int lights_in_use;
	bool directional = 0;
	vec3 position;
	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
};
