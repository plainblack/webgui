 
var adminConsoleIsOn = true;
 
function initAdminConsole (app) {
        if (app) {
                switchToApplication();
        } else {
                switchToAdminConsole();
        }
}
 
function switchToApplication () {
        adminConsoleIsOn = false;
        document.getElementById("console_icon").className = "adminConsoleHidden";
        document.getElementById("console_title").className = "adminConsoleHidden";
        document.getElementById("console_workarea").className = "adminConsoleHidden";
        document.getElementById("application_help").className = "adminConsoleHelpIcon";
        document.getElementById("application_icon").className = "adminConsoleTitleIcon";
        document.getElementById("application_title").className = "adminConsoleTitle";
        document.getElementById("application_submenu").className = "adminConsoleSubmenu";
        document.getElementById("application_workarea").className = "adminConsoleWorkArea";
        document.getElementById("console_toggle_off").className = "adminConsoleHidden";
        document.getElementById("console_toggle_on").className = "adminConsoleToggle";
}
 
function switchToAdminConsole () {
        adminConsoleIsOn = true;
        document.getElementById("application_icon").className = "adminConsoleHidden";
        document.getElementById("application_title").className = "adminConsoleHidden";
        document.getElementById("application_submenu").className = "adminConsoleHidden";
        document.getElementById("application_workarea").className = "adminConsoleHidden";
        document.getElementById("application_help").className = "adminConsoleHidden";
        document.getElementById("console_icon").className = "adminConsoleTitleIcon";
        document.getElementById("console_title").className = "adminConsoleTitle";
        document.getElementById("console_workarea").className = "adminConsoleWorkArea";
        document.getElementById("console_toggle_off").className = "adminConsoleToggle";
        document.getElementById("console_toggle_on").className = "adminConsoleHidden";
}
 
function toggleAdminConsole () {
        if (adminConsoleIsOn) {
                switchToApplication();
        } else {
                switchToAdminConsole();
        }
}
 

