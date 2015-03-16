--
-- Name:        eclipse.lua
-- Purpose:     Define the Eclipse action(s).
-- Author:      Manu Evans
-- Created:     2014/12/22
-- Copyright:   (c) 2008-2014 Jason Perkins and the Premake project
--

	local p = premake

	p.modules.eclipse = {}

	local eclipse = p.modules.eclipse

	local project = p.project
	local api = p.api

	eclipse.support_url = "https://bitbucket.org/premakeext/eclipse/wiki/Home"

	eclipse.printf = function( msg, ... )
		printf( "[eclipse] " .. msg, ...)
	end

	eclipse.printf( "Premake Eclipse Extension (" .. eclipse.support_url .. ")" )

	-- Extend the package path to include the directory containing this
	-- script so we can easily 'require' additional resources from
	-- subdirectories as necessary
	local this_dir = debug.getinfo(1, "S").source:match[[^@?(.*[\/])[^\/]-$]];
	package.path = this_dir .. "actions/?.lua;".. package.path

	eclipse.compiler  = {}
	eclipse.platforms = {}
	eclipse.project   = {}
	eclipse.cproject  = {}
	eclipse.solution  = {}

	io.indent = "\t" -- tabs, UTF8 XML file

	function eclipse.esc(value)
		return value
	end

	function eclipse.uid()
		return math.random(2147483647)-1
	end

--
-- Eclipse action
--
	newaction
	{
		trigger         = "eclipse",
		shortname       = "Eclipse",
		description     = "Generate Eclipse project files",

		valid_kinds     = {"ConsoleApp", "Makefile", "SharedLib", "StaticLib", "WindowedApp"},
		valid_languages = {"C", "C++"},
		valid_tools     = {
		    cc          = {"msc", "gcc", "clang"}
		},

		onsolution = function(sln)
			-- eclipse workspace?
--			premake.generate(sln, sln.name .. ".workspace", eclipse.solution.generate)
		end,

		onproject = function(prj)
			-- TODO: eclipse won't work where all projects are created in the same place as the workspace
			premake.generate(prj, ".project", eclipse.project.generate)
			premake.generate(prj, ".cproject", eclipse.cproject.generate)
		end,

		oncleansolution = function(sln)
			-- delete solution files...
		end,

		oncleanproject = function(prj)
			premake.clean.file(prj, ".project")
			premake.clean.file(prj, ".cproject")
		end
	}


--
-- Set global environment for some platforms...
--


--
-- For each registered premake <action>, we can simply add a file to the
-- 'actions/' extension subdirectory
--
	for k,v in pairs({ "eclipse_solution", "eclipse_project", "eclipse_cproject" }) do
		require( v )
		eclipse.printf( "Loaded action '%s.lua'", v )
	end
