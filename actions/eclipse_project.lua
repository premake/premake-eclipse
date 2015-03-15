--
-- Name:        actions/eclipse_project.lua
-- Purpose:     Generate a Eclipse C/C++ project file.
-- Author:      Manu Evans
-- Created:     2014/12/22
-- Copyright:   (c) 2008-2014 Jason Perkins and the Premake project
--

	local p = premake

	local eclipse = p.modules.eclipse

	local tree = p.tree
	local project = p.project
	local config = p.config


	eclipse.types = {
		WindowedApp	= "exe",
		ConsoleApp	= "exe",
		Makefile	= "", -- TODO??
		SharedLib	= "so", -- /dll??
		StaticLib	= "lib",
	}

	eclipse.typenames = {
		WindowedApp	= "Executable",
		ConsoleApp	= "Executable",
		Makefile	= "", -- TODO??
		SharedLib	= "Shared Library",
		StaticLib	= "Static Library",
	}

	eclipse.classes = {}
	eclipse.classes.project = {
		gcc		= "cdt.managedbuild.target.gnu",
		mingw   = "cdt.managedbuild.target.gnu.mingw",
		clang	= "",	-- TODO?
		msc		= "org.eclipse.cdt.msvc.projectType",
	}
	eclipse.classes.type = {
		gcc		= "cdt.managedbuild.target.gnu",
		mingw   = "cdt.managedbuild.target.gnu.mingw",
		clang	= "", -- ???
		msc		= "org.eclipse.cdt.msvc.projectType",
	}
	eclipse.classes.config = {
		gcc		= "", -- ???
		mingw   = "cdt.managedbuild.config.gnu.mingw",
		clang	= "", -- ???
		msc		= "", -- ???
	}

	function eclipse.project_class(prj)
		local compiler = eclipse.getcompiler()
		local class = eclipse.classes.project[compiler]
		local type = eclipse.type(prj)
		if not class or not type then
			error("Invalid project class for: " .. compiler)
		end
		return prj.name .. "." .. class .. "." .. type .. "." .. prj.uid

		-- kind = exe lib so(/dll?)
		-- [proj].cdt.managedbuild.target.gnu.[kind].[uid]			-- gcc
		-- [proj].cdt.managedbuild.target.gnu.mingw.[kind].[uid]	-- mingw gcc
		-- [proj].org.eclipse.cdt.msvc.projectType.[kind].[uid]		-- msc
	end

	function eclipse.typeclass(prj)
		local compiler = eclipse.getcompiler()
		local class = eclipse.classes.type[compiler]
		local type = eclipse.type(prj)
		if not class or not type then
			error("Invalid project type class for: " .. compiler)
		end
		return class .. "." .. type

		-- kind = exe lib so(/dll?)
		-- cdt.managedbuild.target.gnu.[kind]		-- linux gcc
		-- cdt.managedbuild.target.gnu.mingw.[kind]	-- mingw gcc
		-- org.eclipse.cdt.msvc.projectType.[kind]	-- msc
	end

	function eclipse.typename(prj)
		return eclipse.typenames[prj.kind]
	end

	function eclipse.type(prj)
		return eclipse.types[prj.kind]
	end

	function eclipse.config_class(cfg)
		local compiler = eclipse.getcompiler()
		local class = eclipse.classes.config[compiler]
		local type = eclipse.type(cfg.project)
		local build = "debug" -- / "release"
		if not class or not type then
			error("Invalid config class for: " .. compiler)
		end
		return class .. "." .. type .. "." .. build .. "." .. cfg.uid
	end

	function eclipse.cfgname(cfg)
		local cfgname = cfg.buildcfg
		-- TODO: multi-platform builds need a matrix of configs...
--		if codelite.solution.multiplePlatforms then
--			cfgname = string.format("%s|%s", cfg.platform, cfg.buildcfg)
--		end
		return cfgname
	end

	function eclipse.getcompiler()
		-- TODO: this needs some work... >_<
--		local tool = _OPTIONS.cc or cfg.toolset or p.GCC
		local tool = _OPTIONS.cc or p.GCC
		if os.is("windows") then
			tool = "mingw"
		end
		return tool

