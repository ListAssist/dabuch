const gulp = require('gulp');
const { execSync } = require('child_process');

async function build() {
    await compileFinalMarkdown();
}

async function compileFinalMarkdown() {
    await execSync(".\\scripts\\makeWin.bat", (err, stdout) => {
        if (err) {
          console.error(err);
          return;
        }
        console.log(stdout);
    });
}

async function compileMarkdown() {
    await execSync(".\\scripts\\makeWinDev.bat", (err, stdout) => {
        if (err) {
          console.error(err);
          return;
        }
        console.log(stdout);
    });
}

async function watch() {
    await compileMarkdown();
    gulp.watch("./markdown/*.md", compileMarkdown);
}

exports.build = build;
exports.watch = watch;

gulp.task("default", watch);