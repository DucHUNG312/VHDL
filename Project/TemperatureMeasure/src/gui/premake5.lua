include "./vendor/premake/premake_customization/solution_items.lua"
include "Dependencies.lua"

workspace "GUI"
	architecture "x86_64"
	startproject "gui"
	
	configurations
	{
		"Debug",
		"Release",
		"Dist"
	}

	solution_items
	{
		".editorconfig"
	}
	
	flags
	{
		"MultiProcessorCompile"
	}

	filter "language:C++ or language:C"
		architecture "x86_64"
	filter ""

outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

group "Dependencies"
	include "vendor/premake"
	include "gui/vendor/GLFW"
	include "gui/vendor/imgui"
	include "gui/vendor/Glad"
group ""

include "gui"










