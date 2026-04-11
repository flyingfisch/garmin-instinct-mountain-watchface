import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {
    const SECONDS_MODE_OFF = 0;
    const SECONDS_MODE_ON = 1;
    const SECONDS_MODE_WRIST_TURN = 2;

    const INSET_DATA_FIELD_ALTITUDE = 0;
    const INSET_DATA_FIELD_HEART_RATE = 1;
    const INSET_DATA_FIELD_BATTERY = 2;
    const INSET_DATA_FIELD_STEPS = 3;
    const INSET_DATA_FIELD_NOTIFICATIONS = 4;

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
        var displayHour = clockTime.hour;
        var displayMinute = clockTime.min;
        var displaySeconds = clockTime.sec;
        var secondsMode = getSecondsMode();
        var showLeadingHourZero = getShowLeadingHourZero();

        var hourLabel = View.findDrawableById("HourLabel") as WatchUi.Text;
        var minuteLabel = View.findDrawableById("MinuteLabel") as WatchUi.Text;
        var secondsLabel = View.findDrawableById("SecondsLabel") as WatchUi.Text;
        var dateLabel = View.findDrawableById("DateLabel") as WatchUi.Text;
        var weatherTemperatureLabel = View.findDrawableById("WeatherTemperatureLabel") as WatchUi.Text;
        var insetDataField1Icon = View.findDrawableById("InsetDataField1Icon") as WatchUi.Bitmap;
        var insetDataField1Label = View.findDrawableById("InsetDataField1Label") as WatchUi.Text;
        var insetDataField2Icon = View.findDrawableById("InsetDataField2Icon") as WatchUi.Bitmap;
        var insetDataField2Label = View.findDrawableById("InsetDataField2Label") as WatchUi.Text;

        if (!(deviceSettings.is24Hour)) {
            displayHour = displayHour % 12;

            if (displayHour == 0) {
                displayHour = 12;
            }
        }

        var hourText = displayHour.toString();
        if (showLeadingHourZero && (displayHour < 10)) {
            hourText = "0" + hourText;
        }

        var minuteText = displayMinute.format("%02d");
        var secondsText = displaySeconds.format("%02d");

        var currentDate = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var monthText = normalizeMonthCase(currentDate.month.toString());
        var dayText = currentDate.day.toString();
        var dateText = monthText + " " + dayText;

        var activityInfo = Activity.getActivityInfo();
        var activityMonitorInfo = ActivityMonitor.getInfo();

        var currentWeatherConditions = Weather.getCurrentConditions();
        var weatherTemperatureText = "--°";
        if ((currentWeatherConditions != null) && (currentWeatherConditions.temperature != null)) {
            var localizedTemperatureValue = deviceSettings.temperatureUnits == System.UNIT_METRIC ? currentWeatherConditions.temperature : temperatureToFahrenheit(currentWeatherConditions.temperature);
            weatherTemperatureText = formatTemperature(localizedTemperatureValue) + "°";
        }

        hourLabel.setText(hourText);
        minuteLabel.setText(minuteText);
        secondsLabel.setText(secondsText);
        secondsLabel.setVisible(shouldShowSeconds(secondsMode));

        dateLabel.setText(dateText);
        weatherTemperatureLabel.setText(weatherTemperatureText);

        updateInsetField(insetDataField1Icon, insetDataField1Label, getInsetDataField1(), deviceSettings, activityInfo, activityMonitorInfo);
        updateInsetField(insetDataField2Icon, insetDataField2Label, getInsetDataField2(), deviceSettings, activityInfo, activityMonitorInfo);

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

    function shouldShowSeconds(secondsMode) {
        if (secondsMode == SECONDS_MODE_ON) {
            return true;
        }

        if (secondsMode == SECONDS_MODE_WRIST_TURN) {
            return isAwake;
        }

        return false;
    }

    function normalizeMonthCase(monthText) {
        if ((monthText == null) || (monthText.length() == 0)) {
            return "";
        }

        if (monthText.length() == 1) {
            return monthText;
        }

        return monthText.substring(0, 1).toUpper() + monthText.substring(1, monthText.length()).toLower();
    }

    function temperatureToFahrenheit(temperatureC) {
        return (temperatureC.toFloat() * 9.0 / 5.0) + 32.0;
    }

    function formatTemperature(temperature) {
        return temperature.format("%i");
    }

    function updateInsetField(iconDrawable, textDrawable, fieldType, deviceSettings, activityInfo, activityMonitorInfo) {
        if (fieldType == INSET_DATA_FIELD_ALTITUDE) {
            iconDrawable.setBitmap(Rez.Drawables.AltitudeIcon);
            textDrawable.setText(formatAltitude(deviceSettings));
            return;
        }

        if (fieldType == INSET_DATA_FIELD_HEART_RATE) {
            iconDrawable.setBitmap(Rez.Drawables.HeartIcon);
            textDrawable.setText(formatHeartRate(activityInfo));
            return;
        }

        if (fieldType == INSET_DATA_FIELD_STEPS) {
            iconDrawable.setBitmap(Rez.Drawables.StepsIcon);
            textDrawable.setText(formatSteps(activityMonitorInfo));
            return;
        }

        if (fieldType == INSET_DATA_FIELD_NOTIFICATIONS) {
            iconDrawable.setBitmap(Rez.Drawables.NotificationsIcon);
            textDrawable.setText(formatNotificationCount(deviceSettings));
            return;
        }

        iconDrawable.setBitmap(getBatteryIcon());
        textDrawable.setText(formatBatteryDays());
    }

    function formatAltitude(deviceSettings) {
        var elevation = getLatestElevation();
        if (elevation == null) {
            return "--";
        }

        var localizedElevation = elevation.toFloat();
        if (deviceSettings.elevationUnits != System.UNIT_METRIC) {
            localizedElevation = localizedElevation * 3.28084;
        }

        return formatCompactAltitude(localizedElevation);
    }

    function getLatestElevation() {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getElevationHistory)) {
            return null;
        }

        var iterator = SensorHistory.getElevationHistory({});

        var sample = iterator.next();
        if ((sample == null) || (sample.data == null)) {
            return null;
        }

        return sample.data;
    }

    function formatHeartRate(activityInfo) {
        if ((activityInfo == null) || (activityInfo.currentHeartRate == null)) {
            return "--";
        }

        return activityInfo.currentHeartRate.toString();
    }

    function formatCompactAltitude(altitude) {
        var altitudeValue = altitude.toFloat();
        if (altitudeValue < 0.0) {
            altitudeValue = 0.0;
        }

        if (altitudeValue < 1000.0) {
            return altitudeValue.format("%i");
        }

        var altitudeInThousands = altitudeValue / 1000.0;
        return altitudeInThousands.format("%i") + "k";
    }

    function formatSteps(activityMonitorInfo) {
        var steps = getStepCount(activityMonitorInfo);
        if (steps == null) {
            return "--";
        }

        var stepValue = steps.toFloat();
        if (stepValue < 1000.0) {
            return stepValue.format("%i");
        }

        var stepsInThousands = stepValue / 1000.0;
        var formattedThousands = stepsInThousands.format("%.1f");
        if (formattedThousands.substring(formattedThousands.length() - 2, formattedThousands.length()) == ".0") {
            formattedThousands = formattedThousands.substring(0, formattedThousands.length() - 2);
        }

        return formattedThousands + "k";
    }

    function getStepCount(activityMonitorInfo) {
        if (activityMonitorInfo == null) {
            return null;
        }

        if (activityMonitorInfo has :stepCount) {
            return activityMonitorInfo.stepCount;
        }

        return null;
    }

    function formatNotificationCount(deviceSettings) {
        if ((deviceSettings == null) || (deviceSettings.notificationCount == null)) {
            return "--";
        }

        return deviceSettings.notificationCount.toString();
    }

    function formatBatteryDays() {
        var systemStats = System.getSystemStats();
        if ((systemStats == null) || (systemStats.batteryInDays == null)) {
            return "--";
        }

        return systemStats.batteryInDays.format("%i") + "d";
    }

    function getBatteryIcon() {
        var systemStats = System.getSystemStats();
        if ((systemStats == null) || (systemStats.battery == null)) {
            return Rez.Drawables.BatteryCriticalIcon;
        }

        var batteryPercent = systemStats.battery.toFloat();
        if (batteryPercent >= 80.0) {
            return Rez.Drawables.BatteryFullIcon;
        }

        if (batteryPercent >= 30.0) {
            return Rez.Drawables.BatteryHalfIcon;
        }

        if (batteryPercent > 5.0) {
            return Rez.Drawables.BatteryLowIcon;
        }

        return Rez.Drawables.BatteryCriticalIcon;
    }
}
