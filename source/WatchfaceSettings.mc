import Toybox.Application;
import Toybox.Lang;

module WatchfaceSettings {
    const SECONDS_MODE_OFF = 0;
    const SECONDS_MODE_ON = 1;
    const SECONDS_MODE_WRIST_TURN = 2;

    const BACKGROUND_MODE_DAY = 0;
    const BACKGROUND_MODE_NIGHT = 1;
    const BACKGROUND_MODE_AUTO = 2;

    const BELOW_TIME_FIELD_DATE = 0;
    const BELOW_TIME_FIELD_ALTITUDE = 1;
    const BELOW_TIME_FIELD_HEART_RATE = 2;
    const BELOW_TIME_FIELD_BATTERY = 3;
    const BELOW_TIME_FIELD_STEPS = 4;
    const BELOW_TIME_FIELD_NOTIFICATIONS = 5;

    const INSET_DATA_FIELD_ALTITUDE = 0;
    const INSET_DATA_FIELD_HEART_RATE = 1;
    const INSET_DATA_FIELD_BATTERY = 2;
    const INSET_DATA_FIELD_STEPS = 3;
    const INSET_DATA_FIELD_NOTIFICATIONS = 4;

    function getSecondsMode() {
        var secondsMode = Application.Properties.getValue("SecondsMode");

        return secondsMode.toNumber();
    }

    function getShowLeadingHourZero() {
        var showLeadingHourZero = Application.Properties.getValue("ShowLeadingHourZero");

        return showLeadingHourZero as Lang.Boolean;
    }

    function getBackgroundMode() {
        var backgroundMode = Application.Properties.getValue("BackgroundMode");

        return backgroundMode.toNumber();
    }

    function getInsetDataField1() {
        var insetDataField1 = Application.Properties.getValue("InsetDataField1");

        return insetDataField1.toNumber();
    }

    function getInsetDataField2() {
        var insetDataField2 = Application.Properties.getValue("InsetDataField2");

        return insetDataField2.toNumber();
    }

    function getDataFieldBelowTime() {
        var dataFieldBelowTime = Application.Properties.getValue("DataFieldBelowTime");

        return dataFieldBelowTime.toNumber();
    }
}
