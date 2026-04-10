import Toybox.Application;

class MountainWatchfaceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new MountainWatchfaceView() ];
    }
}
