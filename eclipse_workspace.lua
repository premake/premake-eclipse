--
-- Name:        eclipse/eclipse_workspace.lua
-- Purpose:     Generate a Eclipse solution.
-- Author:      Manu Evans
-- Created:     2014/12/22
-- Copyright:   (c) 2008-2014 Jason Perkins and the Premake project
--

	local p = premake

	local eclipse = p.modules.eclipse

	local solution = p.solution

--
-- Generate an Eclipse workspace
--
	function eclipse.workspace.generate(sln)

		p.eol("\r\n")
		p.indent("\t")
		p.escaper(eclipse.esc)

		--
		-- Header
		--
		local tagsdb = "" --"./" .. sln.name .. ".tags"

		_p('<?xml version="1.0" encoding="UTF-8"?>')
		_p('<Eclipse_Workspace Name="%s" Database="%s">', sln.name, tagsdb)
		--
		-- Project list
		--
		for prj in solution.eachproject(sln) do
			local prjname = premake.esc(prj.name)
			local prjpath = path.join(path.getrelative(sln.location, prj.location), prj.name)
			local active  = iif(prj.name == sln.startproject, "Yes", "No")
			_p(1, '<Project Name="%s" Path="%s.project" Active="%s"/>', prjname, prjpath, active)
		end
		--
		-- Configurations
		--
		_p(1, '<BuildMatrix>')
		for cfg in solution.eachconfig(sln) do
			-- Make sure to use a supported platform
			if eclipse.platforms.isok(cfg.platform) then

				local cfgname = eclipse.getconfigname(cfg)
				_p(2, '<WorkspaceConfiguration Name="%s" Selected="yes">', cfgname)
				for prj in solution.eachproject(sln) do
					_p(3, '<Project Name="%s" ConfigName="%s"/>', prj.name, cfgname)
				end
				_p(2, '</WorkspaceConfiguration>')
			end
		end
		_p(1, '</BuildMatrix>')
		_p('</Eclipse_Workspace>')
	end
