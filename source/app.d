module pw.app;

import std.stdio;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import gl3n.linalg;

import allegro5.allegro;
import allegro5.allegro_primitives;
import allegro5.allegro_image;
import allegro5.allegro_color;
import allegro5.allegro_font;
import allegro5.allegro_ttf;

import tod.glu;
import alledged.scenenode;
import alledged.cameranode;
import alledged.lightnode;
import alledged.transformnode;
import alledged.quadnode;
import alledged.modelnode;
import alledged.model;
import globe.globe;

/*
 * Let the globe have a global list of verts.
 * I'd like to have a system where all faces that should use the same verts actually reference the same verts.
 * 
 * If we also have a global list of edges referenced and shared by faces. When an edge is split it'll have two children.
 * when neighbouring faces split, the first will create the new verts and edges.
 * The second face can then see that one of it's edges already has children ready to be used.
 * */

void Init_perspective_view(float fov, float aspect, float near, float far) {
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	gluPerspective(fov, aspect, near, far);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}
void Pop_view() {
	//Return to Allegros 2D world
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

class Scene {
public:
	void Build() {
		root = new Scenenode;

		camera = new Cameranode;
		camera.Set_position(vec3(0, 0, 20));

		auto lightnode = new Lightnode;
		lightnode.Set_position(vec3(0, 0, 1), 1);
		
		auto transformnode = new Transformnode;
		transformnode.Set_scale(vec3(10, 10, 10));
		
		//A little backdrop
		vec3[4] corners = [
			vec3(100, 100, -100),
			vec3(-100, 100, -100),
			vec3(-100, -100, -100),
			vec3(100, -100, -100)
		];
		quad = new Quadnode;
		quad.Set_corners(corners);
		
		globe = new Globe;
		globe.Init(1);
		writeln("Full globe");
		auto full_globe_model = globe.Generate_detailed_location(vec3(0, 0, 0), 1, 5);
		full_globe_model.Color = vec4(1, 1, 1, 1);
		full_globe = new Modelnode;
		full_globe.Set_model(full_globe_model);
		writeln("Generated");

		writeln("Deailed area");
		auto detailed_area_model = globe.Generate_detailed_location(vec3(0, 0, 1), 0.1, 9);
		detailed_area_model.Color = vec4(0, 0, 1, 1);
		detailed_area = new Modelnode;
		detailed_area.Set_model(detailed_area_model);
		writeln("Generated");
		
		transformnode.Attach_node(detailed_area);
		transformnode.Attach_node(full_globe);
		//lightnode.Attach_node(quad);
		lightnode.Attach_node(transformnode);
		camera.Attach_node(lightnode);
		root.Attach_node(camera);
	}
	
	void Render() {
		float fov = 45;
		float near = 1;
		float far = 1000;
		float width = 640;
		float height = 480;
		Init_perspective_view(fov, width/height, near, far);
		glEnable(GL_DEPTH_TEST);
		glClear(GL_DEPTH_BUFFER_BIT);
		glEnable(GL_LIGHTING);

		root.Apply();

		glDisable(GL_LIGHTING);
		glDisable(GL_DEPTH_TEST);
		Pop_view();
	}

	Scenenode root;
	Cameranode camera;
	Quadnode quad;
	Modelnode full_globe;
	Modelnode detailed_area;
	Globe globe;
};

int main(char[][] args) {
	return al_run_allegro({
		DerelictGL3.load(); // load latest available version
		DerelictGL.load(); // load deprecated functions too

		al_init();
		
		al_set_new_display_flags(ALLEGRO_WINDOWED | ALLEGRO_OPENGL);
		al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_DEPTH_SIZE, 24, ALLEGRO_REQUIRE);
		ALLEGRO_DISPLAY* display = al_create_display(800, 600);
		if(!display) {
			writeln("Failed to create display");
			return 0;
		}
		
		al_install_keyboard();
		al_install_mouse();
		al_init_image_addon();
		al_init_font_addon();
		al_init_ttf_addon();
		al_init_primitives_addon();

		float timer_interval = 0.02;
		ALLEGRO_TIMER *timer = al_create_timer(timer_interval);
		al_start_timer(timer);

		ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
		al_register_event_source(queue, al_get_display_event_source(display));
		al_register_event_source(queue, al_get_keyboard_event_source());
		al_register_event_source(queue, al_get_mouse_event_source());
		al_register_event_source(queue, al_get_timer_event_source(timer));

		Scene scene = new Scene;
		scene.Build();
		bool rotate = false;
		bool move_up = false;
		bool move_down = false;
		bool move_left = false;
		bool move_right = false;
		bool move_forward = false;
		bool move_back = false;
		bool roll_left = false;
		bool roll_right = false;

		bool exit = false;
		while(!exit)
		{
			ALLEGRO_EVENT event;
			while(al_get_next_event(queue, &event))
			{
				//world.Handle_event(event);
				switch(event.type)
				{
					case ALLEGRO_EVENT_DISPLAY_CLOSE:
					{
						exit = true;
						break;
					}
					
					case ALLEGRO_EVENT_KEY_DOWN:
					{
						switch(event.keyboard.keycode)
						{
							case ALLEGRO_KEY_ESCAPE:
							{
								exit = true;
								break;
							}
							case ALLEGRO_KEY_T:
							{
								writeln("update");
								break;
							}
							case ALLEGRO_KEY_A:
							{
								move_left = true;
								break;
							}
							case ALLEGRO_KEY_D:
							{
								move_right = true;
								break;
							}
							case ALLEGRO_KEY_W:
							{
								move_forward = true;
								break;
							}
							case ALLEGRO_KEY_S:
							{
								move_back = true;
								break;
							}
							case ALLEGRO_KEY_R:
							{
								move_up = true;
								break;
							}
							case ALLEGRO_KEY_F:
							{
								move_down = true;
								break;
							}
							case ALLEGRO_KEY_Q:
							{
								roll_left = true;
								break;
							}
							case ALLEGRO_KEY_E:
							{
								roll_right = true;
								break;
							}
							default:
						}
						break;
					}
					case ALLEGRO_EVENT_KEY_UP:
					{
						switch(event.keyboard.keycode)
						{
							case ALLEGRO_KEY_A:
							{
								move_left = false;
								break;
							}
							case ALLEGRO_KEY_D:
							{
								move_right = false;
								break;
							}
							case ALLEGRO_KEY_W:
							{
								move_forward = false;
								break;
							}
							case ALLEGRO_KEY_S:
							{
								move_back = false;
								break;
							}
							case ALLEGRO_KEY_R:
							{
								move_up = false;
								break;
							}
							case ALLEGRO_KEY_F:
							{
								move_down = false;
								break;
							}
							case ALLEGRO_KEY_Q:
							{
								roll_left = false;
								break;
							}
							case ALLEGRO_KEY_E:
							{
								roll_right = false;
								break;
							}
							default:
						}
						break;
					}
					case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
					{
						writeln("rotate");
						rotate = true;
						break;
					}
					case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
					{
						writeln("stop rotate");
						rotate = false;
						break;
					}
					case ALLEGRO_EVENT_MOUSE_AXES:
					{
						if(rotate) {
							scene.camera.Set_rotation(scene.camera.Get_rotation() + vec3(-event.mouse.dy, -event.mouse.dx, 0));
						}
						break;
					}
					
					case ALLEGRO_EVENT_TIMER:
					{
						float roll = 0;
						if(roll_left) {
							roll += 1;
						}
						if(roll_right) {
							roll -= 1;
						}
						scene.camera.Set_rotation(scene.camera.Get_rotation() + vec3(0, 0, 100 * roll * timer_interval));
						
						vec3 move = vec3(0, 0, 0);
						if(move_left) {
							move.x += 1;
						}
						if(move_right) {
							move.x -= 1;
						}
						if(move_up) {
							move.y += 1;
						}
						if(move_down) {
							move.y -= 1;
						}
						if(move_forward) {
							move.z += 1;
						}
						if(move_back) {
							move.z -= 1;
						}

						scene.camera.Set_position(scene.camera.Get_position() + 10 * move.x * scene.camera.Get_right() * timer_interval);
						scene.camera.Set_position(scene.camera.Get_position() + 10 * move.y * scene.camera.Get_up() * timer_interval);
						scene.camera.Set_position(scene.camera.Get_position() + 10 * move.z * scene.camera.Get_front() * timer_interval);
						//scene.camera.Set_position(scene.camera.Get_position() + 10 * move * timer_interval);
						
						break;
					}
					default:
				}
			}

			al_clear_to_color(ALLEGRO_COLOR(0.5, 0.25, 0.125, 1));
			scene.Render();
			//Draw
			al_flip_display();
			al_rest(0.001);
		}

		al_destroy_event_queue(queue);
		al_destroy_display(display);

		return 0;
	});
}
