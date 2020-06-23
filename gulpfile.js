/**
 * ROKU apps builder
 *  this is a part of my old script for build, manipulate with packages and deploys pkg to ROKU
 */

const _localConfigurationFile = "./rokudeploy.json";
const _localBuildConfigurationFileName = "buildConfig.json";
const argv = require('yargs').argv;
const gulp = require('gulp');
const series = gulp.series;
const RooibosProcessor = require('rooibos-preprocessor').RooibosProcessor;
const createProcessorConfig = require('rooibos-preprocessor').createProcessorConfig;
const normalizePath = require('normalize-path');
const parsePath = require('parse-filepath');
const rokuDeploy = require('roku-deploy');
const fs = require('file-system');
const replaceInFile = require('replace-in-file');
const archiver = require('archiver');
const mustache = require("gulp-mustache");
const childProcess = require("child_process");
const glob = require('glob');
const path = require("path");
const rmLines = require('gulp-rm-lines');
const noOp = function(){};


var config = {
	production:     !!argv.production,                       //generate production version?

	appstore:       "./apps/",                            // path to appstore directory (ROKUAPPS git checkout directory)
	out:        	"./out/",                        		 // directory for compilation IL or APP
	dist:       	"./dist/",                               // directory to put compiled packages

	localData: 		require(_localConfigurationFile),

    appManifest:    "manifest",                              // manifest file in application file structure
	appName:   		argv.appname || argv.appName || "app",
	appSrc:    		argv.appsrc  || argv.appSrc  || argv.appSRC || "--empty--",
	appDest:   		argv.appdest || argv.appDest || argv.appDEST|| "--empty--",

	_src:			argv.src     || "--empty--",
	_dest:			argv.dest    || "--empty--"
};

var isWin = process.platform === "win32",
	rooibosConfig;

if (config.production === true) {
	console.log("---> PRODUCTION VERSION <---");
}


/**
 * Build application
 */
async function buildApp(cb) {
	var f, i, len;

	if (config.appDest === "--empty--") {
		if (config._dest === "--empty--") {
			config.appDest = config.dist + config.appName + ".zip";
		} else {
			config.appDest = normalizePath(config._dest);
		}
	}

	if (config.appSrc === "--empty--") {
		if (config._src === "--empty--") {
			config.appSrc = config.appstore + config.appName + "/";
		} else {
			config.appSrc = normalizePath(config._src + "/")
		}
	}

    rewrite_config_from_app_build_configuration();

	console.info("Building App '" + config.appName);

	fs.copySync(                                		//copy all files from application store
		normalizePath(config.appSrc),
		normalizePath(config.out),
        {
			filter: [
				"**/*.*", "*.*",
    			"!buildConfig.json"
			]
		}
	);                                                                                                                                        

	_manifestUpdate(config.out + config.appManifest);   //update manifest file

	if (config.production === true) {                                                   
			
		try {
			replaceInFile.sync({
				files: config.out + config.appManifest,
				from:  /(bs_const=DEBUG=true)/g,                                         
				to:    "bs_const=DEBUG=false"
			});
		}
		catch (error) {
			console.error("Error in manifest DEBUG update", error);
		}
	
//        lintCheck(noOp, true);
//
//		_minify(
//			normalizePath(config.out + "**/*.brs"),
//			normalizePath(config.out)
//		);
	}

	await _createPackage(config.appDest);          		//create zip package

	config.appSrc = config.appDest; 	//for possible calling deployApp in chain of functions

	cb();
};




/**
 * Update build_version to actual timestamp in ROKU manifest file
 */
function _manifestUpdate(fileName) {
	var timestamp = Math.floor(new Date() / 1000);

	try {
		replaceInFile.sync({
			files: fileName,
			from:  /(build_version=\d+)/g,                                         
			to:    "build_version=" + timestamp
		});
	}
	catch (error) {
		console.error("Error in manifest build_version update [03:00]", error);
	}
};


/**
 * Create ZIP package from ./out/ directory
 */
function _createPackage(destination) {
	return new Promise((resolve, reject) => {
		var output = fs.createWriteStream(destination),
			archive = archiver("zip");

		output.on('close', () => {
			resolve();
		});

		output.on('error', (err) => {
			console.error("Error in creating ZIP package [04:00]", err);
			reject(err);
		});

		archive.on('warning', (err) => {
			if (err.code === 'ENOENT') {
				console.error("Error in creating ZIP package [04:01]", err);
			} else {
				reject(err);
			}
		});

		archive.on('error', (err) => {
			console.error("Error in creating ZIP package [04:02]", err);
			reject(err);
		});

		archive.pipe(output);
		archive.directory(config.out, false);

		//finalize the archive
		archive.finalize();
	});
};


/**
 * Check all *.brs with linter
 *  - run BRS linter to each .brs file in config.out directory
 *  - in silent mode write to console only final statistics
 */
function lintCheck(cb, silent) {
	cb();
};


/**
 * Format all *.brs - use identLength tab for indent
 */
function formatBrsFiles(cb) {
	cb();
}

/**
 * Format all *.brs - use indentLength tab for indent
 *  indentLength=0  - disable formatting (now have problems, sets to 1 space)
 */
function _formatBrs(silent, src, indentLength) {
};


/**
 * Set default configuration for tests
 */
