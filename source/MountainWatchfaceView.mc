import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.System;
import Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {
    const INSET_ARC_WIDTH = 2;
    const INSET_ARC_START_DEGREES = 90;
    const INSET_ARC_CENTER_X = 144;
    const INSET_ARC_CENTER_Y = 31;
    const INSET_ARC_RADIUS = 32;
    const INSET_ARC_CENTER_X_INSTINCT2S = 136;
    const INSET_ARC_CENTER_Y_INSTINCT2S = 27;
    const INSET_ARC_RADIUS_INSTINCT2S = 29;

    const SECONDS_CLIP_X = 145;
    const SECONDS_CLIP_Y = 100;
    const SECONDS_CLIP_WIDTH = 20;
    const SECONDS_CLIP_HEIGHT = 16;
    const SECONDS_TEXT_X = 161;
    const SECONDS_TEXT_Y = 95;

    const BATTERY_DOT_COUNT = 4;
    const BATTERY_DOT_SPACING = 2;
    const BATTERY_DOT_Y = 169;
    const BATTERY_DOT_Y_INSTINCT2S = 149;

    var isAwake = true;
    var cachedSecondsMode = WatchfaceSettings.SECONDS_MODE_WRIST_TURN;
    var cachedInsetArcMetric = WatchfaceSettings.INSET_ARC_METRIC_NONE;
    var cachedInsetArcPercent = 0.0;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onUpdate(dc) {
        var deviceSettings = System.getDeviceSettings();
        var systemStats = System.getSystemStats();
        var clockTime = System.getClockTime();
        var secondsMode = WatchfaceSettings.getSecondsMode();
        var showLeadingHourZero = WatchfaceSettings.getShowLeadingHourZero();
        var backgroundMode = WatchfaceSettings.getBackgroundMode();
        var insetArcMetric = WatchfaceSettings.getInsetArcMetric();
        var activityInfo = Activity.getActivityInfo();
        var activityMonitorInfo = ActivityMonitor.getInfo();

        cachedSecondsMode = secondsMode;
        cachedInsetArcMetric = insetArcMetric;
        cachedInsetArcPercent = getInsetArcPercent(insetArcMetric, systemStats, activityMonitorInfo);

        var backgroundImage = View.findDrawableById("BackgroundImage") as WatchUi.Bitmap;
        var hourLabel = View.findDrawableById("HourLabel") as WatchUi.Text;
        var minuteLabel = View.findDrawableById("MinuteLabel") as WatchUi.Text;
        var secondsLabel = View.findDrawableById("SecondsLabel") as WatchUi.Text;
        var subtleNotificationsIcon = View.findDrawableById("SubtleNotificationsIcon") as WatchUi.Bitmap;
        var dataFieldBelowTimeIcon = View.findDrawableById("DataFieldBelowTimeIcon") as WatchUi.Bitmap;
        var dataFieldBelowTimeLabel = View.findDrawableById("DataFieldBelowTimeLabel") as WatchUi.Text;
        var dateLabel = View.findDrawableById("DateLabel") as WatchUi.Text;
        var weatherTemperatureLabel = View.findDrawableById("WeatherTemperatureLabel") as WatchUi.Text;
        var insetDataField1Icon = View.findDrawableById("InsetDataField1Icon") as WatchUi.Bitmap;
        var insetDataField1Label = View.findDrawableById("InsetDataField1Label") as WatchUi.Text;
        var insetDataField2Icon = View.findDrawableById("InsetDataField2Icon") as WatchUi.Bitmap;
        var insetDataField2Label = View.findDrawableById("InsetDataField2Label") as WatchUi.Text;

        var hourText = WatchfaceFormatting.formatHour(clockTime, deviceSettings.is24Hour, showLeadingHourZero);
        var minuteText = WatchfaceFormatting.formatMinute(clockTime);
        var secondsText = WatchfaceFormatting.formatSeconds(clockTime);

        backgroundImage.setBitmap(BackgroundService.getBackgroundBitmap(backgroundMode, clockTime));
        hourLabel.setText(hourText);
        minuteLabel.setText(minuteText);
        secondsLabel.setText(secondsText);
        secondsLabel.setVisible(WatchfaceFormatting.shouldShowSeconds(secondsMode, isAwake));
        subtleNotificationsIcon.setVisible(shouldShowSubtleNotificationsIcon(deviceSettings));

        DataFieldService.updateDataFieldBelowTime(dataFieldBelowTimeIcon, dataFieldBelowTimeLabel, dateLabel, WatchfaceSettings.getDataFieldBelowTime(), deviceSettings, activityInfo, activityMonitorInfo);
        weatherTemperatureLabel.setText(WatchfaceFormatting.getWeatherTemperatureText(deviceSettings));

        DataFieldService.updateInsetDataField(insetDataField1Icon, insetDataField1Label, WatchfaceSettings.getInsetDataField1(), deviceSettings, activityInfo, activityMonitorInfo);
        DataFieldService.updateInsetDataField(insetDataField2Icon, insetDataField2Label, WatchfaceSettings.getInsetDataField2(), deviceSettings, activityInfo, activityMonitorInfo);

        View.onUpdate(dc);
        drawInsetArc(dc, deviceSettings);
        drawSubtleBatteryIndicator(dc, deviceSettings, systemStats, WatchfaceSettings.getShowSubtleBatteryIndicator());
    }

    function onPartialUpdate(dc) {
        if (cachedSecondsMode != WatchfaceSettings.SECONDS_MODE_ON) {
            return;
        }

        var clockTime = System.getClockTime();
        var secondsText = WatchfaceFormatting.formatSeconds(clockTime);

        dc.setClip(SECONDS_CLIP_X, SECONDS_CLIP_Y, SECONDS_CLIP_WIDTH, SECONDS_CLIP_HEIGHT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(SECONDS_TEXT_X, SECONDS_TEXT_Y, Graphics.FONT_TINY, secondsText, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.clearClip();
    }

    function onExitSleep() {
        isAwake = true;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() {
        isAwake = false;
        WatchUi.requestUpdate();
    }

    function shouldShowSubtleNotificationsIcon(deviceSettings) {
        return WatchfaceSettings.getShowSubtleNotificationsIndicator()
            && (deviceSettings.notificationCount > 0);
    }

    function drawInsetArc(dc, deviceSettings) {
        if ((cachedInsetArcMetric == WatchfaceSettings.INSET_ARC_METRIC_NONE) || (cachedInsetArcPercent <= 0.0)) {
            return;
        }

        var arcDegrees = (360.0 * cachedInsetArcPercent).toNumber();
        if (arcDegrees <= 0) {
            return;
        }

        var isInstinct2S = isInstinct2SDevice(deviceSettings);
        var centerX = isInstinct2S ? INSET_ARC_CENTER_X_INSTINCT2S : INSET_ARC_CENTER_X;
        var centerY = isInstinct2S ? INSET_ARC_CENTER_Y_INSTINCT2S : INSET_ARC_CENTER_Y;
        var radius = isInstinct2S ? INSET_ARC_RADIUS_INSTINCT2S : INSET_ARC_RADIUS;
        var endDegrees = INSET_ARC_START_DEGREES - arcDegrees;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        for (var i = 0; i < INSET_ARC_WIDTH; i += 1) {
            dc.drawArc(centerX, centerY, radius - i, Graphics.ARC_CLOCKWISE, INSET_ARC_START_DEGREES, endDegrees);
        }
    }

    function getInsetArcPercent(metric, systemStats, activityMonitorInfo) {
        if (metric == WatchfaceSettings.INSET_ARC_METRIC_BATTERY_PERCENTAGE) {
            return getBatteryPercent(systemStats);
        }

        if (metric == WatchfaceSettings.INSET_ARC_METRIC_INTENSITY_MINUTES) {
            return getIntensityMinutesPercent(activityMonitorInfo);
        }

        return 0.0;
    }

    function getBatteryPercent(systemStats) {
        if ((systemStats == null) || (systemStats.battery == null)) {
            return 0.0;
        }

        return clampPercent(systemStats.battery.toFloat() / 100.0);
    }

    function getIntensityMinutesPercent(activityMonitorInfo) {
        if ((activityMonitorInfo == null) || (activityMonitorInfo.activeMinutesWeek == null) || (activityMonitorInfo.activeMinutesWeekGoal == null)) {
            return 0.0;
        }

        var goal = activityMonitorInfo.activeMinutesWeekGoal.toFloat();
        if (goal <= 0.0) {
            return 0.0;
        }

        return clampPercent(activityMonitorInfo.activeMinutesWeek.total.toFloat() / goal);
    }

    function clampPercent(percent) {
        if (percent <= 0.0) {
            return 0.0;
        }

        if (percent >= 1.0) {
            return 1.0;
        }

        return percent;
    }

    function drawSubtleBatteryIndicator(dc, deviceSettings, systemStats, isVisible) {
        if (!isVisible || (systemStats == null) || (systemStats.battery == null)) {
            return;
        }

        var batteryPercent = systemStats.battery.toFloat();
        var visibleDotCount = getFilledBatteryDotCount(batteryPercent);
        if (visibleDotCount <= 0) {
            return;
        }

        var totalWidth = visibleDotCount + ((visibleDotCount - 1) * BATTERY_DOT_SPACING);
        var isInstinct2S = isInstinct2SDevice(deviceSettings);
        var screenWidth = isInstinct2S ? 156 : dc.getWidth();
        var indicatorY = isInstinct2S ? BATTERY_DOT_Y_INSTINCT2S : BATTERY_DOT_Y;
        var startX = ((screenWidth - totalWidth) / 2).toNumber();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        for (var i = 0; i < visibleDotCount; i += 1) {
            var dotX = startX + (i * (BATTERY_DOT_SPACING + 1));
            dc.drawPoint(dotX, indicatorY);
        }
    }

    function getFilledBatteryDotCount(batteryPercent) {
        if (batteryPercent <= 0.0) {
            return 0;
        }

        if (batteryPercent > 75.0) {
            return 4;
        }

        if (batteryPercent > 50.0) {
            return 3;
        }

        if (batteryPercent > 25.0) {
            return 2;
        }

        return 1;
    }

    function isInstinct2SDevice(deviceSettings) {
        if (deviceSettings.partNumber == null) {
            return false;
        }

        var partNumber = deviceSettings.partNumber;
        return partNumber.equals("006-B3889-00")
            || partNumber.equals("006-B4091-00");
    }
}