--		local toolset = p.tools[_OPTIONS.cc or cfg.toolset or p.GCC]
--		if not toolset then
--			error("Invalid toolset '" + (_OPTIONS.cc or cfg.toolset) + "'")
--		end
--		return toolset
	end

	local function cproject_config_configurationDataProvider(cfg)

		local cfgname = eclipse.cfgname(cfg)
		_p(3, '<storageModule buildSystemId="org.eclipse.cdt.managedbuilder.core.configurationDataProvider" id="%s" moduleId="org.eclipse.cdt.core.settings" name="%s">', cfg.class, cfgname)

		_p(4, '<externalSettings/>')

		_p(4, '<extensions>')
		-- TODO: this can't be right for linux...
		_p(5, '<extension id="org.eclipse.cdt.core.PE" point="org.eclipse.cdt.core.BinaryParser"/>')
		_p(5, '<extension id="org.eclipse.cdt.core.GASErrorParser" point="org.eclipse.cdt.core.ErrorParser"/>')
		_p(5, '<extension id="org.eclipse.cdt.core.GLDErrorParser" point="org.eclipse.cdt.core.ErrorParser"/>')
		_p(5, '<extension id="org.eclipse.cdt.core.GCCErrorParser" point="org.eclipse.cdt.core.ErrorParser"/>')
		_p(4, '</extensions>')

		_p(3, '</storageModule>')
	end

	local function cproject_config_cdtBuildSystem(cfg)
		_p(3, '<storageModule moduleId="cdtBuildSystem" version="4.0.0">')

		-- TODO: lots of stuff...

		_p(3, '</storageModule>')
	end

	local function cproject_config_externalSettings(cfg)
		_p(3, '<storageModule moduleId="org.eclipse.cdt.core.externalSettings"/>')
	end

	local function cproject_configsettings(cfg)

		_x(2, '<cconfiguration id="%s">', cfg.class)

		cproject_config_configurationDataProvider(cfg)
		cproject_config_cdtBuildSystem(cfg)
		cproject_config_externalSettings(cfg)

		_p(2, '</cconfiguration>')
	end

	local function cproject_settings(prj)

		_p(1, '<storageModule moduleId="org.eclipse.cdt.core.settings">')

		for cfg in project.eachconfig(prj) do
			cfg.uid = math.random(2147483647)-1
			cfg.class = eclipse.config_class(cfg)

			cproject_configsettings(cfg)
		end

		_p(1, '</storageModule>')
	end

	local function cproject_cdtbuildsystem(prj)

		_p(1, '<storageModule moduleId="cdtBuildSystem" version="4.0.0">')

		local typeName = eclipse.typename(prj)
		local typeClass = eclipse.typeclass(prj)

		_x(2, '<project id="%s" name="%s" projectType="%s"/>', prj.class, typeName, typeClass)

		_p(1, '</storageModule>')
	end

	local function cproject_scannerconfiguration(prj)

		_p(1, '<storageModule moduleId="scannerConfiguration">')

		_p(2, '<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId=""/>')

-- msvc
--		<scannerConfigBuildInfo instanceId="org.eclipse.cdt.msvc.exe.debug.176944344;org.eclipse.cdt.msvc.exe.debug.176944344.;org.eclipse.cdt.msvc.cl.c.exe.debug.725518222;org.eclipse.cdt.msvc.cl.inputType.c.306700115">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.msw.build.clScannerInfo"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="org.eclipse.cdt.msvc.exe.debug.176944344;org.eclipse.cdt.msvc.exe.debug.176944344.;org.eclipse.cdt.msvc.cl.exe.debug.882832812;org.eclipse.cdt.msvc.cl.inputType.185658992">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.msw.build.clScannerInfo"/>
--		</scannerConfigBuildInfo>

-- gcc
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.exe.release.584194948;cdt.managedbuild.config.gnu.exe.release.584194948.;cdt.managedbuild.tool.gnu.cpp.compiler.exe.release.1075730331;cdt.managedbuild.tool.gnu.cpp.compiler.input.866322608">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileCPP"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.so.release.1023159452;cdt.managedbuild.config.gnu.so.release.1023159452.;cdt.managedbuild.tool.gnu.c.compiler.so.release.1998081228;cdt.managedbuild.tool.gnu.c.compiler.input.497113736">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileC"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.so.release.1023159452;cdt.managedbuild.config.gnu.so.release.1023159452.;cdt.managedbuild.tool.gnu.cpp.compiler.so.release.718275076;cdt.managedbuild.tool.gnu.cpp.compiler.input.242493920">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileCPP"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.so.debug.1274179281;cdt.managedbuild.config.gnu.so.debug.1274179281.;cdt.managedbuild.tool.gnu.cpp.compiler.so.debug.1094801483;cdt.managedbuild.tool.gnu.cpp.compiler.input.1228495640">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileCPP"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.exe.debug.2060505210;cdt.managedbuild.config.gnu.exe.debug.2060505210.;cdt.managedbuild.tool.gnu.cpp.compiler.exe.debug.238488725;cdt.managedbuild.tool.gnu.cpp.compiler.input.349116268">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileCPP"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.exe.debug.2060505210;cdt.managedbuild.config.gnu.exe.debug.2060505210.;cdt.managedbuild.tool.gnu.c.compiler.exe.debug.285834467;cdt.managedbuild.tool.gnu.c.compiler.input.1953979389">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileC"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.so.debug.1274179281;cdt.managedbuild.config.gnu.so.debug.1274179281.;cdt.managedbuild.tool.gnu.c.compiler.so.debug.1035841446;cdt.managedbuild.tool.gnu.c.compiler.input.716557202">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileC"/>
--		</scannerConfigBuildInfo>
--		<scannerConfigBuildInfo instanceId="cdt.managedbuild.config.gnu.exe.release.584194948;cdt.managedbuild.config.gnu.exe.release.584194948.;cdt.managedbuild.tool.gnu.c.compiler.exe.release.421144602;cdt.managedbuild.tool.gnu.c.compiler.input.62034974">
--			<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileC"/>
--		</scannerConfigBuildInfo>

		_p(1, '</storageModule>')
	end

	local function cproject_languagesettingsproviders(prj)
		_p(1, '<storageModule moduleId="org.eclipse.cdt.core.LanguageSettingsProviders"/>')
	end

	local function cproject_refreshscope(prj)

		_p(1, '<storageModule moduleId="refreshScope"/>')