function prepareTests(cb) {
}

/**
 * Set default configuration for tests code coverage
 */
function prepareCoverage(cb) {
}


/**
 * Build Rooibos tests
 */
async function buildTests(cb) {
	cb();
};


/**
 * Deploy built application to ROKU
 *
 * Warning: If starting this function after buildApp, must be swapped config.appDest and config.appSrc
 */
async function deployApp(cb) {
	if (config.appSrc === "--empty--") {
		if (config._src === "--empty--") {
			config.appSrc = config.dist + config.appName + ".zip";
		} else {
			config.appSrc = normalizePath(config._src)
		}
	}
	console.info("Deploy app to ROKU device [" + config.appSrc + "]");
	
	await rokuDeploy.publish({
		"outDir":  parsePath(config.appSrc).dirname,
		"outFile": parsePath(config.appSrc).basename
	});

	cb();
};


/**
 * Rewrite application configuration from application directory (from buildConfig.json)
 */
function rewrite_config_from_app_build_configuration() {
	var path = normalizePath(config.appSrc + _localBuildConfigurationFileName);

    if (fs.existsSync(path)) {
		cfg = require( path );
		
		
	}
}


/**
 * Rewrite configuration from local configuration (rokudeply.json)
 *   appSrc    - application source directory
 *   appDest   - directory destination for application
 *   appStore  - path to appstore directory (ROKUAPPS git checkout directory)
 */
function rewrite_config_from_local_configuration(cb) {
	if (config.localData.appSrc) {
		config.appSrc = config.localData.appSrc;
	}
	if (config.localData.appDest) {
		config.appDest = config.localData.appDest;
	}
    if (config.localData.appStore) {
		config.appSrc = config.localData.appStore;
	}
	cb();
}


/**
 * Delete all files in out directory
 */
function prepare(cb) {
	if (fs.existsSync(config.out)) {
		fs.rmdirSync(config.out);
	}
	fs.mkdirSync(config.out);

	if (!fs.existsSync(config.dist)) {
		fs.mkdirSync(config.dist);
	}

	cb();
}


/**
 * Minify Brightscript files
 *  - delete comment and white-lines
 */
async function _minify(src, dest) {
	console.info("Minify BRS ", src, dest);

    replaceInFile.sync({    						//delete comments
		files: src,
		from:  /(\s*('|REM).+)/gi,
		to:    ""
	});

    replaceInFile.sync({                            //remove whitespaces on start of lines
		files: src,
		from:  /^\s*/gim,
		to:    ""
	});

    //_formatBrs(false, normalizePath(config.out), 0);  //have a problem...

    await _removeWhitespaceLines(src, dest);
}

/**
 * Remove all whitespace lines
 */
function _removeWhitespaceLines(src, dest) {
    return new Promise(function(resolve, reject) {
		gulp.src(src)
			.pipe(rmLines({
    			'filters': [/^\s*'/i, /((\r\n|\n|\r)$)|(^(\r\n|\n|\r))|^\s*$/i]
			}))
			.pipe( gulp.dest(dest) )
	});
}


/**
 * Generate documentation
 */
function generateDocs(cb) {
	cb();
}


/**
 * Print help
 */
function help(cb) {
	console.log("+------------------------------------------------------------------------------+");
	console.log("| ROKU Apps build and deploy tools                                             |");
	console.log("+------------------------------------------------------------------------------+");
	console.log("| Build app:                                                                   |");
	console.log("|   gulp app --appname=app                                                     |");
	console.log("|     or                                                                       |");
	console.log("|   gulp app --src=/var/app                                                    |");
	console.log("|     --appname=APP   - appname (related to app dir name / app package name)   |");
	console.log("|     --src=DIR       - DIR where is source of app located (exclude appname)   |");
	console.log("|     --desc=FILE     - build package location                                 |");
	console.log("|                     - default: ./dist/APPNAME.zip                            |");
    console.log("|   using default application configuration from APPDIR/buildConfig.json       |");
	console.log("+------------------------------------------------------------------------------+");
	console.log("| Deploy built app to ROKU device:                                             |");
	console.log("|   gulp deploy --appname=app                                                  |");
	console.log("|     or                                                                       |");
	console.log("|   gulp deploy --src=/var/app/app.zip                                         |");
	console.log("|      - using configuration from rokudeploy.json                              |");
	console.log("+------------------------------------------------------------------------------+");
	console.log("+------------------------------------------------------------------------------+");
	console.log("| General settings:                                                            |");
	console.log("|   --production=true - set builder to Production mode - without debug log     |");
	console.log("+------------------------------------------------------------------------------+");
	console.log("| Shorcuts and utilities for DEVELOPERS:                                       |");
	console.log("|   gulp _app_ appname=APP                                                     |");
	console.log("|      - build APP, deploy APP and run APP on ROKU  |");
	console.log("|      - using rokudeploy.json                                                 |");
	console.log("+------------------------------------------------------------------------------+");
	cb();
}

//build tasks for apps
exports.app = series(prepare, buildApp);
//deploy app to ROKU device
exports.deploy = deployApp;
//build task for tests
//united tasks for developers
exports._app = series(
	rewrite_config_from_local_configuration,
	prepare,
	buildApp,
	deployApp
);
exports.help = help;


exports.default = help;
