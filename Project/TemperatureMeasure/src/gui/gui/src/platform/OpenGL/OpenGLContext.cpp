#include <pch.h>
#include "OpenGLContext.h"

namespace GUI {

	OpenGLContext::OpenGLContext(GLFWwindow* windowHandle)
		: m_windowHandle(windowHandle)
	{
		TM_CORE_ASSERT(windowHandle, "Window handle is null");
	}

	void OpenGLContext::Init()
	{
		glfwMakeContextCurrent(m_windowHandle);
		// Init Glad
		int status = gladLoadGLLoader((GLADloadproc)glfwGetProcAddress);
		TM_CORE_ASSERT(status, "Failed to initialize Glad!");
		TM_CORE_ASSERT(GLVersion.major > 4 || (GLVersion.major == 4 && GLVersion.minor >= 5), "Application requires at least OpenGL version 4.5!");
	}

	void OpenGLContext::SwapBuffers()
	{
		glfwSwapBuffers(m_windowHandle);
	}

}
