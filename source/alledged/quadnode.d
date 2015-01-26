module alledged.quadnode;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

import alledged.scenenode;

class Quadnode: Scenenode {
public:
	void Set_corners(vec3[4] p) {
		for(int i=0; i<4; ++i) {
			v[i] = p[i];
		}
		vec3 v1 = v[2] - v[1];
		vec3 v2 = v[0] - v[1];
		normal = cross(v1, v2).normalized();// v2.CrossProduct( v1 ).GetNormalized();
	}

	override void Render() {
		glBegin(GL_QUADS);
		glNormal3f(normal.x, normal.y, normal.z);
		glTexCoord2f(0, 0); glVertex3f(v[0].x, v[0].y, v[0].z);
		glTexCoord2f(1, 0); glVertex3f(v[1].x, v[1].y, v[1].z);
		glTexCoord2f(1, 1); glVertex3f(v[2].x, v[2].y, v[2].z);
		glTexCoord2f(0, 1); glVertex3f(v[3].x, v[3].y, v[3].z);
		glEnd();
	}
private:
	vec3 v[4];
	vec3 normal;
};
