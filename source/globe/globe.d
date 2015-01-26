module globe.globe;

import std.stdio;
import std.algorithm;
import gl3n.linalg;
import alledged.model;


class Edge {
public:
	this(vec3[2] c) {
		coords[] = c;
	}
	
	void Set_face(Face f) {
		if(faces[0] is null) {
			faces[0] = f;
		}
		else {
			faces[1] = f;
		}
	}
	
	Face Get_neighbour(Face f) {
		if(faces[0] is f) {
			return faces[1];
		}
		else {
			return faces[0];
		}
	}

	Edge[2] Get_children() {
		if(children[0] is null) {
			vec3 mid = coords[0] + coords[1];
			mid.normalize();
			children[0] = new Edge([coords[0], mid]);
			children[1] = new Edge([coords[1], mid]);
		}
		return children[0 .. 2];
	}
	
	vec3[2] Get_coords() {
		return coords[0 .. 2];
	}
	
	vec3 Get_nearest_point(vec3 center) {
		auto v = coords[1] - coords[0];
		auto w = center - coords[0];

		auto c1 = dot(w, v);		
		if (c1 <= 0) {
			return coords[0];
		}
		
		auto c2 = dot(v, v);
		if (c2 <= c1) {
			return coords[1];
		}

		auto b = c1 / c2;
		auto Pb = coords[0] + b * v;
		return Pb;
	}
private:
	Globe globe;
	vec3[2] coords;
	Edge[2] children;
	Face[2] faces;
};

class Face {
public:
	this(int l, vec3[3] c, Edge[3] e) {
		coords[] = c;
		edges[] = e;
		level = l;
	}

	Face[] Get_children() {
		if(children[0] is null) {
			Edge[] childedges;
			vec3[] midpoints;
			foreach(i, edge; edges) {
				//Put the edges in a known order here.
				Edge[2] edgepair = edge.Get_children();
				if(edgepair[0].Get_coords()[0] is coords[i]) {
					childedges ~= edgepair[0];
					childedges ~= edgepair[1];
				}
				else {
					childedges ~= edgepair[1];
					childedges ~= edgepair[0];
				}
				midpoints ~= childedges[childedges.length-1].Get_coords()[1];
			}
			//Create new edges between midpoints.
			childedges ~= new Edge([midpoints[0], midpoints[1]]);
			childedges ~= new Edge([midpoints[1], midpoints[2]]);
			childedges ~= new Edge([midpoints[2], midpoints[0]]);
			
			
			vec3[3] facecoords = [coords[0], midpoints[0], midpoints[2]];
			Edge[3] faceedges = [childedges[0], childedges[8], childedges[5]];
			Face f = new Face(level+1, facecoords, faceedges);
			foreach(edge; faceedges) {
				edge.Set_face(f);
			}
			children[0] = f;
			
			facecoords = [coords[1], midpoints[1], midpoints[0]];
			faceedges = [childedges[2], childedges[6], childedges[1]];
			f = new Face(level+1, facecoords, faceedges);
			foreach(edge; faceedges) {
				edge.Set_face(f);
			}
			children[1] = f;
			
			facecoords = [coords[2], midpoints[2], midpoints[1]];
			faceedges = [childedges[4], childedges[7], childedges[3]];
			f = new Face(level+1, facecoords, faceedges);
			foreach(edge; faceedges) {
				edge.Set_face(f);
			}
			children[2] = f;

			facecoords = [midpoints[0], midpoints[1], midpoints[2]];
			faceedges = [childedges[6], childedges[7], childedges[8]];
			f = new Face(level+1, facecoords, faceedges);
			foreach(edge; faceedges) {
				edge.Set_face(f);
			}
			children[3] = f;
		}
		
		return children[0 .. 4];
	}
	
	bool Is_within_sphere(vec3 center, float r) {
		foreach(edge; edges) {
			vec3 edgepoint = edge.Get_nearest_point(center);
			if((edgepoint-center).magnitude <= r) {
				return true;
			}
		}
		return false;
	}

	vec3 Get_center() {
		vec3 c = vec3(0, 0, 0);
		foreach(v; coords) {
			c += v;
		}
		c.x /= 3;
		c.y /= 3;
		c.z /= 3;
		return c;
	}
	
