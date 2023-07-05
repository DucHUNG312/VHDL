#include "pch.h"
#include "Platform/OpenGL/OpenGLContext.h"
#include "GUI/Renderer/Renderer.h"
#include "GUI/Renderer/GraphicsContext.h"

namespace GUI {

	struct GraphicsContextData
	{
		GraphicsContext::Statistics Stats;
	};

	static GraphicsContextData s_GraphicsContextData;

	Scope<GraphicsContext> GraphicsContext::Create(void* window)
	{
		switch (Renderer::GetAPI())
		{
			case RendererAPI::API::None:
				TM_CORE_ASSERT(false, "RedererAPI::None is currently not supported");
				return nullptr;
			case RendererAPI::API::OpenGL:
				return CreateScope<OpenGLContext>(static_cast<GLFWwindow*>(window));
		}

		TM_CORE_ASSERT(false, "Unknown RendererAPI");
		return nullptr;
	}

	GraphicsContext::Statistics GraphicsContext::GetStats()
	{
		return s_GraphicsContextData.Stats;
	}

	void GraphicsContext::ResetStats()
	{
		memset(&s_GraphicsContextData.Stats, 0, sizeof(Statistics));
	}

}
