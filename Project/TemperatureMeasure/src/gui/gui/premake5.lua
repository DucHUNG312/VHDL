project "gui"
	kind "ConsoleApp"
	language "C++"
	cppdialect "C++20"
	staticruntime "off"

	targetdir ("%{wks.location}/bin/" .. outputdir .. "/%{prj.name}")
	objdir ("%{wks.location}/bin-int/" .. outputdir .. "/%{prj.name}")
	
	pchheader "pch.h"
	pchsource "src/pch.cpp"

	files
	{
		"src/**.h",
		"src/**.cpp",
		"vendor/implot/**.h",
		"vendor/implot/**.cpp",
		"vendor/glm/glm/**.hpp",
		"vendor/glm/glm/**.inl",
		"vendor/boost_1_82_0/boost/asio/**.hpp",
		"vendor/boost_1_82_0/boost/asio/**.h",
		"vendor/boost_1_82_0/boost/config/**.hpp",
	}

	defines
	{
		"_CRT_SECURE_NO_WARNINGS",
		"TNFW_INCLUDE_NONE",
		"GLM_FORCE_DEPTH_ZERO_TO_ONE",
	}

	includedirs
	{
		"src",
		"vendor/spdlog/include",
		"vendor/implot",
		"vendor/boost_1_82_0",
		"%{IncludeDir.ImGui}",
		"%{IncludeDir.GLFW}",
		"%{IncludeDir.glm}",
		"%{IncludeDir.Glad}",
	}

	links
	{
		"ImGui",
		"GLFW",
		"Glad",
	}

	filter "files:vendor/implot/**.cpp"
	flags { "NoPCH" }

	filter "system:windows"
		systemversion "latest"

		defines
		{
			"IMGUI_IMPL_OPENGL_LOADER_CUSTOM"
		}

	filter "configurations:Debug"
		defines "TM_DEBUG"
		runtime "Debug"
		staticruntime "off"
		symbols "on"
		linkoptions 
		{ 
			"/NODEFAULTLIB:LIBCMTD" 
		}
    
	filter "configurations:Release"
		defines "TM_RELEASE"
		runtime "Release"
		staticruntime "off"
		optimize "on"
		linkoptions 
		{ 
			"/NODEFAULTLIB:LIBCMT"  
		}

	filter "configurations:Dist"
		defines "TM_DIST"
		runtime "Release"
		staticruntime "off"
		optimize "on"
		linkoptions 
		{ 
			"/NODEFAULTLIB:LIBCMT"  
		}
       

