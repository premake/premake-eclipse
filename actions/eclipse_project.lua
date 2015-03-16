--
-- Name:        actions/eclipse_project.lua
-- Purpose:     Generate a Eclipse .project file.
-- Author:      Manu Evans
-- Created:     2014/12/22
-- Copyright:   (c) 2008-2014 Jason Perkins and the Premake project
--

	local p = premake

	local eclipse = p.modules.eclipse

	local tree = p.tree
	local project = p.project
	local config = p.config

	local m = eclipse

--
-- .project stuff
--

	function m.project.projects(prj)

		-- TODO: check the VS solution code which rigs up dependencies, it must be project-wise...

		-- collect all dependencies for all configs
		local dependencies = {}
--		cfgs = prj.allCfgs
--		for each cfg
--			dependencies = table.join(dependencies, config.getlinks(cfg, "siblings", "basename"))

		_p(1, '<projects>')

--		for _, proj in ipairs(dependencies) do
--			_x(2, '<project>%s</project>', proj)
--		end

		_p(1, '</projects>')
	end

	local function project_dictionary(key, value)

		_p(4, '<dictionary>')
		_p(5, '<key>%s</key>', key)
		_p(5, '<value>%s</value>', value)
		_p(4, '</dictionary>')
	end

	function m.project.genmakebuilder_arguments(prj)

--		project_dictionary('?name?', '')
--		project_dictionary('org.eclipse.cdt.make.core.append_environment', 'true')
--		project_dictionary('org.eclipse.cdt.make.core.autoBuildTarget', 'all')
--		project_dictionary('org.eclipse.cdt.make.core.buildArguments', '')
--		project_dictionary('org.eclipse.cdt.make.core.buildCommand', 'make')
--		project_dictionary('org.eclipse.cdt.make.core.buildLocation', '${workspace_loc:/udPlatform/Debug}')
--		project_dictionary('org.eclipse.cdt.make.core.cleanBuildTarget', 'clean')
--		project_dictionary('org.eclipse.cdt.make.core.contents', 'org.eclipse.cdt.make.core.activeConfigSettings')
--		project_dictionary('org.eclipse.cdt.make.core.enableAutoBuild', 'false')
--		project_dictionary('org.eclipse.cdt.make.core.enableCleanBuild', 'true')
--		project_dictionary('org.eclipse.cdt.make.core.enableFullBuild', 'true')
--		project_dictionary('org.eclipse.cdt.make.core.fullBuildTarget', 'all')
--		project_dictionary('org.eclipse.cdt.make.core.stopOnError', 'true')
--		project_dictionary('org.eclipse.cdt.make.core.useDefaultBuildCmd', 'true')
	end

	function m.project.genmakebuilder(prj)

		_p(2, '<buildCommand>')
		_p(3, '<name>%s</name>', 'org.eclipse.cdt.managedbuilder.core.genmakebuilder')
		_p(3, '<triggers>%s</triggers>', 'clean,full,incremental,')
		_p(3, '<arguments>')

		m.project.genmakebuilder_arguments(prj)

		_p(3, '</arguments>')
		_p(2, '</buildCommand>')
	end

	function m.project.scannerconfigbuilder(prj)

		_p(2, '<buildCommand>')
		_p(3, '<name>%s</name>', 'org.eclipse.cdt.managedbuilder.core.ScannerConfigBuilder')
		_p(3, '<triggers>%s</triggers>', 'full,incremental,')
		_p(3, '<arguments>')
		_p(3, '</arguments>')
		_p(2, '</buildCommand>')
	end

	function m.project.buildspec(prj)

		_p(1, '<buildSpec>')

		m.project.genmakebuilder(prj)
		m.project.scannerconfigbuilder(prj)

		_p(1, '</buildSpec>')
	end

	function m.project.natures(prj)

		_p(1, '<natures>')

		_p(2, '<nature>%s</nature>', 'org.eclipse.cdt.core.cnature')
		_p(2, '<nature>%s</nature>', 'org.eclipse.cdt.core.ccnature')
		_p(2, '<nature>%s</nature>', 'org.eclipse.cdt.managedbuilder.core.managedBuildNature')
		_p(2, '<nature>%s</nature>', 'org.eclipse.cdt.managedbuilder.core.ScannerConfigNature')

		_p(1, '</natures>')
	end

--
-- Project: Generate the Eclipse .project file.
--
	function m.project.generate(prj)

		p.eol("\r\n")
		p.indent("\t")
		p.escaper(eclipse.esc)

		_p('<?xml version="1.0" encoding="UTF-8"?>')

		_p('<projectDescription>')

		_x(1, '<name>%s</name>', prj.name)
		_p(1, '<comment></comment>')

		m.project.projects()
		m.project.buildspec()
		m.project.natures()

		_p('</projectDescription>')
	end
