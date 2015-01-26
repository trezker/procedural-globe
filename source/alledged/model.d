module alledged.model;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

class Model {
public:
	void Set_model_data(vec3[] c, int[] f) {
		normals.length = c.length;
		uv_coords.length = c.length;
		coords.length = c.length;
		faces.length = f.length;
		coords[] = c;
		faces[] = f;
		
		for (int i = 0; i < normals.length; ++i) {
			normals[i] = vec3(0, 0, 0);
		}
		
		for (int i = 0; i < faces.length; i += 3) {
			vec3 in1 = coords[faces[i+1]] - coords[faces[i]];
			vec3 in2 = coords[faces[i+2]] - coords[faces[i]];
			vec3 norm = cross(in2, in1);// in1.CrossProduct(in2);
			norm.normalize();
			for (int j = 0; j < 3; ++j) {
				normals[faces[i+j]] += norm;
			}
			uv_coords[faces[i]].u = 1;
			uv_coords[faces[i]].v = 0;
			uv_coords[faces[i+1]].u = 0.5;
			uv_coords[faces[i+1]].v = 1;
			uv_coords[faces[i+2]].u = 0;
			uv_coords[faces[i+2]].v = 0;
		}
		
		foreach(i; normals) {
			i.normalize();
		}
	}

	void Render() {
		auto color = vec4(0.5, 0.5, 0.5, 0.5);
		glEnable(GL_COLOR_MATERIAL);
		glColor4fv(color.value_ptr);
		glShadeModel(GL_SMOOTH);
		glAlphaFunc(GL_GREATER, 0.1f);
		glEnable(GL_ALPHA_TEST);
		glBegin(GL_TRIANGLES);
		foreach(i; faces) { //Indexes::iterator i=faces.begin(); i!=faces.end(); ++i, ++uv) {
			glNormal3f(normals[i].x, normals[i].y, normals[i].z);
			glTexCoord2f(uv_coords[i].u, uv_coords[i].v);
			glVertex3f(coords[i].x, coords[i].y, coords[i].z);
		}
		glEnd();
	}
private:
	vec3[] coords;
	vec3[] normals;
	int[] faces;
	vec2[] uv_coords;
};
