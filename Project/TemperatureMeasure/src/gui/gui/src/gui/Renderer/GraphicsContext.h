#pragma once

namespace GUI {

	class GraphicsContext
	{
	public:
		virtual ~GraphicsContext() = default;

		virtual void Init() = 0;
		virtual void SwapBuffers() = 0;

		static Scope<GraphicsContext> Create(void* window);

		struct Statistics
		{
			char* GraphicsContextVendor;
			char* GraphicsContextRenderer;
			char* GraphicsContextVersion;

			const char* GetGraphicsContextVendor() { return GraphicsContextVendor; }
			const char* GetGraphicsContextRenderer() { return GraphicsContextRenderer; }
			const char* GetGraphicsContextVersion() { return GraphicsContextVersion; }
		};

		static Statistics GetStats();
		static void ResetStats();
	};

}
