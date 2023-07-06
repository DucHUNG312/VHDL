#pragma once

#include <memory>
#include "GUI/Core/PlatformDetection.h"


#ifdef TM_DEBUG
#if defined(TM_PLATFORM_WINDOWS)
#define TM_DEBUGBREAK() __debugbreak()
#elif defined(TM_PLATFORM_LINUX)
#include <signal.h>
#define TM_DEBUGBREAK() raise(SIGTRAP)
#else
#error "Platform doesn't support debugbreak yet!"
#endif
#define TM_ENABLE_ASSERTS
#else
#define TM_DEBUGBREAK()
#endif

#define TM_EXPAND_MACRO(x) x
#define TM_STRINGIFY_MACRO(x) #x

#define BIT(x) (1 << x)

#define TM_BIND_EVENT_FN(fn) [this](auto&&... args) -> decltype(auto) { return this->fn(std::forward<decltype(args)>(args)...); }

namespace GUI {

	template<typename T>
	using Scope = std::unique_ptr<T>;
	template<typename T, typename ... Args>
	constexpr Scope<T> CreateScope(Args&& ... args)
	{
		return std::make_unique<T>(std::forward<Args>(args)...);
	}

	template<typename T>
	using Ref = std::shared_ptr<T>;
	template<typename T, typename ... Args>
	constexpr Ref<T> CreateRef(Args&& ... args)
	{
		return std::make_shared<T>(std::forward<Args>(args)...);
	}

}

#include "GUI/Core/Log.h"
#include "GUI/Core/Assert.h"
