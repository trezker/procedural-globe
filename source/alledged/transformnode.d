module alledged.transformnode;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

import alledged.scenenode;

class Transformnode: Scenenode {
public:
	this() {
		position = vec3(0, 0, 0);
		rotation = vec3(0, 0, 0);
		scale = vec3(1, 1, 1);
	}

	void Set_position(vec3 v) {
		position = v;
	}

	void Set_rotation(vec3 v) {
		rotation = v;
	}

	void Set_scale(vec3 v) {
		scale = v;
	}

	vec3 Get_position() {
		return position;
	}

	vec3 Get_rotation() {
		return rotation;
	}

	vec3 Get_scale() {
		return scale;
	}

/*
	Matrix4 Get_matrix() {
		glPushMatrix();
		glLoadIdentity();
		Prerender();
		float model[16];
		glGetFloatv(GL_MODELVIEW_MATRIX, model);
		Postrender();
		glPopMatrix();
		Matrix4 m;
		m.Set(model);
		return m;
	}
*/
	override void Prerender() {
		glPushMatrix();
		glTranslatef(position.x, position.y, position.z);
		glRotatef(rotation.x, 1, 0, 0);
		glRotatef(rotation.y, 0, 1, 0);
		glRotatef(rotation.z, 0, 0, 1);
		glScalef(scale.x, scale.y, scale.z);
	}

	override void Postrender() {
		glPopMatrix();
	}
private:
	vec3 position;
	vec3 rotation;
	vec3 scale;
};
