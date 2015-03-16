--
-- Name:        actions/eclipse_cproject.lua
-- Purpose:     Generate a Eclipse .cproject file.
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

	m.cdt = {
		types = {
			WindowedApp	= "exe",
			ConsoleApp	= "exe",
			Makefile	= "", -- TODO??
			SharedLib	= "so", -- /dll??
			StaticLib	= "lib",
		},

		typenames = {
			WindowedApp	= "Executable",
			ConsoleApp	= "Executable",
			Makefile	= "", -- TODO??
			SharedLib	= "Shared Library",
			StaticLib	= "Static Library",
		},

		extensions = {
			pe = { id = "org.eclipse.cdt.core.PE", point = "org.eclipse.cdt.core.BinaryParser" },
			elf = { id = "org.eclipse.cdt.core.ELF", point = "org.eclipse.cdt.core.BinaryParser" },
			macho = { id = "org.eclipse.cdt.core.MachO64", point = "org.eclipse.cdt.core.BinaryParser" },
			gas = { id = "org.eclipse.cdt.core.GASErrorParser", point = "org.eclipse.cdt.core.ErrorParser" },
			gld = { id = "org.eclipse.cdt.core.GLDErrorParser", point = "org.eclipse.cdt.core.ErrorParser" },
			gcc = { id = "org.eclipse.cdt.core.GCCErrorParser", point = "org.eclipse.cdt.core.ErrorParser" },
			gmake = { id = "org.eclipse.cdt.core.GmakeErrorParser", point = "org.eclipse.cdt.core.ErrorParser" },
			cwd = { id = "org.eclipse.cdt.core.CWDLocator", point = "org.eclipse.cdt.core.ErrorParser" },
		},

		toolsets = {
			gcc = {
				name = "Linux GCC",
				project = "cdt.managedbuild.target.gnu",
				config = "cdt.managedbuild.config.gnu",
				extensions = { "elf", "gas", "gmake", "gld", "cwd", "gcc" },
				class = "cdt.managedbuild.toolchain.gnu",
				target = "cdt.managedbuild.target.gnu.platform",
				as = {
					class = "cdt.managedbuild.tool.gnu.assembler",
				},
				ar = {
					class = "cdt.managedbuild.tool.gnu.archiver",
				},
				c = {
					class = "cdt.managedbuild.tool.gnu.c.compiler",
					scannerProfile = ""
				},
				cpp = {
					class = "cdt.managedbuild.tool.gnu.cpp.compiler",
					scannerProfile = ""
				},
				ld = {
					class = "cdt.managedbuild.tool.gnu.c.linker",
				},
				ldpp = {
					class = "cdt.managedbuild.tool.gnu.cpp.linker",
				},
			},
			clang = {
				project = "",
				config = "",
				extensions = { },
				c = {
					scannerProfile = ""
				},
				cpp = {
					scannerProfile = ""
				},
			},
			mingw = {
				name = "MinGW GCC",
				project = "cdt.managedbuild.target.gnu.mingw",
				config = "cdt.managedbuild.config.gnu.mingw",
				extensions = { "pe", "gas", "gld", "gcc" },
				class = "cdt.managedbuild.toolchain.gnu.mingw",
				target = "cdt.managedbuild.target.gnu.platform.mingw",
				builder = "cdt.managedbuild.tool.gnu.builder.mingw",
				as = {
					name = "GCC Assembler",
					class = "cdt.managedbuild.tool.gnu.assembler.mingw",
					input = "cdt.managedbuild.tool.gnu.assembler.input",
				},
				ar = {
					name = "GCC Archiver",
					class = "cdt.managedbuild.tool.gnu.archiver.mingw",
				},
				c = {
					name = "GCC C Compiler",
					class = "cdt.managedbuild.tool.gnu.c.compiler.mingw",
					input = "cdt.managedbuild.tool.gnu.c.compiler.input",
					scannerProfile = "org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileC",
				},
				cpp = {
					name = "GCC C++ Compiler",
					class = "cdt.managedbuild.tool.gnu.cpp.compiler.mingw",
					input = "cdt.managedbuild.tool.gnu.cpp.compiler.input",
					scannerProfile = "org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileCPP",
				},
				ld = {
					name = "MinGW C Linker",
					class = "cdt.managedbuild.tool.gnu.c.linker.mingw",
					input = "cdt.managedbuild.tool.gnu.c.linker.input",
				},
				ldpp = {
					name = "MinGW C++ Linker",
					class = "cdt.managedbuild.tool.gnu.cpp.linker.mingw",
					input = "cdt.managedbuild.tool.gnu.cpp.linker.input",
				},
			},
			cygwin = {
				project = "",
				config = "",
				extensions = { },
				c = {
					scannerProfile = ""
				},
				cpp = {
					scannerProfile = ""
				},
			},
			osx = {
				name = "MacOSX GCC",
				project = "cdt.managedbuild.target.gnu.macosx",
				config = "cdt.managedbuild.config.gnu.macosx",
				extensions = { "elf", "gas", "gmake", "gld", "cwd", "gcc" },
				c = {
					scannerProfile = ""
				},
				cpp = {
					scannerProfile = ""
				},
			},
			msc = {
				project = "org.eclipse.cdt.msvc.projectType",
				config = "", -- ??? perhaps: org.eclipse.cdt.msvc
				extensions = { "pe" },
				c = {
					class = "org.eclipse.cdt.msvc.cl.c",
					input = "org.eclipse.cdt.msvc.cl.inputType.c",
					scannerProfile = "org.eclipse.cdt.msw.build.clScannerInfo",
				},
				cpp = {
					class = "org.eclipse.cdt.msvc.cl",
					input = "org.eclipse.cdt.msvc.cl.inputType",
					scannerProfile = "org.eclipse.cdt.msw.build.clScannerInfo",
				},
			},
		},
	}


	function m.build(cfg)
		return "debug" -- TODO: detect 'release' somehow...
	end

	function m.cfgname(cfg)
		local cfgname = cfg.buildcfg
		-- TODO: multi-platform builds need a matrix of configs...
