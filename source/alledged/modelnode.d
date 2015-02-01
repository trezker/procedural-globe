module alledged.modelnode;

import alledged.scenenode;
import alledged.model;

class Modelnode: Scenenode {
public:
	void Set_model(Model m) {
		model = m;
	}

	Model Get_model() {
		return model;
	}
	
	override void Render() {
		if(model !is null) {
			model.Render();
		}
	}
private:
	Model model;
};
