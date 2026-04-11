import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.System;
import Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {
    var isAwake = true;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onUpdate(dc) {
        var deviceSettings = System.getDeviceSettings();
        var clockTime = System.getClockTime();
        var secondsMode = WatchfaceSettings.getSecondsMode();
        var showLeadingHourZero = WatchfaceSettings.getShowLeadingHourZero();

        var hourLabel = View.findDrawableById("HourLabel") as WatchUi.Text;
        var minuteLabel = View.findDrawableById("MinuteLabel") as WatchUi.Text;
        var secondsLabel = View.findDrawableById("SecondsLabel") as WatchUi.Text;
        var dateLabel = View.findDrawableById("DateLabel") as WatchUi.Text;
        var weatherTemperatureLabel = View.findDrawableById("WeatherTemperatureLabel") as WatchUi.Text;
        var insetDataField1Icon = View.findDrawableById("InsetDataField1Icon") as WatchUi.Bitmap;
        var insetDataField1Label = View.findDrawableById("InsetDataField1Label") as WatchUi.Text;
        var insetDataField2Icon = View.findDrawableById("InsetDataField2Icon") as WatchUi.Bitmap;
        var insetDataField2Label = View.findDrawableById("InsetDataField2Label") as WatchUi.Text;

        var activityInfo = Activity.getActivityInfo();
        var activityMonitorInfo = ActivityMonitor.getInfo();
        var hourText = WatchfaceFormatting.formatHour(clockTime, deviceSettings.is24Hour, showLeadingHourZero);
        var minuteText = WatchfaceFormatting.formatMinute(clockTime);
        var secondsText = WatchfaceFormatting.formatSeconds(clockTime);

        hourLabel.setText(hourText);
        minuteLabel.setText(minuteText);
        secondsLabel.setText(secondsText);
        secondsLabel.setVisible(WatchfaceFormatting.shouldShowSeconds(secondsMode, isAwake));

        dateLabel.setText(WatchfaceFormatting.buildDateText());
        weatherTemperatureLabel.setText(WatchfaceFormatting.getWeatherTemperatureText(deviceSettings));

        InsetFieldService.updateInsetField(insetDataField1Icon, insetDataField1Label, WatchfaceSettings.getInsetDataField1(), deviceSettings, activityInfo, activityMonitorInfo);
        InsetFieldService.updateInsetField(insetDataField2Icon, insetDataField2Label, WatchfaceSettings.getInsetDataField2(), deviceSettings, activityInfo, activityMonitorInfo);

        View.onUpdate(dc);
    }

    function onExitSleep() {
        isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() {
        isAwake = false;
        WatchUi.requestUpdate();
    }
}