--		if codelite.solution.multiplePlatforms then
--			cfgname = string.format("%s|%s", cfg.platform, cfg.buildcfg)
--		end
		return cfgname
	end

	function m.getcompiler()
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

	function m.cproject.config_configurationDataProvider(cfg)

		local cfgname = eclipse.cfgname(cfg)

		_p(3, '<storageModule buildSystemId="org.eclipse.cdt.managedbuilder.core.configurationDataProvider" id="%s" moduleId="org.eclipse.cdt.core.settings" name="%s">', cfg.eclipse.class, cfgname)
		_p(4, '<externalSettings/>')
		_p(4, '<extensions>')
		for _, extension in ipairs(cfg.eclipse.toolset.extensions) do
			local ext = eclipse.cdt.extensions[extension]
			_p(5, '<extension id="%s" point="%s"/>', ext.id, ext.point)
		end
		_p(4, '</extensions>')
		_p(3, '</storageModule>')
	end

	function m.cproject.toolchain_targetPlatform(cfg)
		local e = cfg.eclipse
		_p(7, '<targetPlatform id="%s.%s.%s.%s" name="Debug Platform" superClass="%s.%s.%s"/>', e.toolset.target, e.type, e.build, eclipse.uid(), e.toolset.target, e.type, e.build)
	end
	function m.cproject.toolchain_builder(cfg)
		local e = cfg.eclipse
		local path = "${workspace_loc:/e_app}/Debug" -- TODO: path is wrong!
		local type = e.type or "base" -- TODO: when is 'base' used?!
		_p(7, '<builder buildPath="%s" id="%s.%s.%s" keepEnvironmentInBuildfile="false" managedBuildOn="true" name="CDT Internal Builder" superClass="%s.%s"/>', path, e.toolset.builder, type, eclipse.uid(), e.toolset.builder, type)
	end
	function m.cproject.toolchain_assembler(cfg)
		local e = cfg.eclipse
		_p(7, '<tool id="%s.%s.%s.%s" name="%s" superClass="%s.%s.%s">', e.toolset.as.class, e.type, e.build, eclipse.uid(), e.toolset.as.name, e.toolset.as.class, e.type, e.build)
		_p(8, '<inputType id="%s.%s" superClass="%s"/>', e.toolset.as.class, eclipse.uid(), e.toolset.as.class)
		_p(7, '</tool>')
	end
	function m.cproject.toolchain_archiver(cfg)
		local e = cfg.eclipse
		local type = iif(cfg.project.kind == "StaticLib", e.type .. "." .. e.build, "base") -- TODO: confirm this is correct
		_p(7, '<tool id="%s.%s.%s" name="%s" superClass="%s.%s"/>', e.toolset.ar.class, type, eclipse.uid(), e.toolset.ar.name, e.toolset.ar.class, type)
	end
	function m.cproject.toolchain_cc(cfg, cc)
		local e = cfg.eclipse
		_p(7, '<tool id="%s.%s.%s.%s" name="%s" superClass="%s.%s.%s">', e.toolset[cc].class, e.type, e.build, e[cc].uid, e.toolset[cc].name, e.toolset[cc].class, e.type, e.build)

		-- many options...

		_p(8, '<inputType id="%s.%s" superClass="%s"/>', e.toolset[cc].class, e[cc].inputuid, e.toolset[cc].class)
		_p(7, '</tool>')
	end
	function m.cproject.toolchain_ld(cfg)
		local e = cfg.eclipse
		local type = iif(cfg.project.kind == "StaticLib", "base", e.type .. "." .. e.build) -- TODO: confirm this is correct
		-- TODO
	end
	function m.cproject.toolchain_ldpp(cfg)
		-- TODO
	end

	function m.cproject.config_cdtBuildSystem(cfg)

		local cfgname = eclipse.cfgname(cfg)

		-- TODO:
		local extension = "" -- 'artifactExtension="dll" ' -- .dll/.a both seem to use this...
		local cleanCmd = "rm -rf"
		local description = ""

		local e = cfg.eclipse

		_p(3, '<storageModule moduleId="cdtBuildSystem" version="4.0.0">')
		_p(4, '<configuration %sartifactName="${ProjName}" buildArtefactType="org.eclipse.cdt.build.core.buildArtefactType.%s" buildProperties="org.eclipse.cdt.build.core.buildArtefactType=org.eclipse.cdt.build.core.buildArtefactType.%s,org.eclipse.cdt.build.core.buildType=org.eclipse.cdt.build.core.buildType.%s" cleanCommand="%s" description="%s" id="%s" name="%s" parent="%s.%s.%s">',
			extension, e.type, e.type, e.build, cleanCmd, description, e.class, cfgname, e.toolset.config, e.type, e.build)
		_p(5, '<folderInfo id="%s." name="/" resourcePath="">', e.class)
		_p(6, '<toolChain id="%s.%s.%s.%s" name="%s" superClass="%s.%s.%s">', e.toolset.class, e.type, e.build, eclipse.uid(), e.toolset.name, e.toolset.class, e.type, e.build)

		m.cproject.toolchain_targetPlatform(cfg)
		m.cproject.toolchain_builder(cfg)
		m.cproject.toolchain_assembler(cfg)
		m.cproject.toolchain_archiver(cfg)
		m.cproject.toolchain_cc(cfg, "c")
		m.cproject.toolchain_cc(cfg, "cpp")
		m.cproject.toolchain_ld(cfg)
		m.cproject.toolchain_ldpp(cfg)

		_p(6, '</toolChain>')
		_p(5, '</folderInfo>')
		_p(4, '</configuration>')
		_p(3, '</storageModule>')
	end

	function m.cproject.config_externalSettings(cfg)
		_p(3, '<storageModule moduleId="org.eclipse.cdt.core.externalSettings"/>')
	end

	function m.cproject.configsettings(cfg)

		_x(2, '<cconfiguration id="%s">', cfg.eclipse.class)

		m.cproject.config_configurationDataProvider(cfg)
		m.cproject.config_cdtBuildSystem(cfg)
		m.cproject.config_externalSettings(cfg)

		_p(2, '</cconfiguration>')
	end

	function m.cproject.settings(prj)

		_p(1, '<storageModule moduleId="org.eclipse.cdt.core.settings">')

		for cfg in project.eachconfig(prj) do

			-- populate the cfg with eclipse stuff...
			cfg.eclipse = {}
			cfg.eclipse.uid = eclipse.uid()
			cfg.eclipse.compiler = m.getcompiler() -- TODO: this sucks!
			cfg.eclipse.toolset = m.cdt.toolsets[cfg.eclipse.compiler]
			cfg.eclipse.type = prj.eclipse.type
			cfg.eclipse.build = m.build(cfg)
			cfg.eclipse.class = cfg.eclipse.toolset.config .. "." .. cfg.eclipse.type .. "." .. cfg.eclipse.build .. "." .. cfg.eclipse.uid

			cfg.eclipse.c = {}
			cfg.eclipse.c.uid = eclipse.uid()
			cfg.eclipse.c.inputuid = eclipse.uid()
			cfg.eclipse.cpp = {}
			cfg.eclipse.cpp.uid = eclipse.uid()
			cfg.eclipse.cpp.inputuid = eclipse.uid()

			if not cfg.eclipse.toolset or not cfg.eclipse.type then
				error("Invalid compiler for config: " .. compiler)
			end

			m.cproject.configsettings(cfg)
		end

		_p(1, '</storageModule>')
	end

	function m.cproject.cdtbuildsystem(prj)

		_p(1, '<storageModule moduleId="cdtBuildSystem" version="4.0.0">')

		_x(2, '<project id="%s" name="%s" projectType="%s.%s"/>', prj.eclipse.class, m.cdt.typenames[prj.kind], prj.eclipse.toolset.project, prj.eclipse.type)

		_p(1, '</storageModule>')
	end

	function m.cproject.scannerconfiguration(prj)

		_p(1, '<storageModule moduleId="scannerConfiguration">')

		_p(2, '<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId=""/>')

		for cfg in project.eachconfig(prj) do
			local e = cfg.eclipse
			for _, cc in ipairs({ "cpp", "c" }) do
				local compiler = e.toolset[cc].class .. "." .. e.type .. "." .. e.build .. "." .. e[cc].uid
				local input = e.toolset[cc].input .. "." .. e[cc].inputuid
				_p(2, '<scannerConfigBuildInfo instanceId="%s;%s.;%s;%s">', e.class, e.class, compiler, input)
				_p(3, '<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="%s"/>', e.toolset[cc].scannerProfile)
				_p(2, '</scannerConfigBuildInfo>')
			end
		end

		_p(1, '</storageModule>')
	end

	function m.cproject.languagesettingsproviders(prj)
		_p(1, '<storageModule moduleId="org.eclipse.cdt.core.LanguageSettingsProviders"/>')
	end

	function m.cproject.refreshscope(prj)

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

	function m.cproject.commentownerprojectmappings(prj)
		_p(1, '<storageModule moduleId="org.eclipse.cdt.internal.ui.text.commentOwnerProjectMappings"/>')
	end

--
-- Project: Generate the Eclipse .cproject file.
--
	function m.cproject.generate(prj)

		p.eol("\r\n")
		p.indent("\t")
		p.escaper(eclipse.esc)

		prj.eclipse = {}
		prj.eclipse.uid = eclipse.uid()
		prj.eclipse.compiler = m.getcompiler() -- TODO: this sucks!
		prj.eclipse.toolset = m.cdt.toolsets[prj.eclipse.compiler]
		prj.eclipse.type = m.cdt.types[prj.kind]
		prj.eclipse.class = prj.name .. "." .. prj.eclipse.toolset.project .. "." .. prj.eclipse.type .. "." .. prj.eclipse.uid

		_p('<?xml version="1.0" encoding="UTF-8" standalone="no"?>')
		_p('<?fileVersion 4.0.0?>')

		_p('<cproject storage_type_id="org.eclipse.cdt.core.XmlProjectDescriptionStorage">')

		m.cproject.settings(prj)
		m.cproject.cdtbuildsystem(prj)
		m.cproject.scannerconfiguration(prj)
		m.cproject.languagesettingsproviders(prj)
		m.cproject.refreshscope(prj)
		m.cproject.commentownerprojectmappings(prj)

		_p('</cproject>')
	end
