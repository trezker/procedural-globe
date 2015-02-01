module alledged.model;

import std.stdio;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

class Model {
public:
	vec3[] Get_coords() {
		return coords[0 .. coords.length];
	}

	bool Show_normals() const @property {
		return show_normals;
	}

    void Show_normals(bool sn) @property {
		show_normals = sn;
	}

	vec4 Color() const @property {
		return color;
	}

    void Color(vec4 c) @property {
		color = c;
	}
    
	void Set_model_data(vec3[] c, int[] f) {
		writeln("Model data with ", f.length/3, " faces.");
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
			vec3 norm = cross(in1, in2);// in1.CrossProduct(in2);
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
		
		foreach(ref i; normals) {
			i.normalize();
		}
	}

	void Render() {
		glEnable(GL_COLOR_MATERIAL);
		glColor4fv(color.value_ptr);
		glShadeModel(GL_SMOOTH);
		glAlphaFunc(GL_GREATER, 0.1f);
		glEnable(GL_ALPHA_TEST);
		glBegin(GL_TRIANGLES);
		foreach(i; faces) {
			glNormal3f(normals[i].x, normals[i].y, normals[i].z);
			glTexCoord2f(uv_coords[i].u, uv_coords[i].v);
			glVertex3f(coords[i].x, coords[i].y, coords[i].z);
		}
		glEnd();
		
		if(show_normals) {
			glDisable(GL_TEXTURE_2D);
			glDisable(GL_COLOR_MATERIAL);
			glDisable(GL_ALPHA_TEST);
			glBegin(GL_LINES);
			glColor4f(1, 1, 1, 1);
			foreach(i; 0 .. coords.length) {
				glVertex3f(coords[i].x, coords[i].y, coords[i].z);
				glVertex3f(coords[i].x + normals[i].x, coords[i].y + normals[i].y, coords[i].z + normals[i].z);
			}
			glEnd();
		}
	}
private:
	vec4 color = vec4(1, 1, 1, 1);
	vec3[] coords;
	vec3[] normals;
	int[] faces;
	vec2[] uv_coords;
	bool show_normals = false;
};