--		_p(1, '<storageModule moduleId="refreshScope" versionNumber="2">')
--		_p(1, '</storageModule>')

-- looks like v2 has configurations
--	<storageModule moduleId="refreshScope" versionNumber="2">
--		<configuration configurationName="Release">
--			<resource resourceType="PROJECT" workspacePath="/cock"/>
--		</configuration>
--		<configuration configurationName="Debug">
--			<resource resourceType="PROJECT" workspacePath="/cock"/>
--		</configuration>
--	</storageModule>

-- v1 has no configurations?
--	<storageModule moduleId="refreshScope" versionNumber="1">
--		<resource resourceType="PROJECT" workspacePath="/udPlatform"/>
--	</storageModule>
	end

	local function cproject_commentownerprojectmappings(prj)
		_p(1, '<storageModule moduleId="org.eclipse.cdt.internal.ui.text.commentOwnerProjectMappings"/>')
	end

--
-- Project: Generate the Eclipse .cproject file.
--
	function eclipse.project.generate_cproj(prj)

		prj.uid = math.random(2147483647)-1
		prj.class = eclipse.project_class(prj)

		_p('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')
		_p('<?fileVersion 4.0.0?>')

		_p('<cproject storage_type_id="org.eclipse.cdt.core.XmlProjectDescriptionStorage">')

		cproject_settings(prj)
		cproject_cdtbuildsystem(prj)
		cproject_scannerconfiguration(prj)
		cproject_languagesettingsproviders(prj)
		cproject_refreshscope(prj)
		cproject_commentownerprojectmappings(prj)

		_p('</cproject>')
	end


--
-- .project stuff
--

	local function project_projects(prj)

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

	local function project_genmakebuilder_arguments(prj)

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

	local function project_genmakebuilder(prj)

		_p(2, '<buildCommand>')
		_p(3, '<name>%s</name>', 'org.eclipse.cdt.managedbuilder.core.genmakebuilder')
		_p(3, '<triggers>%s</triggers>', 'clean,full,incremental,')
		_p(3, '<arguments>')

		project_genmakebuilder_arguments(prj)

		_p(3, '</arguments>')
		_p(2, '</buildCommand>')
	end

	local function project_scannerconfigbuilder(prj)

		_p(2, '<buildCommand>')
		_p(3, '<name>%s</name>', 'org.eclipse.cdt.managedbuilder.core.ScannerConfigBuilder')
		_p(3, '<triggers>%s</triggers>', 'full,incremental,')
		_p(3, '<arguments>')
		_p(3, '</arguments>')
		_p(2, '</buildCommand>')
	end

	local function project_buildspec(prj)

		_p(1, '<buildSpec>')

		project_genmakebuilder(prj)
		project_scannerconfigbuilder(prj)

		_p(1, '</buildSpec>')
	end

	local function project_natures(prj)

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
	function eclipse.project.generate_proj(prj)

		p.eol("\r\n")
		p.indent("\t")
		p.escaper(eclipse.esc)

		_p('<?xml version="1.0" encoding="UTF-8"?>')

		_p('<projectDescription>')

		_x(1, '<name>%s</name>', prj.name)
		_p(1, '<comment></comment>')

		project_projects()
		project_buildspec()
		project_natures()

		_p('</projectDescription>')
	end
