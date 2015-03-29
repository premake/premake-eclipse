--
-- Name:        eclipse/eclipse.lua
-- Purpose:     Define the Eclipse action(s).
-- Author:      Manu Evans
-- Created:     2014/12/22
-- Copyright:   (c) 2008-2014 Jason Perkins and the Premake project
--

	local p = premake

	p.modules.eclipse = {}

	local eclipse = p.modules.eclipse

	eclipse.compiler  = {}
	eclipse.platforms = {}
	eclipse.project   = {}
	eclipse.cproject  = {}
	eclipse.workspace  = {}

	function eclipse.esc(value)
		-- TODO: not sure if/how eclipse escapes yet
		return value
	end

	function eclipse.uid()
		-- eclipse seems to use random 31 bit numbers as id's
		return math.random(2147483647)-1
	end


--
-- Set global environment for some platforms...
--



	include("_preload.lua")
	include("eclipse_cproject.lua")
	include("eclipse_project.lua")
	include("eclipse_workspace.lua")

	return eclipse