	vec3[3] Get_coords() {
		return coords[0 .. 3];
	}
private:
	Globe globe;
	vec3[3] coords;
	Edge[3] edges;
	Face[4] children;
	int level;
};

class Globe {
public:
	void Init(float r) {
		radius = r;
		vec3[] coords = [
			vec3(0, r, 0),
			vec3(r, 0, 0),
			vec3(0, 0, r),
			vec3(0, -r, 0),
			vec3(-r, 0, 0),
			vec3(0, 0, -r),
		];
		
		Edge[] edges = [
			new Edge([coords[0], coords[1]]),
			new Edge([coords[0], coords[2]]),
			new Edge([coords[0], coords[4]]),
			new Edge([coords[0], coords[5]]),

			new Edge([coords[3], coords[1]]),
			new Edge([coords[3], coords[2]]),
			new Edge([coords[3], coords[4]]),
			new Edge([coords[3], coords[5]]),

			new Edge([coords[1], coords[5]]),
			new Edge([coords[1], coords[2]]),
			new Edge([coords[4], coords[5]]),
			new Edge([coords[4], coords[2]]),
		];

		//3 coords, 3 edges per face
		int[] facelist = [
			0, 2, 1, 1, 9, 0,
			0, 4, 2, 2, 11, 1,
			0, 1, 5, 0, 8, 3,
			0, 5, 4, 3, 10, 2,

			3, 1, 2, 4, 9, 5,
			3, 2, 4, 5, 11, 6,
			3, 5, 1, 7, 8, 4,
			3, 4, 5, 6, 10, 7,
		];
		
		
		for(int i = 0; i < facelist.length; i+= 6) {
			vec3[3] facecoords = [coords[facelist[i]], coords[facelist[i+1]], coords[facelist[i+2]]];
			Edge[3] faceedges = [edges[facelist[i+3]], edges[facelist[i+4]], edges[facelist[i+5]]];

			Face f = new Face(1, facecoords, faceedges);
			foreach(edge; faceedges) {
				edge.Set_face(f);
			}
			faces ~= f;
		}
	}
	
	Model Generate_detailed_location(vec3 center, float r, int level_of_detail) {
		//Find any faces with an edge that goes inside the sphere. 
		/*	To avoid doing the math twice for each edge don't simply go through faces.
		 * 	This adds complexity though, and I'm not sure doing the math is more expensive than the extra loops you'd need.
		 * 	For each unique edge
		 * 		Check if within sphere
		 * 			Select unique faces connected to edge
		 * */
		Face[] candidate_faces = faces;
		Face[] included_faces;
		
		for(int i = 1; i <= level_of_detail; ++i) {
			foreach(face; candidate_faces) {
				if(face.Is_within_sphere(center, r)) {
					included_faces ~= face;
				}
			}

			//If we have found no faces. Find the face closest to center.
			if(included_faces.length == 0) {
				float closest = radius*radius;
				Face closest_face;
				foreach(face; candidate_faces) {
					float d = (center - face.Get_center()).magnitude_squared();
					if(d < closest) {
						closest = d;
						closest_face = face;
					}
				}
				included_faces ~= closest_face;
			}

			//Last loop we can skip getting the next level of detail.
			if(i < level_of_detail) {
				candidate_faces = [];
				//Split each selected face
				foreach(face; included_faces) {
					candidate_faces ~= face.Get_children();
				}
				//Reset included, we're not interested in this level of detail.
				included_faces = [];
			}
		}
		
		//Create model
		vec3[] model_coords;
		int[] model_faces;
		foreach(face; included_faces) {
			auto corners = face.Get_coords();
			foreach(corner; corners) {
				int p = to!int(countUntil(model_coords, corner));
				if(p == -1) {
					model_coords ~= corner;
					model_faces ~= to!int(model_coords.length - 1);
				}
				else {
					model_faces ~= p;
				}
			}
		}
		Model model = new Model;
		model.Set_model_data(model_coords, model_faces);
		return model;
	}
private:
	float radius = 1;
	Face[] faces;
};
