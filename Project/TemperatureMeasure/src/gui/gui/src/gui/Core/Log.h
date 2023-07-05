#pragma once

// This ignores all warnings raised inside External headers
#pragma warning(push, 0)
#include <spdlog/spdlog.h>
#include <spdlog/fmt/ostr.h>
#pragma warning(pop)

#define GLM_ENABLE_EXPERIMENTAL
#include <glm/gtx/string_cast.hpp>

#include "gui/Core/Base.h"

namespace GUI {

	class Log
	{
	public:
		static void Init();

		inline static Ref<spdlog::logger>& GetCoreLogger() { return s_CoreLogger; }
		inline static Ref<spdlog::logger>& GetClientLogger() { return s_ClientLogger; }
	private:
		static Ref<spdlog::logger> s_CoreLogger;
		static Ref<spdlog::logger> s_ClientLogger;
	};

}

template<typename OStream, glm::length_t L, typename T, glm::qualifier Q>
inline OStream& operator<<(OStream& os, const glm::vec<L, T, Q>& vector)
{
	return os << glm::to_string(vector);
}

template<typename OStream, glm::length_t C, glm::length_t R, typename T, glm::qualifier Q>
inline OStream& operator<<(OStream& os, const glm::mat<C, R, T, Q>& matrix)
{
	return os << glm::to_string(matrix);
}

template<typename OStream, typename T, glm::qualifier Q>
inline OStream& operator<<(OStream& os, glm::qua<T, Q> quaternion)
{
	return os << glm::to_string(quaternion);
}

// Core logging macros
#define TM_CORE_TRACE(...)       ::GUI::Log::GetCoreLogger()->trace(__VA_ARGS__)
#define TM_CORE_INFO(...)        ::GUI::Log::GetCoreLogger()->info(__VA_ARGS__)
#define TM_CORE_WARN(...)        ::GUI::Log::GetCoreLogger()->warn(__VA_ARGS__)
#define TM_CORE_ERROR(...)       ::GUI::Log::GetCoreLogger()->error(__VA_ARGS__)
#define TM_CORE_CRITICAL(...)    ::GUI::Log::GetCoreLogger()->critical(__VA_ARGS__)

// Client logging macro
#define TM_TRACE(...)		     ::GUI::Log::GetClientLogger()->trace(__VA_ARGS__)
#define TM_INFO(...)		     ::GUI::Log::GetClientLogger()->info(__VA_ARGS__)
#define TM_WARN(...)		     ::GUI::Log::GetClientLogger()->warn(__VA_ARGS__)
#define TM_ERROR(...)		     ::GUI::Log::GetClientLogger()->error(__VA_ARGS__)
#define TM_CRITICAL(...)		 ::GUI::Log::GetClientLogger()->critical(__VA_ARGS__)



