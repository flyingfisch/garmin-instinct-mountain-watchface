import Toybox.Application;
import Toybox.Lang;

module WatchfaceSettings {
    const SECONDS_MODE_OFF = 0;
    const SECONDS_MODE_ON = 1;
    const SECONDS_MODE_WRIST_TURN = 2;

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

    function getInsetDataField1() {
        var insetDataField1 = Application.Properties.getValue("InsetDataField1");

        return insetDataField1.toNumber();
    }

    function getInsetDataField2() {
        var insetDataField2 = Application.Properties.getValue("InsetDataField2");

        return insetDataField2.toNumber();
    }
}
