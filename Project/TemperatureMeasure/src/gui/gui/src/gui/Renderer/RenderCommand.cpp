#include <pch.h>
#include "GUI/Renderer/RenderCommand.h"
#include "Platform/OpenGL/OpenGLRendererAPI.h"

namespace GUI {

	// in this time the renderer will use OpenGLRendererAPI, but will dynamically in the future
	Scope<RendererAPI> RenderCommand::s_RendererAPI =  RendererAPI::Create();

}
