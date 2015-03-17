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

	local function getvalue(v, default, arg, arg2)
		if type(v) == "function" then
			v = v(arg, arg2)
		end
		return v or default
	end

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
				tools = {
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
			},

			clang = {
				project = "",
				config = "",
				extensions = { },
				tools = {
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
				tools = {
					as = {
						name = "GCC Assembler",
						class = "cdt.managedbuild.tool.gnu.assembler.mingw",
						input = "cdt.managedbuild.tool.gnu.assembler.input",
						command = function(cfg)
							if cfg.gccprefix then return cfg.gccprefix .. "as" end
						end,
						options = {
							{
								name = "Assembler flags",
								class = "gnu.both.asm.option.flags",
								type = "string",
							},
							{
								name = "Include paths (-I)",
								class = "gnu.both.asm.option.include.paths",
								type = "includePath",
								value = function(cfg)
									return cfg.includedirs
								end,
							},
							{
								name = "Suppress warnings (-W)",
								class = "gnu.both.asm.option.warnings.nowarn",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.warnings == "Off", "true")
								end,
							},
						},
					},
					ar = {
						name = "GCC Archiver",
						class = "cdt.managedbuild.tool.gnu.archiver.mingw",
						command = function(cfg)
							if cfg.gccprefix then return cfg.gccprefix .. "ar" end
						end,
						buildpair = function(cfg)
							return iif(cfg.project.kind == "StaticLib", cfg.eclipse.buildpair, "base") -- TODO: confirm this is correct
						end,
						options = {
							{
								name = "Archiver flags",
								class = "gnu.both.lib.option.flags",
								type = "string",
							},
						},
					},
					c = {
						name = "GCC C Compiler",
						class = "cdt.managedbuild.tool.gnu.c.compiler.mingw",
						input = "cdt.managedbuild.tool.gnu.c.compiler.input",
						scannerProfile = "org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileC",
						command = function(cfg)
							if cfg.gccprefix then return cfg.gccprefix .. "gcc" end
						end,
						options = {
							{
								name = "Optimization Level",
								class = function(cfg)
									return "gnu.c.compiler.mingw." .. cfg.eclipse.buildpair .. ".option.optimization.level"
								end,
								type = "enumerated",
								default = "gnu.c.optimization.level.none",
								value = function(cfg, optiondesc)
									return optiondesc.values[cfg.optimize]
								end,
								values = {
									Off = "gnu.c.optimization.level.none",		-- -O0
									Debug = "gnu.c.optimization.level.none",	-- -O0
									On = "gnu.c.optimization.level.more",		-- -O2
									Size = "gnu.c.optimization.level.size",		-- -Os
									Speed = "gnu.c.optimization.level.most",	-- -O3
									Full = "gnu.c.optimization.level.most",		-- -O3
--									"gnu.c.optimization.level.optimize"			-- -O1
								},
							},
							{
								name = "Debug Level",
								class = function(cfg)
									return "gnu.c.compiler.mingw." .. cfg.eclipse.buildpair .. ".option.debugging.level"
								end,
								type = "enumerated",
								value = function(cfg)
									return iif(cfg.flags.Symbols, "gnu.c.debugging.level.default")
								end,
								values = {
									"gnu.c.debugging.level.none",
									"gnu.c.debugging.level.minimal",
									"gnu.c.debugging.level.default",
									"gnu.c.debugging.level.max",
								},
							},
							{
								name = "Preprocess only (-E)",
								class = "gnu.c.compiler.option.preprocessor.preprocess",
								type = "boolean",
							},
							{
								name = "Do not search system directories (-nostdinc)",
								class = "gnu.c.compiler.option.preprocessor.nostdinc",
								type = "boolean",
							},
							{
								name = "Defined symbols (-D)",
								class = "gnu.c.compiler.option.preprocessor.def.symbols",
								type = "definedSymbols",
								value = function(cfg)
									return cfg.defines
								end,
							},
							{
								name = "Undefined symbols (-U)",
								class = "gnu.c.compiler.option.preprocessor.undef.symbol",
								type = "undefDefinedSymbols",
								value = function(cfg)
									return cfg.undefines
								end,
							},
							{
								name = "Include paths (-I)",
								class = "gnu.c.compiler.option.include.paths",
								type = "includePath",
								value = function(cfg)
									return cfg.includedirs
								end,
							},
							{
								name = "Include files (-include)",
								class = "gnu.c.compiler.option.include.files",
								type = "includeFiles",
								value = function(cfg)
									return cfg.forceincludes
								end,
							},
							{
								name = "Other optimization flags",
								class = "gnu.c.compiler.option.optimization.flags",
								type = "string",
							},
							{
								name = "Other debugging flags",
								class = "gnu.c.compiler.option.debugging.other",
								type = "string",
							},
							{
								name = "Generate prof information (-p)",
								class = "gnu.c.compiler.option.debugging.prof",
								type = "boolean",
							},
							{
								name = "Generate gprof information (-pg)",
								class = "gnu.c.compiler.option.debugging.gprof",
								type = "boolean",
							},
							{
								name = "Check syntax only (-fsyntax-only)",
								class = "gnu.c.compiler.option.warnings.syntax",
								type = "boolean",
							},
							{
								name = "Pedantic (-pedantic)",
								class = "gnu.c.compiler.option.warnings.pedantic",
								type = "boolean",
							},
							{
								name = "Pedantic warnings as errors (-pedantic-errors)",
								class = "gnu.c.compiler.option.warnings.pedantic.error",
								type = "boolean",
							},
							{
								name = "Inhibit all warnings (-w)",
								class = "gnu.c.compiler.option.warnings.nowarn",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.warnings == "Off", "true")
								end,
							},
							{
								name = "All warnings (-Wall)",
								class = "gnu.c.compiler.option.warnings.allwarn",
								type = "boolean",
							},
							{
								name = "Extra warnings (-Wextra)",
								class = "gnu.c.compiler.option.warnings.extrawarn",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.warnings == "Extra", "true")
								end,
							},
							{
								name = "Warnings as errors (-Werror)",
								class = "gnu.c.compiler.option.warnings.toerrors",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.flags.FatalCompileWarnings, "true")
								end,
							},
							{
								name = "Implicit conversion warnings (-Wconversion)",
								class = "gnu.c.compiler.option.warnings.wconversion",
								type = "boolean",
							},
							{
								name = "Support ANSI programs (-ansi)",
								class = "gnu.c.compiler.option.misc.ansi",
								type = "boolean",
							},
							{
								name = "Position Independent Code (-fPIC)",
								class = "gnu.c.compiler.option.misc.pic",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.kind == "SharedLib" and cfg.system ~= premake.WINDOWS, "true")
								end,
							},
							{
								name = "Other flags",
								class = "gnu.c.compiler.option.misc.other",
								type = "string",
								value = function(cfg)
									return table.implode(cfg.buildoptions, "", "", " ")
								end,
							},
						},
					},
					cpp = {
						name = "GCC C++ Compiler",
						class = "cdt.managedbuild.tool.gnu.cpp.compiler.mingw",
						input = "cdt.managedbuild.tool.gnu.cpp.compiler.input",
						scannerProfile = "org.eclipse.cdt.managedbuilder.core.GCCManagedMakePerProjectProfileCPP",
						command = function(cfg)
							if cfg.gccprefix then return cfg.gccprefix .. "g++" end
						end,
						options = {
							{
								name = "Optimization Level",
								class = function(cfg)
									return "gnu.cpp.compiler.mingw." .. cfg.eclipse.buildpair .. ".option.optimization.level"
								end,
								type = "enumerated",
								value = function(cfg, optiondesc)
									return optiondesc.values[cfg.optimize]
								end,
								values = {
									Off = "gnu.cpp.compiler.optimization.level.none",	-- -O0
									Debug = "gnu.cpp.compiler.optimization.level.none",	-- -O0
									On = "gnu.cpp.compiler.optimization.level.more",	-- -O2
									Size = "gnu.cpp.compiler.optimization.level.size",	-- -Os
									Speed = "gnu.cpp.compiler.optimization.level.most",	-- -O3
									Full = "gnu.cpp.compiler.optimization.level.most",	-- -O3
--									"gnu.cpp.compiler.optimization.level.optimize"		-- -O1
								},
							},
							{
								name = "Debug Level",
								class = function(cfg)
									return "gnu.cpp.compiler.mingw." .. cfg.eclipse.buildpair .. ".option.debugging.level"
								end,
								type = "enumerated",
								value = function(cfg)
									return iif(cfg.flags.Symbols, "gnu.cpp.compiler.debugging.level.default")
								end,
								values = {
									"gnu.cpp.compiler.debugging.level.none",
									"gnu.cpp.compiler.debugging.level.minimal",
									"gnu.cpp.compiler.debugging.level.default",
									"gnu.cpp.compiler.debugging.level.max",
								},
							},
							{
								name = "Do not search system directories (-nostdinc)",
								class = "gnu.cpp.compiler.option.preprocessor.nostdinc",
								type = "boolean",
							},
							{
								name = "Preprocess only (-E)",
								class = "gnu.cpp.compiler.option.preprocessor.preprocess",
								type = "boolean",
							},
							{
								name = "Defined symbols (-D)",
								class = "gnu.cpp.compiler.option.preprocessor.def",
								type = "definedSymbols",
								value = function(cfg)
									return cfg.defines
								end,
							},
							{
								name = "Undefined symbols (-U)",
								class = "gnu.cpp.compiler.option.preprocessor.undef",
								type = "undefDefinedSymbols",
								value = function(cfg)
									return cfg.undefines
								end,
							},
							{
								name = "Include paths (-I)",
								class = "gnu.cpp.compiler.option.include.paths",
								type = "includePath",
								value = function(cfg)
									return cfg.includedirs
								end,
							},
							{
								name = "Include files (-include)",
								class = "gnu.cpp.compiler.option.include.files",
								type = "includeFiles",
								value = function(cfg)
									return cfg.forceincludes
								end,
							},
							{
								name = "Other optimization flags",
								class = "gnu.cpp.compiler.option.optimization.flags",
								type = "string",
							},
							{
								name = "Other debugging flags",
								class = "gnu.cpp.compiler.option.debugging.other",
								type = "string",
							},
							{
								name = "Generate prof information (-p)",
								class = "gnu.cpp.compiler.option.debugging.prof",
								type = "boolean",
							},
							{
								name = "Generate gprof information (-pg)",
								class = "gnu.cpp.compiler.option.debugging.gprof",
								type = "boolean",
							},
							{
								name = "Check syntax only (-fsyntax-only)",
								class = "gnu.cpp.compiler.option.warnings.syntax",
								type = "boolean",
							},
							{
								name = "Pedantic (-pedantic)",
								class = "gnu.cpp.compiler.option.warnings.pedantic",
								type = "boolean",
							},
							{
								name = "Pedantic warnings as errors (-pedantic-errors)",
								class = "gnu.cpp.compiler.option.warnings.pedantic.error",
								type = "boolean",
							},
							{
								name = "Inhibit all warnings (-w)",
								class = "gnu.cpp.compiler.option.warnings.nowarn",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.warnings == "Off", "true")
								end,
							},
							{
								name = "All warnings (-Wall)",
								class = "gnu.cpp.compiler.option.warnings.allwarn", -- *****
								type = "boolean",
							},
							{
								name = "Extra warnings (-Wextra)",
								class = "gnu.cpp.compiler.option.warnings.extrawarn",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.warnings == "Extra", "true")
								end,
							},
							{
								name = "Warnings as errors (-Werror)",
								class = "gnu.cpp.compiler.option.warnings.toerrors",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.flags.FatalCompileWarnings, "true")
								end,
							},
							{
								name = "Implicit conversion warnings (-Wconversion)",
								class = "gnu.cpp.compiler.option.warnings.wconversion",
								type = "boolean",
							},
							{
								name = "Position Independent Code (-fPIC)",
								class = "gnu.cpp.compiler.option.other.pic",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.kind == "SharedLib" and cfg.system ~= premake.WINDOWS, "true")
								end,
							},
							{
								name = "Other flags",
								class = "gnu.cpp.compiler.option.other.other",
								type = "string",
								value = function(cfg)
									return table.implode(cfg.buildoptions, "", "", " ")
								end,
							},
						},
					},
					ld = {
						name = "MinGW C Linker",
						class = "cdt.managedbuild.tool.gnu.c.linker.mingw",
						input = "cdt.managedbuild.tool.gnu.c.linker.input",
						command = function(cfg)
							if cfg.gccprefix then return cfg.gccprefix .. "gcc" end	-- should we use ld? eclipse seems to link with the compiler
						end,
						buildpair = function(cfg)
							return iif(cfg.project.kind == "StaticLib", "base", cfg.eclipse.buildpair) -- TODO: confirm this is correct
						end,
						options = {
						},
					},
					ldpp = {
						name = "MinGW C++ Linker",
						class = "cdt.managedbuild.tool.gnu.cpp.linker.mingw",
						input = "cdt.managedbuild.tool.gnu.cpp.linker.input",
						command = function(cfg)
							if cfg.gccprefix then return cfg.gccprefix .. "g++" end	-- should we use ld? eclipse seems to link with the compiler
						end,
						buildpair = function(cfg)
							return iif(cfg.project.kind == "StaticLib", "base", cfg.eclipse.buildpair) -- TODO: confirm this is correct
						end,
						options = {
							{
								name = "Libraries (-l)",
								class = "gnu.cpp.link.option.libs",
								type = "libs",
								value = function(cfg)
									-- TODO: only system libs (no siblings)
									return cfg.links
								end,
							},
							{
								name = "Other objects",
								class = "gnu.cpp.link.option.userobjs",
								type = "userObjs",
								value = function(cfg)
									-- TODO: sibling libs (relative path, full filename)
									return nil
								end,
							},
							{
								name = "Do not use standard start files (-nostartfiles)",
								class = "gnu.cpp.link.option.nostart",
								type = "boolean",
							},
							{
								name = "Do not use default libraries (-nodefaultlibs)",
								class = "gnu.cpp.link.option.nodeflibs",
								type = "boolean",
							},
							{
								name = "No startup or default libs (-nostdlib)",
								class = "gnu.cpp.link.option.nostdlibs",
								type = "boolean",
							},
							{
								name = "Omit all symbol information (-s)",
								class = "gnu.cpp.link.option.strip",
								type = "boolean",
							},
							{
								name = "Library search path (-L)",
								class = "gnu.cpp.link.option.paths",
								type = "libPaths",
								value = function(cfg)
									return cfg.libdirs
								end,
							},
							{
								name = "Linker flags",
								class = "gnu.cpp.link.option.flags",
								type = "string",
								value = function(cfg)
									return table.implode(cfg.linkoptions, "", "", " ")
								end,
							},
							{
								name = "Other options (-Xlinker [option])",
								class = "gnu.cpp.link.option.other",
								type = "stringList",
							},
							{
								name = "Shared (-shared)",
								class = "gnu.cpp.link.option.shared",
								type = "boolean",
								value = function(cfg)
									return iif(cfg.kind == "SharedLib", "true")
								end,
							},
							{
								name = "Shared object name (-Wl,-soname=)",
								class = "gnu.cpp.link.option.soname",
								type = "string",
							},
							{
								name = "Import Library name (-Wl,--out-implib=)",
								class = "gnu.cpp.link.option.implname",
								type = "string",
							},
							{
								name = "DEF file name (-Wl,--output-def=)",
								class = "gnu.cpp.link.option.defname",
								type = "string",
							},
							{
								name = "Generate prof information (-p)",
								class = "gnu.cpp.link.option.debugging.prof",
								type = "boolean",
							},
							{
								name = "Generate gprof information (-pg)",
								class = "gnu.cpp.link.option.debugging.gprof",
								type = "boolean",
							},
						},
					},
				},
			},

			cygwin = {
				project = "",
				config = "",
				extensions = { },
				tools = {
				},
			},

			osx = {
				name = "MacOSX GCC",
				project = "cdt.managedbuild.target.gnu.macosx",
				config = "cdt.managedbuild.config.gnu.macosx",
				extensions = { "elf", "gas", "gmake", "gld", "cwd", "gcc" },
				tools = {
				},
			},

			msc = {
				project = "org.eclipse.cdt.msvc.projectType",
				config = "", -- ??? perhaps: org.eclipse.cdt.msvc
				extensions = { "pe" },
				tools = {
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
		_p(7, '<targetPlatform id="%s.%s.%s" name="Debug Platform" superClass="%s.%s"/>', e.toolset.target, e.buildpair, eclipse.uid(), e.toolset.target, e.buildpair)
	end

	function m.cproject.toolchain_builder(cfg)
		local e = cfg.eclipse
		local path = "${workspace_loc:/e_app}/Debug" -- TODO: path is wrong!
		local type = e.type or "base" -- TODO: when is 'base' used?!
		_p(7, '<builder buildPath="%s" id="%s.%s.%s" keepEnvironmentInBuildfile="false" managedBuildOn="true" name="CDT Internal Builder" superClass="%s.%s"/>', path, e.toolset.builder, type, eclipse.uid(), e.toolset.builder, type)
	end

	function m.cproject.tool_option(cfg, optiondesc, value)
		local class = getvalue(optiondesc.class, nil, cfg, optiondesc)
		value = getvalue(optiondesc.value, value, cfg, optiondesc)
		if value == "" or (type(value) == "table" and table.isempty(value)) then
			value = nil
		end
		if value and optiondesc.format then
			value = optiondesc.format(value, cfg, optiondesc)
		end

		local isList = type(value) == "table"

		local valueField = ""
		local defaultField = ""
		if not value then
			if optiondesc.default then
				defaultField = 'defaultValue="' .. optiondesc.default .. '" '
			else
				return
			end
		elseif not isList then
			valueField = 'value="' .. value .. '" '
		end

		_x(8, '<option %sid="%s.%s" name="%s" superClass="%s" %svalueType="%s"%s>', defaultField, class, eclipse.uid(), optiondesc.name, class, valueField, optiondesc.type, iif(isList, "", "/"))
		if isList then
			for _, v in ipairs(value) do
				_x(9, '<listOptionValue builtIn="false" value="%s"/>', v)
			end
			_p(8, '</option>')
		end
	end

	function m.cproject.toolchain_tool(cfg, tool, name)
		local e = cfg.eclipse

		local buildpair = getvalue(tool.buildpair, e.buildpair, cfg)
		local hasOptions = buildpair ~= "base"

		local command = getvalue(tool.command, nil, cfg)
		if command then
			command = 'command="' .. command .. '" '
		else
			command = ""
		end

		-- TODO: work out error parser
		local errorParser = "" -- 'errorParsers="org.eclipse.cdt.core.GLDErrorParser" '

		local uid = iif(name == "c", e.c.uid, nil) or iif(name == "cpp", e.cpp.uid, nil) or eclipse.uid()

		_p(7, '<tool %s%sid="%s.%s.%s" name="%s" superClass="%s.%s"%s>', command, errorParser, tool.class, buildpair, uid, tool.name, tool.class, buildpair, iif(not hasOptions, "/", ""))

		if hasOptions then
			for _, opt in ipairs(tool.options) do
				m.cproject.tool_option(cfg, opt)
			end
			if tool.input then
				-- TODO: this shouldn't always be present...
				uid = iif(name == "c", e.c.inputuid, nil) or iif(name == "cpp", e.cpp.inputuid, nil) or eclipse.uid()
				_p(8, '<inputType id="%s.%s" superClass="%s"/>', tool.input, uid, tool.input)
			end
			_p(7, '</tool>')
		end
	end

	function m.cproject.config_cdtBuildSystem(cfg)

		local e = cfg.eclipse

		local cfgname = eclipse.cfgname(cfg)

		-- TODO:
		local extension = "" -- 'artifactExtension="dll" ' -- .dll/.a both seem to use this...
		local cleanCmd = "rm -rf"
		local description = ""

		local buildEvents = ""
		if cfg.postbuildmessage then
			buildEvents = buildEvents .. ' postannouncebuildStep="' .. cfg.postbuildmessage .. '"'
		end
		if cfg.postbuildcommands then
-- TODO: eclipse seems to only execute one command, but we have a table
--			buildEvents = buildEvents .. ' postbuildStep="' .. cfg.postbuildcommands .. '"'
		end
		if cfg.prebuildmessage then
			buildEvents = buildEvents .. ' preannouncebuildStep="' .. cfg.prebuildmessage .. '"'
		end
		if cfg.prebuildcommands then
-- TODO: eclipse seems to only execute one command, but we have a table
--			buildEvents = buildEvents .. ' prebuildStep="' .. cfg.prebuildcommands .. '"'
		end

		-- TODO: GAS, GCC, GLD all have error parsers...
		local errorParser = "" -- 'errorParsers="org.eclipse.cdt.core.GASErrorParser;org.eclipse.cdt.core.GLDErrorParser;org.eclipse.cdt.core.GCCErrorParser" '

		_p(3, '<storageModule moduleId="cdtBuildSystem" version="4.0.0">')
		_x(4, '<configuration %sartifactName="${ProjName}" buildArtefactType="org.eclipse.cdt.build.core.buildArtefactType.%s" buildProperties="org.eclipse.cdt.build.core.buildArtefactType=org.eclipse.cdt.build.core.buildArtefactType.%s,org.eclipse.cdt.build.core.buildType=org.eclipse.cdt.build.core.buildType.%s" cleanCommand="%s" description="%s" %sid="%s" name="%s" parent="%s.%s"%s>',
			extension, e.type, e.type, e.build, cleanCmd, description, errorParser, e.class, cfgname, e.toolset.config, e.buildpair, buildEvents)
		_p(5, '<folderInfo id="%s." name="/" resourcePath="">', e.class)
		_p(6, '<toolChain id="%s.%s.%s" name="%s" superClass="%s.%s">', e.toolset.class, e.buildpair, eclipse.uid(), e.toolset.name, e.toolset.class, e.buildpair)

		m.cproject.toolchain_targetPlatform(cfg)
		m.cproject.toolchain_builder(cfg)

		for _, tool in ipairs({ "as", "ar", "c", "cpp", "ld", "ldpp" }) do
			m.cproject.toolchain_tool(cfg, e.toolset.tools[tool], tool)
		end

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

			local e = cfg.eclipse
			e.uid = eclipse.uid()
			e.compiler = m.getcompiler() -- TODO: this sucks!
			e.toolset = m.cdt.toolsets[e.compiler]
			e.type = prj.eclipse.type

			if not e.toolset or not e.type then
				error("Invalid compiler for config: " .. compiler)
			end

			e.build = m.build(cfg)
			e.buildpair = e.type .. "." .. e.build
			e.class = e.toolset.config .. "." .. e.buildpair .. "." .. e.uid

			e.c = {}
			e.c.uid = eclipse.uid()
			e.c.inputuid = eclipse.uid()
			e.cpp = {}
			e.cpp.uid = eclipse.uid()
			e.cpp.inputuid = eclipse.uid()

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
				local tool = e.toolset.tools[cc]
				if tool then
					local compiler = tool.class .. "." .. e.buildpair .. "." .. e[cc].uid
					local input = tool.input .. "." .. e[cc].inputuid
					_p(2, '<scannerConfigBuildInfo instanceId="%s;%s.;%s;%s">', e.class, e.class, compiler, input)
					_p(3, '<autodiscovery enabled="true" problemReportingEnabled="true" selectedProfileId="%s"/>', tool.scannerProfile)
					_p(2, '</scannerConfigBuildInfo>')
				end
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
