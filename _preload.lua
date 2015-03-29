--
-- Name:        eclipse/_preload.lua
-- Purpose:     Define the Eclipse action.
-- Author:      Manu Evans
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

	local p = premake

--
-- Eclipse action
--
	newaction
	{
		trigger         = "eclipse",
		shortname       = "Eclipse",
		description     = "Generate Eclipse project files",
		module          = "eclipse",

		valid_kinds     = { "ConsoleApp", "Makefile", "SharedLib", "StaticLib", "WindowedApp" },
		valid_languages = { "C", "C++"},
		valid_tools     = {
		    cc          = { "msc", "gcc", "clang" }
		},

		onsolution = function(sln)
			-- eclipse workspace?
--			premake.generate(sln, sln.name .. ".workspace", eclipse.workspace.generate)
		end,

		onproject = function(prj)
			-- TODO: eclipse won't work where all projects are created in the same place as the workspace
			premake.generate(prj, ".project", p.modules.eclipse.project.generate)
			premake.generate(prj, ".cproject", p.modules.eclipse.cproject.generate)
		end,

		oncleansolution = function(sln)
			-- delete solution files...
			-- this should probably include the entire .workspace/ folder...
		end,

		onCleanTarget = function(prj)
			-- delete the target stuff...
		end,

		oncleanproject = function(prj)
			premake.clean.file(prj, ".project")
			premake.clean.file(prj, ".cproject")
		end
	}
