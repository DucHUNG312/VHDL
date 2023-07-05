#pragma once
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "GUI/Renderer/GraphicsContext.h"

struct GLFWwindow;

namespace GUI {

	class OpenGLContext : public GraphicsContext
	{
	public:
		OpenGLContext(GLFWwindow* windowHandle);

		virtual void Init() override;
		virtual void SwapBuffers() override;
	private:
		GLFWwindow* m_windowHandle;
	};

}
