import Toybox.Activity;
import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class MountainWatchfaceView extends WatchUi.WatchFace {
    const SECONDS_MODE_OFF = 0;
    const SECONDS_MODE_ON = 1;
    const SECONDS_MODE_WRIST_TURN = 2;

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
        var heartRateLabel = View.findDrawableById("HeartRateLabel") as WatchUi.Text;
        var notificationCountLabel = View.findDrawableById("NotificationCountLabel") as WatchUi.Text;

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
        var heartRateText = activityInfo.currentHeartRate != null ? activityInfo.currentHeartRate.toString() : "--";
        var notificationCountText = deviceSettings.notificationCount.toString();

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
        heartRateLabel.setText(heartRateText);
        notificationCountLabel.setText(notificationCountText);

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
}
