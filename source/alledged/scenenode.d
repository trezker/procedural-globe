module alledged.scenenode;

import std.algorithm;
import std.array;

class Scenenode {
public:
	void Attach_node(Scenenode node) {
		children ~= node;
	}
	
	void Detach_node(Scenenode node) {
		children = array(filter!(a => a !is node)(children));
	}
	
	void Detach_all_nodes() {
		children = [];
	}
	
	void Apply() {
		Prerender();
		Render();
		foreach(child; children) {
			child.Apply();
		}
		Postrender();	
	}
	
	void Prerender() {}
	void Render() {}
	void Postrender() {}
private:
	Scenenode[] children;
};
