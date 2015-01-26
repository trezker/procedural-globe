module tod.glu;

version (Tango) {
   import tango.stdc.stdint;
}
else {
   import std.stdint;
}

private {
    import derelict.opengl3.types;
}

extern (C)
{
	void gluPerspective(GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar);
	void gluLookAt(GLdouble eyeX,  GLdouble eyeY,  GLdouble eyeZ,  GLdouble centerX,  GLdouble centerY,  GLdouble centerZ,  GLdouble upX,  GLdouble upY,  GLdouble upZ);
}
