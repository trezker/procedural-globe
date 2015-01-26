module alledged.cameranode;

import std.stdio;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

import tod.glu;
import alledged.scenenode;

class Cameranode: Scenenode {
public:
	void Look_at(vec3 p) {
		lookat_target = p;
		front = p - position;
		front.normalize();
		// right hand rule cross products
		right = cross(front, vec3(0, 1, 0)); //vec3(0, 1, 0).CrossProduct(front);
		right.normalize();
		up = cross(right, front);// front.CrossProduct(right);
		lookat = true;
		/* matrix[0] = right.x;
		matrix[1] = right.y;
		matrix[2] = right.z;
		matrix[3] = 0;
		matrix[4] = up.x;
		matrix[5] = up.y;
		matrix[6] = up.z;
		matrix[7] = 0;
		matrix[8] = front.x;
		matrix[9] = front.y;
		matrix[10] = front.z;
		matrix[11] = 0;
		matrix[12] = -position.x;
		matrix[13] = -position.y;
		matrix[14] = -position.z;
		matrix[15] = 1;
		*/
	}
	
	vec3 Get_up() {
		return up;
	}
	
	vec3 Get_front() {
		return front;
	}
	
	vec3 Get_right() {
		return right;
	}
	
	void Set_position(vec3 v) {
		position = v;
	}

	vec3 Get_position() {
		return position;
	}
	
	vec3 Get_rotation() {
		return rotation;
	}
	
	void Set_rotate_around_world_origo(bool t) {
		rotate_around_world_origo = t;
	}

	void Set_rotation(vec3 v) {
		rotation = v;
		vec3 rotrad = rotation*(PI/180);
		quat quat_temp = quat(1.0, 0.0, 0.0, 0.0);
		quat_total = quat(1.0, 0.0, 0.0, 0.0);
		quat quat_local = quat(1.0, 0.0, 0.0, 0.0);

		quat_total.rotatex(rotrad.x);
		quat_total.rotatey(rotrad.y);
		quat_total.rotatez(rotrad.z);
		
		vec3 vin = vec3(0, 0, -1);
		vec3 vout;
		vout = vin * quat_total;
		front = vec3(vout);
		vin = vec3(0, 1, 0);
		vout = vin * quat_total;
		up = vec3(vout);
		front.normalize();
		up.normalize();
		right = cross(up, front);
		right.normalize();
	}
	
	void Rotate_local_axis(vec3 v) {
		/*
		Vector3 rotrad = v*(M_PI/180);
		quat4_t quat_temp;
		quat4_t quat_local;
		Quat_from_axisangle(quat_local, right.x, right.y, right.z, rotrad.x);
		Quat_multQuat (quat_local, quat_total, quat_temp);
		Quat_copy(quat_temp, quat_total);
		Quat_from_axisangle(quat_local, up.x, up.y, up.z, rotrad.y);
		Quat_multQuat (quat_local, quat_total, quat_temp);
		Quat_copy(quat_temp, quat_total);
		Quat_from_axisangle(quat_local, front.x, front.y, front.z, rotrad.z);
		Quat_multQuat (quat_local, quat_total, quat_temp);
		Quat_copy(quat_temp, quat_total);
		vec3_t out;
		Quat_to_euler(quat_total, out);
		rotation.x = out[0] * (180 / M_PI);
		rotation.y = out[1] * (180 / M_PI);
		rotation.z = out[2] * (180 / M_PI);
		vec3_t in;
		in[0] = 0;
		in[1] = 0;
		in[2] = -1;
		Quat_rotatePoint (quat_total, in, out);
		front.x = out[0];
		front.y = out[1];
		front.z = out[2];
		in[0] = 0;
		in[1] = 1;
		in[2] = 0;
		Quat_rotatePoint (quat_total, in, out);
		up.x = out[0];
		up.y = out[1];
		up.z = out[2];
		front.Normalize();
		up.Normalize();
		right = front.CrossProduct(up);
		right.Normalize();
		*/
	}
	
	override void Prerender() {
		glPushMatrix();
		if(!lookat) {
			if(!rotate_around_world_origo) {
				auto matrix = quat_total.to_matrix!(4,4);
				//mat4 matrix;
				//Quat_to_matrix4 (quat_total, matrix);
				glMultMatrixf(matrix.value_ptr);
				glTranslatef(-position.x, -position.y, -position.z);
			}
			else {
				glTranslatef(-position.x, -position.y, -position.z);
				glRotatef(rotation.x, 1, 0, 0);
				glRotatef(rotation.y, 0, 1, 0);
				glRotatef(rotation.z, 0, 0, 1);
			}
		}
		else {
			gluLookAt( position.x, position.y, position.z,
			lookat_target.x, lookat_target.y, lookat_target.z,
			up.x, up.y, up.z );
		}
	}

	override void Postrender() {
		glPopMatrix();
	}
private:
	bool lookat = false;
	bool rotate_around_world_origo = false;
	vec3 lookat_target = vec3(0, 0, 0);
	vec3 front = vec3(0, 0, 0);
	vec3 right = vec3(0, 0, 0);
	vec3 up = vec3(0, 0, 0);
	vec3 position = vec3(0, 0, 0);
	vec3 rotation = vec3(0, 0, 0);
	quat quat_total = quat(1.0, 0.0, 0.0, 0.0);
};
